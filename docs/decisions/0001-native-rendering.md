# ADR 0001: Native rendering and shared game assets

- **Status:** Accepted for Phase 3; physical iOS performance and oldest-OS runtime checks remain release follow-ups.
- **Date:** 2026-10-29
- **Reviewed:** 2026-10-30
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

Use RealityKit with SwiftUI for the Phase 3 native vertical slices. Reopen the renderer choice if interactive target selection, material quality, or representative-device profiling shows that RealityKit cannot meet the product needs; compare a focused Metal prototype against the same criteria before changing course.

### Phase 2 decision — 2026-10-30

Choose RealityKit for Phase 3. Both native targets compile, the scene has been reviewed in iPhone 17 Pro and iPad Pro 11-inch simulators and a resizable Mac window, and a live Mac run confirmed that mouse drag rotates the garden. The visual pass fixes the iPhone's legacy 2:3 viewport crop and brings the garden edge-to-edge across iPhone and iPad sizes. Simulator captures show the produce, foliage, lighting, and greenhouse cues; they do not establish final visual parity.

The owner approved proceeding without physical iPhone/iPad verification in this process. No physical iOS frame-time or memory measurements were collected, and the available Instruments trace did not provide a reliable performance sample. Carry physical-device profiling into release readiness. Phase 3 must validate touch handling and implement target selection that ignores foliage and greenhouse geometry; the current spike has no target-picking system. Reopen the renderer comparison if those checks reveal a material or performance gap. See the [spike record](0002-realitykit-spike.md) for evidence and follow-ups.

Set the initial deployment floors to **iOS 18 / macOS 15**. Both targets compile with these deployment settings and the selected Xcode SDK; runtime review used iOS 26.5 simulators and the macOS 27 SDK, so the oldest supported runtime versions were not exercised. Revisit the floor if Phase 3 API availability or release-device coverage requires it.

For Phase 3, keep renderer-independent produce identifiers, palettes, tuning values, and procedural-generation inputs in a shared data/package layer; keep the web Three.js implementation in `apps/web`; place authored interchange assets under `packages/assets`, retain editable USD sources, and package USDZ for native delivery where appropriate. Record provenance and licenses in `docs/ASSETS.md`. Native and web renderers may use platform-specific geometry/material derivatives from the same source description; verify the derivatives visually rather than assuming identical USD material behavior.

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

Use **iOS 18 / macOS 15** as the initial native deployment floors. This is a product support choice, not a claim that RealityKit requires those versions. It gives the first native release a recent, common platform baseline and avoids spending Phase 3 on older-system compatibility. Confirm API availability against the selected Xcode SDK during Phase 3. Apple release notes document RealityKit behavior changes between iOS 17/macOS 14 and iOS 18/macOS 15, including transparency behavior, so review materials on the oldest available runtime before release ([macOS 15 release notes](https://developer.apple.com/documentation/macos-release-notes/macos-15-release-notes)).

## Consequences

- Native visual code will not be shared directly with the Three.js renderer; gameplay rules and content parameters can be shared within the native apps.
- The team avoids starting new work on deprecated SceneKit and avoids owning a full custom Metal engine before the game's needs justify it.
- RealityKit is selected for Phase 3, with physical iOS performance, oldest-OS runtime, and occlusion-safe target picking still unverified.
- The initial deployment floors are iOS 18 and macOS 15; revisit them if compatibility evidence or audience needs warrant a change.

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
