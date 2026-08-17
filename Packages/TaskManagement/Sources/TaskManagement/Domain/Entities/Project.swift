import Foundation

public struct Project: Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var colorTag: String
    public var taskIDs: [UUID]

    public init(id: UUID = UUID(), name: String, colorTag: String, taskIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.colorTag = colorTag
        self.taskIDs = taskIDs
    }
}
