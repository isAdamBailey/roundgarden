# Phase 6 copy, accessibility, and polish review

**Issue:** [#1 — Plan: monorepo, native Swift apps, and App Store release](https://github.com/isAdamBailey/roundgarden/issues/1)  
**Scope:** Phase 6 copy, accessibility, contrast, motion, localization-readiness, and scene-legibility checklist items across web, iOS, and macOS.

## Result

The current in-game copy is finalized under the owner's 2026-11-01 direction: keep the Soundgarden allusions in original garden, weather, light, distance, and shadow wordplay, while leaving controls and scores direct. The copy names no song or artist and quotes no lyrics.

The web, iOS, and macOS onboarding now share the same garden description and one-minute challenge. Control instructions adapt to click, tap, and macOS arrow keys. The native flow includes a separate ready step before its timed round; the web starts the round from its welcome action. Pause, leave-round, replay, and round-complete wording is aligned. No help or support surface exists in the current apps.

The web copy now sits over a dark blurred backing with enough opacity for small helper text over bright foliage. The status, score and timer, reticle label, active instructions, toast, pause, and end surfaces also use opaque or high-contrast backing. The mobile pause control becomes icon-only below 390 px and retains its accessible label. Native score/timer HUD and target labels use a dark rounded backing over the 3D scene; increased contrast strengthens borders and text, while reduce transparency selects a more opaque surface. Mac keyboard focus on the garden viewport has a visible focus ring.

The public play-first landing page, iOS/macOS access, and web privacy page are tracked separately in Phase 6.1. Store links will be added only when available, and privacy wording will follow a verified data-flow review.

## Accessibility and visual review

- iOS and macOS expose distinct menu headings and controls, named score and time-remaining values, pause/leave/replay controls, vaporize feedback, and an actionable centered oddity. Frequent values are marked as updating so assistive technology can announce changing score/time state.
- The native garden viewport has a name, direction value, default vaporize action, and VoiceOver actions for looking left/right/up/down. On macOS it receives keyboard focus on entry and arrow keys adjust the camera; a visible ring marks keyboard focus.
- macOS accessibility-tree review verified garden focus, the custom “Look left” action, and its updated direction value. iOS UI automation verified the score/time labels, oddity’s activation hint, vaporize action, score change, and feedback label.
- Web review covered desktop and narrow mobile onboarding, active HUD/instructions, and round-end copy over foliage. CSS includes visible keyboard focus, stronger `prefers-contrast: more` styling, and opaque backing for welcome copy. Native HUD and reticle copy use opaque backing over the 3D scene.
- [macOS HUD and gameplay screenshot](../apps/macos/screenshots/phase6-accessibility-hud.png) shows the dark HUD and target backing, plus the visible garden keyboard-focus ring.
- Reduced-motion review: web observes `prefers-reduced-motion`, freezes time-driven scene animation, removes breathing/rotation/shimmer, and shortens CSS animation/transition; native disables menu transition and pauses the scene timeline when Reduce Motion is enabled.
- The English string catalog contains 45 source entries, including extracted SwiftUI copy and interpolation variants, and compiles successfully. This confirms localization-ready key extraction; no non-English translation is claimed.

## Validation

- `PATH=/Users/adambailey/.nvm/versions/node/v24.22.2/bin:$PATH npm run build` — passed. Vite reports the existing Three.js bundle above its 500 kB advisory threshold.
- `swift test --package-path packages/game-core` — 9 tests passed.
- `xcodebuild -quiet test -project apps/ios/Roundgarden.xcodeproj -scheme Roundgarden -destination 'id=3560A3A8-03FB-4A00-9178-092115E8B159' -derivedDataPath /tmp/roundgarden-phase6-accessibility-ios-final CODE_SIGNING_ALLOWED=NO` — passed, 1 UI test.
- Generic iOS Simulator and macOS builds passed with code signing disabled.
- `xcrun swift-format lint --strict` on shared and UI-test Swift files; `xcrun xcstringstool compile apps/shared/Localizable.xcstrings`; `jq empty apps/shared/Localizable.xcstrings`; and `git diff --check` — passed.
- The local macOS UI test did not expose its app window to XCTest, so its launch assertion could not run locally. Manual macOS accessibility-tree interaction verified the garden viewport and custom navigation action; the hosted Native macOS workflow passed the complete UI test on the final PR head.
- [PR #22](https://github.com/isAdamBailey/roundgarden/pull/22) merged after Web, Native iOS, and Native macOS workflows passed.

## Outcome

All current Phase 6 copy, accessibility, and polish checklist items are implemented and reviewed; the Phase 6 gate passed with PR #22. There are no help/support surfaces in the current apps. The public play-first landing page, app access, and privacy page remain explicitly tracked in Phase 6.1. Do not treat English catalog extraction as completed translation work.
