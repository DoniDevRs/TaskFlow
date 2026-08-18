import LocalAuthentication

public protocol BiometricAuthenticating {
    func evaluateBiometrics(reason: String) async throws -> Bool
}

public final class BiometricAuthenticator: BiometricAuthenticating {
    public init() {}

    public func evaluateBiometrics(reason: String) async throws -> Bool {
        let context = LAContext()
        var evaluationError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evaluationError) else {
            if let evaluationError {
                throw evaluationError
            }
            return false
        }
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }
}
