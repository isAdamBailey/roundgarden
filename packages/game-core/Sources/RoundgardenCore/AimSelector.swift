import Foundation

public struct AimTarget: Equatable, Sendable {
  public let id: Int
  public let value: Int
  public let position: SIMD3<Double>
  public let radius: Double

  public init(id: Int, value: Int, position: SIMD3<Double>, radius: Double = 0.9) {
    self.id = id
    self.value = value
    self.position = position
    self.radius = radius
  }
}

public enum AimSelector {
  /// Selects the closest produce sphere intersected by the center aim ray.
  /// Decorative scene geometry is intentionally absent from this query.
  public static func select(
    targets: [AimTarget],
    origin: SIMD3<Double>,
    direction: SIMD3<Double>,
    maximumDistance: Double
  ) -> (target: AimTarget, distance: Double)? {
    let magnitude = sqrt(
      direction.x * direction.x + direction.y * direction.y + direction.z * direction.z)
    guard magnitude > 0 else { return nil }
    let ray = direction / magnitude

    return targets.compactMap { target -> (AimTarget, Double)? in
      let offset = target.position - origin
      let projected = offset.x * ray.x + offset.y * ray.y + offset.z * ray.z
      guard projected > 0 else { return nil }
      let perpendicularSquared = max(
        0, offset.x * offset.x + offset.y * offset.y + offset.z * offset.z - projected * projected)
      let radiusSquared = target.radius * target.radius
      guard perpendicularSquared <= radiusSquared else { return nil }
      let distance = projected - sqrt(radiusSquared - perpendicularSquared)
      guard distance <= maximumDistance else { return nil }
      return (target, distance)
    }
    .min { $0.1 < $1.1 }
  }
}
