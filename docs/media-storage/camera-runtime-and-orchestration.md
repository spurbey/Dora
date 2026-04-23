# Camera Runtime and Orchestration

## Scope

This document covers the in-app camera runtime (`camerawesome`) and how captures are persisted into live tracking, Vault, and local story draft lanes.

Core files:

- Runtime screen: `flutter/lib/features/capture/presentation/screens/camera_runtime_screen.dart`
- Runtime state/controller/config:
  - `flutter/lib/features/capture/domain/camera_runtime_state.dart`
  - `flutter/lib/features/capture/presentation/providers/camera_runtime_controller.dart`
  - `flutter/lib/features/capture/domain/camera_runtime_config.dart`
- Orchestrator: `flutter/lib/features/capture/domain/capture_orchestrator.dart`
- File manager: `flutter/lib/features/capture/data/media_capture_file_store.dart`

## Entry points

1. Global center FAB
   - `CameraFab` pushes `Routes.camera` with `CameraLaunchContext.fab`
2. Live capture screen actions
   - Pushes `Routes.camera` with `CameraLaunchContext.liveTracking`
   - Passes `preferredTripId` to force trip-scoped active session resolution

Routing files:

- `flutter/lib/core/navigation/navigation_shell.dart`
- `flutter/lib/features/capture/presentation/widgets/camera_fab.dart`
- `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`

## Runtime state machine

Phases:

- `idle`
- `initializing`
- `preview`
- `capturingPhoto`
- `recordingVideo`
- `persisting`
- `permissionDenied`
- `error`
- `disposed`

Contract:

- All state transitions are event-driven through `CameraRuntimeController.dispatch()`
- A transition lock serializes lifecycle callbacks + UI actions + camera callbacks
- UI controls are derived from phase (`canCapture`, `canBack`, `showsControls`)

## Lifecycle policy (tiered)

Mechanisms:

- `WidgetsBindingObserver` for app lifecycle (`inactive/paused/resumed/detached`)
- `RouteAware` for in-app route cover/uncover

Threshold behavior:

- Tier 1: Route covered (keep runtime, probe on return)
- Tier 2: Background/inactive below threshold
- Tier 3: Force reset and full re-init when:
  - Background elapsed >= `kBackgroundTier2Threshold` (10s)
  - `detached`
  - memory pressure
  - resume probe failure

Inactive promotion:

- If `inactive` lasts >= `kInactivePromotionThreshold` (10s), runtime marks background using inactive timestamp.

Resume fallback:

- Fast resume probe (`kResumeFastPathProbeTimeout`) checks camera responsiveness.
- Failed probe triggers `forceTier3Reset()` followed by `_attemptInit()`.

## Runtime constants

From `camera_runtime_config.dart`:

- `kCameraInitTimeout = 5s`
- `kStartRecordingTimeout = 3s`
- `kStopRecordingTimeout = 5s`
- `kPersistTimeout = 10s`
- `kBackgroundTier2Threshold = 10s`
- `kInactivePromotionThreshold = 10s`
- `kResumeFastPathProbeTimeout = 700ms`
- Recording guardrails:
  - `kMinimumRecordingStorageBytes = 100MB`
  - `kMinimumRecordingDuration = 1s`
  - `kDefaultRecordingMaxDuration = 60s`

## Persist orchestration matrix

Inputs:

- Launch context: `fab | liveTracking`
- Capture kind: `photo | video`
- Destination: `vault | storyDraft`
- Active session: resolved globally or trip-scoped (`preferredTripId`)

Behavior:

| Active session | Destination | Result |
| --- | --- | --- |
| yes | `vault` | Live-tracking persist (`createMediaCaptureNow`), attached to trip/session |
| yes | `storyDraft` | Live-tracking persist first, then local story draft row |
| no | `vault` | Canonical media row with `originScope = vault` |
| no | `storyDraft` | Canonical vault row + local story draft row |

Important invariant:

- Story intent never bypasses local persist. Publish is additive after local save.

## Destination chooser

Shown after capture, before persist:

- `Save to Vault`
- `Share as Story`

File:

- `camera_runtime_screen.dart` (`_showDestinationChooser`)

## Story publish handoff

After successful persist:

- If destination is `storyDraft`, screen calls:
  - `storyPublishControllerProvider.notifier.publishLocalStory(storyId, bestEffort: true)`
- Camera returns to preview/pop flow without waiting for network publish.

## File handling

1. Camera capture writes temp file path (`/tmp/dora/captures/...`)
2. Orchestrator copies to managed capture path (`ApplicationSupport/dora/media/captures/...`)
3. Local DB rows point to managed path
4. Source temp file is best-effort deleted after copy

Janitor support:

- `cleanupTempCaptureFiles()`
- `cleanupOrphanManagedFiles()`

## Dependencies

From `flutter/pubspec.yaml`:

- `camerawesome`
- `audio_session`
- `disk_space_plus`
- `video_thumbnail`
- `video_player`

## Extension checklist

When adding new camera behavior:

1. Add state/event explicitly to runtime reducer.
2. Add timeout constant in `camera_runtime_config.dart`; do not hardcode literals.
3. Keep heavy work off the immediate interaction path (camera should recover quickly after local persist).
4. If changing destination semantics, update:
   - destination chooser
   - orchestrator routing
   - story publish controller expectations
   - Vault story status UI
