public enum SyncStatus: String, Codable, Equatable {
    case synced
    case pending
    case conflict
}
