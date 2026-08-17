import CoreData
import XCTest
@testable import Core

final class PersistenceControllerTests: XCTestCase {
    private var sut: PersistenceController!

    override func setUp() {
        super.setUp()
        sut = PersistenceController(inMemory: true)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_saveAndFetch_task_persistsInMemory() throws {
        let task = TaskEntity(context: sut.viewContext)
        task.id = UUID()
        task.title = "Write CoreTests"
        task.priorityRaw = "high"
        task.syncStatusRaw = "pending"
        task.isCompleted = false
        task.lastModified = Date()

        try sut.saveViewContext()

        let fetched = try sut.viewContext.fetch(TaskEntity.fetchRequest())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Write CoreTests")
    }

    func test_saveAndFetch_project_persistsInMemory() throws {
        let project = ProjectEntity(context: sut.viewContext)
        project.id = UUID()
        project.name = "TaskFlow Launch"
        project.colorTag = "terracotta"

        try sut.saveViewContext()

        let fetched = try sut.viewContext.fetch(ProjectEntity.fetchRequest())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "TaskFlow Launch")
    }

    func test_taskProjectRelationship_isNavigableBothWays() throws {
        let project = ProjectEntity(context: sut.viewContext)
        project.id = UUID()
        project.name = "Portfolio"
        project.colorTag = "sage"

        let task = TaskEntity(context: sut.viewContext)
        task.id = UUID()
        task.title = "Ship T2"
        task.priorityRaw = "medium"
        task.syncStatusRaw = "synced"
        task.isCompleted = false
        task.lastModified = Date()
        task.project = project

        try sut.saveViewContext()

        XCTAssertEqual(task.project?.id, project.id)
        XCTAssertEqual(project.tasksArray.map(\.id), [task.id])
    }

    func test_subtasksOrderedRelationship_preservesInsertionOrder() throws {
        let task = TaskEntity(context: sut.viewContext)
        task.id = UUID()
        task.title = "Ship T2"
        task.priorityRaw = "low"
        task.syncStatusRaw = "synced"
        task.isCompleted = false
        task.lastModified = Date()

        let titles = ["Model entities", "Wrap NSPersistentContainer", "Write tests"]
        let subtasks = titles.map { title -> SubtaskEntity in
            let subtask = SubtaskEntity(context: sut.viewContext)
            subtask.id = UUID()
            subtask.title = title
            subtask.isCompleted = false
            return subtask
        }
        task.subtasks = NSOrderedSet(array: subtasks)

        try sut.saveViewContext()

        XCTAssertEqual(task.subtasksArray.map(\.title), titles)
    }
}
