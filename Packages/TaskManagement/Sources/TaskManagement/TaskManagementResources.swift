import Foundation

/// Lets the App target (which has no direct access to this package's
/// Bundle.module) localize strings against this package's own catalog —
/// used for the tab bar item titles set in TaskFlow/AppCoordinator.swift.
public enum TaskManagementResources {
    public static let bundle = Bundle.module
}
