# Phase 2 spike: RealityKit prototype

- **Status:** In progress; renderer choice remains provisional.
- **Date:** 2026-10-29
- **Related:** [ADR 0001](0001-native-rendering.md), [issue #1](https://github.com/isAdamBailey/roundgarden/issues/1)

## Question

Can one SwiftUI + RealityKit scene compile and run on both proposed native platforms while supporting the basic 360-degree garden view and platform touch/drag input?

## Prototype

`spikes/RealityKitSpike` contains one small Xcode project with iOS and macOS targets sharing the same Swift source. The scene has an inward-facing sphere, radially distributed primitive foliage, directional and point lights, a center target pod, a perspective camera near the sphere center, drag-to-look, and a temporary tap/click counter.

## Evidence so far

- `xcodebuild -project RealityKitSpike.xcodeproj -scheme RealityKitSpike_macOS -destination 'generic/platform=macOS' build` — passed on Xcode 27.0 SDK, with deployment target macOS 15.
- `xcodebuild -project RealityKitSpike.xcodeproj -scheme RealityKitSpike_iOS -destination 'platform=iOS Simulator,id=<iPhone 17 Pro>' build` — passed on Xcode 27.0 SDK, with deployment target iOS 18.
- Installed and launched on iPhone 17 Pro simulator running iOS 26.5; screenshot saved under the spike folder.
- The screenshot shows the target in the scene and readable overlay controls, but foliage is sparse and the shell reads as a dark flat background.

## Decision

This is not enough evidence to accept or reject RealityKit. Keep ADR 0001's recommendation provisional. The cross-platform compile and first simulator launch remove basic API uncertainty, but do not establish visual parity, input arbitration, occlusion-safe picking, lighting/shadow quality, transparency, or performance.

## Remaining validation

1. Add moving produce, a transparent greenhouse cue, and a representative plant/branch asset; evaluate material behavior and whether decoration can occlude valid targets.
2. Test touch drag/tap and mouse/trackpad drag/click on actual interactive runs on iPhone, iPad, and Mac.
3. Record frame time and memory on representative devices with a denser scene and shadows enabled; compare against a focused Metal prototype if RealityKit misses the performance or visual bar.
4. Update ADR 0001 with measured results, final renderer, deployment floor, and asset pipeline before creating production app targets.
