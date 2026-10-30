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
| Entitlements | none | none | No capabilities are configured. Revisit only if shipped functionality needs one. |

The project specs allow Xcode signing for archives. Local unsigned builds and CI still pass `CODE_SIGNING_ALLOWED=NO` explicitly. Do not commit a developer team ID or signing secret.

The native targets currently save only an app-local personal-best score in `UserDefaults`; they do not include analytics, ads, or app networking. `apps/shared/PrivacyInfo.xcprivacy` declares no tracking or collected data and the app-only UserDefaults reason. Re-audit the source and every SDK before submission if data handling or dependencies change. Complete App Store Connect privacy answers from the shipped binary and any third-party SDK behavior; the manifest is not a substitute for those answers or a privacy policy.

## Store preparation still required

- Confirm the bundle IDs are available and create both platform records in App Store Connect.
- Enroll/select the developer team, configure signing, and archive with the release configuration.
- Complete Apple’s age-rating questionnaire for the final game content.
- Provide a real support URL and privacy-policy URL. Neither has been chosen or published, so no URL is invented here.
- Approve the product name and release copy; complete trademark/domain checks before using the name publicly.
- Create and approve app icons. Current repository screenshots are development evidence and are not store-ready promotional assets.
- Capture current, clean gameplay screenshots after the release build is reviewed. Apple currently requires iPhone screenshots at a supported Dynamic Island display size, 13-inch iPad screenshots when the app runs on iPad, and 16:10 screenshots for Mac. Verify accepted dimensions again when uploading.
- Complete store descriptions, subtitle, keywords, review notes, and platform-specific compatibility claims from the approved copy inventory.
- Upload signed builds to App Store Connect, distribute candidates with TestFlight where applicable, collect feedback, and track fixes in reviewed PRs.
- Run release smoke tests on supported iPhone, iPad, and Mac hardware. Measure frame time and memory with shadows enabled; the earlier owner-approved device deferral remains open.

## Current Apple guidance checked 2026-10-30

- Apple currently recommends building and testing with Xcode 27. Its submission page says that beginning April 2027, iOS/iPadOS apps must use the iOS/iPadOS 27 SDK or later and target iOS 15 or later. Recheck the live requirements immediately before upload.
- App Store Connect requires privacy-practice disclosures for new submissions and updates. Required-reason APIs used by the app need an appropriate declaration in the bundled privacy manifest.
- Screenshot requirements vary by platform and device generation; use App Store Connect's live screenshot specifications when producing the final assets.

Sources: [Apple submission requirements](https://developer.apple.com/app-store/submitting/), [privacy manifests](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [App Store screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications), [age ratings](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/).
