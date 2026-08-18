import Foundation

public enum KeychainError: Error, Equatable {
    case unexpectedStatus(OSStatus)
}

public protocol KeychainStoring {
    func set(_ data: Data, forKey key: String) throws
    func get(forKey key: String) throws -> Data?
    func delete(forKey key: String) throws
}
