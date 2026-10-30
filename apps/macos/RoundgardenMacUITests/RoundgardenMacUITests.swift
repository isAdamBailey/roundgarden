import XCTest

final class RoundgardenMacUITests: XCTestCase {
  func testPointerClickStartsRoundAndVaporizesCenteredOddity() {
    let app = XCUIApplication()
    app.launch()

    let enterGarden = app.buttons["Enter the garden"]
    XCTAssertTrue(enterGarden.waitForExistence(timeout: 10))
    enterGarden.click()

    let startRound = app.buttons["Start 60-second round"]
    XCTAssertTrue(startRound.waitForExistence(timeout: 10))
    startRound.click()

    let score = app.staticTexts["round-score"]
    XCTAssertTrue(score.waitForExistence(timeout: 10))
    let initialScore = score.label
    app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).click()
    let scoreChanged = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "label != %@", initialScore), object: score)
    XCTAssertEqual(XCTWaiter.wait(for: [scoreChanged], timeout: 3), .completed)

    app.buttons["Pause"].click()
    XCTAssertTrue(app.staticTexts["Round paused"].waitForExistence(timeout: 5))
    app.buttons["Resume"].click()
    app.buttons["Menu"].click()
    XCTAssertTrue(app.buttons["Enter the garden"].waitForExistence(timeout: 5))
  }
}
