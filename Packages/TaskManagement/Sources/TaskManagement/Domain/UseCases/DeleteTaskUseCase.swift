import Foundation

public final class DeleteTaskUseCase {
    private let repository: TaskRepository

    public init(repository: TaskRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
