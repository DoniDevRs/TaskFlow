import Core
import SwiftUI
import UIKit

/// Not named in plan.md §5's coordinator list (only TaskList/ProjectList/
/// Settings are), but Stats is a first-class top-level screen (spec.md,
/// tasks.md T8) — added as a sibling for consistency with the other three.
@MainActor
public final class StatsCoordinator: Coordinator {
    public let navigationController: UINavigationController
    private let container: Container

    public init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        let viewModel = StatsViewModel(fetchStatsUseCase: container.resolve(FetchStatsUseCase.self))
        let view = StatsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = String(localized: "Stats", bundle: .module)
        navigationController.setViewControllers([hostingController], animated: false)
    }
}
