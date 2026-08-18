import XCTest
@testable import TaskManagement

@MainActor
final class ProjectListViewModelTests: XCTestCase {
    private var projectRepository: MockProjectRepository!
    private var taskRepository: MockTaskRepository!

    override func setUp() {
        super.setUp()
        projectRepository = MockProjectRepository()
        taskRepository = MockTaskRepository()
    }

    private func makeSUT() -> ProjectListViewModel {
        ProjectListViewModel(
            projectRepository: projectRepository,
            taskRepository: taskRepository,
            createProjectUseCase: CreateProjectUseCase(repository: projectRepository)
        )
    }

    func test_loadProjects_computesTaskCountsAndProgress() async {
        let project = Project(name: "Launch", colorTag: "terracotta")
        projectRepository.projects[project.id] = project
        let done = TodoItem(title: "Done", projectID: project.id, isCompleted: true)
        let pending = TodoItem(title: "Pending", projectID: project.id, isCompleted: false)
        let unrelated = TodoItem(title: "Elsewhere", isCompleted: true)
        [done, pending, unrelated].forEach { taskRepository.tasks[$0.id] = $0 }

        let sut = makeSUT()
        await sut.loadProjects()

        XCTAssertEqual(sut.projects.map(\.id), [project.id])
        XCTAssertEqual(sut.taskCounts[project.id], 2)
        XCTAssertEqual(sut.completionProgress[project.id], 0.5)
    }

    func test_loadProjects_withNoTasks_reportsZeroProgress() async {
        let project = Project(name: "Empty", colorTag: "sage")
        projectRepository.projects[project.id] = project
        let sut = makeSUT()

        await sut.loadProjects()

        XCTAssertEqual(sut.taskCounts[project.id], 0)
        XCTAssertEqual(sut.completionProgress[project.id], 0)
    }

    func test_createProject_addsToListAfterReload() async {
        let sut = makeSUT()

        await sut.createProject(name: "New Project", colorTag: "amber")

        XCTAssertEqual(sut.projects.map(\.name), ["New Project"])
    }

    func test_createProject_withEmptyName_setsErrorAndDoesNotAdd() async {
        let sut = makeSUT()

        await sut.createProject(name: "   ", colorTag: "amber")

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.projects.isEmpty)
    }
}
