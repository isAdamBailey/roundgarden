public enum ProduceFamily: String, CaseIterable, Sendable {
  case pear
  case berry
  case plum
}

public struct OddityDefinition: Equatable, Sendable {
  public let id: Int
  public let family: ProduceFamily
  public let pointValue: Int
  public let scale: Double
  public let paletteIndex: Int

  public init(id: Int, family: ProduceFamily, pointValue: Int, scale: Double, paletteIndex: Int) {
    self.id = id
    self.family = family
    self.pointValue = pointValue
    self.scale = scale
    self.paletteIndex = paletteIndex
  }
}

/// Renderer-independent starter content shared by native app targets.
public enum GardenContent {
  public static let starterOddities: [OddityDefinition] = (0..<12).map { index in
    let value = index >= 10 ? 500 : (index >= 6 ? 250 : 100)
    return OddityDefinition(
      id: index,
      family: ProduceFamily.allCases[index % ProduceFamily.allCases.count],
      pointValue: value,
      scale: value == 500 ? 1.18 : (value == 250 ? 1.04 : 0.92),
      paletteIndex: index % 6
    )
  }
}
