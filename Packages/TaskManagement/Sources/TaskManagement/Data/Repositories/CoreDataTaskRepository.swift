import Core
import CoreData
import Foundation

public final class CoreDataTaskRepository: TaskRepository {
    /// Internal, not private — CoreDataTaskRepository+SyncMetadata.swift needs it.
    let persistence: PersistenceControlling

    public init(persistence: PersistenceControlling) {
        self.persistence = persistence
    }

    public func fetchAll() async throws -> [TodoItem] {
        let context = persistence.viewContext
        return try await context.perform {
            try context.fetch(TaskEntity.fetchRequest()).map { $0.toDomain() }
        }
    }

    public func fetch(id: UUID) async throws -> TodoItem? {
        let context = persistence.viewContext
        return try await context.perform {
            try Self.findEntity(id: id, in: context)?.toDomain()
        }
    }

    public func create(_ task: TodoItem) async throws -> TodoItem {
        let context = persistence.viewContext
        return try await context.perform {
            let entity = TaskEntity(context: context)
            let projectEntity = try task.projectID.flatMap { try Self.findProjectEntity(id: $0, in: context) }
            entity.apply(from: task, projectEntity: projectEntity, in: context)
            try context.save()
            return entity.toDomain()
        }
    }

    public func update(_ task: TodoItem) async throws -> TodoItem {
        let context = persistence.viewContext
        return try await context.perform {
            guard let entity = try Self.findEntity(id: task.id, in: context) else {
                throw TaskUseCaseError.taskNotFound
            }
            let projectEntity = try task.projectID.flatMap { try Self.findProjectEntity(id: $0, in: context) }
            entity.apply(from: task, projectEntity: projectEntity, in: context)
            try context.save()
            return entity.toDomain()
        }
    }

    public func delete(id: UUID) async throws {
        let context = persistence.viewContext
        try await context.perform {
            guard let entity = try Self.findEntity(id: id, in: context) else { return }
            context.delete(entity)
            try context.save()
        }
    }

    static func findEntity(id: UUID, in context: NSManagedObjectContext) throws -> TaskEntity? {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private static func findProjectEntity(id: UUID, in context: NSManagedObjectContext) throws -> ProjectEntity? {
        let request = ProjectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
