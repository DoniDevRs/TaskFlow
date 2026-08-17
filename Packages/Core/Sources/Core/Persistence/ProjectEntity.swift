import CoreData

@objc(ProjectEntity)
public final class ProjectEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var colorTag: String
    @NSManaged public var tasks: NSSet?
}

extension ProjectEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        NSFetchRequest<ProjectEntity>(entityName: "Project")
    }

    public var tasksArray: [TaskEntity] {
        let set = tasks as? Set<TaskEntity> ?? []
        return set.sorted { $0.lastModified > $1.lastModified }
    }
}

extension ProjectEntity: Identifiable {}
