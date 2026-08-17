import Core
import XCTest
@testable import TaskManagement

final class CoreDataTaskRepositoryTests: XCTestCase {
    private var sut: CoreDataTaskRepository!
    private var projectRepository: CoreDataProjectRepository!

    override func setUp() {
        super.setUp()
        let persistence = PersistenceController(inMemory: true)
        sut = CoreDataTaskRepository(persistence: persistence)
        projectRepository = CoreDataProjectRepository(persistence: persistence)
    }

    func test_create_thenFetchAll_returnsCreatedTask() async throws {
        let task = TodoItem(title: "Write repository tests", priority: .high, tags: ["core-data"])

        let created = try await sut.create(task)

        XCTAssertEqual(created.title, task.title)
        let all = try await sut.fetchAll()
        XCTAssertEqual(all.map(\.id), [task.id])
        XCTAssertEqual(all.first?.priority, .high)
        XCTAssertEqual(all.first?.tags, ["core-data"])
    }

    func test_create_withProjectID_linksRelationship() async throws {
        let project = try await projectRepository.create(Project(name: "Launch", colorTag: "terracotta"))
        let task = TodoItem(title: "Linked task", projectID: project.id)

        let created = try await sut.create(task)

        XCTAssertEqual(created.projectID, project.id)
    }

    func test_create_withSubtasks_preservesOrder() async throws {
        let subtasks = [
            Subtask(title: "First"),
            Subtask(title: "Second"),
            Subtask(title: "Third")
        ]
        let task = TodoItem(title: "Checklist", subtasks: subtasks)

        let created = try await sut.create(task)

        XCTAssertEqual(created.subtasks.map(\.title), ["First", "Second", "Third"])
    }

    func test_update_persistsChanges() async throws {
        let created = try await sut.create(TodoItem(title: "Original"))
        var edited = created
        edited.title = "Edited"
        edited.isCompleted = true

        let updated = try await sut.update(edited)

        XCTAssertEqual(updated.title, "Edited")
        let fetched = try await sut.fetch(id: created.id)
        XCTAssertEqual(fetched?.title, "Edited")
        XCTAssertEqual(fetched?.isCompleted, true)
    }

    func test_update_whenTaskMissing_throwsTaskNotFound() async {
        do {
            _ = try await sut.update(TodoItem(title: "Never created"))
            XCTFail("Expected TaskUseCaseError.taskNotFound")
        } catch TaskUseCaseError.taskNotFound {
            // expected
        } catch {
            XCTFail("Expected taskNotFound, got \(error)")
        }
    }

    func test_delete_removesTask() async throws {
        let created = try await sut.create(TodoItem(title: "To delete"))

        try await sut.delete(id: created.id)

        let fetched = try await sut.fetch(id: created.id)
        XCTAssertNil(fetched)
    }

    func test_fetch_whenTaskMissing_returnsNil() async throws {
        let fetched = try await sut.fetch(id: UUID())
        XCTAssertNil(fetched)
    }
}
