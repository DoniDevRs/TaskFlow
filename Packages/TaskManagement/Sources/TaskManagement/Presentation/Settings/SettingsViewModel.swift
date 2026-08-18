import Combine
import Core
import Foundation

@MainActor
public final class SettingsViewModel: ObservableObject {
    private enum Keys {
        static let biometricLockEnabled = "settings.biometricLockEnabled"
        static let passcodeHash = "com.donidevrs.TaskFlow.passcodeHash"
    }

    @Published public var isBiometricLockEnabled: Bool {
        didSet { userDefaults.set(isBiometricLockEnabled, forKey: Keys.biometricLockEnabled) }
    }
    @Published public var errorMessage: String?
    public let languageDisplayName: String

    private let biometricAuthenticator: BiometricAuthenticating
    private let keychain: KeychainStoring
    private let userDefaults: UserDefaults

    public init(
        biometricAuthenticator: BiometricAuthenticating,
        keychain: KeychainStoring,
        userDefaults: UserDefaults = .standard,
        locale: Locale = .current
    ) {
        self.biometricAuthenticator = biometricAuthenticator
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.isBiometricLockEnabled = userDefaults.bool(forKey: Keys.biometricLockEnabled)
        self.languageDisplayName = locale.localizedString(forIdentifier: locale.identifier) ?? locale.identifier
    }

    public var hasPasscodeSet: Bool {
        guard let stored = try? keychain.get(forKey: Keys.passcodeHash) else { return false }
        return stored != nil
    }

    public func enableBiometricLock() async {
        do {
            let success = try await biometricAuthenticator.evaluateBiometrics(
                reason: "Confirm to enable Face ID lock for TaskFlow"
            )
            isBiometricLockEnabled = success
        } catch {
            errorMessage = error.localizedDescription
            isBiometricLockEnabled = false
        }
    }

    public func disableBiometricLock() {
        isBiometricLockEnabled = false
    }

    public func setPasscode(_ passcode: String) {
        guard (4...6).contains(passcode.count), passcode.allSatisfy(\.isNumber) else {
            errorMessage = String(localized: "Passcode must be 4 to 6 digits.", bundle: .module)
            return
        }
        do {
            try keychain.set(PasscodeHasher.hash(passcode), forKey: Keys.passcodeHash)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func verifyPasscode(_ passcode: String) -> Bool {
        guard let storedHash = try? keychain.get(forKey: Keys.passcodeHash) else { return false }
        return storedHash == PasscodeHasher.hash(passcode)
    }
}
