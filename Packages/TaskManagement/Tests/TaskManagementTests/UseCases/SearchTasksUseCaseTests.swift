import XCTest
@testable import TaskManagement

final class SearchTasksUseCaseTests: XCTestCase {
    private var repository: MockTaskRepository!
    private var sut: SearchTasksUseCase!

    private let projectA = UUID()
    private let projectB = UUID()

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
        sut = SearchTasksUseCase(repository: repository)
    }

    private func seed(_ tasks: [TodoItem]) {
        for task in tasks {
            repository.tasks[task.id] = task
        }
    }

    func test_execute_withEmptyQueryAndNoFilter_returnsAllTasks() async throws {
        seed([TodoItem(title: "A"), TodoItem(title: "B")])

        let results = try await sut.execute()

        XCTAssertEqual(results.count, 2)
    }

    func test_execute_matchesQueryAgainstTitleDescriptionAndTags() async throws {
        let byTitle = TodoItem(title: "Ship TaskFlow")
        let byDescription = TodoItem(title: "Unrelated", description: "involves taskflow work")
        let byTag = TodoItem(title: "Also unrelated", tags: ["TaskFlow"])
        let nonMatch = TodoItem(title: "Nothing here")
        seed([byTitle, byDescription, byTag, nonMatch])

        let results = try await sut.execute(query: "taskflow")

        XCTAssertEqual(Set(results.map(\.id)), Set([byTitle.id, byDescription.id, byTag.id]))
    }

    func test_execute_filtersByProjectPriorityTagCompletionAndDueDate() async throws {
        let now = Date()
        let match = TodoItem(
            title: "Match",
            dueDate: now,
            priority: .high,
            tags: ["urgent"],
            projectID: projectA,
            isCompleted: false
        )
        let wrongProject = TodoItem(title: "Wrong project", priority: .high, tags: ["urgent"], projectID: projectB)
        let wrongPriority = TodoItem(title: "Wrong priority", priority: .low, tags: ["urgent"], projectID: projectA)
        seed([match, wrongProject, wrongPriority])

        let results = try await sut.execute(filter: TaskFilter(
            projectID: projectA,
            priority: .high,
            tag: "urgent",
            isCompleted: false,
            dueBefore: now.addingTimeInterval(60)
        ))

        XCTAssertEqual(results.map(\.id), [match.id])
    }

    func test_execute_whenRepositoryFails_propagatesError() async {
        repository.fetchAllError = TestError.stub

        do {
            _ = try await sut.execute()
            XCTFail("Expected repository error to propagate")
        } catch TestError.stub {
            // expected
        } catch {
            XCTFail("Expected TestError.stub, got \(error)")
        }
    }
}
