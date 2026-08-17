import Foundation

public final class CreateTaskUseCase {
    private let repository: TaskRepository
    private let clock: () -> Date

    public init(repository: TaskRepository, clock: @escaping () -> Date = Date.init) {
        self.repository = repository
        self.clock = clock
    }

    public func execute(
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        tags: [String] = [],
        projectID: UUID? = nil,
        subtasks: [Subtask] = []
    ) async throws -> TodoItem {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw TaskValidationError.emptyTitle
        }

        let now = clock()
        if let dueDate, dueDate < now {
            throw TaskValidationError.dueDateInPast
        }

        let task = TodoItem(
            title: trimmedTitle,
            description: description,
            dueDate: dueDate,
            priority: priority,
            tags: tags,
            projectID: projectID,
            subtasks: subtasks,
            isCompleted: false,
            syncStatus: .pending,
            lastModified: now
        )
        return try await repository.create(task)
    }
}
