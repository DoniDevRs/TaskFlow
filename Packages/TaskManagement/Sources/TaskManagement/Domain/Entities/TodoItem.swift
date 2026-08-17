import Foundation

/// Named TodoItem, not Task — "Task" collides with Swift Concurrency's
/// built-in _Concurrency.Task, which this codebase uses throughout for
/// async/await. Repositories, use cases, and ViewModels still use "Task"
/// as domain vocabulary (TaskRepository, TaskListViewModel, etc.) since
/// only the bare type name collides, not compound identifiers.
public struct TodoItem: Identifiable, Equatable {
    public var id: UUID
    public var title: String
    public var description: String?
    public var dueDate: Date?
    public var priority: Priority
    public var tags: [String]
    public var projectID: UUID?
    public var subtasks: [Subtask]
    public var isCompleted: Bool
    public var syncStatus: SyncStatus
    public var lastModified: Date

    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        tags: [String] = [],
        projectID: UUID? = nil,
        subtasks: [Subtask] = [],
        isCompleted: Bool = false,
        syncStatus: SyncStatus = .pending,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.priority = priority
        self.tags = tags
        self.projectID = projectID
        self.subtasks = subtasks
        self.isCompleted = isCompleted
        self.syncStatus = syncStatus
        self.lastModified = lastModified
    }
}
