import Foundation

public struct TaskFilter: Equatable {
    public var projectID: UUID?
    public var priority: Priority?
    public var tag: String?
    public var isCompleted: Bool?
    public var dueBefore: Date?

    public init(
        projectID: UUID? = nil,
        priority: Priority? = nil,
        tag: String? = nil,
        isCompleted: Bool? = nil,
        dueBefore: Date? = nil
    ) {
        self.projectID = projectID
        self.priority = priority
        self.tag = tag
        self.isCompleted = isCompleted
        self.dueBefore = dueBefore
    }
}
