import Foundation

public final class UpdateTaskUseCase {
    private let repository: TaskRepository
    private let clock: () -> Date

    public init(repository: TaskRepository, clock: @escaping () -> Date = Date.init) {
        self.repository = repository
        self.clock = clock
    }

    public func execute(_ task: TodoItem) async throws -> TodoItem {
        let trimmedTitle = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw TaskValidationError.emptyTitle
        }

        var updated = task
        updated.title = trimmedTitle
        updated.lastModified = clock()
        updated.syncStatus = .pending
        return try await repository.update(updated)
    }
}
