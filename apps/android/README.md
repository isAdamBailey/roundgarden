# Roundgarden for Android

The Android app packages the existing Roundgarden game locally in an Android
WebView. The browser game remains the shared gameplay implementation, including
360° touch look, centered-target vaporization, the one-minute round, proximity
scoring, pause/resume, and the on-device personal best. Game files are bundled
inside the APK; playing does not require the website or a network connection.

## Build

Use JDK 17, Android SDK 37.2, and Node 24.22.2. Open this directory as a
Gradle project or run:

```sh
./gradlew assembleDebug
```

The Gradle build runs the Vite production build with relative asset URLs and
copies its output into the app's local assets before packaging. `npm ci` from
the repository root is required once to install the web workspace dependencies.

## Test

Run the unit-test task, Android lint, and the WebView smoke test on a running
emulator. There are no JVM unit tests yet; the instrumentation test is the
current automated behavior check.

```sh
./gradlew testDebugUnitTest lintDebug connectedDebugAndroidTest
```

The instrumented test checks that the packaged game loads and shows the Android
entry copy. The GitHub Actions workflow starts an Android 16 emulator, runs
these checks, assembles the debug APK, and uploads it as a build artifact.

## Platform behavior

Touch drag rotates the view and a tap activates the centered reachable oddity.
The WebView uses its local DOM storage for the personal best. When Android
pauses the activity, the host pauses the round and garden motion. The Android
system bars remain visible for standard device navigation.
