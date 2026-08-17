import Foundation

public protocol ProjectRepository {
    func fetchAll() async throws -> [Project]
    func fetch(id: UUID) async throws -> Project?
    func create(_ project: Project) async throws -> Project
    func update(_ project: Project) async throws -> Project
    func delete(id: UUID) async throws
}
