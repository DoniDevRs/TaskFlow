import CoreData

/// Abstraction over the Core Data stack so callers (and tests) never touch
/// NSPersistentContainer directly — keeps the Data layer's repositories
/// mockable without spinning up a real store.
public protocol PersistenceControlling {
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func saveViewContext() throws
}
