import XCTest
@testable import TaskManagement

@MainActor
final class TaskListViewModelTests: XCTestCase {
    private var repository: MockTaskRepository!

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
    }

    private func makeSUT() -> TaskListViewModel {
        TaskListViewModel(
            searchTasksUseCase: SearchTasksUseCase(repository: repository),
            toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase(repository: repository),
            deleteTaskUseCase: DeleteTaskUseCase(repository: repository)
        )
    }

    func test_loadTasks_populatesTasksFromUseCase() async {
        let task = TodoItem(title: "Ship T7")
        repository.tasks[task.id] = task
        let sut = makeSUT()

        await sut.loadTasks()

        XCTAssertEqual(sut.tasks.map(\.id), [task.id])
    }

    func test_toggleCompletion_updatesTaskInPlace() async {
        let task = TodoItem(title: "Ship T7", isCompleted: false)
        repository.tasks[task.id] = task
        let sut = makeSUT()
        await sut.loadTasks()

        await sut.toggleCompletion(id: task.id)

        XCTAssertEqual(sut.tasks.first?.isCompleted, true)
    }

    func test_deleteTask_removesTaskFromList() async {
        let task = TodoItem(title: "Ship T7")
        repository.tasks[task.id] = task
        let sut = makeSUT()
        await sut.loadTasks()

        await sut.deleteTask(id: task.id)

        XCTAssertTrue(sut.tasks.isEmpty)
    }

    func test_loadTasks_whenRepositoryFails_setsErrorMessage() async {
        repository.fetchAllError = TestError.stub
        let sut = makeSUT()

        await sut.loadTasks()

        XCTAssertNotNil(sut.errorMessage)
    }

    func test_searchQueryChange_afterDebounce_filtersTasks() async throws {
        let matching = TodoItem(title: "Ship T7")
        let nonMatching = TodoItem(title: "Unrelated")
        repository.tasks[matching.id] = matching
        repository.tasks[nonMatching.id] = nonMatching
        let sut = makeSUT()

        sut.searchQuery = "Ship"
        try await Task.sleep(nanoseconds: 600_000_000)

        XCTAssertEqual(sut.tasks.map(\.id), [matching.id])
    }
}
