import Foundation

public struct TaskSyncMetadata: Equatable {
    public let remoteID: Int
    public let lastSyncedAt: Date

    public init(remoteID: Int, lastSyncedAt: Date) {
        self.remoteID = remoteID
        self.lastSyncedAt = lastSyncedAt
    }
}

/// Sync-only bookkeeping (remoteID, lastSyncedAt) — split out from
/// TaskRepository so the Domain-facing protocol stays free of Data-layer
/// sync concerns. CoreDataTaskRepository conforms to both; the composition
/// root wires the same instance into SyncActor for this half.
public protocol TaskSyncMetadataStore {
    func syncMetadata(forLocalID id: UUID) async throws -> TaskSyncMetadata?
    func setSyncMetadata(_ metadata: TaskSyncMetadata, forLocalID id: UUID) async throws
}
