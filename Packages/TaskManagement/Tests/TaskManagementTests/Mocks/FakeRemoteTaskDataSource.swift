@testable import TaskManagement

final class FakeRemoteTaskDataSource: RemoteTaskDataSource {
    var remoteByID: [Int: RemoteTaskSnapshot] = [:]
    var nextCreatedRemoteID = 1000
    var fetchError: Error?
    var createError: Error?
    var updateError: Error?

    private(set) var updateCalls: [(remoteID: Int, title: String?, completed: Bool?)] = []

    func create(title: String, completed: Bool) async throws -> RemoteTaskSnapshot {
        if let createError { throw createError }
        let snapshot = RemoteTaskSnapshot(remoteID: nextCreatedRemoteID, title: title, completed: completed)
        remoteByID[nextCreatedRemoteID] = snapshot
        nextCreatedRemoteID += 1
        return snapshot
    }

    func fetch(remoteID: Int) async throws -> RemoteTaskSnapshot {
        if let fetchError { throw fetchError }
        guard let snapshot = remoteByID[remoteID] else {
            fatalError("FakeRemoteTaskDataSource has no stub for remoteID \(remoteID)")
        }
        return snapshot
    }

    func update(remoteID: Int, title: String?, completed: Bool?) async throws -> RemoteTaskSnapshot {
        if let updateError { throw updateError }
        updateCalls.append((remoteID, title, completed))
        let existing = remoteByID[remoteID]
        let updated = RemoteTaskSnapshot(
            remoteID: remoteID,
            title: title ?? existing?.title ?? "",
            completed: completed ?? existing?.completed ?? false
        )
        remoteByID[remoteID] = updated
        return updated
    }

    func delete(remoteID: Int) async throws {
        remoteByID[remoteID] = nil
    }
}
