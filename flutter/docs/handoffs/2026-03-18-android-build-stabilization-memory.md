# Android Build Stabilization Memory (Phase 3 Window)

## Objective
Capture every major Android build/release blocker we hit during Phase 3 execution, what actually fixed it, and what to avoid repeating.

## Scope
- Flutter Android local build/release
- GitHub Actions Android build
- Shorebird Android release/patch pipeline

## Final Outcome
- Local release build succeeded:
  - `flutter build appbundle --release --dart-define-from-file=.env`
- GitHub Actions `Flutter Build` run succeeded (green).
- `Shorebird release Android` step completed successfully.

## Incident Log (Problem -> Root Cause -> Fix)

### 1) `build_runner` / `json_serializable` recursion errors
- Symptom:
  - `Bad state: Cannot recurse at later or equal phase 2, already running at: [2]`
- Practical root cause:
  - Corrupted/stale build graph after interrupted generation.
- Fix:
  - Clean and regenerate (`flutter clean`, then `dart run build_runner build --delete-conflicting-outputs`).
- Important guardrail:
  - Do **not** manually copy `.g.part` files from `.dart_tool/build/generated` into `lib/`.

### 2) JVM target mismatch (`shared_preferences_android`)
- Symptom:
  - `compileReleaseJavaWithJavac (11)` vs `compileReleaseKotlin (17)` mismatch.
- Root cause:
  - CI/Shorebird toolchain drift from local working Flutter toolchain + plugin constraints.
- Fixes applied:
  - Pinned CI and Shorebird Flutter version to `3.38.9`.
  - Kept Android/JVM configuration aligned in Gradle.
- Reference commits:
  - `5f18b7d`
  - `61dae34`

### 3) NDK mismatch in CI
- Symptom:
  - Plugins required NDK `27.0.12077973`, project resolved older NDK.
- Fix:
  - Set `ndkVersion = "27.0.12077973"` in `flutter/android/app/build.gradle.kts`.
- Reference commit:
  - `61dae34`

### 4) Missing Cupertino font family during release build
- Symptom:
  - `Expected to find fonts for (... CupertinoIcons), but found (MaterialIcons)`.
- Root cause:
  - `cupertino_icons` dependency not present.
- Fix:
  - Added `cupertino_icons` in `flutter/pubspec.yaml`.
- Reference commit:
  - `61dae34`

### 5) Local signing failure (`keystore password was incorrect`)
- Symptom:
  - `:app:signReleaseBundle` failed reading `upload-keystore.jks`.
- Root cause:
  - Signing env vars not set (or wrong) at build time.
- Fix:
  - Ensure correct `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` are present before release build.

### 6) CI signing failure (`toDerInputStream rejects tag type 42`)
- Symptom:
  - Keystore unreadable in runner after decode.
- Root cause:
  - Corrupted keystore decode path / malformed base64 secret content.
- Fixes applied:
  - Decode with `printf '%s' "$KEYSTORE_BASE64" | base64 --decode ...` (not `echo`).
  - Validate keystore before build using `keytool -list`.
  - Re-uploaded valid base64 keystore secret in GitHub.
- Reference commit:
  - `7e5d3ab`

### 7) CI run ended after long `bundleRelease` (`exit code 143` / canceled)
- Symptom:
  - Build looked "stuck" after SDK installs, then failed with cancellation/143.
- Root cause:
  - Gradle process stability/resource pressure in CI.
- Fixes applied:
  - Lowered Gradle heap/metaspace and worker count.
  - Disabled Gradle daemon for Shorebird Android CI steps.
  - Enabled `--verbose` Shorebird logs for faster diagnosis.
- Reference commit:
  - `40e98c3`

### 8) `google-services.json` missing from CI context
- Symptom:
  - Firebase Android config absent in CI release path.
- Root cause:
  - File ignored by `flutter/.gitignore`.
- Fix:
  - Removed ignore entry and tracked `flutter/android/app/google-services.json`.
- Reference commit:
  - `2a47d76`

## Current Known-Good Config

### Workflow (`.github/workflows/flutter-build.yml`)
- Flutter action pinned to `3.38.9`.
- Shorebird Android commands pinned to `--flutter-version=3.38.9`.
- Android keystore decode uses `printf + base64 --decode`.
- Android keystore validated with `keytool -list`.
- Shorebird Android uses:
  - `--verbose`
  - `GRADLE_OPTS=-Dorg.gradle.daemon=false -Dorg.gradle.console=plain`

### Gradle (`flutter/android/gradle.properties`)
- `org.gradle.jvmargs=-Xmx3072m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError -Dkotlin.daemon.jvm.options=-Xmx1024m`
- `org.gradle.workers.max=2`

## Operational Rules For Next Agents
- Always keep Shorebird `--flutter-version` pinned to the same version used by CI/local validation.
- If signing fails:
  - verify keystore file integrity with `keytool -list` first,
  - then verify secret values/passwords.
- If `build_runner` errors recur, clean and regenerate; never copy generated cache artifacts manually.
- If CI dies with 143/cancel near `bundleRelease`, inspect memory/daemon behavior first before touching app code.

## Commits In This Stabilization Track
- `a9d2bcc` - Shorebird setup/token env wiring fix
- `5f18b7d` - initial Shorebird Flutter pin
- `61dae34` - align CI Flutter + NDK + cupertino_icons
- `2a47d76` - track `google-services.json` in repo
- `7e5d3ab` - robust keystore decode + validation
- `40e98c3` - Gradle memory/daemon stabilization for Shorebird Android
