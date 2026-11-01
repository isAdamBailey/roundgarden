import XCTest

final class RoundgardenMacUITests: XCTestCase {
  func testAccessibleCenteredOddityActionVaporizesTarget() {
    let app = XCUIApplication()
    app.launch()

    let enterGarden = app.buttons["enter-garden-button"]
    XCTAssertTrue(enterGarden.waitForExistence(timeout: 10))
    XCTAssertEqual(enterGarden.label, "Enter the garden")
    enterGarden.click()

    let startRound = app.buttons["start-round-button"]
    XCTAssertTrue(startRound.waitForExistence(timeout: 10))
    XCTAssertEqual(startRound.label, "Start 60-second round")
    startRound.click()

    let gardenView = app.descendants(matching: .any).matching(identifier: "garden-view").firstMatch
    XCTAssertTrue(gardenView.waitForExistence(timeout: 5))
    let initialDirection = gardenView.value as? String
    app.typeKey(.leftArrow, modifierFlags: [])
    let leftTurn = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "value != %@", initialDirection ?? ""), object: gardenView)
    XCTAssertEqual(XCTWaiter.wait(for: [leftTurn], timeout: 3), .completed)
    app.typeKey(.rightArrow, modifierFlags: [])
    let centeredDirection = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "value == %@", "View direction 0 degrees"), object: gardenView)
    XCTAssertEqual(XCTWaiter.wait(for: [centeredDirection], timeout: 3), .completed)

    let target = app.buttons["aimed-garden-oddity"]
    XCTAssertTrue(target.waitForExistence(timeout: 10))
    XCTAssertTrue(target.label.contains("Garden oddity worth"))
    XCTAssertTrue(target.label.contains("Activate to vaporize it into light."))
    let score = app.descendants(matching: .any).matching(identifier: "round-score").firstMatch
    XCTAssertTrue(score.waitForExistence(timeout: 5))
    XCTAssertEqual(score.label, "Score: 0 points")
    let timer = app.descendants(matching: .any).matching(identifier: "round-timer").firstMatch
    XCTAssertTrue(timer.waitForExistence(timeout: 5))
    XCTAssertTrue(timer.label.hasPrefix("Time remaining:"))
    XCTAssertTrue(timer.label.contains("seconds"))
    let initialScore = score.label
    target.click()
    let scoreUpdated = XCTNSPredicateExpectation(
      predicate: NSPredicate(format: "label != %@", initialScore), object: score)
    XCTAssertTrue(
      XCTWaiter.wait(for: [scoreUpdated], timeout: 5) == .completed,
      "Activating the centered oddity should increase the score."
    )

    app.buttons["pause-resume-button"].click()
    XCTAssertTrue(app.staticTexts["Take a breath."].waitForExistence(timeout: 5))
    app.buttons["pause-resume-button"].click()
    app.buttons["leave-round-button"].click()
    XCTAssertTrue(app.buttons["enter-garden-button"].waitForExistence(timeout: 5))
  }
}
