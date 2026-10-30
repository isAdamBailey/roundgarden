# RealityKit renderer spike

Disposable SwiftUI + RealityKit prototype for the Phase 2 renderer decision. The same source builds for iOS and macOS. It exercises a full-sphere perspective camera, procedural radial foliage and produce, directional and point lighting, and drag-to-look input. Tap/click is a temporary interaction stand-in; production target selection and scoring remain out of scope.

## Build and run

Open `RealityKitSpike.xcodeproj` in Xcode and select `RealityKitSpike_iOS` for an iPhone/iPad simulator or `RealityKitSpike_macOS` for Mac. The deployment targets are iOS 18 and macOS 15, matching the provisional ADR proposal. The project is generated from `project.yml` with XcodeGen.

## Initial results

- The shared scene compiles for macOS and iOS Simulator with the proposed deployment targets.
- The app launches on an iPhone 17 Pro simulator (iOS 26.5). Drag gestures rotate the camera; a tap increments the temporary light counter.
- The screenshot shows the procedural foliage field and moving produce on iPhone 17 Pro Simulator.

![iPhone 17 Pro simulator capture](screenshots/iphone-17-pro.png)

## Limits and next checks

The latest pass adds a seven-leaf clustered canopy modeled on the web distribution, explicit leaf normals, a nine-color palette, raised midribs, directional shadows, and a larger near-field produce pod. The capture has more color and depth, but still does not match the web scene and the composition appears clipped. Treat this as an incremental renderer evaluation, not a visual-quality pass. Target selection, safe-area composition, and frame rate on representative iPhone/iPad and Mac hardware still need validation before adopting RealityKit or changing the proposed renderer decision.
