import Foundation

public struct DummyJSONTodo: Codable, Equatable {
    public let id: Int
    public let todo: String
    public let completed: Bool
    public let userId: Int

    public init(id: Int, todo: String, completed: Bool, userId: Int) {
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
    }
}

public struct DummyJSONTodosPage: Codable, Equatable {
    public let todos: [DummyJSONTodo]
    public let total: Int
    public let skip: Int
    public let limit: Int
}

/// Body for POST /todos/add.
public struct DummyJSONTodoInput: Codable, Equatable {
    public let todo: String
    public let completed: Bool
    public let userId: Int

    public init(todo: String, completed: Bool, userId: Int) {
        self.todo = todo
        self.completed = completed
        self.userId = userId
    }
}

/// Body for PUT /todos/{id} — only the fields being changed are encoded,
/// matching DummyJSON's partial-update contract.
public struct DummyJSONTodoUpdate: Encodable {
    public let todo: String?
    public let completed: Bool?

    public init(todo: String? = nil, completed: Bool? = nil) {
        self.todo = todo
        self.completed = completed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(todo, forKey: .todo)
        try container.encodeIfPresent(completed, forKey: .completed)
    }

    private enum CodingKeys: String, CodingKey {
        case todo, completed
    }
}
