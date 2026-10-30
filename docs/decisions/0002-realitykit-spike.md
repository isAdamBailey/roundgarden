# Phase 2 spike: RealityKit prototype

- **Status:** Phase 2 complete by owner-approved deferral of physical iOS checks; RealityKit selected for Phase 3.
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
- Native and web GitHub Actions builds passed for the merged visual follow-up (PR #6) and the Phase 2 visual/CI pass (PR #7).
- The earlier capture had more layered color and a readable near-field pod, but the iPhone viewport was cropped. The 2026-10-30 visual pass replaced repeated leaf silhouettes with three foliage shapes, weighted the palette toward green, added a continuous dark backdrop, and fixed full-display composition on iPhone and iPad; the macOS window was also reviewed.
- On 2026-10-30, local `xcodebuild` builds passed for `RealityKitSpike_iOS` on the iPhone 17 Pro simulator destination and `RealityKitSpike_macOS` with a generic macOS destination. The iOS app launched on the iPhone 17 Pro simulator running iOS 26.5 and rendered the scene.
- Generated launch-screen metadata and iOS-only safe-area filling resolved the iPhone's black bands while keeping the Mac HUD below the title bar. Fresh iPhone, iPad, and Mac captures are saved under `spikes/RealityKitSpike/screenshots/`. A live Mac run confirmed mouse drag rotates the garden, produce continues moving, and click updates the temporary counter. The dome and ribs were visually reviewed on iPad and Mac. Xcode reports no connected physical iPhone/iPad; a Game Performance trace on the simulator emitted a missing-input-source warning and did not provide a reliable frame-rate sample. No physical-device frame-time or memory measurements were collected.
- Native CI now lints Swift with `xcrun swift-format` and builds both iOS Simulator and macOS targets. Local instructions document format and build commands and note that physical-device installation requires an Apple development team and provisioning profile.
- The owner approved proceeding without physical iPhone/iPad validation in this process. This is a documented deviation, not a claim that physical performance was measured.

## Decision

Proceed to Phase 3 with RealityKit and SwiftUI. Cross-platform builds, simulator launches, full-display composition review, and a live Mac pointer-input check establish enough renderer and layout evidence for the next implementation phase. The owner approved moving past physical iOS verification in this process. Physical device performance, iPhone/iPad touch behavior, and runtime behavior on the oldest supported OS versions remain unverified. Produce currently drifts and floats but does not simulate approaching and scaling toward the player. The tap counter is still a temporary stand-in, so the spike does not demonstrate target picking or occlusion-safe selection.

The dome, ribs, leaves, and branches are decorative entities; source inspection found no collision components, raycast, or target hit-testing code. They cannot intercept the spike's current global click counter, but visual target occlusion cannot be tested until Phase 3 target selection exists. Phase 2 records that limitation and carries the target-selection check forward.

## Follow-up validation for Phase 3 and release readiness

1. In Phase 3, implement target picking that checks produce independently of foliage and greenhouse ribs; verify a valid target remains selectable behind decoration.
2. Add the approaching/scale-up produce behavior to the playable round and verify the distance cue.
3. Verify touch drag/tap on iPhone and iPad in simulator and mouse/trackpad input on Mac; the current interactive check covers Mac only.
4. Before release, measure frame time and memory on physical iPhone/iPad and representative Mac hardware with shadows enabled; compare a focused Metal prototype only if results miss the performance or visual bar.
5. Verify API availability and material behavior on the oldest supported OS versions when those runtimes or devices are available.
