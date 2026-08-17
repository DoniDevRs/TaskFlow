import Foundation

public protocol DummyJSONTodosServicing {
    func fetchTodos(limit: Int, skip: Int) async throws -> DummyJSONTodosPage
    func fetchTodo(id: Int) async throws -> DummyJSONTodo
    func createTodo(_ input: DummyJSONTodoInput) async throws -> DummyJSONTodo
    func updateTodo(id: Int, with update: DummyJSONTodoUpdate) async throws -> DummyJSONTodo
    func deleteTodo(id: Int) async throws -> DummyJSONTodo
}

public final class DummyJSONTodosService: DummyJSONTodosServicing {
    private let client: APIClient
    private let encoder: JSONEncoder

    public init(client: APIClient, encoder: JSONEncoder = JSONEncoder()) {
        self.client = client
        self.encoder = encoder
    }

    public func fetchTodos(limit: Int, skip: Int) async throws -> DummyJSONTodosPage {
        try await client.send(Endpoint(
            path: "todos",
            queryItems: [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "skip", value: String(skip))
            ]
        ))
    }

    public func fetchTodo(id: Int) async throws -> DummyJSONTodo {
        try await client.send(Endpoint(path: "todos/\(id)"))
    }

    public func createTodo(_ input: DummyJSONTodoInput) async throws -> DummyJSONTodo {
        try await client.send(Endpoint(
            path: "todos/add",
            method: .post,
            body: try encoder.encode(input)
        ))
    }

    public func updateTodo(id: Int, with update: DummyJSONTodoUpdate) async throws -> DummyJSONTodo {
        try await client.send(Endpoint(
            path: "todos/\(id)",
            method: .put,
            body: try encoder.encode(update)
        ))
    }

    public func deleteTodo(id: Int) async throws -> DummyJSONTodo {
        try await client.send(Endpoint(path: "todos/\(id)", method: .delete))
    }
}
