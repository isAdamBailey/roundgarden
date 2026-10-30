import XCTest

@testable import RoundgardenCore

final class RoundgardenCoreTests: XCTestCase {
  func testRoundStartsAtSixtyWithZeroScore() {
    var round = RoundState(personalBest: 250)
    round.start()

    XCTAssertEqual(round.phase, .playing)
    XCTAssertEqual(round.remainingTime, 60)
    XCTAssertEqual(round.score, 0)
    XCTAssertEqual(round.personalBest, 250)
  }

  func testPauseFreezesTimeAndResumeContinues() {
    var round = RoundState()
    round.start()
    round.advance(by: 9)
    round.pause()
    round.advance(by: 20)

    XCTAssertEqual(round.remainingTime, 51)
    round.resume()
    round.advance(by: 1)
    XCTAssertEqual(round.remainingTime, 50)
  }

  func testRoundCompletesAndRecordsPersonalBestOnlyAfterTimeRunsOut() {
    var round = RoundState(personalBest: 100)
    round.start()
    XCTAssertEqual(round.vaporize(value: 250, distance: 5), 500)
    XCTAssertEqual(round.personalBest, 100)
    round.advance(by: 60)

    XCTAssertEqual(round.phase, .complete)
    XCTAssertEqual(round.remainingTime, 0)
    XCTAssertEqual(round.personalBest, 500)
    XCTAssertNil(round.vaporize(value: 100, distance: 3))
  }

  func testProximityMatchesWebThresholds() {
    XCTAssertEqual(RoundState.proximityMultiplier(for: 12), 1)
    XCTAssertEqual(RoundState.proximityMultiplier(for: 8.5), 2)
    XCTAssertEqual(RoundState.proximityMultiplier(for: 4.2), 3)
  }

  func testMissesAndUnreachableTargetsDoNotScore() {
    var round = RoundState()
    round.start()

    XCTAssertNil(round.vaporize(value: 100, distance: 12.81))
    XCTAssertNil(round.vaporize(value: 50, distance: 5))
    XCTAssertEqual(round.score, 0)
  }

  func testTouchTapCanSelectTargetBehindDecorativeGeometry() {
    let target = AimTarget(id: 1, value: 250, position: [0, 0, -8])

    XCTAssertEqual(
      AimSelector.select(
        targets: [target], origin: .zero, direction: [0, 0, -1], maximumDistance: 12.8
      )?.target.id,
      target.id
    )
  }

  func testPointerClickUsesSameCenterAimAndIgnoresDecorativeGeometry() {
    let target = AimTarget(id: 2, value: 500, position: [0.1, 0, -7])

    XCTAssertEqual(
      AimSelector.select(
        targets: [target], origin: .zero, direction: [0, 0, -1], maximumDistance: 12.8
      )?.target.id,
      target.id
    )
  }

  func testSelectorChoosesNearestTargetAndRejectsOffAimOrOutOfRangeTargets() {
    let near = AimTarget(id: 1, value: 100, position: [0, 0, -8])
    let far = AimTarget(id: 2, value: 500, position: [0, 0, -15])
    let offAim = AimTarget(id: 3, value: 250, position: [3, 0, -6])

    XCTAssertEqual(
      AimSelector.select(
        targets: [far, offAim, near], origin: .zero, direction: [0, 0, -1], maximumDistance: 12.8
      )?.target.id,
      near.id
    )
  }

  func testStarterSetDefinesTwelveOdditiesAcrossAllPointValuesAndFamilies() {
    let starterSet = GardenContent.starterOddities

    XCTAssertEqual(starterSet.count, 12)
    XCTAssertEqual(Set(starterSet.map(\.pointValue)), [100, 250, 500])
    XCTAssertEqual(Set(starterSet.map(\.family)), Set(ProduceFamily.allCases))
    XCTAssertEqual(starterSet.filter { $0.pointValue == 500 }.count, 2)
  }
}
