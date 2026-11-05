# Apple release readiness

**Status:** archive preparation complete; no store action taken. App Store Connect record `6830464374` covers iOS and macOS with the shared bundle identifier. Fresh iOS and macOS archives were built from merged commit `7129929` on 2026-11-03, signed with Adam Bailey's Apple Distribution identity, and passed the repository signed-archive checks. Neither archive has been uploaded to TestFlight or App Review. Store action remains on hold pending the product owner's direction.

## Repository configuration

| Setting | iOS | macOS | Status |
| --- | --- | --- | --- |
| Bundle identifier | `io.adambailey.roundgarden` | `io.adambailey.roundgarden` | Shared App ID registered and selected for App Store Connect record `6830464374`, matching FrameBeat. The mistaken unused `com.roundgarden.ios` App ID has been removed. |
| Marketing version | `1.0` | `1.0` | Initial candidate; change before release if product scope requires it. |
| Build number | `1` | `1` | Initial candidate; increment separately for each platform upload. |
| Minimum OS | iOS 18 | macOS 15 | Set in XcodeGen specs; validate on these oldest supported releases before submission. |
| Signing team | Adam Bailey in local Xcode | Adam Bailey in local Xcode | App Store profiles are configured by name in the project specs. The team selection stays local to Xcode; do not commit the team ID or signing secrets. |
| Entitlements | none | App Sandbox | The macOS App Sandbox is required for Mac App Store distribution. Only the sandbox entitlement is enabled; add other permissions only for verified product needs. |
| Copyright metadata | — | `Copyright © 2026 Adam Bailey` | Product owner provided the exact macOS Info.plist string; included in the locally signed archive. |

Release signing uses the manually selected App Store profiles `Roundgarden iOS App Store` and `Roundgarden Mac App Store`, with the existing Apple Distribution certificate. Debug signing remains Apple Development. The profiles and certificate are managed in the developer account and installed locally in Xcode; the repository contains only profile names, never a team ID or signing secret. Local unsigned builds and CI still pass `CODE_SIGNING_ALLOWED=NO` explicitly. The macOS target declares the mandatory App Sandbox entitlement; verify the signed app runs sandboxed before submission.

### Phase 7 repository preparation

- Added original opaque RGB 1024 px iOS and multi-size macOS app icons, wired to each app's `AppIcon` asset catalog. The SVG source is in `packages/assets/roundgarden-app-icon.svg`; no external assets are used. Platform corner masks are applied to square artwork.
- Enabled the required macOS App Sandbox entitlement with no file or network exceptions.
- Added the product-owner-provided `NSHumanReadableCopyright` string to macOS metadata and verified it in the signed archive.
- Regenerated both Xcode projects from their specs. iOS Simulator and macOS builds passed.
- Unsigned generic Release archives succeeded for iOS and macOS. Both contain `Assets.car` and `PrivacyInfo.xcprivacy`; regenerate them with the selected shared bundle ID before signing and upload.
- A macOS Release archive signed locally with an ad-hoc identity contains the App Sandbox entitlement, confirmed with `codesign`. This is not the developer identity needed for distribution and was not a runtime sandbox smoke test.
- Fresh signed archives from merged commit `7129929` passed `scripts/verify-native-archive.py --require-signature` for both platforms:
  - iOS: `~/Library/Developer/Xcode/Archives/2026-11-03/Roundgarden iOS 1.0 (1).xcarchive`
  - macOS: `~/Library/Developer/Xcode/Archives/2026-11-03/Roundgarden Mac 1.0 (1).xcarchive`
- Both archives use `io.adambailey.roundgarden`, version/build `1.0 (1)`, and Adam Bailey's Apple Distribution identity. The Mac archive also contains App Sandbox and the approved `Copyright © 2026 Adam Bailey` metadata.
- No physical-device smoke/performance result, completed App Store Connect declarations, TestFlight distribution, or release approval is established yet. Do not upload or submit until the product owner directs that store action.

Before signing a new archive, run the repository preflight against each `.xcarchive`:

```sh
python3 scripts/verify-native-archive.py ios /path/to/Roundgarden-iOS.xcarchive
python3 scripts/verify-native-archive.py macos /path/to/Roundgarden-macOS.xcarchive
```

The unsigned preflight checks bundle identity, version/build consistency, platform and minimum OS, compiled icon resources, square RGB icon source files without transparency, and the privacy manifest. With `--require-signature`, it also verifies the code signature and the macOS App Sandbox entitlement. It does not validate the developer team/provisioning, establish App Store Connect metadata, or replace Apple's upload validation.

After signing, rerun with `--require-signature`:

```sh
python3 scripts/verify-native-archive.py ios /path/to/Roundgarden-iOS.xcarchive --require-signature
python3 scripts/verify-native-archive.py macos /path/to/Roundgarden-macOS.xcarchive --require-signature
```

The macOS check verifies that the signed app carries the mandatory App Sandbox entitlement. Confirm the expected developer team and identity in Xcode Organizer; a valid local/ad-hoc signature is not an App Store distribution signature.

The native targets currently save only an app-local personal-best score in `UserDefaults`; they do not include analytics, ads, or app networking. `apps/shared/PrivacyInfo.xcprivacy` declares no tracking or collected data and the app-only UserDefaults reason. Re-audit the source and every SDK before submission if data handling or dependencies change. Complete App Store Connect privacy answers from the shipped binary and any third-party SDK behavior; the manifest is not a substitute for those answers or a privacy policy.

## Store preparation still required

- The registered iOS and macOS bundle IDs, version/build values, Mac Games category, and UserDefaults privacy manifest are configured in the Xcode projects and verified in the fresh signed archives.
- Apple requires App Sandbox for Mac App Store distribution. The signed macOS archive carries the configured entitlement; an on-device sandbox smoke check remains open.
- Original Roundgarden app icons are included in both native asset catalogs and the archives. Product-owner review of the icons remains open.
- The public site now has a support page at `/support.html` with the product-owner-provided support email. App Store Connect iOS and macOS version drafts use that Support URL and the public homepage as the Marketing URL. The site change must be merged and deployed before either URL is considered verified.
- The App Store Connect Privacy Policy URL is set to `https://roundgarden.adambailey.io/privacy.html`. The `Data Not Collected` response is saved as a draft; it has not been published.
- The bundle ID and App Store Connect record are configured, and fresh signed archives exist for both platforms. Rebuild from a new reviewed commit and increment the platform build number if any source or asset changes are made before upload.
- Complete Apple’s age-rating questionnaire for the final game content.
- Verify `/support.html`, `/privacy.html`, and the homepage return the expected public pages after deployment; keep App Store Connect URLs pointed at the live pages.
- Approve the product name and release copy; complete trademark/domain checks before using the name publicly.
- Review and approve the app icons and prepared screenshots before store use.
- Release-configuration screenshots are prepared for supported iPhone, 13-inch iPad, and Mac display classes; see `docs/release/APP-STORE-SCREENSHOTS.md`. Review the iPad window-resize grip and capture a Mac gameplay view if preferred. Verify accepted dimensions again when uploading.
- Complete store descriptions, subtitle, keywords, review notes, and platform-specific compatibility claims from the approved copy inventory.
- Upload signed builds to App Store Connect, distribute candidates with TestFlight where applicable, collect feedback, and track fixes in reviewed PRs only after the product owner authorizes store action.
- Run release smoke tests on supported iPhone, iPad, and Mac hardware. Measure frame time and memory with shadows enabled; the earlier owner-approved device deferral remains open.

## Current Apple guidance checked 2026-11-03

- Apple currently recommends building and testing with Xcode 27. Its submission page says that beginning April 2027, iOS/iPadOS apps must use the iOS/iPadOS 27 SDK or later and target iOS 15 or later. Recheck the live requirements immediately before upload.
- Mac App Store distribution requires the App Sandbox entitlement. Apple also requires `NSHumanReadableCopyright` in the macOS app's Info.plist; the configured value was supplied by the product owner.
- App Store Connect requires privacy-practice disclosures for new submissions and updates. Required-reason APIs used by the app need an appropriate declaration in the bundled privacy manifest.
- Screenshot requirements vary by platform and device generation; use App Store Connect's live screenshot specifications when producing the final assets.

Sources: [Apple submission requirements](https://developer.apple.com/app-store/submitting/), [macOS App Sandbox configuration](https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox), [macOS app distribution preparation](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution), [privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [App Store screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [age ratings](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/).
