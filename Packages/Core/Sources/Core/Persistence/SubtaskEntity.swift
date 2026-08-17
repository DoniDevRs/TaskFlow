import CoreData

@objc(SubtaskEntity)
public final class SubtaskEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var isCompleted: Bool
    @NSManaged public var task: TaskEntity?
}

extension SubtaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubtaskEntity> {
        NSFetchRequest<SubtaskEntity>(entityName: "Subtask")
    }
}

extension SubtaskEntity: Identifiable {}
