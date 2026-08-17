import Foundation

public protocol TaskRepository {
    func fetchAll() async throws -> [TodoItem]
    func fetch(id: UUID) async throws -> TodoItem?
    func create(_ task: TodoItem) async throws -> TodoItem
    func update(_ task: TodoItem) async throws -> TodoItem
    func delete(id: UUID) async throws
}
