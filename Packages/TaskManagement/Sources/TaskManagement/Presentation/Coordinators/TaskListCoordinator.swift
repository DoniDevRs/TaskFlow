import Core
import SwiftUI
import UIKit

@MainActor
public final class TaskListCoordinator: Coordinator {
    public let navigationController: UINavigationController
    private let container: Container

    public init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        let viewModel = TaskListViewModel(
            searchTasksUseCase: container.resolve(SearchTasksUseCase.self),
            toggleTaskCompletionUseCase: container.resolve(ToggleTaskCompletionUseCase.self),
            deleteTaskUseCase: container.resolve(DeleteTaskUseCase.self)
        )
        let view = TaskListView(
            viewModel: viewModel,
            onSelectTask: { [weak self] task in self?.showTaskDetail(task) },
            onAddTask: { [weak self] in self?.showAddTask() }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Tasks"
        navigationController.setViewControllers([hostingController], animated: false)
    }

    func showTaskDetail(_ task: TodoItem) {
        let viewModel = TaskDetailViewModel(
            task: task,
            updateTaskUseCase: container.resolve(UpdateTaskUseCase.self),
            toggleTaskCompletionUseCase: container.resolve(ToggleTaskCompletionUseCase.self)
        )
        let view = TaskDetailView(
            viewModel: viewModel,
            onEdit: { [weak self] task in self?.showEditTask(task) }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Task"
        navigationController.pushViewController(hostingController, animated: true)
    }

    func showAddTask(projectID: UUID? = nil) {
        let viewModel = AddEditTaskViewModel(
            createTaskUseCase: container.resolve(CreateTaskUseCase.self),
            updateTaskUseCase: container.resolve(UpdateTaskUseCase.self)
        )
        if let projectID {
            viewModel.projectID = projectID
        }
        presentAddEditTask(viewModel: viewModel)
    }

    private func showEditTask(_ task: TodoItem) {
        let viewModel = AddEditTaskViewModel(
            editing: task,
            createTaskUseCase: container.resolve(CreateTaskUseCase.self),
            updateTaskUseCase: container.resolve(UpdateTaskUseCase.self)
        )
        presentAddEditTask(viewModel: viewModel)
    }

    private func presentAddEditTask(viewModel: AddEditTaskViewModel) {
        let dismiss = { [weak navigationController] in
            navigationController?.presentedViewController?.dismiss(animated: true)
        }
        let view = AddEditTaskView(
            viewModel: viewModel,
            onSave: { _ in dismiss() },
            onCancel: dismiss
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = viewModel.isEditing ? "Edit Task" : "New Task"
        let modalNavigationController = UINavigationController(rootViewController: hostingController)
        navigationController.present(modalNavigationController, animated: true)
    }
}
