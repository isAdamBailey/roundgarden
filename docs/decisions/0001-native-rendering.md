# ADR 0001: Native rendering and shared game assets

- **Status:** Proposed; validate with the Phase 2 rendering and input spike before creating production app targets.
- **Date:** 2026-10-29
- **Scope:** iOS and macOS native game clients.

## Context

The existing browser game is built with Three.js and Vite. It uses a continuously animated, procedural 360-degree greenhouse, drifting produce, a center reticle, and click/tap catching. The native clients need the same round rules and recognizable visual direction while adopting platform-appropriate controls. The browser implementation remains the behavior reference; this decision does not replace or migrate it.

## Options considered

| Option | Strengths | Costs and risks |
| --- | --- | --- |
| **RealityKit with SwiftUI** | Apple positions RealityKit for 3D apps and games across iOS and macOS. `RealityView` hosts 3D content on both platforms; RealityKit supports custom meshes, materials, entity systems, and USD assets. SwiftUI can provide each platform's surrounding interface and input handling. | RealityKit's material, shader, lighting, and mesh-instancing behavior must be checked against this game's procedural scene. Translating the Three.js scene is still a rewrite; API similarity does not imply visual parity. |
| **Custom Metal / MetalKit** | Direct GPU control and a shared low-level graphics API; `MTKView` is available as a view on iOS and macOS. Offers the most control over custom shaders and rendering. | Requires building and maintaining the scene graph, material system, asset loading, animation/update loop, and many rendering features ourselves. This is disproportionate for the current small game and raises the cost of reaching feature parity. |
| **SceneKit** | High-level 3D scene descriptions and game-oriented features; its scene graph is conceptually close to the current Three.js scene. | Apple has deprecated SceneKit and recommends RealityKit for new projects. Starting a new game on a deprecated framework creates avoidable long-term risk. |
| **Reuse the web renderer in a web view** | Reuses the current Three.js code and visuals with the least rendering rewrite. | It would wrap the browser experience rather than provide the requested native rendering and platform integration. Keep it as a possible temporary prototype only if native renderer evaluation needs a visual reference. |

Apple describes [RealityKit](https://developer.apple.com/documentation/realitykit/realityview) as a 3D framework, with `RealityView` support on both iOS and macOS. It supports [custom mesh resources](https://developer.apple.com/documentation/realitykit/scene-content-models-and-meshes), and its [systems](https://developer.apple.com/documentation/realitykit/system) update entities as part of scene updates. Apple documents [Metal](https://developer.apple.com/documentation/metal) as its lower-level GPU API and [MetalKit's `MTKView`](https://developer.apple.com/documentation/metalkit/mtkview) as the view that manages drawable presentation. Apple marks [SceneKit deprecated](https://developer.apple.com/documentation/scenekit) and recommends RealityKit for new projects.

## Proposed direction

Use **RealityKit for native 3D rendering**, embedded in **SwiftUI** screens. Keep round rules, timer, scoring, and produce motion in a renderer-independent Swift package that both app targets can use. Use RealityKit entities/components/systems to represent and update the native scene. Use SwiftUI for onboarding, HUD, pause/replay controls, and accessibility.

This is a recommendation to validate, not a final renderer commitment. The Phase 2 spike must prove a full-sphere camera, procedural foliage and produce, distance-aware detail, catch targeting that ignores decorative occluders, lighting/shadows, and representative device performance. If RealityKit cannot meet those scene or performance needs without awkward workarounds, compare a focused Metal renderer against the same spike criteria before committing.

## Input and platform adaptation

- **iOS:** touch drag turns the view; a tap without a meaningful drag attempts to catch the centered reachable produce. Put pause and other round controls in visible, accessible SwiftUI buttons.
- **macOS:** mouse or trackpad drag turns the view; click attempts a catch. Provide keyboard navigation and an Escape pause/resume shortcut alongside visible controls.
- **Both:** share the same aim vector, catch radius, score changes, timer behavior, pause semantics, and 360-degree camera rules. A foliage or branch mesh must not prevent a valid produce catch.

These are product decisions aligned with the [shared gameplay contract](../GAMEPLAY-CONTRACT.md). Apple provides [SwiftUI gestures](https://developer.apple.com/documentation/swiftui/gestures) for taps and drags and [hardware keyboard input](https://developer.apple.com/documentation/swiftui/input-events); its platform overview describes touch as the primary iPad input and mouse/keyboard as the primary Mac inputs ([SwiftUI platform overview](https://developer.apple.com/documentation/technologyoverviews/swiftui)). Exact gesture arbitration and macOS keyboard behavior remain spike validation items.

## Shared asset strategy

- Author or export hand-made 3D assets as **USD/USDZ**, with USDZ for packaged assets. Apple identifies USD as its format of choice for 3D content and RealityKit apps ([USD overview](https://developer.apple.com/documentation/usd), [Apple USD asset guidance](https://developer.apple.com/documentation/usd/creating-usd-files-for-apple-devices)).
- Keep palette values, produce-family identifiers, procedural parameters, and gameplay tuning in renderer-independent data files or the shared Swift package. Both native apps should consume the same data.
- Recreate the current procedurally generated plants and produce with shared Swift generation code where practical; do not require a single baked mesh for geometry that needs to animate or vary at runtime.
- Keep web-specific Three.js code and assets in the web app. Share source assets and semantic parameters, not renderer-specific runtime objects or an assumption that a USD material will look identical in Three.js and RealityKit.
- Validate USD materials, transparency, scale, coordinate conventions, and performance in RealityKit itself. Apple's guidance notes that renderer support for USD features varies and recommends testing in the target renderer.

## Minimum OS proposal

Start the native spike and project configuration at **iOS 18 / macOS 15**. This is a product support-floor proposal, not a claim that RealityKit requires those versions. It gives the first native release a recent, common platform baseline and avoids spending the prototype on older-system compatibility. Confirm API availability against the selected Xcode SDK and revisit the floor after the spike and audience review. Apple release notes document RealityKit behavior changes between iOS 17/macOS 14 and iOS 18/macOS 15, including transparency behavior, so the spike must specifically validate materials on the proposed baseline ([macOS 15 release notes](https://developer.apple.com/documentation/macos-release-notes/macos-15-release-notes)).

## Consequences

- Native visual code will not be shared directly with the Three.js renderer; gameplay rules and content parameters can be shared within the native apps.
- The team avoids starting new work on deprecated SceneKit and avoids owning a full custom Metal engine before the game's needs justify it.
- RealityKit suitability remains unproven until the Phase 2 spike meets the visual and performance criteria on representative iPhone/iPad and Mac hardware.
- The minimum OS proposal is provisional and should be confirmed before the app targets and store metadata are finalized.

## References

- [RealityView](https://developer.apple.com/documentation/realitykit/realityview)
- [RealityKit models and meshes](https://developer.apple.com/documentation/realitykit/scene-content-models-and-meshes)
- [RealityKit systems](https://developer.apple.com/documentation/realitykit/system)
- [Metal](https://developer.apple.com/documentation/metal)
- [MetalKit MTKView](https://developer.apple.com/documentation/metalkit/mtkview)
- [SceneKit deprecation](https://developer.apple.com/documentation/scenekit)
- [SwiftUI gestures](https://developer.apple.com/documentation/swiftui/gestures)
- [SwiftUI input events](https://developer.apple.com/documentation/swiftui/input-events)
- [SwiftUI platform overview](https://developer.apple.com/documentation/technologyoverviews/swiftui)
- [USD overview](https://developer.apple.com/documentation/usd)
- [Apple USD asset guidance](https://developer.apple.com/documentation/usd/creating-usd-files-for-apple-devices)
- [macOS 15 release notes: RealityKit behavior](https://developer.apple.com/documentation/macos-release-notes/macos-15-release-notes)
