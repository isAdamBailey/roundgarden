# Phase 2 spike: RealityKit prototype

- **Status:** In progress; renderer choice remains provisional.
- **Date:** 2026-10-29; validation updated 2026-10-30
- **Related:** [ADR 0001](0001-native-rendering.md), [issue #1](https://github.com/isAdamBailey/roundgarden/issues/1)

## Question

Can one SwiftUI + RealityKit scene compile and run on both proposed native platforms while supporting the basic 360-degree garden view and platform touch/drag input?

## Prototype

`spikes/RealityKitSpike` contains one small Xcode project with iOS and macOS targets sharing the same Swift source. The scene has an inward-facing sphere, radially distributed primitive foliage, directional and point lights, a center target pod, a perspective camera near the sphere center, drag-to-look, and a temporary tap/click counter.

The current prototype animates multiple produce entities and uses curved leaf meshes with explicit normals, a clustered inner-glass canopy, radial stems, veins, flowers, vines, a gradient dome, segmented greenhouse ribs, a nine-color foliage palette, directional shadows, and instancing on iOS 26/macOS 26 and newer. The inner canopy now follows the web renderer's seven-leaf cluster layout and distribution. These generated forms probe renderer behavior; they are not proposed production art. The iPhone capture has more color, surface definition, and depth than the first port, but still looks different from the web garden and retains a clipped-looking composition.

## Evidence so far

- `xcodebuild` for `RealityKitSpike_macOS` with destination `generic/platform=macOS` — passed locally on Xcode 27.1, with deployment target macOS 15.
- `xcodebuild` for `RealityKitSpike_iOS` with an iPhone 17 Pro simulator destination — passed locally on Xcode 27.1, with deployment target iOS 18.
- Installed and relaunched on the iPhone 17 Pro simulator running iOS 26.5; the latest capture is `screenshots/iphone-17-pro.png`.
- Side-by-side review with the web app informed a seven-leaf canopy cluster layout, explicit leaf normals, nine-color foliage palette, raised midribs, directional shadows, and a larger near-field produce pod.
- Native and web GitHub Actions builds passed for the merged visual follow-up (PR #6).
- The earlier capture had more layered color and a readable near-field pod, but the iPhone viewport was cropped. The 2026-10-30 visual pass replaced repeated leaf silhouettes with three foliage shapes, weighted the palette toward green, added a continuous dark backdrop, and fixed full-display composition on iPhone and iPad; the macOS window was also reviewed.
- On 2026-10-30, local `xcodebuild` builds passed for `RealityKitSpike_iOS` on the iPhone 17 Pro simulator destination and `RealityKitSpike_macOS` with a generic macOS destination. The iOS app launched on the iPhone 17 Pro simulator running iOS 26.5 and rendered the scene.
- Generated launch-screen metadata and iOS-only safe-area filling resolved the iPhone's black bands while keeping the Mac HUD below the title bar. Fresh iPhone, iPad, and Mac captures are saved under `spikes/RealityKitSpike/screenshots/`. A live Mac run confirmed mouse drag rotates the garden, produce continues moving, and click updates the temporary counter. iPhone/iPad touch input, accurate target selection, transparency/shadow quality, and target-device performance remain unverified. No physical-device frame-time or memory measurements were collected.
- Native CI now lints Swift with `xcrun swift-format` and builds both iOS Simulator and macOS targets. Local instructions document format and build commands and note that physical-device installation requires an Apple development team and provisioning profile.

## Decision

This is not enough evidence to accept or reject RealityKit. Keep ADR 0001's recommendation provisional, with RealityKit as the lead candidate for the next spike pass. Cross-platform builds, simulator launches, and full-display composition review reduce basic API and layout uncertainty, but do not establish visual parity, input arbitration, occlusion-safe picking, lighting/shadow quality, a useful greenhouse transparency treatment, oldest-OS compatibility, or device performance. The iOS 18/macOS 15 deployment settings compile, but the current run used an iOS 26.5 simulator and macOS 27 SDK rather than those minimum runtime versions.

## Remaining validation

1. Review the new foliage and composition against side-by-side web captures across native sizes; the pass improves depth and silhouettes but does not establish final visual parity.
2. Inspect the dome/ribs and transparency on iPad and Mac. Target picking is not implemented, so occlusion of valid targets cannot yet be evaluated.
3. Mac mouse drag and click are confirmed in a live run; test touch drag/tap on iPhone and iPad and mouse/trackpad behavior on representative Macs. Target selection remains unimplemented.
4. Record frame time and memory on representative devices with shadows enabled; compare against a focused Metal prototype if RealityKit misses the performance or visual bar.
5. Update ADR 0001 with measured results, final renderer, deployment floor, and asset pipeline before creating production app targets.
