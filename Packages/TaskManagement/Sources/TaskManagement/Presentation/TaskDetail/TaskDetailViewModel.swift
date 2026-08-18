import Combine
import Foundation

@MainActor
public final class TaskDetailViewModel: ObservableObject {
    @Published public private(set) var task: TodoItem
    @Published public var errorMessage: String?

    private let updateTaskUseCase: UpdateTaskUseCase
    private let toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase

    public var hasConflict: Bool { task.syncStatus == .conflict }

    public init(
        task: TodoItem,
        updateTaskUseCase: UpdateTaskUseCase,
        toggleTaskCompletionUseCase: ToggleTaskCompletionUseCase
    ) {
        self.task = task
        self.updateTaskUseCase = updateTaskUseCase
        self.toggleTaskCompletionUseCase = toggleTaskCompletionUseCase
    }

    public func toggleCompletion() async {
        do {
            task = try await toggleTaskCompletionUseCase.execute(id: task.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func toggleSubtask(id: UUID) async {
        guard let index = task.subtasks.firstIndex(where: { $0.id == id }) else { return }
        var updated = task
        updated.subtasks[index].isCompleted.toggle()

        do {
            task = try await updateTaskUseCase.execute(updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
