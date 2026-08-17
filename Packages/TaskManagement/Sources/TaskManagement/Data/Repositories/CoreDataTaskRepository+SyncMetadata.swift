import Core
import Foundation

extension CoreDataTaskRepository: TaskSyncMetadataStore {
    public func syncMetadata(forLocalID id: UUID) async throws -> TaskSyncMetadata? {
        let context = persistence.viewContext
        return try await context.perform {
            guard
                let entity = try Self.findEntity(id: id, in: context),
                let remoteID = entity.remoteID?.intValue,
                let lastSyncedAt = entity.lastSyncedAt
            else { return nil }
            return TaskSyncMetadata(remoteID: remoteID, lastSyncedAt: lastSyncedAt)
        }
    }

    public func setSyncMetadata(_ metadata: TaskSyncMetadata, forLocalID id: UUID) async throws {
        let context = persistence.viewContext
        try await context.perform {
            guard let entity = try Self.findEntity(id: id, in: context) else {
                throw TaskUseCaseError.taskNotFound
            }
            entity.remoteID = NSNumber(value: metadata.remoteID)
            entity.lastSyncedAt = metadata.lastSyncedAt
            try context.save()
        }
    }
}
