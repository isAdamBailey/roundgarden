import Foundation

public enum RoundPhase: Equatable, Sendable {
  case ready
  case playing
  case paused
  case complete
}

public struct RoundState: Equatable, Sendable {
  public static let duration: TimeInterval = 60
  public static let maximumTargetDistance = 12.8

  public private(set) var phase: RoundPhase = .ready
  public private(set) var remainingTime = duration
  public private(set) var elapsedTime: TimeInterval = 0
  public private(set) var score = 0
  public private(set) var personalBest: Int

  public init(personalBest: Int = 0) {
    self.personalBest = personalBest
  }

  public mutating func start() {
    remainingTime = Self.duration
    elapsedTime = 0
    score = 0
    phase = .playing
  }

  public mutating func pause() {
    guard phase == .playing else { return }
    phase = .paused
  }

  public mutating func resume() {
    guard phase == .paused else { return }
    phase = .playing
  }

  public mutating func leave() {
    phase = .ready
    remainingTime = Self.duration
    elapsedTime = 0
    score = 0
  }

  public mutating func advance(by seconds: TimeInterval) {
    guard phase == .playing, seconds > 0 else { return }
    elapsedTime += seconds
    remainingTime = max(0, remainingTime - seconds)
    guard remainingTime == 0 else { return }
    phase = .complete
    personalBest = max(personalBest, score)
  }

  @discardableResult
  public mutating func vaporize(value: Int, distance: Double) -> Int? {
    guard phase == .playing, [100, 250, 500].contains(value),
      (0...Self.maximumTargetDistance).contains(distance)
    else {
      return nil
    }
    let points = value * Self.proximityMultiplier(for: distance)
    score += points
    return points
  }

  public static func proximityMultiplier(for distance: Double) -> Int {
    if distance <= 4.2 { return 3 }
    if distance <= 8.5 { return 2 }
    return 1
  }
}
