/// Interface only — implemented by SyncActor in the Data layer (T6), so
/// ViewModels depend on this protocol rather than the concrete sync engine.
public protocol SyncTasksUseCase {
    func execute() async throws -> SyncResult
}
