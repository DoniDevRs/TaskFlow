import Core
import SwiftUI
import UIKit

@MainActor
public final class ProjectListCoordinator: Coordinator {
    public let navigationController: UINavigationController
    private let container: Container

    /// Reuses TaskListCoordinator's task-detail/add-task presentation
    /// rather than duplicating it — never started (that would reset this
    /// nav stack's root), just used for its push/present helpers.
    private lazy var taskPresenter = TaskListCoordinator(navigationController: navigationController, container: container)

    public init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        let viewModel = ProjectListViewModel(
            projectRepository: container.resolve(ProjectRepository.self),
            taskRepository: container.resolve(TaskRepository.self),
            createProjectUseCase: container.resolve(CreateProjectUseCase.self)
        )
        let view = ProjectListView(
            viewModel: viewModel,
            onSelectProject: { [weak self] project in self?.showProjectTasks(project) }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Projects"
        navigationController.setViewControllers([hostingController], animated: false)
    }

    private func showProjectTasks(_ project: Project) {
        let viewModel = TaskListViewModel(
            searchTasksUseCase: container.resolve(SearchTasksUseCase.self),
            toggleTaskCompletionUseCase: container.resolve(ToggleTaskCompletionUseCase.self),
            deleteTaskUseCase: container.resolve(DeleteTaskUseCase.self)
        )
        viewModel.filter = TaskFilter(projectID: project.id)

        let view = TaskListView(
            viewModel: viewModel,
            onSelectTask: { [weak self] task in self?.taskPresenter.showTaskDetail(task) },
            onAddTask: { [weak self] in self?.taskPresenter.showAddTask(projectID: project.id) }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = project.name
        navigationController.pushViewController(hostingController, animated: true)
    }
}
