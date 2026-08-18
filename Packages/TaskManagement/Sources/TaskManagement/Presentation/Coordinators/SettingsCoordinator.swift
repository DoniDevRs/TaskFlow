import Core
import SwiftUI
import UIKit

@MainActor
public final class SettingsCoordinator: Coordinator {
    public let navigationController: UINavigationController
    private let container: Container

    public init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }

    public func start() {
        let viewModel = SettingsViewModel(
            biometricAuthenticator: container.resolve(BiometricAuthenticating.self),
            keychain: container.resolve(KeychainStoring.self)
        )
        let view = SettingsView(
            viewModel: viewModel,
            onSyncNow: { [weak self] in self?.triggerSync() }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = String(localized: "Settings", bundle: .module)
        navigationController.setViewControllers([hostingController], animated: false)
    }

    private func triggerSync() {
        let syncUseCase = container.resolve(SyncTasksUseCase.self)
        Task {
            _ = try? await syncUseCase.execute()
        }
    }
}
