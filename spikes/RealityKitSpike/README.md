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

The foliage now uses a curved leaf mesh, stems, veins, flowers, vines, a gradient dome, greenhouse ribs, and instancing on newer OS versions. The screenshot still does not match the web scene: the canopy reads as repeated small silhouettes, the backdrop is flat, and the greenhouse cue is hard to see. Treat this as a renderer capability check, not a visual-quality pass. Shadows, target selection, safe-area composition, and frame rate on representative iPhone/iPad and Mac hardware still need validation before adopting RealityKit or changing the proposed renderer decision.
