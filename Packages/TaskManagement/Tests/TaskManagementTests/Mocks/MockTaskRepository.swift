import Foundation
@testable import TaskManagement

enum TestError: Error, Equatable {
    case stub
}

final class MockTaskRepository: TaskRepository {
    var tasks: [UUID: TodoItem] = [:]
    var fetchAllError: Error?
    var fetchError: Error?
    var createError: Error?
    var updateError: Error?
    var deleteError: Error?

    private(set) var createdTasks: [TodoItem] = []
    private(set) var updatedTasks: [TodoItem] = []
    private(set) var deletedIDs: [UUID] = []

    func fetchAll() async throws -> [TodoItem] {
        if let fetchAllError { throw fetchAllError }
        return Array(tasks.values)
    }

    func fetch(id: UUID) async throws -> TodoItem? {
        if let fetchError { throw fetchError }
        return tasks[id]
    }

    func create(_ task: TodoItem) async throws -> TodoItem {
        if let createError { throw createError }
        tasks[task.id] = task
        createdTasks.append(task)
        return task
    }

    func update(_ task: TodoItem) async throws -> TodoItem {
        if let updateError { throw updateError }
        tasks[task.id] = task
        updatedTasks.append(task)
        return task
    }

    func delete(id: UUID) async throws {
        if let deleteError { throw deleteError }
        tasks[id] = nil
        deletedIDs.append(id)
    }
}
