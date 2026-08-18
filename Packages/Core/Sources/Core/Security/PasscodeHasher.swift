import CryptoKit
import Foundation

/// The passcode fallback is hashed before it ever reaches Keychain — never
/// stored in plaintext or UserDefaults, per plan.md §6.
public enum PasscodeHasher {
    public static func hash(_ passcode: String) -> Data {
        Data(SHA256.hash(data: Data(passcode.utf8)))
    }
}
