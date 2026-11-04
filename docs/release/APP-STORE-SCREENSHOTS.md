# App Store screenshot inventory

These are direct captures of the release-configuration app with no added marketing copy. They are stored as opaque RGB PNGs so the dimensions are preserved and App Store Connect can accept them without alpha transparency.

| Platform/display class | Capture size | Files |
| --- | ---: | --- |
| iPhone with Dynamic Island (iPhone 18 Pro simulator) | 1206 × 2622 | [`01-gameplay.png`](../../apps/ios/screenshots/app-store/iphone-18-pro/01-gameplay.png), [`02-menu.png`](../../apps/ios/screenshots/app-store/iphone-18-pro/02-menu.png) |
| 13-inch iPad (13-inch iPad Pro simulator) | 2064 × 2752 | [`01-gameplay.png`](../../apps/ios/screenshots/app-store/ipad-pro-13-inch/01-gameplay.png), [`02-menu.png`](../../apps/ios/screenshots/app-store/ipad-pro-13-inch/02-menu.png) |
| Mac (16:10 display) | 2880 × 1800 | [`01-menu.png`](../../apps/macos/screenshots/app-store/mac-2880x1800/01-menu.png) |

The iOS files were captured from the `Release-iphonesimulator` build on iOS 27.0 (iPhone) and iOS 26.5 (iPad). The Mac menu capture is from the release app in `/tmp/roundgarden-phase7-macos-rc.xcarchive`; the host display returned a native 2880 × 1800 capture. The Mac screenshot shows the menu; capture a gameplay view from the signed release candidate if the product owner wants a gameplay-first Mac listing.

The iPad simulator retained a small iPadOS window resize grip at the bottom-right corner. Review that system UI before upload; if it is unsuitable for the store listing, recapture with the app presented full-screen.

Apple's [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications) call for iPhone screenshots, 13-inch iPad screenshots when iPad is supported, and Mac screenshots for Mac apps. For consistent UI, App Store Connect can scale down from the highest required resolution. Reconfirm the accepted device slots and image dimensions when uploading.

## Pre-upload checks

- Review the screenshots against the final release candidate; any code or asset changes after archive creation require a new build.
- Confirm the App Store Connect slots accept these dimensions and that the iPad capture is appropriate for the current app presentation.
- Keep the gameplay image first for iPhone and iPad. Add or reorder platform screenshots in App Store Connect only after review.
- Do not treat these simulator and local release-archive captures as proof that a signed, uploaded build passed TestFlight or App Review.
