# Phase 6 copy and contrast review

**Issue:** [#1 — Plan: monorepo, native Swift apps, and App Store release](https://github.com/isAdamBailey/roundgarden/issues/1)  
**Scope:** Phase 6 copy checklist items 1 and 6; web and shared native in-game copy.

## Result

The current in-game copy is finalized under the owner's 2026-11-01 direction: keep the Soundgarden allusions in original garden, weather, light, distance, and shadow wordplay, while leaving controls and scores direct. The copy names no song or artist and quotes no lyrics.

The web, iOS, and macOS onboarding now share the same garden description and one-minute challenge. Control instructions adapt to click, tap, and macOS arrow keys. The native flow includes a separate ready step before its timed round; the web starts the round from its welcome action. Pause, leave-round, replay, and round-complete wording is aligned. No help or support surface exists in the current apps.

The web copy now sits over a dark blurred backing with enough opacity for small helper text over bright foliage. The status, score and timer, reticle label, active instructions, toast, pause, and end surfaces also use opaque or high-contrast backing. The mobile pause control becomes icon-only below 390 px and retains its accessible label.

The public play-first landing page, iOS/macOS access, and web privacy page are tracked separately in Phase 6.1. Store links will be added only when available, and privacy wording will follow a verified data-flow review.

## Review and validation

- Standards and spec reviews found no remaining copy or localization issues. VoiceOver/focus behavior and broader contrast, reduced-motion, localization-readiness, and 3D-scene legibility checks remain separate Phase 6 items.
- Manually reviewed the web onboarding at desktop and narrow mobile sizes, then checked the active HUD/instructions and round-end copy at both sizes. Text stayed within the viewport and remained readable over the foliage. The narrow active header fits with its status and controls visible.
- `PATH=/Users/adambailey/.nvm/versions/node/v24.22.2/bin:$PATH npm run build` — passed. Vite reports the existing Three.js bundle above its 500 kB advisory threshold.
- `swift test --package-path packages/game-core` — 9 tests passed.
- `xcodebuild -quiet test -project apps/ios/Roundgarden.xcodeproj -scheme Roundgarden -destination 'id=3560A3A8-03FB-4A00-9178-092115E8B159' -derivedDataPath /tmp/roundgarden-copy-ios-final CODE_SIGNING_ALLOWED=NO` — passed, 1 UI test.
- Generic iOS Simulator and macOS builds passed with code signing disabled.
- `xcrun swift-format lint --strict` on shared, UI-test, and game-core Swift files; `jq empty apps/shared/Localizable.xcstrings`; and `git diff --check` — passed.
- The macOS UI test did not reach gameplay: the runner could not find the existing **Enter the garden** button after launch. The Mac build passed; UI-test behavior remains inconclusive in this environment.

## Remaining Phase 6 work

Complete VoiceOver and keyboard-focus review, review contrast/reduced motion/localization and legibility on each platform, and verify any help/support copy if those surfaces are added. The Phase 6 gate remains open until those checks are complete.
