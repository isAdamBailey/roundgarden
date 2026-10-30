# Existing game inventory and native parity gaps

This inventory records the current web game as the behavior and visual reference for future native work. It is scoped to Phase 0 of issue #1; it does not start native implementation.

## Current web features

| Area | Current behavior |
| --- | --- |
| Runtime | Vite page with a Three.js scene rendered in a full-window canvas. |
| Web product role | The current page is the playable browser game. It should remain playable and also become the public landing page for the iOS and macOS apps, following the existing FrameBeat web-and-marketing-site pattern. Native store links should appear when those releases are available. |
| View | Perspective camera at the sphere center; yaw rotates freely and pitch is clamped. Pointer drag works with mouse and touch. |
| Garden | Procedural greenhouse dome and glass shell, ribs, instanced foliage and veins, vines, flowers, pollen, and woody branches. |
| Produce | Twelve procedural drifting pods with several silhouettes, color families, tendrils, leaves, close-range veins and freckles, approach scaling, and target shimmer. |
| Targeting | Center-screen ray targets produce meshes only. Decorative leaves and branches are excluded from the gameplay raycast. Reach is limited to 12.8 scene units. |
| Round | A 60-second timer, 100/250/500 point values, a 1×/2×/3× proximity multiplier, pause/resume, local personal best, completion panel, and fresh replay. Produce drifts slowly before play and approaches faster during an active round; motion pauses with the round. |
| Feedback | Target value and proximity multiplier at the reticle, vaporization points and light burst, optional synthesized sound, timer urgency, toast messages, and a final score/personal-best recap. |
| Accessibility and layout | Semantic headings and buttons, accessible labels on the canvas and controls, keyboard focus styling, reduced-motion CSS, and responsive welcome/HUD styling. |

## Procedural content and assets

- No external game art or 3D asset files are currently checked in; record any future third-party content in [the asset register](ASSETS.md). The garden, plants, branches, pods, pollen, and vaporization effects are generated from Three.js geometry and materials in `apps/web/src/main.js`.
- The web scene uses renderer-specific materials, instancing, shaders, lights, and shadow settings. These objects cannot be reused directly by a native renderer.
- Reusable content meaning exists in the palette, produce profile arrays, plant curves, scene dimensions, and gameplay tuning, but it is currently embedded in JavaScript rather than stored as a shared content schema.
- Fonts are loaded from Google Fonts in `apps/web/index.html`; the experience therefore has a network-dependent typography fallback. No licensing or attribution inventory for art assets is needed yet, but one will be needed before adding external assets.

## Performance constraints and observed baseline

- Repeated garden content is instanced to reduce draw calls. Main foliage instances cast and receive shadows; the compact canopy does not cast shadows.
- The directional light uses a 4096² shadow map on desktop and 2048² on narrow/coarse-pointer devices. Renderer pixel ratio is capped at 1.75 on desktop and 1.35 on narrow screens.
- The scene allocates substantial repeated geometry and material detail during setup. No device benchmark, frame-time target, memory budget, or automated performance profile is recorded yet.
- `npm run build` succeeds. Vite warns that the generated Three.js chunk is over 500 kB minified; this is a web delivery/performance follow-up, not a blocker for documenting native parity.
- The native spike should measure frame time, memory, load time, shadow quality, and thermal behavior on representative iPhone/iPad and Mac hardware before fixing production quality tiers.

## Native parity gaps

1. **No native projects or shared native modules exist.** There is no `.xcodeproj`, Swift package, app target, signing setup, or native CI configuration in this checkout.
2. **Pause and lifecycle handling need native parity.** The web round has an on-screen pause control, Escape behavior, and pause-on-backgrounding. The native clients must match these shared round rules.
3. **Core rules are coupled to the web scene.** Timer, score, target activation decisions, produce motion, and UI state are implemented in `apps/web/src/main.js`; there is no renderer-independent game model that native clients can consume.
4. **Native asset parity is unproven.** There are no USD/USDZ assets or shared semantic asset definitions. Procedural shapes and Three.js shader/material choices need a native representation and visual comparison.
5. **Native input and camera parity are unproven.** There is no iOS touch or macOS mouse/trackpad implementation, 360-degree native camera, center reticle, or occlusion-independent native target query.
6. **Native accessibility and platform behavior are unproven.** The web has basic labels and reduced-motion styling, but there is no VoiceOver, keyboard navigation, window resizing, safe-area, pause menu, or native focus behavior to assess.
7. **Performance evidence is missing.** The desktop/mobile web quality caps are known, but native device performance and memory are not measured.
8. **The web landing page is not built yet.** The current full-screen game page does not explain the native platform options or provide store calls to action. Add this after app availability is known while preserving the browser game as a first-class way to play.

## Validation baseline for the spike

The renderer spike should compare its implementation with the web behavior for a full round and document:

- 360-degree look and comfortable input response on an iPhone/iPad and a Mac.
- One complete 60-second round, including aim, reachable target activation, score, pause/background, resume, completion, and fresh replay.
- Clear near/middle/far produce scale and detail, warm directional light, greenhouse depth, and visible but non-blocking foliage occlusion.
- Frame time, memory, startup time, shadow behavior, and thermal stability on representative devices.
- Accessibility and window/safe-area behavior appropriate to each platform.

The detailed gameplay rules are in [the shared gameplay contract](GAMEPLAY-CONTRACT.md), and the renderer options and proposed minimum OS versions are in [ADR 0001](decisions/0001-native-rendering.md).
