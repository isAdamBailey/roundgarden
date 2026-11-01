# Phase 5 gameplay flow review

Reviewed 2026-11-01 against the web game, the shared RealityKit scene, the
gameplay contract, a fresh iPhone 17 Pro Simulator capture, and a live macOS
gameplay view.
The web scene remains the visual reference; native input, HUD placement, and
accessibility controls follow each platform.

## Matched object states

| State | Web | iOS and macOS | Review |
| --- | --- | --- | --- |
| Far approach | Oddities enter at randomized 17–38 unit distances. Their size grows with the clamped `(31 / distance)^0.4` curve. | Twelve oddities use a deterministic spherical layout; one starts at 10.5 units and the rest at 28–36.4. They now use the same distance growth curve, multiplied by the native family/value scale. | Compared equivalent distances rather than matching elapsed seconds, since spawn placement differs. Far silhouettes remain distinct from foliage. |
| Mid approach | Freckles appear inside 19 units; the fruit's apparent size keeps increasing. | Grouped freckles and rib detail appear inside 19 units; pods keep growing and their aim radius grows with the visible scale. | Detail begins before target reach, making the approach readable without changing which objects can be selected. |
| Reach and aim | Center ray selects produce within 12.8 units; foliage and greenhouse ribs are excluded. | `AimSelector` checks only produce spheres within 12.8 units; decorative geometry is not part of the query. | A centered produce target remains selectable through the canopy. The iPhone UI flow activated a centered oddity and observed a score change. |
| Proximity feedback | Centered value and `×1`, `×2`, or `×3` use hit-distance bands above 8.5, from 4.2–8.5, and at or below 4.2 units. | Shared `RoundState` uses the same bands and values. | The current iPhone screenshot shows a centered 100-point target; shared-core tests cover the 1×/2×/3× boundaries. |
| Vaporize and return | The produce disappears, emits a short light burst and score feedback, then returns at a random far bearing after about 760 ms. Objects that pass 1.45 units also reset to a random far bearing. | The produce is hidden for 700 ms with score feedback, then continues its deterministic cyclic path at the same bearing. | Scoring, target reach, and selection stay the same. The native path is an intentional deterministic presentation adaptation; it does not reproduce the web's randomized choreography. |

Both renderers show value feedback only while a target is centered and reachable.
In the native capture, the centered target stays legible against overlapping
leaves, and the HUD remains readable across the wide iPhone layout. The 74°
camera field of view matches the web camera.

## Visual evidence

- iPhone 17 Pro Simulator, iOS 26.5: [gameplay capture](../apps/ios/screenshots/phase5-gameplay-flow.png)
- macOS full-canopy comparison: [Phase 5 canopy capture](../apps/macos/screenshots/phase5-shadow-canopy.png)
- Web reference: run `npm run dev` from the repository root and enter a round.

## Device detail and limits

Current high-detail native rendering uses 900 plants and 3,200 inner-glass
clusters when RealityKit mesh instancing is available. The merged-mesh fallback
uses 180 plants and 480 clusters to bound static geometry on older supported
systems. Produce detail follows the same near-distance cutoffs on both native
platforms. These settings are visual tiers, not a performance result.

No physical iPhone/iPad was available for frame-time or memory measurements.
The owner-approved Phase 7 follow-up remains open; Simulator screenshots and
builds do not establish mobile-device performance.

## Validation

- iOS Simulator and macOS Debug builds succeeded with Xcode 27.2.
- The iPhone 17 Pro / iOS 26.5 UI flow passed: enter the garden, start a round,
  activate a centered oddity, confirm the score changes, pause/resume, rotate,
  and return to the menu.
- Strict `swift-format lint` passed for the changed shared scene.
- Physical iPhone/iPad performance and memory validation remains deferred to
  Phase 7 as approved in issue #1.
