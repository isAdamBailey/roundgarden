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
| Mid approach | Freckles appear inside 19 units, leaf veins inside 11.5, and the fruit's apparent size keeps increasing. | Grouped freckles/rib detail appears inside 19 units and the warm center glow inside 12; pods keep growing and their aim radius grows with the visible scale. | Detail begins before target reach, making the approach readable without changing which objects can be selected. |
| Reach and aim | Center ray selects produce within 12.8 units; foliage and greenhouse ribs are excluded. | `AimSelector` checks only produce spheres within 12.8 units; decorative geometry is not part of the query. | A centered produce target remains selectable through the canopy. The iPhone UI flow activated a centered oddity and observed a score change. |
| Proximity feedback | Centered value and `×1`, `×2`, or `×3` use hit-distance bands above 8.5, from 4.2–8.5, and at or below 4.2 units. | Shared `RoundState` uses the same bands and values. | The current iPhone screenshot shows a centered 100-point target; shared-core tests cover the 1×/2×/3× boundaries. |
| Vaporize and return | The produce disappears, emits 14 randomly directed octahedra and score feedback, then returns at a random far bearing after about 760 ms. Objects that pass 1.45 units also reset to a random far bearing. | The produce hides for 700 ms while 14 same-color sparks travel outward by 1.6–4.7 units and shrink to a point; score text and success haptic fire immediately. The oddity then continues its deterministic cyclic path at the same bearing. | Burst count, color, approximate travel envelope, and duration track the web effect. Native sparks use reusable spheres and stable directions instead of randomized octahedra; shrinking approximates the web's opacity fade. Native oddities keep a deterministic path instead of the web's randomized respawn. |

Both renderers show value feedback only while a target is centered and reachable.
In the native capture, the centered target stays legible against overlapping
leaves, and the HUD remains readable across the wide iPhone layout. The 74°
camera field of view matches the web camera.

## Visual evidence

- iPhone 17 Pro Simulator, iOS 26.5: [gameplay capture](../apps/ios/screenshots/phase5-gameplay-flow.png)
- macOS iOS-comparison gameplay capture: [gameplay flow](../apps/macos/screenshots/phase5-gameplay-flow.png)
- Earlier macOS full-canopy comparison: [Phase 5 canopy capture](../apps/macos/screenshots/phase5-shadow-canopy.png)
- Web reference: `npm run dev` from the repository root, then enter a round. Compared the current live web scene against the native captures and reviewed the source animation for scale, detail thresholds, score bands, burst travel, and return timing.

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

- `xcodebuild -project apps/ios/Roundgarden.xcodeproj -scheme Roundgarden -sdk iphonesimulator -configuration Debug -destination 'platform=iOS Simulator,id=3560A3A8-03FB-4A00-9178-092115E8B159' -derivedDataPath /tmp/roundgarden-phase5-ios build CODE_SIGNING_ALLOWED=NO` passed.
- `xcodebuild -project apps/macos/RoundgardenMac.xcodeproj -scheme RoundgardenMac -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/roundgarden-phase5-macos build CODE_SIGNING_ALLOWED=NO` passed.
- `xcodebuild test -project apps/ios/Roundgarden.xcodeproj -scheme Roundgarden -destination 'platform=iOS Simulator,id=3560A3A8-03FB-4A00-9178-092115E8B159' -derivedDataPath /tmp/roundgarden-phase5-ios -resultBundlePath /tmp/roundgarden-phase5-burst-capture.xcresult -only-testing:RoundgardenUITests/RoundgardenUITests/testTouchCanStartRoundVaporizeCenteredOddityPauseAndReturnToMenu CODE_SIGNING_ALLOWED=NO` passed (1 test, 0 failures).
- iPhone 17 Pro / iOS 26.5 UI flow passed: enter, start, activate a centered
  oddity, confirm the score changes, pause/resume, rotate, and return to menu.
  The simulator screenshot and UI test confirm selection and score feedback;
  they do not establish physical-device frame time or memory.
- A live macOS check activated the centered 100-point oddity at 2×; score
  advanced from 0 to 200 and the “vaporized into light” message appeared. The transient burst
  timing was reviewed in source; the live capture followed the 700 ms effect.
- `swift test --package-path packages/game-core` passed (9 tests).
- `npm run build` passed; Vite reported the existing Three.js bundle size warning.
- `xcrun swift-format lint --strict apps/shared/GardenSceneView.swift` and
  `git diff --check` passed.
- Attempted `xcodebuild test -project apps/macos/RoundgardenMac.xcodeproj -scheme RoundgardenMac -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/roundgarden-phase5-macos -only-testing:RoundgardenMacUITests/RoundgardenMacUITests/testAccessibleCenteredOddityActionVaporizesTarget CODE_SIGNING_ALLOWED=NO`; the UI-test runner was killed before connecting to the app. The macOS Debug build and live gameplay capture passed, but this UI test is inconclusive.
- Physical iPhone/iPad performance and memory validation remains deferred to
  Phase 7 as approved in issue #1.
