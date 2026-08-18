import Core
import XCTest
@testable import TaskManagement

@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var biometricAuthenticator: FakeBiometricAuthenticator!
    private var keychain: FakeKeychainStore!
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        biometricAuthenticator = FakeBiometricAuthenticator()
        keychain = FakeKeychainStore()
        userDefaults = UserDefaults(suiteName: "SettingsViewModelTests-\(UUID().uuidString)")
    }

    override func tearDown() {
        userDefaults = nil
        super.tearDown()
    }

    private func makeSUT() -> SettingsViewModel {
        SettingsViewModel(
            biometricAuthenticator: biometricAuthenticator,
            keychain: keychain,
            userDefaults: userDefaults,
            locale: Locale(identifier: "en_US")
        )
    }

    func test_enableBiometricLock_whenAuthenticationSucceeds_setsEnabled() async {
        biometricAuthenticator.result = .success(true)
        let sut = makeSUT()

        await sut.enableBiometricLock()

        XCTAssertTrue(sut.isBiometricLockEnabled)
    }

    func test_enableBiometricLock_whenAuthenticationFails_staysDisabledAndSetsError() async {
        biometricAuthenticator.result = .failure(TestError.stub)
        let sut = makeSUT()

        await sut.enableBiometricLock()

        XCTAssertFalse(sut.isBiometricLockEnabled)
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_disableBiometricLock_setsDisabled() async {
        biometricAuthenticator.result = .success(true)
        let sut = makeSUT()
        await sut.enableBiometricLock()

        sut.disableBiometricLock()

        XCTAssertFalse(sut.isBiometricLockEnabled)
    }

    func test_setPasscode_withValidDigits_isRetrievableAndVerifiable() {
        let sut = makeSUT()

        sut.setPasscode("1234")

        XCTAssertTrue(sut.hasPasscodeSet)
        XCTAssertTrue(sut.verifyPasscode("1234"))
        XCTAssertFalse(sut.verifyPasscode("9999"))
    }

    func test_setPasscode_withNonNumericInput_setsErrorAndDoesNotStore() {
        let sut = makeSUT()

        sut.setPasscode("abcd")

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.hasPasscodeSet)
    }

    func test_setPasscode_withWrongLength_setsErrorAndDoesNotStore() {
        let sut = makeSUT()

        sut.setPasscode("12")

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.hasPasscodeSet)
    }

    func test_verifyPasscode_whenNoneSet_returnsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.verifyPasscode("1234"))
    }
}
