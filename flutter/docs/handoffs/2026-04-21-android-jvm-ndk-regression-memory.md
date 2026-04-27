# Android JVM + NDK Regression Memory (2026-04-21)

Owner: `codex`  
Context: Recurring Android build mismatch after camera runtime integration (`camerawesome`).

---

## 1) Objective

Document exactly what broke, how it was diagnosed, what was fixed, and what is still deferred so future agents do not repeat exploratory work.

---

## 2) Incident Summary

### 2.1 Symptom

`flutter run` failed with:

- `Execution failed for task ':camerawesome:compileDebugKotlin'`
- `Inconsistent JVM-target compatibility detected for tasks 'compileDebugJavaWithJavac' (1.8) and 'compileDebugKotlin' (17)`

### 2.2 Trigger

Regression appeared after camera integration introduced `camerawesome` into the plugin graph.

### 2.3 Immediate Fix Applied

In `flutter/android/build.gradle.kts`, `camerawesome` was added to the existing Java/Kotlin `1.8` compatibility exception block:

- before: `sentry_flutter`, `mapbox_maps_flutter`
- after: `sentry_flutter`, `mapbox_maps_flutter`, `camerawesome`

Verification command succeeded:

- `./gradlew.bat :camerawesome:compileDebugKotlin --info --stacktrace`
- result: `BUILD SUCCESSFUL`

---

## 3) Root Cause Analysis

### 3.1 Why mismatch happened

1. Root project globally forces Kotlin JVM target to `17` for all subprojects.
2. `camerawesome` plugin Android build still declares Java/Kotlin `1.8`.
3. Without a project-level exception for `camerawesome`, resolved task config became:
   - Java compile target: `1.8`
   - Kotlin compile target: `17`
4. Kotlin Gradle plugin now hard-fails on Java/Kotlin target mismatch.

### 3.2 Evidence used

- `flutter/pubspec.lock` shows `camerawesome: 2.5.0`.
- Plugin file in pub cache (`.../camerawesome-2.5.0/android/build.gradle`) explicitly sets:
  - `compileOptions { sourceCompatibility 1.8; targetCompatibility 1.8 }`
  - `kotlinOptions { jvmTarget = '1.8' }`
- One-off Gradle inspection script printed resolved task values:
  - `INSPECT_JAVA source=1.8 target=1.8`
  - `INSPECT_KOTLIN jvmTarget=JVM_17`

---

## 4) NDK and Page-Size Context (Deferred)

### 4.1 Historical state

From prior stabilization:

- `flutter/android/app/build.gradle.kts` was pinned to `ndkVersion = "27.0.12077973"` to resolve earlier CI/plugin mismatch.

### 4.2 Play Console page-size note

`flutter/docs/handoffs/2026-03-19-play-console-rollout-memory.md` records:

- 16 KB page-size blocker was resolved during rollout.
- Sentry upgrade (`7.x` -> `9.x`) was a key change in that release path.

### 4.3 Why mismatch warning now appears again

Current local Flutter SDK is newer and defaults to NDK `28.2.13676358`.
The transitive `jni` plugin now expects this newer NDK and warns when app stays pinned to `27.0.12077973`.

Status in this pass:

- JVM mismatch was fixed.
- NDK mismatch remains deferred by request.

---

## 5) Command Workflow That Worked

Use this order for fast triage:

1. Capture toolchain and failing task:
   - `flutter --version`
   - `./gradlew.bat :<plugin>:compileDebugKotlin --info --stacktrace`
2. Confirm plugin versions:
   - `flutter pub deps --style=compact`
   - inspect `flutter/pubspec.lock`
3. Inspect project-level Gradle overrides:
   - `flutter/android/build.gradle.kts`
   - `flutter/android/app/build.gradle.kts`
   - `flutter/android/settings.gradle.kts`
4. Inspect plugin Android Gradle in pub cache:
   - `%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\<plugin-version>\android\build.gradle`
5. If needed, print resolved task targets via Gradle init script.

---

## 6) Operational Rules for Future Agents

1. Do not edit plugin files in pub cache as the primary fix path.
2. Keep Java and Kotlin targets aligned per module.
3. When adding native plugins, proactively run plugin-scoped compile checks.
4. Keep local Flutter version and CI/Shorebird Flutter version aligned during release windows.
5. Treat NDK pinning as an explicit policy decision:
   - either track `flutter.ndkVersion`,
   - or pin to a chosen version and revalidate all native plugins.

---

## 7) Files Touched in This Incident

- `flutter/android/build.gradle.kts`
- `flutter/docs/handoffs/2026-04-21-android-jvm-ndk-regression-memory.md`

