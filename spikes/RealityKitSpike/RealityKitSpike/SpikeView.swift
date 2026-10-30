import RealityKit
import SwiftUI
import simd
#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

struct SpikeView: View {
    @State private var yaw = 0.0
    @State private var pitch = 0.0
    @State private var score = 0
    @State private var lastDragTranslation = CGSize.zero
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { timeline in
                    RealityView { content in
                        content.add(makeGarden())
                    } update: { content in
                        guard let camera = content.entities.first?.findEntity(named: "spike-camera") as? PerspectiveCamera else { return }
                        let radius: Float = 0.08
                        let y = Float(pitch)
                        let horizontal = sqrt(max(0.01, 1 - y * y))
                        camera.position = [Float(sin(yaw)) * horizontal * radius, y * radius, Float(cos(yaw)) * horizontal * radius]
                        camera.look(at: .zero, from: camera.position, relativeTo: nil)
                        let elapsed = Float(timeline.date.timeIntervalSinceReferenceDate)
                        for index in 0..<12 {
                            let name = "oddity-\(index)"
                            guard let produce = content.entities.first?.findEntity(named: name) else { continue }
                            let phase = elapsed * 0.18 + Float(index) * 1.57
                            let base: SIMD3<Float>
                            if index == 0 {
                                base = [0.2, 0.1, -19]
                            } else {
                                let sample = Float(index - 1)
                                let y = 1 - 2 * (sample + 0.5) / 11
                                let angle = sample * 2.399963
                                let ring = sqrt(max(0, 1 - y * y))
                                base = SIMD3<Float>(cos(angle) * ring, y, sin(angle) * ring) * (23 + Float(index % 4) * 3.5)
                            }
                            produce.position = base + [sin(phase) * 1.1, sin(phase * 0.7) * 0.85, 0]
                            produce.look(at: .zero, from: produce.position, relativeTo: nil)
                        }
                    }
                    .ignoresSafeArea()
                }

                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("roundgarden")
                                .font(.system(size: 19, weight: .medium, design: .serif))
                                .tracking(-0.4)
                                .foregroundStyle(Color(red: 0.91, green: 0.96, blue: 0.83))
                            Text("SCORE  ·  \(score)")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .tracking(1.7)
                                .foregroundStyle(Color(red: 0.69, green: 0.78, blue: 0.64))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("01:00")
                                .font(.system(size: 25, weight: .medium, design: .rounded).monospacedDigit())
                                .foregroundStyle(Color(red: 0.91, green: 0.96, blue: 0.83))
                            Capsule().fill(Color(red: 0.77, green: 0.91, blue: 0.63).opacity(0.72)).frame(width: 62, height: 2)
                        }
                    }
                    Spacer()
                    HStack(spacing: 7) {
                        Image(systemName: "viewfinder").font(.system(size: 12, weight: .light))
                        Text("DRAG TO LOOK  ·  TAP A NEARBY ODDITY")
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                            .tracking(1.2)
                    }
                    .foregroundStyle(Color(red: 0.73, green: 0.82, blue: 0.70).opacity(0.88))
                }
                .padding(.horizontal, 23)
                .padding(.top, max(16, geometry.safeAreaInsets.top + 10))
                .padding(.bottom, max(13, geometry.safeAreaInsets.bottom + 8))
                .allowsHitTesting(false)

                ZStack {
                    Circle().stroke(Color(red: 0.84, green: 0.96, blue: 0.79).opacity(0.66), lineWidth: 0.8).frame(width: 27, height: 27)
                    Circle().fill(Color(red: 0.9, green: 1, blue: 0.79)).frame(width: 3, height: 3)
                    Rectangle().fill(.white.opacity(0.58)).frame(width: 1, height: 4).offset(y: -17)
                    Rectangle().fill(.white.opacity(0.58)).frame(width: 1, height: 4).offset(y: 17)
                    Rectangle().fill(.white.opacity(0.58)).frame(width: 4, height: 1).offset(x: -17)
                    Rectangle().fill(.white.opacity(0.58)).frame(width: 4, height: 1).offset(x: 17)
                }
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.012, green: 0.032, blue: 0.031).ignoresSafeArea())
        }
        .preferredColorScheme(.dark)
        .gesture(DragGesture(minimumDistance: 0)
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
                if hypot(value.translation.width, value.translation.height) < 8 { score += 1 }
                lastDragTranslation = .zero
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private func makeGarden() -> Entity {
        let root = Entity()
        root.name = "garden-root"
        let camera = PerspectiveCamera()
        camera.name = "spike-camera"
        camera.camera.fieldOfViewInDegrees = 74
        root.addChild(camera)

        root.addChild(makeGardenDome())

        // Match the web renderer's nearly invisible greenhouse shell while keeping
        // its opaque shader-like garden backdrop behind it.
        var greenhouseMaterial = SimpleMaterial(color: PlatformColor(red: 0.84, green: 0.90, blue: 0.68, alpha: 0.035), roughness: 0.58, isMetallic: false)
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
        let leafMesh = makeLeafMesh()
        let palette = (0..<6).map { index in
            SimpleMaterial(color: leafColor(index), roughness: 0.74, isMetallic: false)
        }
        let canInstance: Bool
        if #available(iOS 26.0, macOS 26.0, *) {
            canInstance = true
        } else {
            canInstance = false
        }
        let plantCount = canInstance ? 900 : 180
        var leafInstances = Array(repeating: [Transform](), count: palette.count)
        var veinInstances: [Transform] = []
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
            let shellRadius = 29 + Float((i * 37) % 26)
            let clusterPosition = normal * shellRadius
            let clusterOrientation = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: -normal)
            let bend = Float((i * 17) % 19) / 18 - 0.5
            for segment in 0..<6 {
                let start = plantPoint(Float(segment) / 6, bend: bend)
                let end = plantPoint(Float(segment + 1) / 6, bend: bend)
                let delta = end - start
                let localRotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
                stemInstances.append(Transform(
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
                let localRotation = simd_quatf(angle: side * (0.72 + Float((i + leafIndex) % 5) * 0.13), axis: [0, 0, 1])
                let size = 1.35 + Float((i * 11 + leafIndex * 7) % 14) * 0.10
                let worldRotation = clusterOrientation * localRotation
                let worldPosition = clusterPosition + clusterOrientation.act(localPosition)
                let colorIndex = (i * 7 + leafIndex * 3) % palette.count
                leafInstances[colorIndex].append(Transform(
                    scale: [size, size * 1.12, size],
                    rotation: worldRotation,
                    translation: worldPosition
                ))
                veinInstances.append(Transform(
                    scale: [1, size * 0.66, 1],
                    rotation: worldRotation,
                    translation: worldPosition + worldRotation.act(SIMD3<Float>(0, 0, 0.12))
                ))
            }
            for branchIndex in 0..<2 {
                let side: Float = branchIndex == 0 ? -1 : 1
                let t: Float = branchIndex == 0 ? 0.42 : 0.69
                let start = plantPoint(t, bend: bend)
                let end = start + SIMD3<Float>(side * (1.4 + Float(i % 4) * 0.26), 0.75, 0.14)
                let delta = end - start
                let localRotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
                branchInstances.append(Transform(
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
                    let petalRotation = simd_quatf(angle: angle, axis: [0, 1, 0])
                        * simd_quatf(angle: -0.55, axis: [0, 0, 1])
                    flowerInstances[flowerColorIndex].append(Transform(
                        scale: [0.38, 0.58, 0.34],
                        rotation: clusterOrientation * petalRotation,
                        translation: flowerPosition + clusterOrientation.act(SIMD3<Float>(cos(angle) * 0.16, sin(angle) * 0.06, 0))
                    ))
                }
                flowerCoreInstances.append(Transform(
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
                var point = origin + tangent * (length * t) + bitangent * (sin(t * .pi) * bend) + normal * (-t * 1.8)
                point = simd_normalize(point) * (simd_length(origin) - t * 0.8)
                if let previous {
                    let delta = point - previous
                    let rotation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
                    let radius = 0.12 - t * 0.055
                    woodyInstances.append(Transform(
                        scale: [radius, simd_length(delta), radius * 0.92],
                        rotation: rotation,
                        translation: (point + previous) * 0.5
                    ))
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
                vineInstances.append(Transform(
                    scale: [1, simd_length(delta), 1],
                    rotation: orientation * localRotation,
                    translation: origin + orientation.act((first + second) * 0.5)
                ))
            }
        }
        let coverLeafCount = canInstance ? 2200 : 300
        for i in 0..<coverLeafCount {
            let y = 1 - 2 * (Float(i) + 0.5) / Float(coverLeafCount)
            let angle = Float(i) * 2.399963
            let ring = sqrt(max(0, 1 - y * y))
            let normal = SIMD3<Float>(cos(angle) * ring, y, sin(angle) * ring)
            let orientation = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: -normal)
            let spin = simd_quatf(angle: Float(i % 11) * 0.21, axis: [0, 0, 1])
            let colorIndex = (i * 13 + i / 7) % palette.count
            leafInstances[colorIndex].append(Transform(
                scale: [1.5, 2.1, 1.35],
                rotation: orientation * spin,
                translation: normal * 53.2
            ))
        }
        for index in palette.indices {
            var material = palette[index]
            material.faceCulling = .none
            addInstanced(mesh: leafMesh, material: material, transforms: leafInstances[index], name: "foliage-\(index)", to: root)
        }
        addInstanced(
            mesh: .generateCylinder(height: 1, radius: 0.10),
            material: SimpleMaterial(color: PlatformColor(red: 0.40, green: 0.49, blue: 0.23, alpha: 1), roughness: 0.86, isMetallic: false),
            transforms: stemInstances,
            name: "garden-stems",
            to: root
        )
        addInstanced(
            mesh: .generateCylinder(height: 2.5, radius: 0.055),
            material: SimpleMaterial(color: PlatformColor(red: 0.43, green: 0.48, blue: 0.26, alpha: 1), roughness: 0.9, isMetallic: false),
            transforms: branchInstances,
            name: "garden-branches",
            to: root
        )
        addInstanced(
            mesh: .generateCylinder(height: 1, radius: 0.018),
            material: SimpleMaterial(color: PlatformColor(red: 0.78, green: 0.86, blue: 0.49, alpha: 1), roughness: 0.78, isMetallic: false),
            transforms: veinInstances,
            name: "leaf-veins",
            to: root
        )
        let petalColors: [PlatformColor] = [
            PlatformColor(red: 0.79, green: 0.42, blue: 0.52, alpha: 1),
            PlatformColor(red: 0.89, green: 0.65, blue: 0.28, alpha: 1),
            PlatformColor(red: 0.62, green: 0.50, blue: 0.77, alpha: 1),
            PlatformColor(red: 0.83, green: 0.47, blue: 0.37, alpha: 1)
        ]
        for index in flowerInstances.indices {
            var material = SimpleMaterial(color: petalColors[index], roughness: 0.68, isMetallic: false)
            material.faceCulling = .none
            addInstanced(mesh: leafMesh, material: material, transforms: flowerInstances[index], name: "flower-petals-\(index)", to: root)
        }
        addInstanced(
            mesh: .generateSphere(radius: 1),
            material: SimpleMaterial(color: PlatformColor(red: 1, green: 0.78, blue: 0.30, alpha: 1), roughness: 0.45, isMetallic: false),
            transforms: flowerCoreInstances,
            name: "flower-centers",
            to: root
        )
        addInstanced(
            mesh: .generateCylinder(height: 1, radius: 0.035),
            material: SimpleMaterial(color: PlatformColor(red: 0.55, green: 0.66, blue: 0.30, alpha: 1), roughness: 0.82, isMetallic: false),
            transforms: vineInstances,
            name: "curling-vines",
            to: root
        )
        addInstanced(
            mesh: .generateCylinder(height: 1, radius: 1),
            material: SimpleMaterial(color: PlatformColor(red: 0.34, green: 0.25, blue: 0.15, alpha: 1), roughness: 0.92, isMetallic: false),
            transforms: woodyInstances,
            name: "woody-runners",
            to: root
        )

        let fruitMesh = makeProduceMesh()
        let fruitColors: [PlatformColor] = [
            PlatformColor(red: 0.91, green: 0.63, blue: 0.24, alpha: 1),
            PlatformColor(red: 0.83, green: 0.31, blue: 0.24, alpha: 1),
            PlatformColor(red: 0.78, green: 0.48, blue: 0.71, alpha: 1),
            PlatformColor(red: 0.78, green: 0.77, blue: 0.35, alpha: 1)
        ]
        for index in 0..<12 {
            let fruit = Entity()
            fruit.name = "oddity-\(index)"
            let produceScale = 0.82 + Float(index % 4) * 0.10
            let core = ModelEntity(mesh: fruitMesh, materials: [SimpleMaterial(color: fruitColors[index % fruitColors.count], roughness: 0.55, isMetallic: false)])
            core.scale = [produceScale, produceScale * (1.02 + Float(index % 3) * 0.09), produceScale]
            core.position.y = 0.9
            fruit.addChild(core)
            let crownLeaf = ModelEntity(mesh: leafMesh, materials: [SimpleMaterial(color: PlatformColor(red: 0.69, green: 0.83, blue: 0.32, alpha: 1), roughness: 0.72, isMetallic: false)])
            crownLeaf.scale = [0.58, 0.82, 0.52]
            crownLeaf.position = [0.32, 2.7, 0.12]
            crownLeaf.orientation = simd_quatf(angle: -0.85, axis: [0, 0, 1])
            fruit.addChild(crownLeaf)
            root.addChild(fruit)
        }
        return root
    }

    private func makeLeafMesh() -> MeshResource {
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        let rows = 12
        let columns = 8
        for row in 0...rows {
            let v = Float(row) / Float(rows)
            let halfWidth = sin(.pi * v) * 0.24
            for column in 0...columns {
                let u = Float(column) / Float(columns) * 2 - 1
                let cup = (1 - u * u) * 0.07
                positions.append([u * halfWidth, (v - 0.5) * 0.82, cup + sin(v * .pi) * 0.035])
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
        descriptor.primitives = .triangles(indices)
        return (try? MeshResource.generate(from: [descriptor])) ?? .generateSphere(radius: 0.2)
    }

    private func plantPoint(_ t: Float, bend: Float) -> SIMD3<Float> {
        let controlPoints: [SIMD3<Float>] = [
            [0, 0, 0], [0.12, 0.7, 0.02], [0.36, 1.5, -0.08],
            [0.22, 2.3, -0.12], [0.52, 3.1, -0.04], [0.85, 3.2, 0.12]
        ]
        let position = min(t, 0.999) * Float(controlPoints.count - 1)
        let index = Int(position)
        let point = simd_mix(controlPoints[index], controlPoints[index + 1], SIMD3<Float>(repeating: position - Float(index)))
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
                        cos(latitude) * sin(longitude) * radius
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
            [0.010, 0.025, 0.027], [0.020, 0.052, 0.045], [0.038, 0.095, 0.050], [0.095, 0.145, 0.062]
        ]
        let materials = (0..<bandCount).map { band -> UnlitMaterial in
            let t = Float(band) / Float(bandCount - 1) * Float(colors.count - 1)
            let index = min(Int(t), colors.count - 2)
            let blend = t - Float(index)
            let color = simd_mix(colors[index], colors[index + 1], SIMD3<Float>(repeating: blend))
            var material = UnlitMaterial(color: PlatformColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1))
            material.faceCulling = .front
            return material
        }

        do {
            return ModelEntity(mesh: try MeshResource.generate(from: descriptors), materials: materials)
        } catch {
            var material = UnlitMaterial(color: PlatformColor(red: 0.02, green: 0.05, blue: 0.04, alpha: 1))
            material.faceCulling = .front
            return ModelEntity(mesh: .generateSphere(radius: radius), materials: [material])
        }
    }

    private func makeProduceMesh() -> MeshResource {
        let profile: [(radius: Float, height: Float)] = [
            (0.04, 0.00), (0.34, 0.07), (0.52, 0.22), (0.60, 0.44),
            (0.58, 0.68), (0.48, 0.88), (0.32, 1.03), (0.17, 1.06),
            (0.12, 1.18), (0.04, 1.22)
        ]
        let slices = 32
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        for (ring, point) in profile.enumerated() {
            for slice in 0..<slices {
                let angle = Float(slice) / Float(slices) * 2 * .pi
                let rib = 1 + sin(angle * 5 + Float(ring) * 0.12) * 0.045
                positions.append([cos(angle) * point.radius * rib, point.height, sin(angle) * point.radius * rib])
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

    private func leafColor(_ seed: Int) -> PlatformColor {
        let palette: [PlatformColor] = [
            PlatformColor(red: 0.34, green: 0.48, blue: 0.25, alpha: 1),
            PlatformColor(red: 0.45, green: 0.57, blue: 0.27, alpha: 1),
            PlatformColor(red: 0.57, green: 0.63, blue: 0.30, alpha: 1),
            PlatformColor(red: 0.24, green: 0.47, blue: 0.39, alpha: 1),
            PlatformColor(red: 0.41, green: 0.58, blue: 0.47, alpha: 1),
            PlatformColor(red: 0.69, green: 0.60, blue: 0.35, alpha: 1),
            PlatformColor(red: 0.72, green: 0.43, blue: 0.42, alpha: 1),
            PlatformColor(red: 0.53, green: 0.45, blue: 0.67, alpha: 1)
        ]
        return palette[seed % palette.count]
    }

    private func addGreenhouseRibs(to root: Entity) {
        let radius: Float = 55
        let material = SimpleMaterial(color: PlatformColor(red: 0.72, green: 0.73, blue: 0.43, alpha: 0.28), roughness: 0.58, isMetallic: false)
        for rib in 0..<8 {
            let longitude = Float(rib) * (.pi / 8)
            for segment in 0..<16 {
                let lowerLatitude = -.pi / 2 + Float(segment) * (.pi / 16)
                let upperLatitude = lowerLatitude + (.pi / 16)
                let lower = SIMD3<Float>(cos(lowerLatitude) * cos(longitude), sin(lowerLatitude), cos(lowerLatitude) * sin(longitude)) * radius
                let upper = SIMD3<Float>(cos(upperLatitude) * cos(longitude), sin(upperLatitude), cos(upperLatitude) * sin(longitude)) * radius
                let delta = upper - lower
                let ribSegment = ModelEntity(mesh: .generateCylinder(height: simd_length(delta), radius: 0.028), materials: [material])
                ribSegment.position = (lower + upper) * 0.5
                ribSegment.orientation = simd_quatf(from: SIMD3<Float>(0, 1, 0), to: simd_normalize(delta))
                root.addChild(ribSegment)
            }
        }
    }

    private func addInstanced(mesh: MeshResource, material: SimpleMaterial, transforms: [Transform], name: String, to root: Entity) {
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
                let instances = try MeshInstancesComponent(mesh: mesh, modelID: modelID, instances: instanceData)
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
