import XCTest

final class RoundgardenUITests: XCTestCase {
  func testTouchCanStartRoundVaporizeCenteredOddityPauseAndReturnToMenu() {
    let app = XCUIApplication()
    app.launch()

    let enterGarden = app.buttons["enter-garden-button"]
    XCTAssertTrue(enterGarden.waitForExistence(timeout: 10))
    XCTAssertEqual(enterGarden.label, "Enter the garden")
    enterGarden.tap()

    let startRound = app.buttons["start-round-button"]
    XCTAssertTrue(startRound.waitForExistence(timeout: 10))
    XCTAssertEqual(startRound.label, "Start 60-second round")
    startRound.tap()

    let score = app.descendants(matching: .any).matching(identifier: "round-score").firstMatch
    XCTAssertTrue(score.waitForExistence(timeout: 10))
    XCTAssertEqual(score.label, "Score")
    XCTAssertEqual(score.value as? String, "0 points")
    let timer = app.descendants(matching: .any).matching(identifier: "round-timer").firstMatch
    XCTAssertTrue(timer.waitForExistence(timeout: 5))
    XCTAssertEqual(timer.label, "Time remaining")
    XCTAssertTrue((timer.value as? String)?.contains("seconds") == true)

    let target = app.buttons["aimed-garden-oddity"]
    XCTAssertTrue(target.waitForExistence(timeout: 10))
    XCTAssertTrue(target.label.contains("Garden oddity worth"))
    XCTAssertTrue(target.label.contains("Activate to vaporize it into light."))
    let initialScore = score.value as? String
    target.tap()
    let scoreChanged = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "value != %@", initialScore ?? ""), object: score)
    XCTAssertEqual(XCTWaiter.wait(for: [scoreChanged], timeout: 3), .completed)
    let feedback = app.staticTexts["vaporize-feedback"]
    XCTAssertTrue(feedback.waitForExistence(timeout: 5))
    XCTAssertTrue(feedback.label.contains("Vaporized into light"))

    let screenshot = XCTAttachment(screenshot: app.screenshot())
    screenshot.name = "Roundgarden playable garden"
    screenshot.lifetime = .keepAlways
    add(screenshot)

    app.buttons["pause-resume-button"].tap()
    XCTAssertTrue(app.staticTexts["Take a breath."].waitForExistence(timeout: 5))
    app.buttons["pause-resume-button"].tap()
    XCUIDevice.shared.orientation = .landscapeLeft
    waitForOrientation(app, landscape: true)
    app.buttons["leave-round-button"].tap()
    XCTAssertTrue(app.buttons["enter-garden-button"].waitForExistence(timeout: 5))
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
