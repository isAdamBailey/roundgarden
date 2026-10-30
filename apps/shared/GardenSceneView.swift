import RealityKit
import RoundgardenCore
import SwiftUI
import simd

#if os(iOS)
  import UIKit
  typealias PlatformColor = UIColor
#else
  import AppKit
  typealias PlatformColor = NSColor
#endif

struct GardenSceneView: View {
  let round: RoundState
  let onVaporize: (Int, Double) -> Void
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.colorSchemeContrast) private var colorContrast
  @State private var yaw = 0.0
  @State private var pitch = 0.0
  @State private var lastDragTranslation = CGSize.zero
  @State private var vaporizedTargetIDs: Set<Int> = []
  #if os(macOS)
    @FocusState private var gardenHasFocus: Bool
  #endif

  private var aimDirection: SIMD3<Double> {
    let horizontal = cos(pitch)
    return [-sin(yaw) * horizontal, -sin(pitch), -cos(yaw) * horizontal]
  }

  private var aimedTarget: (target: AimTarget, distance: Double)? {
    AimSelector.select(
      targets: targets,
      origin: .zero,
      direction: aimDirection,
      maximumDistance: RoundState.maximumTargetDistance
    )
  }

  private var targets: [AimTarget] {
    (0..<12).map { index in
      let distance = produceDistance(index: index, elapsed: sceneElapsedTime)
      let direction = produceDirection(index: index)
      let wobble = sin(round.elapsedTime * 1.7 + Double(index) * 1.6) * 0.32
      let position = direction * distance + SIMD3<Double>(wobble, wobble * 0.65, 0)
      let definition = GardenContent.starterOddities[index]
      return AimTarget(
        id: definition.id, value: definition.pointValue, position: position,
        radius: 1.15 * definition.scale)
    }
  }

  private var sceneElapsedTime: Double {
    reduceMotion ? 0 : round.elapsedTime
  }

  var body: some View {
    GeometryReader { viewport in
      let uiScale = min(1.55, max(0.9, viewport.size.width / 430))
      ZStack {
        TimelineView(
          .animation(
            minimumInterval: 1.0 / 30.0,
            paused: reduceMotion || round.phase == .paused || round.phase == .complete)
        ) { timeline in
          RealityView { content in
            content.add(makeGarden())
          } update: { content in
            guard
              let camera = content.entities.first?.findEntity(named: "spike-camera")
                as? PerspectiveCamera
            else { return }
            let radius: Float = 0.08
            let y = Float(pitch)
            let horizontal = sqrt(max(0.01, 1 - y * y))
            camera.position = [
              Float(sin(yaw)) * horizontal * radius, y * radius,
              Float(cos(yaw)) * horizontal * radius,
            ]
            camera.look(at: .zero, from: camera.position, relativeTo: nil)
            for index in 0..<12 {
              let name = "oddity-\(index)"
              guard let produce = content.entities.first?.findEntity(named: name) else { continue }
              produce.isEnabled = !vaporizedTargetIDs.contains(index)
              let position = targets[index].position
              let distance = simd_length(position)
              produce.position = SIMD3<Float>(
                Float(position.x), Float(position.y), Float(position.z))
              produce.look(at: .zero, from: produce.position, relativeTo: nil)
              if let skinDetail = content.entities.first?.findEntity(
                named: "produce-detail-\(index)")
              {
                skinDetail.isEnabled = distance < 19
              }
              if let innerGlow = content.entities.first?.findEntity(named: "produce-glow-\(index)")
              {
                innerGlow.isEnabled = distance < 12
              }
              let pulse =
                1 + sin(Float(timeline.date.timeIntervalSinceReferenceDate) * 2 + Float(index))
                * 0.045
              produce.scale = SIMD3<Float>(repeating: pulse)
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(cameraDragGesture)
        #if os(iOS)
          .ignoresSafeArea()
        #endif

        Color.clear
          .contentShape(Rectangle())
          .accessibilityElement()
          .accessibilityLabel("Garden view")
          #if os(macOS)
            .accessibilityHint(
              "Drag to look. Use arrow keys to turn. Click a centered oddity to vaporize it."
            )
            .focusable()
            .focused($gardenHasFocus)
            .onKeyPress(.leftArrow) {
              yaw += 0.08
              return .handled
            }
            .onKeyPress(.rightArrow) {
              yaw -= 0.08
              return .handled
            }
            .onKeyPress(.upArrow) {
              pitch = min(0.94, pitch + 0.08)
              return .handled
            }
            .onKeyPress(.downArrow) {
              pitch = max(-0.94, pitch - 0.08)
              return .handled
            }
          #else
            .accessibilityHint(
              "Drag to look around. When an oddity is centered, tap to vaporize it.")
          #endif
          .accessibilityAction(.default) {
            vaporizeAimedTarget()
          }
          .accessibilityAction(named: Text("Vaporize centered oddity")) {
            vaporizeAimedTarget()
          }
          .allowsHitTesting(false)

        ZStack {
          Circle().stroke(
            Color(red: 0.84, green: 0.96, blue: 0.79)
              .opacity(colorContrast == .increased ? 0.98 : 0.66),
            lineWidth: 0.8 * uiScale
          ).frame(width: 27 * uiScale, height: 27 * uiScale)
          Circle().fill(Color(red: 0.9, green: 1, blue: 0.79)).frame(
            width: 3 * uiScale, height: 3 * uiScale)
          Rectangle().fill(.white.opacity(0.58)).frame(width: 1 * uiScale, height: 4 * uiScale)
            .offset(y: -17 * uiScale)
          Rectangle().fill(.white.opacity(0.58)).frame(width: 1 * uiScale, height: 4 * uiScale)
            .offset(y: 17 * uiScale)
          Rectangle().fill(.white.opacity(0.58)).frame(width: 4 * uiScale, height: 1 * uiScale)
            .offset(x: -17 * uiScale)
          Rectangle().fill(.white.opacity(0.58)).frame(width: 4 * uiScale, height: 1 * uiScale)
            .offset(x: 17 * uiScale)
        }
        .allowsHitTesting(false)

        if let aimedTarget, round.phase == .playing {
          Button(action: vaporizeAimedTarget) {
            Text(
              "\(aimedTarget.target.value) POINTS  ·  ×\(RoundState.proximityMultiplier(for: aimedTarget.distance))"
            )
            .font(.system(size: 12 * uiScale, weight: .semibold, design: .rounded))
            .tracking(0.8 * uiScale)
            .foregroundStyle(Color(red: 0.91, green: 0.96, blue: 0.83))
            .padding(.horizontal, 12 * uiScale)
            .padding(.vertical, 8 * uiScale)
            .background(.black.opacity(0.4), in: Capsule())
          }
          .buttonStyle(.plain)
          .position(x: viewport.size.width / 2, y: viewport.size.height * 0.58)
          .accessibilityLabel(
            Text(
              "Garden oddity worth \(aimedTarget.target.value) points, \(RoundState.proximityMultiplier(for: aimedTarget.distance)) times proximity multiplier. Activate to vaporize it into light."
            )
          )
          .accessibilityAddTraits(.updatesFrequently)
          .accessibilityIdentifier("aimed-garden-oddity")
        }
      }
      .frame(width: viewport.size.width, height: viewport.size.height)
      .background(
        Color(red: 0.012, green: 0.032, blue: 0.031)
          #if os(iOS)
            .ignoresSafeArea()
          #endif
      )
      .preferredColorScheme(.dark)
    }
    #if os(iOS)
      .ignoresSafeArea()
    #endif
  }

  private var cameraDragGesture: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        let delta = CGSize(
          width: value.translation.width - lastDragTranslation.width,
          height: value.translation.height - lastDragTranslation.height
        )
        lastDragTranslation = value.translation
        yaw -= delta.width * 0.004
        pitch = min(0.94, max(-0.94, pitch - delta.height * 0.004))
      }
      .onEnded { value in
        if hypot(value.translation.width, value.translation.height) < 8 {
          vaporizeAimedTarget()
        }
        lastDragTranslation = .zero
      }
  }

  private func vaporizeAimedTarget() {
    guard round.phase == .playing, let hit = aimedTarget else { return }
    vaporizedTargetIDs.insert(hit.target.id)
    onVaporize(hit.target.value, hit.distance)
    Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(700))
      vaporizedTargetIDs.remove(hit.target.id)
    }
  }

  private func produceDirection(index: Int) -> SIMD3<Double> {
    if index == 0 { return SIMD3<Double>(0.018, 0.012, -1) / sqrt(1.000468) }
    let sample = Double(index - 1)
    let y = 1 - 2 * (sample + 0.5) / 11
    let angle = sample * 2.399963
    let ring = sqrt(max(0, 1 - y * y))
    return SIMD3<Double>(cos(angle) * ring, y, sin(angle) * ring)
  }

  private func produceDistance(index: Int, elapsed: Double) -> Double {
    let startDistance = index == 0 ? 10.5 : 28 + Double(index % 4) * 2.8
    let speed = index == 0 ? 0.22 : 0.38 + Double(index % 3) * 0.035
    let cycleLength = startDistance - 4.5
    let traveled = elapsed * speed
    return startDistance - traveled.truncatingRemainder(dividingBy: cycleLength)
  }

  private func makeGarden() -> Entity {
    let root = Entity()
    root.name = "garden-root"
    let camera = PerspectiveCamera()
    camera.name = "spike-camera"
    camera.camera.fieldOfViewInDegrees = 74
    root.addChild(camera)

    // Keep a continuous, quiet garden color behind the segmented gradient
    // dome so portrait, landscape, and resized Mac windows never show black.
    var backdropMaterial = UnlitMaterial(
      color: PlatformColor(red: 0.012, green: 0.035, blue: 0.032, alpha: 1))
    backdropMaterial.faceCulling = .none
    let backdrop = ModelEntity(mesh: .generateSphere(radius: 59), materials: [backdropMaterial])
    backdrop.name = "garden-backdrop"
    root.addChild(backdrop)
    root.addChild(makeGardenDome())

    // Match the web renderer's nearly invisible greenhouse shell while keeping
    // its opaque shader-like garden backdrop behind it.
    var greenhouseMaterial = SimpleMaterial(
      color: PlatformColor(red: 0.84, green: 0.90, blue: 0.68, alpha: 0.035), roughness: 0.58,
      isMetallic: false)
    greenhouseMaterial.faceCulling = .front
    greenhouseMaterial.readsDepth = false
    greenhouseMaterial.writesDepth = false
    let greenhouse = ModelEntity(
      mesh: .generateSphere(radius: 57.2),
      materials: [greenhouseMaterial]
    )
    greenhouse.name = "greenhouse-cue"
    root.addChild(greenhouse)
    addGreenhouseRibs(to: root)

    let key = DirectionalLight()
    key.light.intensity = 1800
    key.light.color = .init(red: 1, green: 0.91, blue: 0.70, alpha: 1)
    key.components.set(DirectionalLightComponent.Shadow())
    key.position = [-12, 19, 8]
    key.look(at: .zero, from: key.position, relativeTo: nil)
    root.addChild(key)

    let fill = PointLight()
    fill.light.intensity = 600
    fill.light.attenuationRadius = 30
    fill.light.color = .init(red: 1, green: 0.73, blue: 0.48, alpha: 1)
    fill.position = [5, -3, -6]
    root.addChild(fill)

    let ambience = PointLight()
    ambience.light.intensity = 1000
    ambience.light.attenuationRadius = 62
    ambience.light.color = .init(red: 1, green: 0.94, blue: 0.79, alpha: 1)
    ambience.position = [0, 0, 0]
    root.addChild(ambience)

    // Fibonacci-distributed growth fills the same spherical shell as the web scene.
    let leafMeshes = (0..<3).map { makeLeafMesh(shape: $0) }
    let palette = (0..<9).map { index in
      SimpleMaterial(color: leafColor(index), roughness: 0.74, isMetallic: false)
    }
    let canInstance: Bool
    if #available(iOS 26.0, macOS 26.0, *) {
      canInstance = true
    } else {
      canInstance = false
    }
    let plantCount = canInstance ? 900 : 180
    var leafInstances = leafMeshes.map { _ in Array(repeating: [Transform](), count: palette.count)
    }
    var veinInstances: [Transform] = []
    var branchVeinInstances: [Transform] = []
    var stemInstances: [Transform] = []
    var branchInstances: [Transform] = []
    var flowerInstances = Array(repeating: [Transform](), count: 4)
    var flowerCoreInstances: [Transform] = []
    var woodyInstances: [Transform] = []
    var vineInstances: [Transform] = []
    for i in 0..<plantCount {
      let u = Float(i) * 2.399963
      let y = 1 - (Float(i) + 0.5) * 2 / Float(plantCount)
      let r = sqrt(max(0, 1 - y * y))
      let normal = SIMD3<Float>(cos(u) * r, y, sin(u) * r)
      let shellRadius: Float =
        i % 5 == 0
        ? 20 + randomUnit(i * 17 + 4) * 9
        : 31 + randomUnit(i * 17 + 5) * 21
      let clusterPosition = normal * shellRadius
      let clusterOrientation = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: -normal)
      let bend = Float((i * 17) % 19) / 18 - 0.5
      for segment in 0..<6 {
        let start = plantPoint(Float(segment) / 6, bend: bend)
        let end = plantPoint(Float(segment + 1) / 6, bend: bend)
        let delta = end - start
        let localRotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
        stemInstances.append(
          Transform(
            scale: [1, simd_length(delta), 1],
            rotation: clusterOrientation * localRotation,
            translation: clusterPosition + clusterOrientation.act((start + end) * 0.5)
          ))
      }
      for leafIndex in 0..<8 {
        let side: Float = leafIndex.isMultiple(of: 2) ? -1 : 1
        let t = 0.12 + Float(leafIndex) * 0.105
        let center = plantPoint(t, bend: bend)
        let localPosition = center + SIMD3<Float>(side * 0.18, 0, 0.04)
        let localRotation = simd_quatf(
          angle: side * (0.72 + Float((i + leafIndex) % 5) * 0.13), axis: [0, 0, 1])
        let size = 1.35 + Float((i * 11 + leafIndex * 7) % 14) * 0.10
        let worldRotation = clusterOrientation * localRotation
        let worldPosition = clusterPosition + clusterOrientation.act(localPosition)
        let leafShape = (i + leafIndex * 2) % leafMeshes.count
        let colorIndex = foliageColorIndex(plant: i, leaf: leafIndex)
        leafInstances[leafShape][colorIndex].append(
          Transform(
            scale: [size, size * 1.12, size],
            rotation: worldRotation,
            translation: worldPosition
          ))
        veinInstances.append(
          Transform(
            scale: [1, size * 0.66, 1],
            rotation: worldRotation,
            translation: worldPosition + worldRotation.act(SIMD3<Float>(0, 0, size * 0.13))
          ))
        if i.isMultiple(of: 3), leafIndex.isMultiple(of: 2) {
          let along: Float = leafIndex.isMultiple(of: 4) ? 0.34 : 0.66
          let y = (along - 0.5) * 0.84 * size * 1.12
          let width = sin(along * .pi) * 0.24 * size * 0.78
          let start = worldPosition + worldRotation.act([0, y, size * 0.12])
          let end = worldPosition + worldRotation.act([width, y + 0.04 * size, size * 0.07])
          let delta = end - start
          branchVeinInstances.append(
            Transform(
              scale: [1, simd_length(delta), 1],
              rotation: simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta)),
              translation: (start + end) * 0.5
            ))
        }
      }
      for branchIndex in 0..<2 {
        let side: Float = branchIndex == 0 ? -1 : 1
        let t: Float = branchIndex == 0 ? 0.42 : 0.69
        let start = plantPoint(t, bend: bend)
        let end = start + SIMD3<Float>(side * (1.4 + Float(i % 4) * 0.26), 0.75, 0.14)
        let delta = end - start
        let localRotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
        branchInstances.append(
          Transform(
            scale: [1, simd_length(delta) / 2.5, 1],
            rotation: clusterOrientation * localRotation,
            translation: clusterPosition + clusterOrientation.act((start + end) * 0.5)
          ))
      }
      if i % 8 == 0 {
        let flowerCenter = plantPoint(0.98, bend: bend)
        let flowerPosition = clusterPosition + clusterOrientation.act(flowerCenter)
        let flowerColorIndex = (i / 8) % flowerInstances.count
        for petal in 0..<5 {
          let angle = Float(petal) * 2 * .pi / 5
          let petalRotation =
            simd_quatf(angle: angle, axis: [0, 1, 0])
            * simd_quatf(angle: -0.55, axis: [0, 0, 1])
          flowerInstances[flowerColorIndex].append(
            Transform(
              scale: [0.38, 0.58, 0.34],
              rotation: clusterOrientation * petalRotation,
              translation: flowerPosition
                + clusterOrientation.act(SIMD3<Float>(cos(angle) * 0.16, sin(angle) * 0.06, 0))
            ))
        }
        flowerCoreInstances.append(
          Transform(
            scale: SIMD3<Float>(repeating: 0.13),
            rotation: clusterOrientation,
            translation: flowerPosition
          ))
      }
    }

    for branch in 0..<118 {
      let y = 1 - 2 * (Float(branch) + 0.5) / 118
      let angle = Float(branch) * 2.399963
      let ring = sqrt(max(0, 1 - y * y))
      let normal = SIMD3<Float>(cos(angle) * ring, y, sin(angle) * ring)
      var tangent = simd_cross(normal, SIMD3<Float>(cos(angle * 1.7), 0.4, sin(angle * 1.7)))
      if simd_length_squared(tangent) < 0.04 { tangent = simd_cross(normal, SIMD3<Float>(0, 1, 0)) }
      tangent = simd_normalize(tangent)
      let bitangent = simd_normalize(simd_cross(normal, tangent))
      let origin = normal * (46 + Float(branch % 5))
      let length: Float = 5.5 + Float(branch % 7) * 0.8
      let bend = Float(branch % 9) * 0.32 - 1.28
      var previous: SIMD3<Float>?
      for segment in 0...5 {
        let t = Float(segment) / 5
        var point =
          origin + tangent * (length * t) + bitangent * (sin(t * .pi) * bend) + normal * (-t * 1.8)
        point = simd_normalize(point) * (simd_length(origin) - t * 0.8)
        if let previous {
          let delta = point - previous
          let rotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
          let radius = 0.12 - t * 0.055
          woodyInstances.append(
            Transform(
              scale: [radius, simd_length(delta), radius * 0.92],
              rotation: rotation,
              translation: (point + previous) * 0.5
            ))
          if segment == 3, branch.isMultiple(of: 3) {
            let forkDirection = simd_normalize(
              tangent * (branch.isMultiple(of: 2) ? 1 : -1) + bitangent * 0.38 - normal * 0.12)
            let forkEnd = simd_normalize(point + forkDirection * 3.1) * (simd_length(point) - 0.65)
            let forkDelta = forkEnd - point
            woodyInstances.append(
              Transform(
                scale: [radius * 0.68, simd_length(forkDelta), radius * 0.62],
                rotation: simd_quatf(
                  from: SIMD3<Float>(0, 1, 0), to: simd_normalize(forkDelta)),
                translation: (point + forkEnd) * 0.5
              ))
          }
        }
        previous = point
      }
    }

    let vineCount = canInstance ? 92 : 18
    for vine in 0..<vineCount {
      let y = 1 - 2 * (Float(vine) + 0.5) / Float(vineCount)
      let angle = Float(vine) * 2.399963
      let ring = sqrt(max(0, 1 - y * y))
      let normal = SIMD3<Float>(cos(angle) * ring, y, sin(angle) * ring)
      let origin = normal * (39 + Float((vine * 7) % 13))
      let orientation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: -normal)
      for segment in 0..<36 {
        let first = vinePoint(Float(segment) / 36)
        let second = vinePoint(Float(segment + 1) / 36)
        let delta = second - first
        let localRotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
        vineInstances.append(
          Transform(
            scale: [1, simd_length(delta), 1],
            rotation: orientation * localRotation,
            translation: origin + orientation.act((first + second) * 0.5)
          ))
      }
    }
    // Mirror the web renderer's seven-leaf clusters on the inner glass.
    // Keep the lower-system fallback smaller because it uses individual entities.
    let coverClusters = canInstance ? 1800 : 300
    for i in 0..<coverClusters {
      let y = 1 - 2 * (Float(i) + 0.5) / Float(coverClusters)
      let angle = Float(i) * 2.399963
      let ring = sqrt(max(0, 1 - y * y))
      let normal = SIMD3<Float>(cos(angle) * ring, y, sin(angle) * ring)
      var tangent = simd_cross(
        normal,
        SIMD3<Float>(
          randomUnit(i * 3 + 11) * 2 - 1,
          randomUnit(i * 3 + 12) * 2 - 1,
          randomUnit(i * 3 + 13) * 2 - 1
        ))
      if simd_length_squared(tangent) < 0.04 { tangent = simd_cross(normal, SIMD3<Float>(0, 1, 0)) }
      tangent = simd_normalize(tangent)
      let inward = -normal
      let sideways = simd_normalize(simd_cross(tangent, inward))
      let frame = simd_quatf(simd_float3x3(columns: (sideways, tangent, inward)))
      let origin = normal * (48.5 + randomUnit(i * 7 + 31) * 4.5)
      for leaf in 0..<7 {
        let seed = i * 7 + leaf
        let spreadAngle = Float(leaf) / 7 * 2 * .pi + randomUnit(seed * 5 + 2) * 0.48
        let spread = 0.35 + randomUnit(seed * 5 + 3) * 1.35
        let translation =
          origin
          + tangent * (cos(spreadAngle) * spread)
          + sideways * (sin(spreadAngle) * spread)
        let localRotation =
          simd_quatf(angle: (randomUnit(seed * 5 + 4) - 0.5) * 0.55, axis: [1, 0, 0])
          * simd_quatf(angle: (randomUnit(seed * 5 + 5) - 0.5) * 0.55, axis: [0, 1, 0])
          * simd_quatf(angle: (randomUnit(seed * 5 + 6) - 0.5) * 0.5, axis: [0, 0, 1])
        let size = 1.8 + randomUnit(seed * 5 + 7) * 1.5
        let leafShape = Int(randomUnit(seed * 5 + 10) * Float(leafMeshes.count))
        let colorIndex = foliageColorIndex(plant: i + seed, leaf: leaf)
        leafInstances[leafShape][colorIndex].append(
          Transform(
            scale: [size, size * (0.78 + randomUnit(seed * 5 + 9) * 0.3), size],
            rotation: frame * localRotation,
            translation: translation
          ))
      }
    }
    for shape in leafMeshes.indices {
      for color in palette.indices {
        var material = palette[color]
        material.faceCulling = .none
        addInstanced(
          mesh: leafMeshes[shape],
          material: material,
          transforms: leafInstances[shape][color],
          name: "foliage-\(shape)-\(color)",
          to: root
        )
      }
    }
    addInstanced(
      mesh: .generateCylinder(height: 1, radius: 0.10),
      material: SimpleMaterial(
        color: PlatformColor(red: 0.40, green: 0.49, blue: 0.23, alpha: 1), roughness: 0.86,
        isMetallic: false),
      transforms: stemInstances,
      name: "garden-stems",
      to: root
    )
    addInstanced(
      mesh: .generateCylinder(height: 2.5, radius: 0.055),
      material: SimpleMaterial(
        color: PlatformColor(red: 0.43, green: 0.48, blue: 0.26, alpha: 1), roughness: 0.9,
        isMetallic: false),
      transforms: branchInstances,
      name: "garden-branches",
      to: root
    )
    addInstanced(
      mesh: .generateCylinder(height: 1, radius: 0.018),
      material: SimpleMaterial(
        color: PlatformColor(red: 0.78, green: 0.86, blue: 0.49, alpha: 1), roughness: 0.78,
        isMetallic: false),
      transforms: veinInstances,
      name: "leaf-veins",
      to: root
    )
    addInstanced(
      mesh: .generateCylinder(height: 1, radius: 0.006),
      material: SimpleMaterial(
        color: PlatformColor(red: 0.73, green: 0.82, blue: 0.47, alpha: 1), roughness: 0.76,
        isMetallic: false),
      transforms: branchVeinInstances,
      name: "leaf-branch-veins",
      to: root
    )
    let petalColors: [PlatformColor] = [
      PlatformColor(red: 0.79, green: 0.42, blue: 0.52, alpha: 1),
      PlatformColor(red: 0.89, green: 0.65, blue: 0.28, alpha: 1),
      PlatformColor(red: 0.62, green: 0.50, blue: 0.77, alpha: 1),
      PlatformColor(red: 0.83, green: 0.47, blue: 0.37, alpha: 1),
    ]
    for index in flowerInstances.indices {
      var material = SimpleMaterial(color: petalColors[index], roughness: 0.68, isMetallic: false)
      material.faceCulling = .none
      addInstanced(
        mesh: leafMeshes[0], material: material, transforms: flowerInstances[index],
        name: "flower-petals-\(index)", to: root)
    }
    addInstanced(
      mesh: .generateSphere(radius: 1),
      material: SimpleMaterial(
        color: PlatformColor(red: 1, green: 0.78, blue: 0.30, alpha: 1), roughness: 0.45,
        isMetallic: false),
      transforms: flowerCoreInstances,
      name: "flower-centers",
      to: root
    )
    addInstanced(
      mesh: .generateCylinder(height: 1, radius: 0.035),
      material: SimpleMaterial(
        color: PlatformColor(red: 0.55, green: 0.66, blue: 0.30, alpha: 1), roughness: 0.82,
        isMetallic: false),
      transforms: vineInstances,
      name: "curling-vines",
      to: root
    )
    addInstanced(
      mesh: .generateCylinder(height: 1, radius: 1),
      material: SimpleMaterial(
        color: PlatformColor(red: 0.34, green: 0.25, blue: 0.15, alpha: 1), roughness: 0.92,
        isMetallic: false),
      transforms: woodyInstances,
      name: "woody-runners",
      to: root
    )

    let fruitColors: [PlatformColor] = [
      PlatformColor(red: 0.91, green: 0.63, blue: 0.24, alpha: 1),
      PlatformColor(red: 0.83, green: 0.31, blue: 0.24, alpha: 1),
      PlatformColor(red: 0.78, green: 0.48, blue: 0.71, alpha: 1),
      PlatformColor(red: 0.78, green: 0.77, blue: 0.35, alpha: 1),
      PlatformColor(red: 0.52, green: 0.72, blue: 0.35, alpha: 1),
      PlatformColor(red: 0.96, green: 0.72, blue: 0.43, alpha: 1),
    ]
    for definition in GardenContent.starterOddities {
      let index = definition.id
      let fruit = Entity()
      fruit.name = "oddity-\(index)"
      fruit.scale = SIMD3<Float>(repeating: Float(definition.scale))
      let core = ModelEntity(
        mesh: makeProduceMesh(family: definition.family),
        materials: [
          SimpleMaterial(
            color: fruitColors[definition.paletteIndex], roughness: 0.55, isMetallic: false)
        ])
      core.scale = [1, 1, 1]
      core.position.y = 0.9
      fruit.addChild(core)
      for leafIndex in 0..<3 {
        let angle = Float(leafIndex) * 2 * .pi / 3
        let crownLeaf = ModelEntity(
          mesh: leafMeshes[leafIndex % leafMeshes.count],
          materials: [
            SimpleMaterial(
              color: leafColor(leafIndex + definition.paletteIndex), roughness: 0.7,
              isMetallic: false)
          ])
        crownLeaf.scale = [0.45, 0.7, 0.42]
        crownLeaf.position = [
          cos(angle) * 0.18, 2.58 + Float(leafIndex % 2) * 0.08, sin(angle) * 0.18,
        ]
        crownLeaf.orientation =
          simd_quatf(angle: angle, axis: [0, 1, 0])
          * simd_quatf(angle: -0.78, axis: [0, 0, 1])
        fruit.addChild(crownLeaf)
      }
      let skinDetail = ModelEntity(
        mesh: makeProduceDetailsMesh(family: definition.family, seed: index),
        materials: [
          SimpleMaterial(
            color: PlatformColor(red: 0.31, green: 0.22, blue: 0.14, alpha: 1),
            roughness: 0.9, isMetallic: false)
        ])
      skinDetail.name = "produce-detail-\(index)"
      skinDetail.isEnabled = false
      skinDetail.position.y = 0.9
      fruit.addChild(skinDetail)
      let innerGlow = ModelEntity(
        mesh: .generateSphere(radius: 0.13),
        materials: [
          UnlitMaterial(color: PlatformColor(red: 1, green: 0.82, blue: 0.43, alpha: 1))
        ])
      innerGlow.name = "produce-glow-\(index)"
      innerGlow.position = [0.02, 1.45, 0.48]
      innerGlow.isEnabled = false
      fruit.addChild(innerGlow)
      let tendrilPoints: [SIMD3<Float>] = [
        [0, 2.05, 0], [-0.08, 2.23, 0.02], [-0.23, 2.34, 0.08],
        [-0.13, 2.45, 0.13], [0.02, 2.4, 0.16],
      ]
      let tendrilMaterial = SimpleMaterial(
        color: PlatformColor(red: 0.61, green: 0.75, blue: 0.29, alpha: 1),
        roughness: 0.78, isMetallic: false)
      for segment in 0..<(tendrilPoints.count - 1) {
        let start = tendrilPoints[segment]
        let end = tendrilPoints[segment + 1]
        let delta = end - start
        let tendril = ModelEntity(
          mesh: .generateCylinder(height: simd_length(delta), radius: 0.022),
          materials: [tendrilMaterial])
        tendril.position = (start + end) * 0.5
        tendril.orientation = simd_quatf(
          from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
        fruit.addChild(tendril)
      }
      root.addChild(fruit)
    }
    return root
  }

  private func makeLeafMesh(shape: Int) -> MeshResource {
    var positions: [SIMD3<Float>] = []
    var indices: [UInt32] = []
    let rows = 12
    let columns = 8
    var normals: [SIMD3<Float>] = []
    let leafLength: Float = shape == 0 ? 0.84 : (shape == 1 ? 0.96 : 0.76)
    func surfacePoint(_ u: Float, _ v: Float) -> SIMD3<Float> {
      let taper = max(0, sin(.pi * v))
      let halfWidth: Float
      switch shape {
      case 1:
        halfWidth = pow(taper, 0.82) * 0.19
      case 2:
        halfWidth = pow(taper, 0.56) * 0.205
      default:
        let lobes = 0.84 + 0.16 * pow(sin(4 * .pi * v), 2)
        halfWidth = taper * 0.24 * lobes
      }
      let cup = (1 - u * u) * (shape == 2 ? 0.055 : 0.07)
      let arch = sin(v * .pi) * (shape == 1 ? 0.05 : 0.035)
      return [u * halfWidth, (v - 0.5) * leafLength, cup + arch]
    }
    for row in 0...rows {
      let v = Float(row) / Float(rows)
      for column in 0...columns {
        let u = Float(column) / Float(columns) * 2 - 1
        positions.append(surfacePoint(u, v))
        let across = surfacePoint(min(1, u + 0.002), v) - surfacePoint(max(-1, u - 0.002), v)
        let along = surfacePoint(u, min(1, v + 0.002)) - surfacePoint(u, max(0, v - 0.002))
        normals.append(simd_normalize(simd_cross(across, along)))
      }
    }
    for row in 0..<rows {
      for column in 0..<columns {
        let a = UInt32(row * (columns + 1) + column)
        let b = a + UInt32(columns + 1)
        indices.append(contentsOf: [a, a + 1, b, a + 1, b + 1, b])
      }
    }
    var descriptor = MeshDescriptor()
    descriptor.positions = MeshBuffer(positions)
    descriptor.normals = MeshBuffer(normals)
    descriptor.primitives = .triangles(indices)
    return (try? MeshResource.generate(from: [descriptor])) ?? .generateSphere(radius: 0.2)
  }

  private func plantPoint(_ t: Float, bend: Float) -> SIMD3<Float> {
    let controlPoints: [SIMD3<Float>] = [
      [0, 0, 0], [0.12, 0.7, 0.02], [0.36, 1.5, -0.08],
      [0.22, 2.3, -0.12], [0.52, 3.1, -0.04], [0.85, 3.2, 0.12],
    ]
    let position = min(t, 0.999) * Float(controlPoints.count - 1)
    let index = Int(position)
    let point = simd_mix(
      controlPoints[index], controlPoints[index + 1],
      SIMD3<Float>(repeating: position - Float(index)))
    return point + SIMD3<Float>(sin(t * .pi) * bend * 1.8, 0, sin(t * .pi * 0.75) * bend * 0.45)
  }

  private func vinePoint(_ t: Float) -> SIMD3<Float> {
    let angle = t * .pi * 2.3
    let radius = 0.72 + 0.2 * sin(t * .pi * 3)
    return [cos(angle) * radius, t * 8.5, sin(angle) * radius]
  }

  private func makeGardenDome() -> ModelEntity {
    let bandCount = 24
    let sliceCount = 48
    let radius: Float = 58
    var descriptors: [MeshDescriptor] = []
    for band in 0..<bandCount {
      let lowerLatitude = -.pi / 2 + Float(band) / Float(bandCount) * .pi
      let upperLatitude = -.pi / 2 + Float(band + 1) / Float(bandCount) * .pi
      var positions: [SIMD3<Float>] = []
      var indices: [UInt32] = []
      for latitude in [lowerLatitude, upperLatitude] {
        for slice in 0...sliceCount {
          let longitude = Float(slice) / Float(sliceCount) * 2 * .pi
          positions.append([
            cos(latitude) * cos(longitude) * radius,
            sin(latitude) * radius,
            cos(latitude) * sin(longitude) * radius,
          ])
        }
      }
      for slice in 0..<sliceCount {
        let a = UInt32(slice)
        let b = a + UInt32(sliceCount + 1)
        indices.append(contentsOf: [a, b, a + 1, a + 1, b, b + 1])
      }
      var descriptor = MeshDescriptor(name: "canopy-band-\(band)")
      descriptor.positions = MeshBuffer(positions)
      descriptor.primitives = .triangles(indices)
      descriptor.materials = .allFaces(UInt32(band))
      descriptors.append(descriptor)
    }

    let colors: [SIMD3<Float>] = [
      [0.010, 0.025, 0.027], [0.020, 0.052, 0.045], [0.038, 0.095, 0.050], [0.095, 0.145, 0.062],
    ]
    let materials = (0..<bandCount).map { band -> UnlitMaterial in
      let t = Float(band) / Float(bandCount - 1) * Float(colors.count - 1)
      let index = min(Int(t), colors.count - 2)
      let blend = t - Float(index)
      let color = simd_mix(colors[index], colors[index + 1], SIMD3<Float>(repeating: blend))
      var material = UnlitMaterial(
        color: PlatformColor(
          red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1))
      material.faceCulling = .front
      return material
    }

    do {
      return ModelEntity(mesh: try MeshResource.generate(from: descriptors), materials: materials)
    } catch {
      var material = UnlitMaterial(
        color: PlatformColor(red: 0.02, green: 0.05, blue: 0.04, alpha: 1))
      material.faceCulling = .front
      return ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
    }
  }

  private func makeProduceMesh(family: ProduceFamily) -> MeshResource {
    let profile = produceProfile(family: family)
    let slices = 32
    var positions: [SIMD3<Float>] = []
    var indices: [UInt32] = []
    for (ring, point) in profile.enumerated() {
      for slice in 0..<slices {
        let angle = Float(slice) / Float(slices) * 2 * .pi
        let ribCount: Float = family == .berry ? 7 : (family == .plum ? 5 : 4)
        let rib = 1 + sin(angle * ribCount + Float(ring) * 0.12) * 0.055
        positions.append([
          cos(angle) * point.radius * rib, point.height, sin(angle) * point.radius * rib,
        ])
      }
    }
    for ring in 0..<(profile.count - 1) {
      for slice in 0..<slices {
        let next = (slice + 1) % slices
        let a = UInt32(ring * slices + slice)
        let b = UInt32(ring * slices + next)
        let c = UInt32((ring + 1) * slices + slice)
        let d = UInt32((ring + 1) * slices + next)
        indices.append(contentsOf: [a, c, b, b, c, d])
      }
    }
    var descriptor = MeshDescriptor()
    descriptor.positions = MeshBuffer(positions)
    descriptor.primitives = .triangles(indices)
    return (try? MeshResource.generate(from: [descriptor])) ?? .generateSphere(radius: 0.55)
  }

  private func produceProfile(family: ProduceFamily) -> [(radius: Float, height: Float)] {
    switch family {
    case .pear:
      [
        (0.04, 0.00), (0.34, 0.07), (0.52, 0.22), (0.60, 0.44),
        (0.58, 0.68), (0.48, 0.88), (0.32, 1.03), (0.17, 1.06),
        (0.12, 1.18), (0.04, 1.22),
      ]
    case .berry:
      [
        (0.05, 0.00), (0.23, 0.04), (0.39, 0.14), (0.49, 0.30),
        (0.52, 0.48), (0.46, 0.68), (0.33, 0.84), (0.17, 0.94), (0.04, 0.98),
      ]
    case .plum:
      [
        (0.04, 0.00), (0.18, 0.03), (0.34, 0.14), (0.43, 0.33),
        (0.45, 0.54), (0.39, 0.76), (0.29, 0.94), (0.17, 1.08), (0.04, 1.12),
      ]
    }
  }

  private func makeProduceDetailsMesh(family: ProduceFamily, seed: Int) -> MeshResource {
    let profile = produceProfile(family: family)
    let slices = 6
    let rings = 4
    var positions: [SIMD3<Float>] = []
    var normals: [SIMD3<Float>] = []
    var indices: [UInt32] = []
    let frequency: Float = family == .berry ? 7 : (family == .plum ? 5 : 4)
    for spot in 0..<18 {
      let y = 0.12 + randomUnit(seed * 37 + spot * 11) * 0.74
      let radius = profileRadius(profile, at: y)
      let centerAngle = randomUnit(seed * 71 + spot * 17) * 2 * .pi
      let rib = 1 + sin(centerAngle * frequency + Float(seed)) * 0.055
      let shellRadius = radius * rib + sin(y * 3.1 + Float(seed)) * 0.035
      let radial = SIMD3<Float>(cos(centerAngle), 0, sin(centerAngle))
      let center = SIMD3<Float>(radial.x * shellRadius, y, radial.z * shellRadius)
      let beadRadius = 0.018 + randomUnit(seed * 97 + spot * 23) * 0.018
      let firstVertex = UInt32(positions.count)
      for ring in 0...rings {
        let latitude = (Float(ring) / Float(rings) - 0.5) * .pi
        for slice in 0..<slices {
          let longitude = Float(slice) / Float(slices) * 2 * .pi
          let normal =
            radial * (cos(latitude) * cos(longitude))
            + SIMD3<Float>(0, sin(latitude), 0)
          normals.append(simd_normalize(normal))
          positions.append(center + normal * beadRadius)
        }
      }
      for ring in 0..<rings {
        for slice in 0..<slices {
          let next = (slice + 1) % slices
          let a = firstVertex + UInt32(ring * slices + slice)
          let b = firstVertex + UInt32(ring * slices + next)
          let c = firstVertex + UInt32((ring + 1) * slices + slice)
          let d = firstVertex + UInt32((ring + 1) * slices + next)
          indices.append(contentsOf: [a, c, b, b, c, d])
        }
      }
    }
    var descriptor = MeshDescriptor()
    descriptor.positions = MeshBuffer(positions)
    descriptor.normals = MeshBuffer(normals)
    descriptor.primitives = .triangles(indices)
    return (try? MeshResource.generate(from: [descriptor])) ?? .generateSphere(radius: 0.01)
  }

  private func profileRadius(
    _ profile: [(radius: Float, height: Float)], at height: Float
  ) -> Float {
    for index in 1..<profile.count where profile[index].height >= height {
      let first = profile[index - 1]
      let second = profile[index]
      let fraction = (height - first.height) / max(0.001, second.height - first.height)
      return first.radius + (second.radius - first.radius) * fraction
    }
    return profile[profile.count - 1].radius
  }

  private func leafColor(_ seed: Int) -> PlatformColor {
    let palette: [PlatformColor] = [
      PlatformColor(red: 0.20, green: 0.35, blue: 0.20, alpha: 1),
      PlatformColor(red: 0.29, green: 0.44, blue: 0.22, alpha: 1),
      PlatformColor(red: 0.39, green: 0.52, blue: 0.24, alpha: 1),
      PlatformColor(red: 0.52, green: 0.61, blue: 0.29, alpha: 1),
      PlatformColor(red: 0.22, green: 0.43, blue: 0.35, alpha: 1),
      PlatformColor(red: 0.34, green: 0.50, blue: 0.39, alpha: 1),
      PlatformColor(red: 0.56, green: 0.48, blue: 0.29, alpha: 1),
      PlatformColor(red: 0.48, green: 0.39, blue: 0.51, alpha: 1),
      PlatformColor(red: 0.59, green: 0.39, blue: 0.34, alpha: 1),
    ]
    return palette[seed % palette.count]
  }

  private func foliageColorIndex(plant: Int, leaf: Int) -> Int {
    let roll = (plant * 7 + leaf * 3) % 20
    if roll < 16 { return roll % 5 }
    if roll < 19 { return 5 + (roll % 2) }
    return 7 + (roll % 2)
  }

  private func randomUnit(_ seed: Int) -> Float {
    let value = sin(Float(seed) * 12.9898) * 43_758.547
    return value - floor(value)
  }

  private func addGreenhouseRibs(to root: Entity) {
    let radius: Float = 55
    let material = SimpleMaterial(
      color: PlatformColor(red: 0.72, green: 0.73, blue: 0.43, alpha: 0.28), roughness: 0.58,
      isMetallic: false)
    for rib in 0..<8 {
      let longitude = Float(rib) * (.pi / 8)
      for segment in 0..<16 {
        let lowerLatitude = -.pi / 2 + Float(segment) * (.pi / 16)
        let upperLatitude = lowerLatitude + (.pi / 16)
        let lower =
          SIMD3<Float>(
            cos(lowerLatitude) * cos(longitude), sin(lowerLatitude),
            cos(lowerLatitude) * sin(longitude)) * radius
        let upper =
          SIMD3<Float>(
            cos(upperLatitude) * cos(longitude), sin(upperLatitude),
            cos(upperLatitude) * sin(longitude)) * radius
        let delta = upper - lower
        let ribSegment = ModelEntity(
          mesh: .generateCylinder(height: simd_length(delta), radius: 0.028), materials: [material])
        ribSegment.position = (lower + upper) * 0.5
        ribSegment.orientation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
        root.addChild(ribSegment)
      }
    }
  }

  private func addInstanced(
    mesh: MeshResource, material: SimpleMaterial, transforms: [Transform], name: String,
    to root: Entity
  ) {
    guard !transforms.isEmpty else { return }
    let entity = ModelEntity(mesh: mesh, materials: [material])
    entity.name = name
    if #available(iOS 26.0, macOS 26.0, *) {
      do {
        let instanceData = try LowLevelInstanceData(instanceCount: transforms.count)
        instanceData.withMutableTransforms { buffer in
          for (index, transform) in transforms.enumerated() {
            buffer[index] = transform.matrix
          }
        }
        guard let mesh = entity.components[ModelComponent.self]?.mesh else { return }
        let modelID = mesh.contents.models.first?.id
        let instances = try MeshInstancesComponent(
          mesh: mesh, modelID: modelID, instances: instanceData)
        entity.components.set(instances)
        root.addChild(entity)
        return
      } catch {
        // The prototype falls back to individual entities if instancing cannot be allocated.
      }
    }
    for (index, transform) in transforms.enumerated() {
      let instance = ModelEntity(mesh: mesh, materials: [material])
      instance.name = "\(name)-\(index)"
      instance.transform = transform
      root.addChild(instance)
    }
  }
}
