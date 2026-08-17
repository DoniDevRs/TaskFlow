import Foundation
@testable import Core

final class FakeAPIClient: APIClient {
    private(set) var sentEndpoints: [Endpoint] = []
    var stubbedResult: Result<Any, Error> = .failure(APIClientError.invalidURL)

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        sentEndpoints.append(endpoint)
        switch stubbedResult {
        case .success(let value):
            guard let typed = value as? T else {
                fatalError("FakeAPIClient stub type \(type(of: value)) does not match requested \(T.self)")
            }
            return typed
        case .failure(let error):
            throw error
        }
    }
}
