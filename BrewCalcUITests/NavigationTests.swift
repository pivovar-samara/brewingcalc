import XCTest

@MainActor
final class NavigationTests: XCTestCase {
    var app: XCUIApplication!

    // XCTestCase.setUpWithError() is nonisolated in the SDK, so it cannot be
    // overridden from a @MainActor class without an isolation mismatch. All
    // XCUIAutomation APIs are @MainActor (XCUI_SWIFT_MAIN_ACTOR at class level),
    // so the class must be @MainActor. setUp() is called from each test instead.
    private func launchApp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCalculatorListDisplays() throws {
        launchApp()
        // The sidebar/master list should show calculator categories
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
    }

    func testAboutSheetPresents() throws {
        launchApp()
        // Tap the About button
        let aboutButton = app.buttons["About"]
        if aboutButton.exists {
            aboutButton.tap()
            // About view should be presented
            let closeButton = app.buttons["Close"]
            XCTAssertTrue(closeButton.waitForExistence(timeout: 2))
            closeButton.tap()
        }
    }

    func testSelectCalculatorCategory() throws {
        launchApp()
        // Tap on the first calculator category
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            // Should show detail view
            XCTAssertTrue(app.navigationBars.count >= 1)
        }
    }
}
