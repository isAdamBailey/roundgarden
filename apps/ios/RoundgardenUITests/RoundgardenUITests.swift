import XCTest

final class RoundgardenUITests: XCTestCase {
  func testTouchCanStartRoundVaporizeCenteredOddityPauseAndReturnToMenu() {
    let app = XCUIApplication()
    app.launch()

    let enterGarden = app.buttons["Enter the garden"]
    XCTAssertTrue(enterGarden.waitForExistence(timeout: 10))
    enterGarden.tap()

    let startRound = app.buttons["Start 60-second round"]
    XCTAssertTrue(startRound.waitForExistence(timeout: 10))
    startRound.tap()

    let score = app.staticTexts["round-score"]
    XCTAssertTrue(score.waitForExistence(timeout: 10))
    let initialScore = score.value as? String
    app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    let scoreChanged = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "value != %@", initialScore ?? ""), object: score)
    XCTAssertEqual(XCTWaiter.wait(for: [scoreChanged], timeout: 3), .completed)

    let screenshot = XCTAttachment(screenshot: app.screenshot())
    screenshot.name = "Roundgarden playable garden"
    screenshot.lifetime = .keepAlways
    add(screenshot)

    app.buttons["Pause"].tap()
    XCTAssertTrue(app.staticTexts["Round paused"].waitForExistence(timeout: 5))
    app.buttons["Resume"].tap()
    XCUIDevice.shared.orientation = .landscapeLeft
    waitForOrientation(app, landscape: true)
    app.buttons["Menu"].tap()
    XCTAssertTrue(app.buttons["Enter the garden"].waitForExistence(timeout: 5))
  }

  private func waitForOrientation(_ app: XCUIApplication, landscape: Bool) {
    let window = app.windows.firstMatch
    let sizeMatchesOrientation = NSPredicate { _, _ in
      landscape
        ? window.frame.width > window.frame.height : window.frame.height > window.frame.width
    }
    let orientation = XCTNSPredicateExpectation(predicate: sizeMatchesOrientation, object: window)
    XCTAssertEqual(XCTWaiter.wait(for: [orientation], timeout: 5), .completed)
  }
}
