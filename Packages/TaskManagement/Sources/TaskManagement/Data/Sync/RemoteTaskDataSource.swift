public struct RemoteTaskSnapshot: Equatable {
    public let remoteID: Int
    public let title: String
    public let completed: Bool

    public init(remoteID: Int, title: String, completed: Bool) {
        self.remoteID = remoteID
        self.title = title
        self.completed = completed
    }
}

/// Only title + completion state round-trip through DummyJSON — see
/// DummyJSONTaskDataSource for why.
public protocol RemoteTaskDataSource {
    func create(title: String, completed: Bool) async throws -> RemoteTaskSnapshot
    func fetch(remoteID: Int) async throws -> RemoteTaskSnapshot
    func update(remoteID: Int, title: String?, completed: Bool?) async throws -> RemoteTaskSnapshot
    func delete(remoteID: Int) async throws
}
