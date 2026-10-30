import XCTest

final class RoundgardenMacUITests: XCTestCase {
  func testAccessibleCenteredOddityActionVaporizesTarget() {
    let app = XCUIApplication()
    app.launch()

    let enterGarden = app.buttons["Enter the garden"]
    XCTAssertTrue(enterGarden.waitForExistence(timeout: 10))
    enterGarden.click()

    let startRound = app.buttons["Start 60-second round"]
    XCTAssertTrue(startRound.waitForExistence(timeout: 10))
    startRound.click()

    let target = app.buttons["aimed-garden-oddity"]
    XCTAssertTrue(target.waitForExistence(timeout: 10))
    target.click()
    let vaporizationFeedback = app.staticTexts.matching(
      NSPredicate(format: "label BEGINSWITH %@", "Vaporized into light.")
    ).firstMatch
    XCTAssertTrue(
      vaporizationFeedback.waitForExistence(timeout: 5),
      "Activating the centered oddity should award points and announce its vaporization."
    )

    app.buttons["Pause"].click()
    XCTAssertTrue(app.staticTexts["Round paused"].waitForExistence(timeout: 5))
    app.buttons["Resume"].click()
    app.buttons["Menu"].click()
    XCTAssertTrue(app.buttons["Enter the garden"].waitForExistence(timeout: 5))
  }
}
