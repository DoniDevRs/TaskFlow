import XCTest
@testable import TaskManagement

final class CreateTaskUseCaseTests: XCTestCase {
    private var repository: MockTaskRepository!
    private let fixedNow = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
    }

    private func makeSUT() -> CreateTaskUseCase {
        CreateTaskUseCase(repository: repository, clock: { self.fixedNow })
    }

    func test_execute_withValidTitle_createsPendingTaskViaRepository() async throws {
        let sut = makeSUT()

        let task = try await sut.execute(title: "Write CLAUDE.md")

        XCTAssertEqual(task.title, "Write CLAUDE.md")
        XCTAssertEqual(task.syncStatus, .pending)
        XCTAssertEqual(task.isCompleted, false)
        XCTAssertEqual(task.lastModified, fixedNow)
        XCTAssertEqual(repository.createdTasks.count, 1)
    }

    func test_execute_trimsWhitespaceFromTitle() async throws {
        let sut = makeSUT()

        let task = try await sut.execute(title: "  Ship T5  ")

        XCTAssertEqual(task.title, "Ship T5")
    }

    func test_execute_withEmptyTitle_throwsValidationError() async {
        let sut = makeSUT()

        do {
            _ = try await sut.execute(title: "   ")
            XCTFail("Expected TaskValidationError.emptyTitle")
        } catch TaskValidationError.emptyTitle {
            // expected
        } catch {
            XCTFail("Expected emptyTitle, got \(error)")
        }

        XCTAssertTrue(repository.createdTasks.isEmpty)
    }

    func test_execute_withPastDueDate_throwsValidationError() async {
        let sut = makeSUT()
        let pastDueDate = fixedNow.addingTimeInterval(-3600)

        do {
            _ = try await sut.execute(title: "Overdue on arrival", dueDate: pastDueDate)
            XCTFail("Expected TaskValidationError.dueDateInPast")
        } catch TaskValidationError.dueDateInPast {
            // expected
        } catch {
            XCTFail("Expected dueDateInPast, got \(error)")
        }

        XCTAssertTrue(repository.createdTasks.isEmpty)
    }

    func test_execute_whenRepositoryFails_propagatesError() async {
        repository.createError = TestError.stub
        let sut = makeSUT()

        do {
            _ = try await sut.execute(title: "Valid title")
            XCTFail("Expected repository error to propagate")
        } catch TestError.stub {
            // expected
        } catch {
            XCTFail("Expected TestError.stub, got \(error)")
        }
    }
}
