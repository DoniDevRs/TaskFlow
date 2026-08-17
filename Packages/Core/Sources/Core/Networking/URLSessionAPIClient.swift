import Foundation

public final class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared, baseURL: URL, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.baseURL = baseURL
        self.decoder = decoder
    }

    public func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIClientError.invalidURL
        }
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIClientError.transportError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.transportError("Response was not an HTTP response")
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIClientError.requestFailed(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIClientError.decodingFailed(error.localizedDescription)
        }
    }
}
