import XCTest
@testable import TaskManagement

final class CreateProjectUseCaseTests: XCTestCase {
    private var repository: MockProjectRepository!
    private var sut: CreateProjectUseCase!

    override func setUp() {
        super.setUp()
        repository = MockProjectRepository()
        sut = CreateProjectUseCase(repository: repository)
    }

    func test_execute_withValidName_createsProjectViaRepository() async throws {
        let project = try await sut.execute(name: "  TaskFlow Launch  ", colorTag: "terracotta")

        XCTAssertEqual(project.name, "TaskFlow Launch")
        XCTAssertEqual(project.colorTag, "terracotta")
        XCTAssertEqual(repository.createdProjects.count, 1)
    }

    func test_execute_withEmptyName_throwsValidationError() async {
        do {
            _ = try await sut.execute(name: "   ", colorTag: "sage")
            XCTFail("Expected ProjectValidationError.emptyName")
        } catch ProjectValidationError.emptyName {
            // expected
        } catch {
            XCTFail("Expected emptyName, got \(error)")
        }

        XCTAssertTrue(repository.createdProjects.isEmpty)
    }

    func test_execute_whenRepositoryFails_propagatesError() async {
        repository.createError = TestError.stub

        do {
            _ = try await sut.execute(name: "Valid", colorTag: "sage")
            XCTFail("Expected repository error to propagate")
        } catch TestError.stub {
            // expected
        } catch {
            XCTFail("Expected TestError.stub, got \(error)")
        }
    }
}
