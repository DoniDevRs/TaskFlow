import XCTest
@testable import Core

final class DummyJSONTodosServiceTests: XCTestCase {
    private var fakeClient: FakeAPIClient!
    private var sut: DummyJSONTodosService!

    override func setUp() {
        super.setUp()
        fakeClient = FakeAPIClient()
        sut = DummyJSONTodosService(client: fakeClient)
    }

    override func tearDown() {
        fakeClient = nil
        sut = nil
        super.tearDown()
    }

    func test_fetchTodos_buildsListEndpointWithPaging() async throws {
        let page = DummyJSONTodosPage(todos: [], total: 0, skip: 0, limit: 30)
        fakeClient.stubbedResult = .success(page)

        let result = try await sut.fetchTodos(limit: 30, skip: 10)

        XCTAssertEqual(result, page)
        let endpoint = try XCTUnwrap(fakeClient.sentEndpoints.first)
        XCTAssertEqual(endpoint.path, "todos")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertTrue(endpoint.queryItems.contains(URLQueryItem(name: "limit", value: "30")))
        XCTAssertTrue(endpoint.queryItems.contains(URLQueryItem(name: "skip", value: "10")))
    }

    func test_fetchTodo_buildsDetailEndpoint() async throws {
        let todo = DummyJSONTodo(id: 7, todo: "Ship T3", completed: false, userId: 1)
        fakeClient.stubbedResult = .success(todo)

        let result = try await sut.fetchTodo(id: 7)

        XCTAssertEqual(result, todo)
        XCTAssertEqual(fakeClient.sentEndpoints.first?.path, "todos/7")
    }

    func test_createTodo_postsEncodedInput() async throws {
        let created = DummyJSONTodo(id: 99, todo: "New task", completed: false, userId: 1)
        fakeClient.stubbedResult = .success(created)

        let result = try await sut.createTodo(DummyJSONTodoInput(todo: "New task", completed: false, userId: 1))

        XCTAssertEqual(result, created)
        let endpoint = try XCTUnwrap(fakeClient.sentEndpoints.first)
        XCTAssertEqual(endpoint.path, "todos/add")
        XCTAssertEqual(endpoint.method, .post)
        let body = try XCTUnwrap(endpoint.body)
        let decoded = try JSONDecoder().decode(DummyJSONTodoInput.self, from: body)
        XCTAssertEqual(decoded.todo, "New task")
        XCTAssertEqual(decoded.userId, 1)
    }

    func test_updateTodo_putsOnlyProvidedFields() async throws {
        let updated = DummyJSONTodo(id: 7, todo: "Ship T3", completed: true, userId: 1)
        fakeClient.stubbedResult = .success(updated)

        let result = try await sut.updateTodo(id: 7, with: DummyJSONTodoUpdate(completed: true))

        XCTAssertEqual(result, updated)
        let endpoint = try XCTUnwrap(fakeClient.sentEndpoints.first)
        XCTAssertEqual(endpoint.path, "todos/7")
        XCTAssertEqual(endpoint.method, .put)
        let body = try XCTUnwrap(endpoint.body)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["completed"] as? Bool, true)
        XCTAssertNil(json["todo"])
    }

    func test_deleteTodo_buildsDeleteEndpoint() async throws {
        let deleted = DummyJSONTodo(id: 7, todo: "Ship T3", completed: true, userId: 1)
        fakeClient.stubbedResult = .success(deleted)

        let result = try await sut.deleteTodo(id: 7)

        XCTAssertEqual(result, deleted)
        let endpoint = try XCTUnwrap(fakeClient.sentEndpoints.first)
        XCTAssertEqual(endpoint.path, "todos/7")
        XCTAssertEqual(endpoint.method, .delete)
    }

    func test_fetchTodo_propagatesClientError() async {
        fakeClient.stubbedResult = .failure(APIClientError.requestFailed(statusCode: 404))

        do {
            _ = try await sut.fetchTodo(id: 404)
            XCTFail("Expected error to propagate")
        } catch APIClientError.requestFailed(let statusCode) {
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("Expected APIClientError.requestFailed, got \(error)")
        }
    }
}
