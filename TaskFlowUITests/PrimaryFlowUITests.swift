import XCTest

/// End-to-end: create project -> add task -> mark complete -> stats reflect it.
final class PrimaryFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITest_ResetState"]
        app.launch()
    }

    func test_createProject_addTask_markComplete_statsReflectCompletion() throws {
        let projectName = "UITest Project \(UUID().uuidString.prefix(6))"
        let taskTitle = "UITest Task \(UUID().uuidString.prefix(6))"

        app.tabBars.buttons["Projects"].tap()
        app.buttons["Add task"].tap()

        let projectNameField = app.textFields["addProject.nameField"]
        XCTAssertTrue(projectNameField.waitForExistence(timeout: 5))
        projectNameField.tap()
        projectNameField.typeText(projectName)
        app.buttons["addProject.save"].tap()

        XCTAssertTrue(app.staticTexts[projectName].waitForExistence(timeout: 5))

        app.tabBars.buttons["Tasks"].tap()
        app.buttons["Add task"].tap()

        let titleField = app.textFields["addEditTask.titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText(taskTitle)
        app.buttons["addEditTask.save"].tap()

        XCTAssertTrue(app.staticTexts[taskTitle].waitForExistence(timeout: 5))
        let toggleButtons = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH 'taskRow.toggleCompletion.'")
        )
        XCTAssertEqual(toggleButtons.count, 1, "expected exactly one task after a fresh in-memory launch")
        toggleButtons.element(boundBy: 0).tap()

        app.tabBars.buttons["Stats"].tap()
        let completionLabel = app.staticTexts["stats.completionRateLabel"]
        XCTAssertTrue(completionLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(completionLabel.label, "100%")
    }
}
