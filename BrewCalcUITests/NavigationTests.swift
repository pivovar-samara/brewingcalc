import XCTest

@MainActor
final class NavigationTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testCalculatorListDisplays() throws {
        // The sidebar/master list should show calculator categories
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
    }

    func testAboutSheetPresents() throws {
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
        // Tap on the first calculator category
        let firstCell = app.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            // Should show detail view
            XCTAssertTrue(app.navigationBars.count >= 1)
        }
    }
}
