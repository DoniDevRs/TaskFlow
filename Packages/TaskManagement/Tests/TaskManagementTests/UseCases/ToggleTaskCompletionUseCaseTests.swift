import XCTest
@testable import TaskManagement

final class ToggleTaskCompletionUseCaseTests: XCTestCase {
    private var repository: MockTaskRepository!
    private let fixedNow = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
    }

    private func makeSUT() -> ToggleTaskCompletionUseCase {
        ToggleTaskCompletionUseCase(repository: repository, clock: { self.fixedNow })
    }

    func test_execute_onIncompleteTask_marksCompletedAndPending() async throws {
        let task = TodoItem(title: "Ship T5", isCompleted: false, syncStatus: .synced)
        repository.tasks[task.id] = task
        let sut = makeSUT()

        let result = try await sut.execute(id: task.id)

        XCTAssertTrue(result.isCompleted)
        XCTAssertEqual(result.syncStatus, .pending)
        XCTAssertEqual(result.lastModified, fixedNow)
    }

    func test_execute_onCompletedTask_marksIncomplete() async throws {
        let task = TodoItem(title: "Ship T5", isCompleted: true, syncStatus: .synced)
        repository.tasks[task.id] = task
        let sut = makeSUT()

        let result = try await sut.execute(id: task.id)

        XCTAssertFalse(result.isCompleted)
    }

    func test_execute_whenTaskNotFound_throwsTaskNotFound() async {
        let sut = makeSUT()

        do {
            _ = try await sut.execute(id: UUID())
            XCTFail("Expected TaskUseCaseError.taskNotFound")
        } catch TaskUseCaseError.taskNotFound {
            // expected
        } catch {
            XCTFail("Expected taskNotFound, got \(error)")
        }
    }
}
