import Core
import XCTest
@testable import TaskManagement

final class CoreDataProjectRepositoryTests: XCTestCase {
    private var sut: CoreDataProjectRepository!

    override func setUp() {
        super.setUp()
        sut = CoreDataProjectRepository(persistence: PersistenceController(inMemory: true))
    }

    func test_create_thenFetchAll_returnsCreatedProject() async throws {
        let project = Project(name: "TaskFlow Launch", colorTag: "terracotta")

        _ = try await sut.create(project)

        let all = try await sut.fetchAll()
        XCTAssertEqual(all.map(\.id), [project.id])
    }

    func test_update_persistsChanges() async throws {
        let created = try await sut.create(Project(name: "Original", colorTag: "sage"))
        var edited = created
        edited.name = "Renamed"

        let updated = try await sut.update(edited)

        XCTAssertEqual(updated.name, "Renamed")
    }

    func test_update_whenProjectMissing_throwsProjectNotFound() async {
        do {
            _ = try await sut.update(Project(name: "Never created", colorTag: "sage"))
            XCTFail("Expected ProjectUseCaseError.projectNotFound")
        } catch ProjectUseCaseError.projectNotFound {
            // expected
        } catch {
            XCTFail("Expected projectNotFound, got \(error)")
        }
    }

    func test_delete_removesProject() async throws {
        let created = try await sut.create(Project(name: "To delete", colorTag: "amber"))

        try await sut.delete(id: created.id)

        let fetched = try await sut.fetch(id: created.id)
        XCTAssertNil(fetched)
    }
}
