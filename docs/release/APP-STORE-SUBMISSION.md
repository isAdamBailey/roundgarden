# App Store submission and launch runbook

**Status:** draft procedure. No app record, signed build, TestFlight candidate, or App Review submission exists yet. The Phase 4–7 gates and product-owner copy approval remain open. Do not submit until those prerequisites are resolved and the owner selects the release timing.

## Submission order

Treat the iOS and macOS apps as separate platform submissions. Complete the following for each platform and keep its App Store Connect record, binary, screenshots, and review notes together:

1. Merge and verify the release candidate changes. Record the exact commit SHA and create the release tag only after review, validation, icon approval, and required metadata are complete. Build from a clean checkout of that commit. Once an archive is submitted, any code or asset change requires a new reviewed commit and a new build number; never alter the source while reusing the same uploaded build.
2. Confirm the proposed bundle identifier is available and belongs to the developer account. Create the platform app record and configure signing in that account; never commit credentials or signing certificates to this repository.
3. Build a Release archive and run the [repository archive preflight](../RELEASE-READINESS.md#phase-7-repository-preparation). Then sign the archive and verify the bundle identifier, marketing version, build number, privacy manifest, entitlements, and signing identity. Increment each platform's build number before every subsequent upload. The macOS build must include the required `NSHumanReadableCopyright` value approved for the product owner.
   - After signing, run `python3 scripts/verify-native-archive.py macos /path/to/Roundgarden-macOS.xcarchive --require-signature`. Confirm the Mac archive includes App Sandbox and the expected developer team in Xcode Organizer. Launch the signed Mac app and verify normal gameplay under the sandbox.
4. Complete App Store Connect metadata and required declarations from the actual binary: age-rating answers, privacy details, export-compliance answers, support/privacy URLs, and accurate compatibility statements. Re-audit every included SDK and data flow before answering privacy questions.
5. Upload screenshots and metadata for that platform. Use fresh captures of the release build with no development UI or personal information. Confirm current accepted sizes in App Store Connect when uploading.
6. Upload the build and distribute it through TestFlight where applicable. Record the build number, testers, feedback, fixes, and retest evidence. Fixes go through reviewed PRs.
7. Submit to App Review with platform-specific notes. Resolve review findings through tracked follow-up PRs and resubmit the affected platform.
8. After approval, choose the release timing in App Store Connect, publish each platform release, verify the live listing and install, and record store URLs and version/build numbers in issue #1.

Do not imply that approval of one platform means the other platform is approved. Do not publish store links or release-date claims before the corresponding listing is live.

## Current platform details

| | iOS | macOS |
| --- | --- | --- |
| Proposed bundle identifier | `com.roundgarden.ios` | `com.roundgarden.macos` |
| Proposed initial version/build | `1.0` / `1` | `1.0` / `1` |
| Deployment floor | iOS 18 | macOS 15 |
| Store screenshots required | iPhone; iPad because the app supports iPad | Mac |
| Current repository capture | Release-configuration simulator captures for iPhone and 13-inch iPad; see the [screenshot inventory](APP-STORE-SCREENSHOTS.md) | Release archive menu capture at 2880 × 1800; see the [screenshot inventory](APP-STORE-SCREENSHOTS.md) |
| Review flow to verify | Enter the garden, complete a 60-second round, pause/resume, finish and replay | Enter the garden, drag to look, use arrow keys after focusing the garden, click a centered oddity, pause/resume with Escape, finish and replay |

Bundle identifiers and initial versions are proposals until verified in the Apple account and approved by the owner. The Mac category is Games. Entitlements currently remain empty; add one only if release functionality requires it.

## Draft App Review notes

### iOS

> Roundgarden is a one-minute game set inside a whimsical garden that surrounds the player. Tap a nearby garden oddity to vaporize it into light and score points. No account is required. The app stores the personal-best score in app-local preferences. To review, choose “Enter the garden,” drag to look around, tap a centered oddity, pause and resume with the on-screen control, and finish a round to see the score and replay option.

### macOS

> Roundgarden is a one-minute game set inside a whimsical garden that surrounds the player. Click a nearby garden oddity to vaporize it into light and score points. No account is required. The app stores the personal-best score in app-local preferences. To review, choose “Enter the garden,” drag in the scene to look around, focus the garden and use the arrow keys to look, click a centered oddity, press Escape to pause and resume, and finish a round to see the score and replay option.

These notes are drafts. Confirm every statement against the signed candidate and final privacy implementation. Add real support contact details and any reviewer-specific setup instructions before submission.

## Metadata and asset checks

- Approve the product name, subtitle, descriptions, keywords, icon, and platform-specific control wording. The [copy and naming inventory](../COPY-AND-NAMING-INVENTORY.md) remains draft; name clearance is still outstanding.
- Create the required app icon assets and confirm they match the approved in-game identity.
- The repository includes release-configuration screenshots for the currently required iPhone, 13-inch iPad, and Mac display classes. Review the [screenshot inventory](APP-STORE-SCREENSHOTS.md), then confirm the upload slots and accepted dimensions in App Store Connect immediately before upload because supported devices change.
- Ensure screenshots and previews show actual app behavior, have no alpha channel, and follow Apple’s metadata and review guidelines. App previews are optional; do not make a preview a gate if still images are sufficient.
- Set the support URL and privacy-policy URL after those pages exist. The repository currently has no approved URLs.
- Answer the age-rating and privacy questionnaires in App Store Connect from the final game and binary. The privacy manifest describes API usage; it does not replace App Store privacy disclosures or a published privacy policy.
- Recheck SDK, screenshot, metadata, age-rating, privacy-manifest, and review requirements on the upload date.

## Verification record template

For each platform, append a record to issue #1 containing:

| Field | Record |
| --- | --- |
| App Store Connect app name / platform | |
| Bundle ID | |
| Version / build | |
| Archive commit and signing identity | |
| Privacy/age-rating declarations reviewed by | |
| TestFlight groups and feedback summary | |
| App Review submission and decision date | |
| Release choice and publication date | |
| Live store URL | |
| Follow-up issues / PRs | |

## Apple references checked 2026-10-30

- [Submit apps and current SDK requirements](https://developer.apple.com/app-store/submitting/)
- [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications)
- [Upload screenshots and app previews](https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots/)
- [Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

Apple's current submission page says to build and test with Xcode 27. It also describes a future April 2027 SDK minimum; verify the live requirement again at upload time.
