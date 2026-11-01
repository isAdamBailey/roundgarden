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
    let score = app.staticTexts["round-score"]
    XCTAssertTrue(score.waitForExistence(timeout: 5))
    let initialScore = score.value as? String
    target.click()
    let scoreUpdated = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "value != %@", initialScore ?? ""), object: score)
    XCTAssertTrue(
      XCTWaiter.wait(for: [scoreUpdated], timeout: 5) == .completed,
      "Activating the centered oddity should increase the score."
    )

    app.buttons["Pause"].click()
    XCTAssertTrue(app.staticTexts["Take a breath."].waitForExistence(timeout: 5))
    app.buttons["Resume"].click()
    app.buttons["Leave round"].click()
    XCTAssertTrue(app.buttons["Enter the garden"].waitForExistence(timeout: 5))
  }
}
