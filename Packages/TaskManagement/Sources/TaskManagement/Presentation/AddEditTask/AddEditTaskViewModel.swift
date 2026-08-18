import Combine
import Foundation

@MainActor
public final class AddEditTaskViewModel: ObservableObject {
    @Published public var title: String = ""
    @Published public var description: String = ""
    @Published public var dueDate: Date?
    @Published public var priority: Priority = .medium
    @Published public var tags: [String] = []
    @Published public var projectID: UUID?
    @Published public var subtasks: [Subtask] = []
    @Published public var validationError: String?
    @Published public var isSaving = false

    private let createTaskUseCase: CreateTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let originalTask: TodoItem?

    public var isEditing: Bool { originalTask != nil }

    public init(
        editing task: TodoItem? = nil,
        createTaskUseCase: CreateTaskUseCase,
        updateTaskUseCase: UpdateTaskUseCase
    ) {
        self.createTaskUseCase = createTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.originalTask = task

        if let task {
            title = task.title
            description = task.description ?? ""
            dueDate = task.dueDate
            priority = task.priority
            tags = task.tags
            projectID = task.projectID
            subtasks = task.subtasks
        }
    }

    @discardableResult
    public func save() async -> TodoItem? {
        validationError = nil
        isSaving = true
        defer { isSaving = false }

        do {
            if let originalTask {
                // Preserve everything the form doesn't expose (isCompleted,
                // etc.) — only apply the editable fields on top.
                var updated = originalTask
                updated.title = title
                updated.description = description.isEmpty ? nil : description
                updated.dueDate = dueDate
                updated.priority = priority
                updated.tags = tags
                updated.projectID = projectID
                updated.subtasks = subtasks
                return try await updateTaskUseCase.execute(updated)
            } else {
                return try await createTaskUseCase.execute(
                    title: title,
                    description: description.isEmpty ? nil : description,
                    dueDate: dueDate,
                    priority: priority,
                    tags: tags,
                    projectID: projectID,
                    subtasks: subtasks
                )
            }
        } catch {
            validationError = error.localizedDescription
            return nil
        }
    }

    public func addSubtask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        subtasks.append(Subtask(title: trimmed))
    }

    public func removeSubtask(id: UUID) {
        subtasks.removeAll { $0.id == id }
    }
}
