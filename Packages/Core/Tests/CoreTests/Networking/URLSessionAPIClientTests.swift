import XCTest
@testable import Core

final class URLSessionAPIClientTests: XCTestCase {
    private struct Fixture: Decodable, Equatable {
        let id: Int
        let name: String
    }

    private var sut: URLSessionAPIClient!

    override func setUp() {
        super.setUp()
        sut = URLSessionAPIClient(session: MockURLProtocol.makeSession(), baseURL: URL(string: "https://dummyjson.com")!)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        sut = nil
        super.tearDown()
    }

    func test_send_decodesSuccessResponse() async throws {
        let json = #"{"id": 1, "name": "TaskFlow"}"#.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let result: Fixture = try await sut.send(Endpoint(path: "fixture"))

        XCTAssertEqual(result, Fixture(id: 1, name: "TaskFlow"))
    }

    func test_send_throwsRequestFailed_onNon2xxStatus() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            let _: Fixture = try await sut.send(Endpoint(path: "fixture"))
            XCTFail("Expected requestFailed to be thrown")
        } catch APIClientError.requestFailed(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Expected APIClientError.requestFailed, got \(error)")
        }
    }

    func test_send_throwsDecodingFailed_onMalformedJSON() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "not json".data(using: .utf8)!)
        }

        do {
            let _: Fixture = try await sut.send(Endpoint(path: "fixture"))
            XCTFail("Expected decodingFailed to be thrown")
        } catch APIClientError.decodingFailed {
            // expected
        } catch {
            XCTFail("Expected APIClientError.decodingFailed, got \(error)")
        }
    }

    func test_send_setsHTTPMethodAndBody() async throws {
        let json = #"{"id": 2, "name": "Body Check"}"#.data(using: .utf8)!
        var capturedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            capturedRequest = request
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let body = #"{"name":"new"}"#.data(using: .utf8)!
        let _: Fixture = try await sut.send(Endpoint(path: "fixture", method: .post, body: body))

        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
}
