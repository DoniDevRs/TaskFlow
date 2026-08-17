import Core
import CoreData
import Foundation

extension TaskEntity {
    func toDomain() -> TodoItem {
        TodoItem(
            id: id,
            title: title,
            description: taskDescription,
            dueDate: dueDate,
            priority: Priority(rawValue: priorityRaw) ?? .medium,
            tags: tagsArray,
            projectID: project?.id,
            subtasks: subtasksArray.map { $0.toDomain() },
            isCompleted: isCompleted,
            syncStatus: SyncStatus(rawValue: syncStatusRaw) ?? .pending,
            lastModified: lastModified
        )
    }

    /// Replaces subtasks wholesale — they have no identity outside their parent task.
    func apply(from task: TodoItem, projectEntity: ProjectEntity?, in context: NSManagedObjectContext) {
        id = task.id
        title = task.title
        taskDescription = task.description
        dueDate = task.dueDate
        priorityRaw = task.priority.rawValue
        syncStatusRaw = task.syncStatus.rawValue
        isCompleted = task.isCompleted
        lastModified = task.lastModified
        tags = task.tags as NSArray
        project = projectEntity

        let existingByID = Dictionary(uniqueKeysWithValues: subtasksArray.map { ($0.id, $0) })
        let updatedEntities: [SubtaskEntity] = task.subtasks.map { subtask in
            if let existing = existingByID[subtask.id] {
                existing.title = subtask.title
                existing.isCompleted = subtask.isCompleted
                return existing
            } else {
                let entity = SubtaskEntity(context: context)
                entity.id = subtask.id
                entity.title = subtask.title
                entity.isCompleted = subtask.isCompleted
                return entity
            }
        }
        subtasks = NSOrderedSet(array: updatedEntities)
    }
}

extension SubtaskEntity {
    func toDomain() -> Subtask {
        Subtask(id: id, title: title, isCompleted: isCompleted)
    }
}
