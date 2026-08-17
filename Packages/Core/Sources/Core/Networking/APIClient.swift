import Foundation

public enum APIClientError: Error, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case transportError(String)
    case decodingFailed(String)
}

/// URLSession wrapped behind a protocol so callers can be tested against a
/// fake — no live network calls in unit tests.
public protocol APIClient {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
