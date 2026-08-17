import Core
import CoreData
import Foundation

public final class CoreDataProjectRepository: ProjectRepository {
    private let persistence: PersistenceControlling

    public init(persistence: PersistenceControlling) {
        self.persistence = persistence
    }

    public func fetchAll() async throws -> [Project] {
        let context = persistence.viewContext
        return try await context.perform {
            try context.fetch(ProjectEntity.fetchRequest()).map { $0.toDomain() }
        }
    }

    public func fetch(id: UUID) async throws -> Project? {
        let context = persistence.viewContext
        return try await context.perform {
            try Self.findEntity(id: id, in: context)?.toDomain()
        }
    }

    public func create(_ project: Project) async throws -> Project {
        let context = persistence.viewContext
        return try await context.perform {
            let entity = ProjectEntity(context: context)
            entity.apply(from: project)
            try context.save()
            return entity.toDomain()
        }
    }

    public func update(_ project: Project) async throws -> Project {
        let context = persistence.viewContext
        return try await context.perform {
            guard let entity = try Self.findEntity(id: project.id, in: context) else {
                throw ProjectUseCaseError.projectNotFound
            }
            entity.apply(from: project)
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

    private static func findEntity(id: UUID, in context: NSManagedObjectContext) throws -> ProjectEntity? {
        let request = ProjectEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
