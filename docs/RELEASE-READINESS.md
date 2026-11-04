# Apple release readiness

**Status:** preparation only. No signed archive, App Store Connect record, or TestFlight build has been created.

## Repository configuration

| Setting | iOS | macOS | Status |
| --- | --- | --- | --- |
| Bundle identifier | `com.roundgarden.ios` | `com.roundgarden.macos` | Proposed; confirm availability and ownership in the Apple Developer account before registration. |
| Marketing version | `1.0` | `1.0` | Initial candidate; change before release if product scope requires it. |
| Build number | `1` | `1` | Initial candidate; increment separately for each platform upload. |
| Minimum OS | iOS 18 | macOS 15 | Set in XcodeGen specs; validate on these oldest supported releases before submission. |
| Signing team | unset | unset | Select the enrolled team in Xcode or CI when credentials are available. |
| Entitlements | none | App Sandbox | The macOS App Sandbox is required for Mac App Store distribution. Only the sandbox entitlement is enabled; add other permissions only for verified product needs. |
| Copyright metadata | — | `Copyright © 2026 Adam Bailey` | Product owner provided the exact macOS Info.plist string; included in the locally signed archive. |

The project specs allow Xcode signing for archives. Local unsigned builds and CI still pass `CODE_SIGNING_ALLOWED=NO` explicitly. Do not commit a developer team ID or signing secret. The macOS target declares the mandatory App Sandbox entitlement; verify the signed app runs sandboxed before submission.

### Phase 7 repository preparation

- Added original opaque RGB 1024 px iOS and multi-size macOS app icons, wired to each app's `AppIcon` asset catalog. The SVG source is in `packages/assets/roundgarden-app-icon.svg`; no external assets are used. Platform corner masks are applied to square artwork.
- Enabled the required macOS App Sandbox entitlement with no file or network exceptions.
- Added the product-owner-provided `NSHumanReadableCopyright` string to macOS metadata and verified it in the signed archive.
- Regenerated both Xcode projects from their specs. iOS Simulator and macOS builds passed.
- Unsigned generic Release archives succeeded for iOS and macOS. Both contain `Assets.car` and `PrivacyInfo.xcprivacy`; archive metadata reports the proposed bundle IDs and version/build `1.0 (1)`.
- A macOS Release archive signed locally with an ad-hoc identity contains the App Sandbox entitlement, confirmed with `codesign`. This is not the developer identity needed for distribution and was not a runtime sandbox smoke test.
- These are packaging checks only. No signing identity, Apple account ownership, physical-device smoke/performance result, App Store Connect declaration, TestFlight distribution, or release approval is established by the unsigned archives.

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

- The proposed iOS and macOS bundle IDs, version/build values, Mac Games category, and UserDefaults privacy manifest are configured in the Xcode projects. They remain proposals until verified against the Apple Developer account and final archive.
- Apple requires App Sandbox for Mac App Store distribution. Confirm the signed macOS archive carries the configured entitlement and passes an on-device sandbox smoke check.
- Original Roundgarden app icons are now included in both native asset catalogs. Review them in the release build and replace them if product approval requests a different treatment.
- Confirm the bundle IDs are available and create both platform records in App Store Connect.
- Enroll/select the developer team, configure signing, and archive with the release configuration.
- Complete Apple’s age-rating questionnaire for the final game content.
- Choose a real support URL before submission. The web privacy page is implemented at `/privacy.html`; publish the site and use its production URL in App Store Connect.
- Approve the product name and release copy; complete trademark/domain checks before using the name publicly.
- Approve the app icons. Current repository screenshots are development evidence and are not store-ready promotional assets.
- Capture current, clean gameplay screenshots after the release build is reviewed. Apple currently requires iPhone screenshots at a supported Dynamic Island display size, 13-inch iPad screenshots when the app runs on iPad, and 16:10 screenshots for Mac. Verify accepted dimensions again when uploading.
- Complete store descriptions, subtitle, keywords, review notes, and platform-specific compatibility claims from the approved copy inventory.
- Upload signed builds to App Store Connect, distribute candidates with TestFlight where applicable, collect feedback, and track fixes in reviewed PRs.
- Run release smoke tests on supported iPhone, iPad, and Mac hardware. Measure frame time and memory with shadows enabled; the earlier owner-approved device deferral remains open.

## Current Apple guidance checked 2026-11-03

- Apple currently recommends building and testing with Xcode 27. Its submission page says that beginning April 2027, iOS/iPadOS apps must use the iOS/iPadOS 27 SDK or later and target iOS 15 or later. Recheck the live requirements immediately before upload.
- Mac App Store distribution requires the App Sandbox entitlement. Apple also requires `NSHumanReadableCopyright` in the macOS app's Info.plist; the configured value was supplied by the product owner.
- App Store Connect requires privacy-practice disclosures for new submissions and updates. Required-reason APIs used by the app need an appropriate declaration in the bundled privacy manifest.
- Screenshot requirements vary by platform and device generation; use App Store Connect's live screenshot specifications when producing the final assets.

Sources: [Apple submission requirements](https://developer.apple.com/app-store/submitting/), [macOS App Sandbox configuration](https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox), [macOS app distribution preparation](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution), [privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [App Store screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [age ratings](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/).
