import XCTest
@testable import TaskManagement

@MainActor
final class TaskDetailViewModelTests: XCTestCase {
    private var repository: MockTaskRepository!

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
    }

    private func makeSUT(task: TodoItem) -> TaskDetailViewModel {
        repository.tasks[task.id] = task
        return TaskDetailViewModel(
            task: task,
            updateTaskUseCase: UpdateTaskUseCase(repository: repository),
            toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase(repository: repository)
        )
    }

    func test_hasConflict_reflectsSyncStatus() {
        let conflicted = makeSUT(task: TodoItem(title: "Conflicted", syncStatus: .conflict))
        XCTAssertTrue(conflicted.hasConflict)

        let synced = makeSUT(task: TodoItem(title: "Synced", syncStatus: .synced))
        XCTAssertFalse(synced.hasConflict)
    }

    func test_toggleCompletion_updatesPublishedTask() async {
        let sut = makeSUT(task: TodoItem(title: "Ship T7", isCompleted: false))

        await sut.toggleCompletion()

        XCTAssertTrue(sut.task.isCompleted)
    }

    func test_toggleSubtask_flipsOnlyThatSubtask() async {
        let subtasks = [Subtask(title: "First", isCompleted: false), Subtask(title: "Second", isCompleted: false)]
        let sut = makeSUT(task: TodoItem(title: "Checklist", subtasks: subtasks))
        let targetID = subtasks[0].id

        await sut.toggleSubtask(id: targetID)

        XCTAssertEqual(sut.task.subtasks.first(where: { $0.id == targetID })?.isCompleted, true)
        XCTAssertEqual(sut.task.subtasks.last?.isCompleted, false)
    }

    func test_toggleCompletion_whenRepositoryFails_setsErrorMessage() async {
        let sut = makeSUT(task: TodoItem(title: "Ship T7"))
        repository.updateError = TestError.stub

        await sut.toggleCompletion()

        XCTAssertNotNil(sut.errorMessage)
    }
}
