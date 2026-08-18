import SwiftUI
import UIKit

/// Bridges AppCoordinator's UIKit tab bar root into SwiftUI's WindowGroup,
/// so navigation stays UIKit-coordinator-owned (plan.md §5) without needing
/// a custom UIWindowSceneDelegate under the SwiftUI App lifecycle.
struct AppCoordinatorHostView: UIViewControllerRepresentable {
    let coordinator: AppCoordinator

    func makeUIViewController(context: Context) -> UIViewController {
        coordinator.rootViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
