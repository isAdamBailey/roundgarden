# RealityKit renderer spike

Disposable SwiftUI + RealityKit prototype for the Phase 2 renderer decision. The same source builds for iOS and macOS. It exercises a full-sphere perspective camera, radial procedural foliage, warm directional and point lighting, a visible target behind decorative growth, and drag-to-look input. Tap/click is a temporary interaction stand-in; production target selection and scoring remain out of scope.

## Build and run

Open `RealityKitSpike.xcodeproj` in Xcode and select `RealityKitSpike_iOS` for an iPhone/iPad simulator or `RealityKitSpike_macOS` for Mac. The deployment targets are iOS 18 and macOS 15, matching the provisional ADR proposal. The project is generated from `project.yml` with XcodeGen.

## Initial results

- The shared scene compiles for macOS and iOS Simulator with the proposed deployment targets.
- The app launches on an iPhone 17 Pro simulator (iOS 26.5). Drag gestures rotate the camera; a tap increments the temporary light counter.
- The screenshot shows a lit target pod at a garden scale and proves that the same SwiftUI/RealityKit source runs on iOS.

![iPhone 17 Pro simulator capture](screenshots/iphone-17-pro.png)

## Limits and next checks

The scene intentionally uses low-cost primitives. The screenshot reveals sparse foliage and a flat-looking shell; this is a capability check, not a visual-quality pass. It does not yet prove production foliage quality, transparent greenhouse materials, shadows, animated produce, real target selection, or frame rate on representative iPhone/iPad and Mac hardware. Measure those before adopting RealityKit for production or changing the proposed renderer decision.
