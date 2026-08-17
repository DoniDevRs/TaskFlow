import CoreData

@objc(TaskEntity)
public final class TaskEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var priorityRaw: String
    @NSManaged public var syncStatusRaw: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var lastModified: Date
    /// Sync bookkeeping only — never exposed through TaskRepository or TodoItem.
    @NSManaged public var lastSyncedAt: Date?
    @NSManaged public var remoteID: NSNumber?
    @NSManaged public var tags: NSArray?
    @NSManaged public var project: ProjectEntity?
    @NSManaged public var subtasks: NSOrderedSet?
}

extension TaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "Task")
    }

    public var subtasksArray: [SubtaskEntity] {
        (subtasks?.array as? [SubtaskEntity]) ?? []
    }

    public var tagsArray: [String] {
        (tags as? [String]) ?? []
    }
}

extension TaskEntity: Identifiable {}
