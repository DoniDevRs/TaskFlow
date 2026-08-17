import Foundation

public final class CreateProjectUseCase {
    private let repository: ProjectRepository

    public init(repository: ProjectRepository) {
        self.repository = repository
    }

    public func execute(name: String, colorTag: String) async throws -> Project {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ProjectValidationError.emptyName
        }

        let project = Project(name: trimmedName, colorTag: colorTag)
        return try await repository.create(project)
    }
}
