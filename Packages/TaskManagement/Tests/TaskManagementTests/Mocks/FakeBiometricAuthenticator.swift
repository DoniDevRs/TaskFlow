import Core

final class FakeBiometricAuthenticator: BiometricAuthenticating {
    var result: Result<Bool, Error> = .success(true)

    func evaluateBiometrics(reason: String) async throws -> Bool {
        try result.get()
    }
}
