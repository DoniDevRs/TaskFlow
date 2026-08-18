import Core
import TaskManagement
import UIKit

/// Root of the navigation graph. Not itself a `Coordinator` (that protocol
/// is shaped for a single UINavigationController) — this owns the tab bar
/// and one UINavigationController per child coordinator.
@MainActor
final class AppCoordinator {
    let rootViewController = UITabBarController()

    private let container: Container
    private var childCoordinators: [Coordinator] = []

    init(container: Container) {
        self.container = container
    }

    func start() {
        let taskListNav = UINavigationController()
        let taskListCoordinator = TaskListCoordinator(navigationController: taskListNav, container: container)
        taskListCoordinator.start()
        taskListNav.tabBarItem = UITabBarItem(
            title: String(localized: "Tasks", bundle: TaskManagementResources.bundle),
            image: UIImage(systemName: "checklist"),
            tag: 0
        )

        let projectListNav = UINavigationController()
        let projectListCoordinator = ProjectListCoordinator(navigationController: projectListNav, container: container)
        projectListCoordinator.start()
        projectListNav.tabBarItem = UITabBarItem(
            title: String(localized: "Projects", bundle: TaskManagementResources.bundle),
            image: UIImage(systemName: "folder"),
            tag: 1
        )

        let statsNav = UINavigationController()
        let statsCoordinator = StatsCoordinator(navigationController: statsNav, container: container)
        statsCoordinator.start()
        statsNav.tabBarItem = UITabBarItem(
            title: String(localized: "Stats", bundle: TaskManagementResources.bundle),
            image: UIImage(systemName: "chart.bar.fill"),
            tag: 2
        )

        let settingsNav = UINavigationController()
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav, container: container)
        settingsCoordinator.start()
        settingsNav.tabBarItem = UITabBarItem(
            title: String(localized: "Settings", bundle: TaskManagementResources.bundle),
            image: UIImage(systemName: "gearshape"),
            tag: 3
        )

        childCoordinators = [taskListCoordinator, projectListCoordinator, statsCoordinator, settingsCoordinator]
        rootViewController.viewControllers = [taskListNav, projectListNav, statsNav, settingsNav]
    }
}
