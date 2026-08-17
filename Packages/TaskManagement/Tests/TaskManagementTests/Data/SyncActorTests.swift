import XCTest
@testable import TaskManagement

final class SyncActorTests: XCTestCase {
    private var taskRepository: MockTaskRepository!
    private var metadataStore: FakeTaskSyncMetadataStore!
    private var remoteDataSource: FakeRemoteTaskDataSource!
    private let fixedNow = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        taskRepository = MockTaskRepository()
        metadataStore = FakeTaskSyncMetadataStore()
        remoteDataSource = FakeRemoteTaskDataSource()
    }

    private func makeSUT() -> SyncActor {
        SyncActor(
            taskRepository: taskRepository,
            syncMetadataStore: metadataStore,
            remoteDataSource: remoteDataSource,
            clock: { self.fixedNow }
        )
    }

    func test_execute_newLocalTask_pushesToRemoteAndRecordsMetadata() async throws {
        let task = TodoItem(title: "New task", isCompleted: false, syncStatus: .pending)
        taskRepository.tasks[task.id] = task
        let sut = makeSUT()

        let result = try await sut.execute()

        XCTAssertEqual(result.pulled, 0)
        XCTAssertTrue(result.conflictedTaskIDs.isEmpty)
        let updated = try XCTUnwrap(taskRepository.updatedTasks.first)
        XCTAssertEqual(updated.syncStatus, .synced)

        let storedMetadata = try await metadataStore.syncMetadata(forLocalID: task.id)
        let metadata = try XCTUnwrap(storedMetadata)
        XCTAssertEqual(metadata.lastSyncedAt, fixedNow)
        XCTAssertNotNil(remoteDataSource.remoteByID[metadata.remoteID])
    }

    func test_execute_linkedTaskWithNoChanges_doesNotCallUpdate() async throws {
        let syncedAt = fixedNow.addingTimeInterval(-3600)
        let task = TodoItem(title: "Stable", isCompleted: false, syncStatus: .synced, lastModified: syncedAt)
        taskRepository.tasks[task.id] = task
        metadataStore.metadata[task.id] = TaskSyncMetadata(remoteID: 5, lastSyncedAt: syncedAt)
        remoteDataSource.remoteByID[5] = RemoteTaskSnapshot(remoteID: 5, title: "Stable", completed: false)
        let sut = makeSUT()

        let result = try await sut.execute()

        XCTAssertEqual(result.pulled, 0)
        XCTAssertTrue(result.conflictedTaskIDs.isEmpty)
        XCTAssertTrue(taskRepository.updatedTasks.isEmpty, "already synced and unchanged — nothing to write")
    }

    func test_execute_whenOnlyRemoteChanged_pullsRemoteValuesIntoLocal() async throws {
        let syncedAt = fixedNow.addingTimeInterval(-3600)
        let task = TodoItem(title: "Old title", isCompleted: false, syncStatus: .synced, lastModified: syncedAt)
        taskRepository.tasks[task.id] = task
        metadataStore.metadata[task.id] = TaskSyncMetadata(remoteID: 5, lastSyncedAt: syncedAt)
        remoteDataSource.remoteByID[5] = RemoteTaskSnapshot(remoteID: 5, title: "New remote title", completed: true)
        let sut = makeSUT()

        let result = try await sut.execute()

        XCTAssertEqual(result.pulled, 1)
        let updated = try XCTUnwrap(taskRepository.updatedTasks.first)
        XCTAssertEqual(updated.title, "New remote title")
        XCTAssertTrue(updated.isCompleted)
        XCTAssertEqual(updated.syncStatus, .synced)
    }

    func test_execute_whenOnlyLocalChanged_marksSyncedWithoutPushingUpdate() async throws {
        let syncedAt = fixedNow.addingTimeInterval(-3600)
        let task = TodoItem(
            title: "Edited locally",
            isCompleted: false,
            syncStatus: .pending,
            lastModified: fixedNow.addingTimeInterval(-60)
        )
        taskRepository.tasks[task.id] = task
        metadataStore.metadata[task.id] = TaskSyncMetadata(remoteID: 5, lastSyncedAt: syncedAt)
        remoteDataSource.remoteByID[5] = RemoteTaskSnapshot(remoteID: 5, title: "Edited locally", completed: false)
        let sut = makeSUT()

        let result = try await sut.execute()

        XCTAssertEqual(result.pulled, 0)
        XCTAssertTrue(result.conflictedTaskIDs.isEmpty)
        let updated = try XCTUnwrap(taskRepository.updatedTasks.first)
        XCTAssertEqual(updated.syncStatus, .synced)
        XCTAssertTrue(remoteDataSource.updateCalls.isEmpty, "remote already matches — no push needed")
    }

    func test_execute_whenBothSidesChanged_localWinsAndFlagsConflict() async throws {
        let syncedAt = fixedNow.addingTimeInterval(-3600)
        let task = TodoItem(
            title: "Local edit",
            isCompleted: true,
            syncStatus: .pending,
            lastModified: fixedNow.addingTimeInterval(-60)
        )
        taskRepository.tasks[task.id] = task
        metadataStore.metadata[task.id] = TaskSyncMetadata(remoteID: 5, lastSyncedAt: syncedAt)
        remoteDataSource.remoteByID[5] = RemoteTaskSnapshot(remoteID: 5, title: "Remote edit", completed: false)
        let sut = makeSUT()

        let result = try await sut.execute()

        XCTAssertEqual(result.conflictedTaskIDs, [task.id])
        let updated = try XCTUnwrap(taskRepository.updatedTasks.first)
        XCTAssertEqual(updated.syncStatus, .conflict)
        XCTAssertEqual(updated.title, "Local edit", "local wins the value; only the status reflects the conflict")

        let pushed = try XCTUnwrap(remoteDataSource.updateCalls.first)
        XCTAssertEqual(pushed.remoteID, 5)
        XCTAssertEqual(pushed.title, "Local edit")
        XCTAssertEqual(pushed.completed, true)
    }

    func test_execute_whenRemoteFetchFails_propagatesError() async {
        let syncedAt = fixedNow.addingTimeInterval(-3600)
        let task = TodoItem(title: "Task", syncStatus: .synced, lastModified: syncedAt)
        taskRepository.tasks[task.id] = task
        metadataStore.metadata[task.id] = TaskSyncMetadata(remoteID: 5, lastSyncedAt: syncedAt)
        remoteDataSource.fetchError = TestError.stub
        let sut = makeSUT()

        do {
            _ = try await sut.execute()
            XCTFail("Expected repository error to propagate")
        } catch TestError.stub {
            // expected
        } catch {
            XCTFail("Expected TestError.stub, got \(error)")
        }
    }
}
