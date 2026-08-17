import Foundation

public final class ToggleTaskCompletionUseCase {
    private let repository: TaskRepository
    private let clock: () -> Date

    public init(repository: TaskRepository, clock: @escaping () -> Date = Date.init) {
        self.repository = repository
        self.clock = clock
    }

    public func execute(id: UUID) async throws -> TodoItem {
        guard var task = try await repository.fetch(id: id) else {
            throw TaskUseCaseError.taskNotFound
        }

        task.isCompleted.toggle()
        task.lastModified = clock()
        task.syncStatus = .pending
        return try await repository.update(task)
    }
}
