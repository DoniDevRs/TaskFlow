import UIKit

/// Entry point for AppCoordinator wiring (T9) — SwiftUI's App protocol has no
/// applicationDidFinishLaunching hook, so this bridges to one for coordinators.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        true
    }
}
