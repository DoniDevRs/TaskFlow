import Foundation
@testable import TaskManagement

final class MockProjectRepository: ProjectRepository {
    var projects: [UUID: Project] = [:]
    var fetchAllError: Error?
    var fetchError: Error?
    var createError: Error?
    var updateError: Error?
    var deleteError: Error?

    private(set) var createdProjects: [Project] = []

    func fetchAll() async throws -> [Project] {
        if let fetchAllError { throw fetchAllError }
        return Array(projects.values)
    }

    func fetch(id: UUID) async throws -> Project? {
        if let fetchError { throw fetchError }
        return projects[id]
    }

    func create(_ project: Project) async throws -> Project {
        if let createError { throw createError }
        projects[project.id] = project
        createdProjects.append(project)
        return project
    }

    func update(_ project: Project) async throws -> Project {
        if let updateError { throw updateError }
        projects[project.id] = project
        return project
    }

    func delete(id: UUID) async throws {
        if let deleteError { throw deleteError }
        projects[id] = nil
    }
}
