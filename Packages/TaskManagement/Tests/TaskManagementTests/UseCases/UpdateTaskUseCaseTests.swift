import XCTest
@testable import TaskManagement

final class UpdateTaskUseCaseTests: XCTestCase {
    private var repository: MockTaskRepository!
    private let fixedNow = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
    }

    private func makeSUT() -> UpdateTaskUseCase {
        UpdateTaskUseCase(repository: repository, clock: { self.fixedNow })
    }

    func test_execute_withValidTask_bumpsLastModifiedAndMarksPending() async throws {
        let original = TodoItem(
            title: "Original",
            syncStatus: .synced,
            lastModified: fixedNow.addingTimeInterval(-86_400)
        )
        repository.tasks[original.id] = original
        let sut = makeSUT()

        var edited = original
        edited.title = "Updated"

        let result = try await sut.execute(edited)

        XCTAssertEqual(result.title, "Updated")
        XCTAssertEqual(result.syncStatus, .pending)
        XCTAssertEqual(result.lastModified, fixedNow)
        XCTAssertEqual(repository.updatedTasks.count, 1)
    }

    func test_execute_withEmptyTitle_throwsValidationError() async {
        let task = TodoItem(title: "  ")
        let sut = makeSUT()

        do {
            _ = try await sut.execute(task)
            XCTFail("Expected TaskValidationError.emptyTitle")
        } catch TaskValidationError.emptyTitle {
            // expected
        } catch {
            XCTFail("Expected emptyTitle, got \(error)")
        }

        XCTAssertTrue(repository.updatedTasks.isEmpty)
    }

    func test_execute_whenRepositoryFails_propagatesError() async {
        repository.updateError = TestError.stub
        let sut = makeSUT()

        do {
            _ = try await sut.execute(TodoItem(title: "Valid"))
            XCTFail("Expected repository error to propagate")
        } catch TestError.stub {
            // expected
        } catch {
            XCTFail("Expected TestError.stub, got \(error)")
        }
    }
}
