import Foundation

/// Reconciles local tasks against DummyJSON. Deliberately does NOT bulk-pull
/// DummyJSON's full /todos list into local tasks — that list is a shared
/// public seed dataset (the same ~150 generic todos for every DummyJSON
/// consumer), not "this user's" data, so importing it wholesale would flood
/// the task list with unrelated content. Instead: tasks created locally are
/// pushed to DummyJSON on first sync (linked via remoteID); tasks already
/// linked are reconciled one at a time against their specific remote record.
///
/// Conflict detection: DummyJSON has no update timestamp, so "did remote
/// change" is approximated by diffing its current title/completed against
/// local's current values, and "did local change" compares TodoItem's
/// lastModified against this task's lastSyncedAt (Data-layer-only
/// bookkeeping — see TaskSyncMetadataStore). When both sides changed since
/// the last sync, local wins (this device is the active source of truth)
/// and the task is flagged .conflict for the Task Detail banner to surface.
public actor SyncActor: SyncTasksUseCase {
    private enum ReconcileOutcome {
        case pulled
        case conflict
        case unchanged
    }

    private let taskRepository: TaskRepository
    private let syncMetadataStore: TaskSyncMetadataStore
    private let remoteDataSource: RemoteTaskDataSource
    private let clock: () -> Date

    public init(
        taskRepository: TaskRepository,
        syncMetadataStore: TaskSyncMetadataStore,
        remoteDataSource: RemoteTaskDataSource,
        clock: @escaping () -> Date = Date.init
    ) {
        self.taskRepository = taskRepository
        self.syncMetadataStore = syncMetadataStore
        self.remoteDataSource = remoteDataSource
        self.clock = clock
    }

    public func execute() async throws -> SyncResult {
        let now = clock()
        let tasks = try await taskRepository.fetchAll()

        var pulledCount = 0
        var conflictedIDs: [UUID] = []

        for task in tasks {
            if let metadata = try await syncMetadataStore.syncMetadata(forLocalID: task.id) {
                switch try await reconcile(task: task, metadata: metadata, now: now) {
                case .pulled: pulledCount += 1
                case .conflict: conflictedIDs.append(task.id)
                case .unchanged: break
                }
            } else {
                try await push(newTask: task, now: now)
            }
        }

        return SyncResult(pulled: pulledCount, conflictedTaskIDs: conflictedIDs)
    }

    private func reconcile(task: TodoItem, metadata: TaskSyncMetadata, now: Date) async throws -> ReconcileOutcome {
        let remote = try await remoteDataSource.fetch(remoteID: metadata.remoteID)
        let localChangedSinceSync = task.lastModified > metadata.lastSyncedAt
        let remoteDiffersFromLocal = remote.title != task.title || remote.completed != task.isCompleted

        var updated = task
        let outcome: ReconcileOutcome

        switch (localChangedSinceSync, remoteDiffersFromLocal) {
        case (false, true):
            updated.title = remote.title
            updated.isCompleted = remote.completed
            updated.lastModified = now
            updated.syncStatus = .synced
            outcome = .pulled

        case (false, false):
            updated.syncStatus = .synced
            outcome = .unchanged

        case (true, false):
            updated.syncStatus = .synced
            outcome = .unchanged

        case (true, true):
            _ = try await remoteDataSource.update(remoteID: metadata.remoteID, title: task.title, completed: task.isCompleted)
            updated.syncStatus = .conflict
            outcome = .conflict
        }

        if updated != task {
            _ = try await taskRepository.update(updated)
        }
        try await syncMetadataStore.setSyncMetadata(
            TaskSyncMetadata(remoteID: metadata.remoteID, lastSyncedAt: now),
            forLocalID: task.id
        )
        return outcome
    }

    private func push(newTask task: TodoItem, now: Date) async throws {
        let remote = try await remoteDataSource.create(title: task.title, completed: task.isCompleted)

        var updated = task
        updated.syncStatus = .synced
        _ = try await taskRepository.update(updated)

        try await syncMetadataStore.setSyncMetadata(
            TaskSyncMetadata(remoteID: remote.remoteID, lastSyncedAt: now),
            forLocalID: task.id
        )
    }
}
