import Core
import Foundation

final class FakeKeychainStore: KeychainStoring {
    var storage: [String: Data] = [:]

    func set(_ data: Data, forKey key: String) throws {
        storage[key] = data
    }

    func get(forKey key: String) throws -> Data? {
        storage[key]
    }

    func delete(forKey key: String) throws {
        storage[key] = nil
    }
}
