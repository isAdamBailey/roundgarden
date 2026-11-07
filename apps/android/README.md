# Roundgarden for Android

The Android app runs the existing Three.js game in a WebView and packages the
game files in the APK. Gameplay stays shared with the browser version, including
360° touch look, centered-target vaporization, one-minute rounds, scoring,
pause/resume, and the on-device personal best.

## Build

Use JDK 17, Android SDK 37.2, and Node 24.22.2. Run from this directory:

```sh
./gradlew assembleDebug
```

Gradle builds the web game with relative asset URLs and copies it into the APK.
Run `npm ci` from the repository root once to install web dependencies.

## Test

Android lint and an emulator test verify the packaged entry screen, round start,
pause, and resume:

```sh
./gradlew lintDebug connectedDebugAndroidTest
```

GitHub Actions runs these checks on an Android emulator and uploads the debug
APK. The unit-test task currently has no JVM test sources.

## Screenshots

The phone capture shows the packaged Android app on an Android 16 emulator; the
desktop capture shows the shared web game used as its visual reference.

![Android phone layout](../../docs/android/android-phone.jpg)

![Desktop visual reference](../../docs/android/desktop-reference.jpg)

## Platform behavior

Drag to look and tap to activate a centered reachable oddity. The WebView's
local storage keeps the personal best. Android pauses the round when the
activity leaves the foreground; system navigation bars remain visible.
