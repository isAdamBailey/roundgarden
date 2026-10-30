# Phase 2 spike: RealityKit prototype

- **Status:** In progress; renderer choice remains provisional.
- **Date:** 2026-10-29
- **Related:** [ADR 0001](0001-native-rendering.md), [issue #1](https://github.com/isAdamBailey/roundgarden/issues/1)

## Question

Can one SwiftUI + RealityKit scene compile and run on both proposed native platforms while supporting the basic 360-degree garden view and platform touch/drag input?

## Prototype

`spikes/RealityKitSpike` contains one small Xcode project with iOS and macOS targets sharing the same Swift source. The scene has an inward-facing sphere, radially distributed primitive foliage, directional and point lights, a center target pod, a perspective camera near the sphere center, drag-to-look, and a temporary tap/click counter.

The current prototype animates multiple produce entities and uses curved leaf meshes, radial stems, veins, flowers, vines, a gradient dome, segmented greenhouse ribs, and instancing on iOS 26/macOS 26 and newer. These generated forms probe renderer behavior; they are not proposed production art. The iPhone capture still looks substantially different from the web game: its leaves read as repeated small silhouettes, the background lacks the web scene's depth, and the greenhouse is difficult to perceive.

## Evidence so far

- `xcodebuild` for `RealityKitSpike_macOS` with destination `generic/platform=macOS` — passed locally on Xcode 27.1, with deployment target macOS 15.
- `xcodebuild` for `RealityKitSpike_iOS` with an iPhone 17 Pro simulator destination — passed locally on Xcode 27.1, with deployment target iOS 18.
- Installed and relaunched on the iPhone 17 Pro simulator running iOS 26.5; the latest capture is `screenshots/iphone-17-pro.png`. It confirms that the richer procedural scene renders, but it does not pass visual parity.
- Added `.github/workflows/native-spike.yml` to build both targets on macOS GitHub runners when the spike changes. CI has not run for this update yet.
- The capture shows radial foliage and animated produce. The canopy still reads as repeated silhouettes; the gradient dome and greenhouse ribs do not establish the web look, production quality, or useful depth cues.

## Decision

This is not enough evidence to accept or reject RealityKit. Keep ADR 0001's recommendation provisional. The cross-platform compile and simulator launch remove basic API uncertainty, but do not establish visual parity, input arbitration, occlusion-safe picking, lighting/shadow quality, a useful greenhouse transparency treatment, or device performance.

## Remaining validation

1. Rework the native foliage and lighting against a side-by-side web capture; keep the spike open until the scene has recognizable depth and leaf silhouettes.
2. Inspect the dome/ribs on iPad and Mac, then evaluate whether decoration can occlude valid targets.
3. Test touch drag/tap and mouse/trackpad drag/click in interactive runs on iPhone, iPad, and Mac. Simulator input and one simulator screenshot do not establish hardware behavior.
4. Record frame time and memory on representative devices with shadows enabled; compare against a focused Metal prototype if RealityKit misses the performance or visual bar.
5. Update ADR 0001 with measured results, final renderer, deployment floor, and asset pipeline before creating production app targets.
