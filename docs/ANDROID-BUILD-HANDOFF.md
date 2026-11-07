# Android build handoff

## Current state

- Branch: `codex/android-initial-build`.
- Initial source-only checkpoint is committed on the branch.
- No PR has been opened.
- The initial Android app shell is in `apps/android`. It packages the existing
  Three.js game as local APK assets and serves them through AndroidX
  `WebViewAssetLoader`.
- The Android entry screen uses `?android-app=1` for app-specific copy/layout.
  The app pauses the active round from `Activity.onPause` and uses local storage
  for the personal best.
- Android Gradle build and instrumentation smoke test pass on the existing
  `fb_phone` Pixel 9 emulator (Android 16/API 36). The test confirms the
  packaged game loads and displays its Android-specific entry copy.
- `.github/workflows/android.yml` runs the unit-test task (currently with no
  JVM test sources), lint, the instrumentation test, and debug APK assembly on
  an Android 16 emulator, then publishes the APK as a workflow artifact.

## Machine setup used

- SDK: `/Users/adambailey/Library/Android/sdk` (platform 37.2 and API 36
  emulator image).
- Emulator: `fb_phone` (Pixel 9 profile).
- Gradle: project wrapper at `apps/android/gradlew` (Gradle 9.6.0; copied from
  the machine's FrameBeat Android setup).
- JDK 17: temporary Temurin install at
  `/private/tmp/roundgarden-jdk/jdk-17.0.21+9/Contents/Home`; DataGrip's
  bundled runtime did not include `jlink`.

Build command:

```sh
JAVA_HOME='/private/tmp/roundgarden-jdk/jdk-17.0.21+9/Contents/Home' \
ANDROID_HOME=/Users/adambailey/Library/Android/sdk \
apps/android/gradlew -p apps/android assembleDebug
```

The debug APK is `apps/android/app/build/outputs/apk/debug/app-debug.apk`.
Emulator screenshots are temporary files under `/private/tmp` and are not in
the repository.

## Remaining validation

The smoke test verifies packaging and startup copy only. Full round-start,
look-drag, pause/resume, and background-timer behavior still need manual
emulator review. Physical-device behavior has not been checked.

Current build warnings are Gradle Kotlin DSL task-registration deprecations
and deprecated platform window-inset methods; the build completes successfully.
