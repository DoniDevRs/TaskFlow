import Core

/// DummyJSON's Todo DTO is minimal (todo, completed, userId) — priority,
/// tags, project, subtasks, and due date live authoritatively in Core Data
/// only; only title + completion round-trip through the remote API. This is
/// a deliberate, documented trade-off of using a public mock API for a demo
/// sync layer (see plan.md §3, README).
public final class DummyJSONTaskDataSource: RemoteTaskDataSource {
    private let service: DummyJSONTodosServicing
    private let userID: Int

    public init(service: DummyJSONTodosServicing, userID: Int = 1) {
        self.service = service
        self.userID = userID
    }

    public func create(title: String, completed: Bool) async throws -> RemoteTaskSnapshot {
        let todo = try await service.createTodo(DummyJSONTodoInput(todo: title, completed: completed, userId: userID))
        return Self.snapshot(from: todo)
    }

    public func fetch(remoteID: Int) async throws -> RemoteTaskSnapshot {
        Self.snapshot(from: try await service.fetchTodo(id: remoteID))
    }

    public func update(remoteID: Int, title: String?, completed: Bool?) async throws -> RemoteTaskSnapshot {
        let todo = try await service.updateTodo(id: remoteID, with: DummyJSONTodoUpdate(todo: title, completed: completed))
        return Self.snapshot(from: todo)
    }

    public func delete(remoteID: Int) async throws {
        _ = try await service.deleteTodo(id: remoteID)
    }

    private static func snapshot(from todo: DummyJSONTodo) -> RemoteTaskSnapshot {
        RemoteTaskSnapshot(remoteID: todo.id, title: todo.todo, completed: todo.completed)
    }
}
