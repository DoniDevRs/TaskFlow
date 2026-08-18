import XCTest

/// Standalone from PrimaryFlowUITests by design (tasks.md T10) — fails the
/// build on any finding rather than just reporting, so findings get fixed,
/// not silently tolerated.
final class AccessibilityAuditUITests: XCTestCase {
    func test_allTabs_passAccessibilityAudit() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-UITest_ResetState"]
        app.launch()

        try app.performAccessibilityAudit()

        app.tabBars.buttons["Projects"].tap()
        try app.performAccessibilityAudit()

        app.tabBars.buttons["Stats"].tap()
        try app.performAccessibilityAudit()

        app.tabBars.buttons["Settings"].tap()
        try app.performAccessibilityAudit()
    }
}
