import Foundation

public struct SyncResult: Equatable {
    public let pulled: Int
    /// IDs of tasks where both local and remote changed since the last sync.
    public let conflictedTaskIDs: [UUID]

    public init(pulled: Int, conflictedTaskIDs: [UUID]) {
        self.pulled = pulled
        self.conflictedTaskIDs = conflictedTaskIDs
    }
}
