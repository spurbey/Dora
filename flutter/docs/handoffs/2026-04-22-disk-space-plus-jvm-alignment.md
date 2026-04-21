# Android JVM Alignment Follow-Up (`disk_space_plus`) - 2026-04-22

Owner: `codex`

## What Changed

1. Updated root Android Gradle plugin exceptions for Java/Kotlin 11 modules:
   - File: `flutter/android/build.gradle.kts`
   - Change: added `disk_space_plus` to the Java/Kotlin 11 alignment block that already handled `flutter_image_compress_common`.
   - Why: fix recurring mismatch:
     - `compileDebugJavaWithJavac` -> `11`
     - `compileDebugKotlin` -> `17`

2. Fixed Kotlin daemon JVM arg typo:
   - File: `flutter/android/gradle.properties`
   - Change: `-Dkotlin.daemon.jvm.options=-Xm1024m` -> `-Dkotlin.daemon.jvm.options=-Xmx1024m`
   - Why: ensure valid JVM heap argument for Kotlin daemon.

## Daemon / Lock Handling Performed

1. Stopped active Java processes to clear Gradle daemon contention.
2. `./gradlew.bat --stop` could not run because wrapper lock access failed at:
   - `%USERPROFILE%\\.gradle\\wrapper\\dists\\gradle-8.14-all\\...\\gradle-8.14-all.zip.lck`
3. Lock file metadata and ACL were inspected; removal was blocked by OS-level access denial.

## Verification Status

- Config patch applied in repo files.
- Full Gradle task verification was not completed in this pass because wrapper lock contention persisted in the global Gradle cache path.

## Recommended Verification Command (next run)

Run after clearing any external lock holder:

```powershell
cd C:\Users\sumit\Downloads\Dora\flutter\android
.\gradlew.bat :disk_space_plus:compileDebugKotlin --stacktrace
```
