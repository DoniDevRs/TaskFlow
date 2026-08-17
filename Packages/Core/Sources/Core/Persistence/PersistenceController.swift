import CoreData

public final class PersistenceController: PersistenceControlling {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskFlow", managedObjectModel: Self.model)

        if inMemory {
            container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        }

        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Failed to load Core Data store \(description): \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    public func saveViewContext() throws {
        guard viewContext.hasChanges else { return }
        try viewContext.save()
    }

    /// Explicit load, not name-inference — entities use manual codegen (TaskEntity.swift etc).
    private static let model: NSManagedObjectModel = {
        guard
            let url = Bundle.module.url(forResource: "TaskFlow", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Failed to locate TaskFlow.momd in Core's resource bundle")
        }
        return model
    }()
}
