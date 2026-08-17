import Foundation
import XCTest
@testable import TaskManagement

final class DeleteTaskUseCaseTests: XCTestCase {
    private var repository: MockTaskRepository!
    private var sut: DeleteTaskUseCase!

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
        sut = DeleteTaskUseCase(repository: repository)
    }

    func test_execute_deletesTaskViaRepository() async throws {
        let task = TodoItem(title: "To be deleted")
        repository.tasks[task.id] = task

        try await sut.execute(id: task.id)

        XCTAssertEqual(repository.deletedIDs, [task.id])
        XCTAssertNil(repository.tasks[task.id])
    }

    func test_execute_whenRepositoryFails_propagatesError() async {
        repository.deleteError = TestError.stub

        do {
            try await sut.execute(id: UUID())
            XCTFail("Expected repository error to propagate")
        } catch TestError.stub {
            // expected
        } catch {
            XCTFail("Expected TestError.stub, got \(error)")
        }
    }
}
