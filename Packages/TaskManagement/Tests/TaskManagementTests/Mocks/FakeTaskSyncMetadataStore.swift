import Foundation
@testable import TaskManagement

final class FakeTaskSyncMetadataStore: TaskSyncMetadataStore {
    var metadata: [UUID: TaskSyncMetadata] = [:]

    func syncMetadata(forLocalID id: UUID) async throws -> TaskSyncMetadata? {
        metadata[id]
    }

    func setSyncMetadata(_ metadata: TaskSyncMetadata, forLocalID id: UUID) async throws {
        self.metadata[id] = metadata
    }
}
