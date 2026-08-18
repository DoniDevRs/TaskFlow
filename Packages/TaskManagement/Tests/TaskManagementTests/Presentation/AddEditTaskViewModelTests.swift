import XCTest
@testable import TaskManagement

@MainActor
final class AddEditTaskViewModelTests: XCTestCase {
    private var repository: MockTaskRepository!

    override func setUp() {
        super.setUp()
        repository = MockTaskRepository()
    }

    private func makeSUT(editing task: TodoItem? = nil) -> AddEditTaskViewModel {
        AddEditTaskViewModel(
            editing: task,
            createTaskUseCase: CreateTaskUseCase(repository: repository),
            updateTaskUseCase: UpdateTaskUseCase(repository: repository)
        )
    }

    func test_init_withNoTask_isNotEditing() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isEditing)
    }

    func test_init_withTask_prefillsFieldsAndIsEditing() {
        let task = TodoItem(title: "Existing", description: "Notes", priority: .high, tags: ["a"])
        let sut = makeSUT(editing: task)

        XCTAssertTrue(sut.isEditing)
        XCTAssertEqual(sut.title, "Existing")
        XCTAssertEqual(sut.description, "Notes")
        XCTAssertEqual(sut.priority, .high)
        XCTAssertEqual(sut.tags, ["a"])
    }

    func test_save_withValidTitle_createsTask() async {
        let sut = makeSUT()
        sut.title = "New task"

        let saved = await sut.save()

        XCTAssertNotNil(saved)
        XCTAssertEqual(repository.createdTasks.count, 1)
        XCTAssertNil(sut.validationError)
    }

    func test_save_withEmptyTitle_setsValidationErrorAndDoesNotCreate() async {
        let sut = makeSUT()
        sut.title = "   "

        let saved = await sut.save()

        XCTAssertNil(saved)
        XCTAssertNotNil(sut.validationError)
        XCTAssertTrue(repository.createdTasks.isEmpty)
    }

    func test_save_whenEditing_preservesIsCompletedFromOriginal() async {
        let original = TodoItem(title: "Original", isCompleted: true)
        let sut = makeSUT(editing: original)
        sut.title = "Renamed"

        let saved = await sut.save()

        XCTAssertEqual(saved?.title, "Renamed")
        XCTAssertEqual(saved?.isCompleted, true, "editing shouldn't silently reset completion state")
    }

    func test_addSubtask_withBlankTitle_isIgnored() {
        let sut = makeSUT()
        sut.addSubtask(title: "   ")
        XCTAssertTrue(sut.subtasks.isEmpty)
    }

    func test_addSubtask_thenRemoveSubtask_roundTrips() {
        let sut = makeSUT()
        sut.addSubtask(title: "Write tests")
        XCTAssertEqual(sut.subtasks.count, 1)

        sut.removeSubtask(id: sut.subtasks[0].id)
        XCTAssertTrue(sut.subtasks.isEmpty)
    }
}
