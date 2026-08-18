import Core
import Foundation
import TaskManagement

/// Composition root — the only place concrete implementations get wired
/// against protocols. Coordinators and ViewModels only ever resolve.
enum DIContainer {
    static func makeContainer() -> Container {
        let container = Container()

        container.register(PersistenceControlling.self, scope: .singleton) {
            PersistenceController.shared
        }

        container.register(APIClient.self, scope: .singleton) {
            URLSessionAPIClient(baseURL: URL(string: "https://dummyjson.com")!)
        }
        container.register(DummyJSONTodosServicing.self, scope: .singleton) {
            DummyJSONTodosService(client: container.resolve(APIClient.self))
        }
        container.register(RemoteTaskDataSource.self, scope: .singleton) {
            DummyJSONTaskDataSource(service: container.resolve(DummyJSONTodosServicing.self))
        }

        // CoreDataTaskRepository conforms to both TaskRepository and
        // TaskSyncMetadataStore — registering the concrete singleton once
        // and having both protocol registrations resolve through it keeps
        // SyncActor's bookkeeping and the ViewModels' CRUD on the same store.
        container.register(CoreDataTaskRepository.self, scope: .singleton) {
            CoreDataTaskRepository(persistence: container.resolve(PersistenceControlling.self))
        }
        container.register(TaskRepository.self, scope: .singleton) {
            container.resolve(CoreDataTaskRepository.self)
        }
        container.register(TaskSyncMetadataStore.self, scope: .singleton) {
            container.resolve(CoreDataTaskRepository.self)
        }
        container.register(ProjectRepository.self, scope: .singleton) {
            CoreDataProjectRepository(persistence: container.resolve(PersistenceControlling.self))
        }

        container.register(SyncTasksUseCase.self, scope: .singleton) {
            SyncActor(
                taskRepository: container.resolve(TaskRepository.self),
                syncMetadataStore: container.resolve(TaskSyncMetadataStore.self),
                remoteDataSource: container.resolve(RemoteTaskDataSource.self)
            )
        }

        container.register(KeychainStoring.self, scope: .singleton) {
            KeychainStore()
        }
        container.register(BiometricAuthenticating.self, scope: .singleton) {
            BiometricAuthenticator()
        }

        container.register(CreateTaskUseCase.self) {
            CreateTaskUseCase(repository: container.resolve(TaskRepository.self))
        }
        container.register(UpdateTaskUseCase.self) {
            UpdateTaskUseCase(repository: container.resolve(TaskRepository.self))
        }
        container.register(DeleteTaskUseCase.self) {
            DeleteTaskUseCase(repository: container.resolve(TaskRepository.self))
        }
        container.register(ToggleTaskCompletionUseCase.self) {
            ToggleTaskCompletionUseCase(repository: container.resolve(TaskRepository.self))
        }
        container.register(CreateProjectUseCase.self) {
            CreateProjectUseCase(repository: container.resolve(ProjectRepository.self))
        }
        container.register(SearchTasksUseCase.self) {
            SearchTasksUseCase(repository: container.resolve(TaskRepository.self))
        }
        container.register(FetchStatsUseCase.self) {
            FetchStatsUseCase(repository: container.resolve(TaskRepository.self))
        }

        return container
    }
}
