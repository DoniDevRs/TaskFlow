import SwiftUI

@main
struct TaskFlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let appCoordinator: AppCoordinator

    init() {
        let container = DIContainer.makeContainer()
        let coordinator = AppCoordinator(container: container)
        coordinator.start()
        appCoordinator = coordinator
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorHostView(coordinator: appCoordinator)
                .ignoresSafeArea()
        }
    }
}
