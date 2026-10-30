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
        ZStack(alignment: .top) {
            RealityView { content in
                content.add(makeGarden())
            } update: { content in
                guard let camera = content.entities.first?.findEntity(named: "spike-camera") as? PerspectiveCamera else { return }
                let radius: Float = 0.08
                let y = Float(pitch)
                let horizontal = sqrt(max(0.01, 1 - y * y))
                camera.position = [Float(sin(yaw)) * horizontal * radius, y * radius, Float(cos(yaw)) * horizontal * radius]
                camera.look(at: .zero, from: camera.position, relativeTo: nil)
            }
            .gesture(DragGesture(minimumDistance: 4)
                .onChanged { value in
                    let delta = CGSize(
                        width: value.translation.width - lastDragTranslation.width,
                        height: value.translation.height - lastDragTranslation.height
                    )
                    lastDragTranslation = value.translation
                    yaw -= delta.width * 0.004
                    pitch = min(0.94, max(-0.94, pitch - delta.height * 0.004))
                }
                .onEnded { _ in lastDragTranslation = .zero }
            )
            .simultaneousGesture(TapGesture().onEnded { score += 1 })

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("REALITYKIT SPIKE").font(.caption.weight(.bold)).tracking(2)
                    Text("360° garden · \(targetDevice)").font(.footnote)
                }
                Spacer()
                Text("LIGHT \(score)").font(.system(.headline, design: .rounded).weight(.semibold))
            }
            .padding(18)
            .foregroundStyle(.white)
            .background(.black.opacity(0.76), in: RoundedRectangle(cornerRadius: 18))
            .padding()

            Image(systemName: "viewfinder")
                .font(.system(size: 30, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.8))
                .allowsHitTesting(false)
        }
        .background(Color(red: 0.025, green: 0.055, blue: 0.045))
        .preferredColorScheme(.dark)
    }

    private var targetDevice: String {
#if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
#else
        "Mac"
#endif
    }

    private func makeGarden() -> Entity {
        let root = Entity()
        root.name = "garden-root"
        let camera = PerspectiveCamera()
        camera.name = "spike-camera"
        camera.camera.fieldOfViewInDegrees = 74
        root.addChild(camera)

        let shell = ModelEntity(mesh: .generateSphere(radius: 18), materials: [SimpleMaterial(color: PlatformColor(red: 0.035, green: 0.11, blue: 0.07, alpha: 1), roughness: 1, isMetallic: false)])
        shell.scale = [-1, 1, 1]
        root.addChild(shell)

        let key = DirectionalLight()
        key.light.intensity = 1800
        key.light.color = .init(red: 1, green: 0.84, blue: 0.57, alpha: 1)
        key.position = [-5, 7, 5]
        key.look(at: .zero, from: key.position, relativeTo: nil)
        root.addChild(key)

        let fill = PointLight()
        fill.light.intensity = 500
        fill.light.attenuationRadius = 16
        fill.light.color = .init(red: 0.67, green: 0.83, blue: 0.56, alpha: 1)
        fill.position = [1, -2, 0]
        root.addChild(fill)

        let ambience = PointLight()
        ambience.light.intensity = 2800
        ambience.light.attenuationRadius = 30
        ambience.light.color = .init(red: 0.72, green: 0.82, blue: 0.62, alpha: 1)
        ambience.position = [0, 0, 0]
        root.addChild(ambience)

        // Sparse procedural radial planting keeps the spike focused on renderer capability,
        // full-sphere depth, targeting visibility, and camera motion.
        for i in 0..<48 {
            let u = Float(i) * 2.399963
            let y = 1 - (Float(i) + 0.5) * 2 / 48
            let r = sqrt(max(0, 1 - y * y))
            let normal = SIMD3<Float>(cos(u) * r, y, sin(u) * r)
            let cluster = Entity()
            cluster.position = normal * 17.2
            cluster.orientation = simd_quatf(from: [0, 0, 1], to: -normal)
            root.addChild(cluster)
            for leafIndex in 0..<5 {
                let angle = Float(leafIndex) * 1.256 + Float(i % 7) * 0.21
                let leaf = ModelEntity(mesh: .generateSphere(radius: 0.34), materials: [SimpleMaterial(color: leafColor(i + leafIndex), roughness: 0.82, isMetallic: false)])
                leaf.scale = [0.78, 0.18, 1.45]
                leaf.position = [cos(angle) * 0.55, sin(angle) * 0.55, 0.28]
                leaf.orientation = simd_quatf(angle: angle, axis: [0, 0, 1])
                cluster.addChild(leaf)
            }
            let stem = ModelEntity(mesh: .generateCylinder(height: 1.2, radius: 0.035), materials: [SimpleMaterial(color: PlatformColor(red: 0.30, green: 0.25, blue: 0.11, alpha: 1), roughness: 0.9, isMetallic: false)])
            stem.position = [0, 0, -0.4]
            cluster.addChild(stem)
        }

        let oddity = ModelEntity(mesh: .generateSphere(radius: 0.55), materials: [SimpleMaterial(color: PlatformColor(red: 0.88, green: 0.43, blue: 0.27, alpha: 1), roughness: 0.3, isMetallic: false)])
        oddity.name = "target-oddity"
        oddity.position = [0, 0, -5]
        oddity.scale = [0.7, 1.25, 0.7]
        root.addChild(oddity)
        let glow = PointLight()
        glow.light.intensity = 220
        glow.light.attenuationRadius = 2.8
        glow.light.color = .init(red: 1, green: 0.45, blue: 0.19, alpha: 1)
        glow.position = oddity.position
        root.addChild(glow)
        return root
    }

    private func leafColor(_ seed: Int) -> PlatformColor {
        let palette: [PlatformColor] = [
            PlatformColor(red: 0.28, green: 0.48, blue: 0.20, alpha: 1),
            PlatformColor(red: 0.48, green: 0.59, blue: 0.25, alpha: 1),
            PlatformColor(red: 0.26, green: 0.48, blue: 0.39, alpha: 1),
            PlatformColor(red: 0.64, green: 0.53, blue: 0.25, alpha: 1)
        ]
        return palette[seed % palette.count]
    }
}
