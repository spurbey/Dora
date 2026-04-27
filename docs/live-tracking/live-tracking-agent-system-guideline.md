# Live Tracking Agent System Guideline (No-Assumption Contract)

Last verified: 2026-04-04  
Owner: Live Tracking architecture memory  
Purpose: Prevent incorrect assumptions by future agents when changing backend, API transport, Flutter sync/runtime, or live-capture UX.

This document is implementation-grounded (code + tests + shipped commits), not only plan intent.

## 1. Canonical Source Order (Strict)

When sources conflict, use this precedence:

1. Runtime code + tests in `backend/` and `flutter/lib/`.
2. This document (`docs/live-tracking/live-tracking-agent-system-guideline.md`).
3. `docs/live-tracking-unified-system-architecture-plan.md`.
4. `flutter/docs/live-capture-screen-implementation-spec.md`.
5. `flutter/docs/live-tracking-flutter-execution-plan.md`.
6. Older handoff logs as historical context only.

Required behavior:

1. Never implement from plan text alone when code behavior differs.
2. If code and docs diverge, fix code or docs in the same change set.
3. Before coding, read the exact files listed in Section 12 (Agent Checklist).

## 2. Current Shipped Baseline (Commit-Anchored)

Baseline commit chain (latest first):

1. `e3e476c` - `fix(live-tracking): normalize API snapshots and unblock live-capture state transitions`
2. `121a6a5` - `feat(live-capture): Slice G Phase 4 - transient capture burst effects`
3. `a2c7c19` - `feat(live-capture): Slice G Phase 3 - dedicated live map controller`
4. `586a799` - `feat(live-capture): Slice G animation & UX pass - Phase 1 + Phase 2`
5. `256291d` - `fix(live-capture): organize full-map runtime shell`
6. `4926079` - `fix(live-capture): render full-screen mapbox map in live screen`
7. `44a7894` - `feat(live): stabilize create-to-live routing and deep-link entry`

Important meaning:

1. Slice G is implemented in code (tokens + overlay animation + map controller + transient effects).
2. Latest runtime bug fix (`e3e476c`) addresses start-session UI not transitioning due to API snapshot normalization gaps.
3. Some execution trackers still show older status markers; do not treat stale checkboxes as runtime truth.

## 3. System Boundary (Non-Negotiable)

Command plane (server-authoritative):

1. `start`, `pause`, `resume`, `stop` session lifecycle.
2. Implemented write-through in Flutter runtime repository.
3. Must resolve `serverTripId` first; local `trip.id` is not sent to backend lifecycle endpoints.

Data plane (local-first, deferred sync):

1. `tracking_event` writes.
2. `tracking_event_media` writes.
3. `tracking_point_batch` writes.
4. Moment/checkin operations in sync worker lanes.

Invariant:

1. Command failure must not erase local data-plane writes.

## 4. Backend Contract (Actual Runtime Behavior)

Primary API file: `backend/app/api/v1/live_tracking.py`  
Service logic: `backend/app/services/live_tracking_service.py`

### 4.1 Lifecycle endpoints

1. `POST /api/v1/trips/{trip_id}/tracking/start`
2. `POST /api/v1/trips/{trip_id}/tracking/pause`
3. `POST /api/v1/trips/{trip_id}/tracking/resume`
4. `POST /api/v1/trips/{trip_id}/tracking/stop`

Behavior details:

1. `start` returns existing active session (200) if already active.
2. `pause` is idempotent when already paused.
3. `resume` is idempotent when already active.
4. `stop` is idempotent when already ended.
5. Idempotency is enforced via `run_idempotent_mutation(...)` with payload + path params in hash material.

### 4.2 Batch ingest endpoints

1. `POST /api/v1/trips/{trip_id}/tracking/points:batch`
2. `POST /api/v1/trips/{trip_id}/tracking/events:batch`
3. `POST /api/v1/trips/{trip_id}/tracking/media:batch`
4. `POST /api/v1/trips/{trip_id}/tracking/media:upload`

Behavior details:

1. Points batch rejects ended/abandoned sessions.
2. Events/media batch are partial-accept APIs (`accepted[]`, `rejected[]`).
3. Media bind contract:
   - `bind_mode=place` requires valid `trip_place_id`.
   - `bind_mode=route` requires valid `location` anchor.
4. Duplicate client IDs are accepted as duplicates (idempotent semantics), not hard failures.

### 4.3 Projection and rebind endpoints

1. `GET /api/v1/trips/{trip_id}/compiled/projection`
2. `POST /api/v1/trips/{trip_id}/compiled/rebind`

Behavior details:

1. Rebind supports `tracking_event` and `tracking_event_media` source kinds.
2. Backend compiler remains authoritative for compiled projection shape.

### 4.4 Push token endpoints

1. `POST /api/v1/notifications/device-tokens/register`
2. `POST /api/v1/notifications/device-tokens/deactivate`

## 5. Flutter Runtime + Sync Architecture (Actual Wiring)

### 5.1 Core providers

1. Runtime repository provider: `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
2. Runtime snapshot stream: `liveTrackingRuntimeSnapshotProvider(tripId)`
3. Map overlay provider: `liveTrackingMapOverlayProvider(tripId)`
4. Capture coordinator provider: `liveTrackingCaptureCoordinatorProvider`

### 5.2 Runtime command path

Primary file: `flutter/lib/features/create/data/live_tracking_runtime_repository.dart`

Flow:

1. Resolve remote trip identity (`ensureRemoteTripId(..., allowCreate: false)`).
2. Execute command through `LiveTrackingApi`.
3. Persist server snapshot locally in `tracking_sessions`.
4. Stream updates to UI via `watchLatestSessionForTrip(tripId)`.

### 5.3 Local-first data path

Primary files:

1. `flutter/lib/features/live_capture/data/live_tracking_event_repository.dart`
2. `flutter/lib/core/sync/tracking_sync_worker.dart`

Flow:

1. UI action writes local `tracking_events` or `tracking_event_media`.
2. `sync_tasks` row is enqueued.
3. Tracking worker claims and processes.
4. Worker updates local row to `synced` or `pending/blocked` by response outcome.

### 5.4 Workers and responsibility split

1. `EntitySyncWorker`: `trip/place/route`
2. `TrackingSyncWorker`: `tracking_session`, `tracking_point_batch`, `checkin_decision`, `moment`, `tracking_event`, `tracking_event_media`
3. `UploadQueueWorker`: place-media queue path (`media` table lane)

Live screen retry behavior (`_retrySyncNow`) now starts all three worker families where relevant to reduce false blocked/synced mismatches.

### 5.5 Identity recovery behavior

Implemented in both runtime command path and tracking worker:

1. Detect `404 trip not found` mismatch.
2. Clear stale local `serverTripId`.
3. Queue trip create sync task.
4. Requeue identity-blocked tracking tasks with trip dependency.

## 6. API Transport Layer Rules (Flutter)

Primary file: `flutter/lib/core/network/live_tracking_api.dart`

Strict rules:

1. Do not modify generated `flutter/packages/dora_api/**` directly.
2. Wrapper (`DioLiveTrackingApi`) is the place for compatibility normalization.

Critical fix already shipped (`e3e476c`):

1. `_asJsonMap` now normalizes built_value envelopes/lists and nested `JsonObject`/`DateTime`.
2. This fix is required for lifecycle snapshots (`state`, `session_id`, `trip_id`) to reach runtime repository.
3. Removing/reverting this normalization can reintroduce "Start Tracking success but UI remains Ready" behavior.

## 7. Live Capture UI/UX + Motion (Current Implementation)

Primary screen: `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`

### 7.1 Map layer

1. Uses `LiveCaptureMapWidget` (direct Mapbox widget for live screen), not `AppMapView`.
2. Controller: `flutter/lib/features/live_capture/map/live_capture_map_controller.dart`.
3. Recenter FAB appears when follow mode is disabled by user interaction.
4. Map key is stable by trip ID (`ValueKey('liveCaptureMap-${tripId}')`).

### 7.2 Overlay motion system (Slice G)

1. Token source: `flutter/lib/core/theme/animation_tokens.dart`.
2. Top bar, action dock, bottom panel, recent events strip, and screen entrance animations are implemented.
3. Paused action gating fixed: only Note enabled in paused state.
4. Reduced-motion branches are implemented in overlay/transient surfaces.

### 7.3 Transient effects (Type C)

1. Widget: `flutter/lib/features/live_capture/presentation/widgets/live_capture_transient_effects.dart`.
2. Assets:
   - `flutter/assets/lottie/live_capture_photo_burst.json`
   - `flutter/assets/lottie/live_capture_warn_burst.json`
3. Current durations are half-speed overrides:
   - photo: `2500ms`
   - warn: `1500ms`
4. `cancelAll` clears in-flight bursts on sync-blocked state.

## 8. Resolver + Event Semantics (Current)

Primary files:

1. `flutter/lib/features/live_capture/data/live_tracking_event_resolver.dart`
2. `flutter/lib/features/live_capture/data/live_tracking_event_repository.dart`

Deterministic resolver thresholds:

1. `resolved >= 0.75`
2. `review_required >= 0.45 and < 0.75`
3. `on_route_unresolved < 0.45`

Ordered passes:

1. Trip-place radius match.
2. Prior resolved anchor match.
3. Reverse geocode fallback.
4. Nearby POI fallback.

Merge rule:

1. Network fallback cannot downgrade stronger local decision.

## 9. Sync Status Semantics (Current)

Primary file: `flutter/lib/features/create/presentation/providers/editor_sync_status_provider.dart`

For live tracking:

1. Blocked status excludes historical start `http_409` false-positive.
2. Unsynced row count includes trip row + tracking rows.
3. First blocked task metadata is surfaced for callout messaging.

Implication:

1. Do not interpret "Synced" only from session row; task + row aggregation drives UI label.

## 10. Known Drift / Open Work (As of 2026-04-04)

1. Advisory in-app pipeline remains pending in runtime code (planned in architecture docs).
2. Some tracker docs still show Slice G unchecked despite shipped commits (`586a799`, `a2c7c19`, `121a6a5`).
3. Long session soak validation is still operational QA work, not fully encoded in this doc.
4. Lottie assets are functional but not contract-short (timed by controller override, not native short compositions).

## 11. Hard "Do Not Assume" Rules for Agents

1. Do not assume plan checkbox state equals shipped code state.
2. Do not assume generated OpenAPI objects deserialize to plain maps; always check wrapper normalization.
3. Do not send local trip IDs to live-tracking backend endpoints.
4. Do not reintroduce deferred lifecycle sync-task path for `start/pause/resume/stop`.
5. Do not block local capture writes because command-plane is degraded.
6. Do not remove identity-recovery hooks (`clear serverTripId + requeue trip + requeue blocked tracking tasks`).
7. Do not edit `flutter/packages/dora_api` generated code manually.
8. Do not change resolver thresholds/order without tests and doc updates in all three core docs.

## 12. Mandatory Pre-Change Checklist for Any Agent

Read these files first:

1. `docs/live-tracking-unified-system-architecture-plan.md`
2. `flutter/docs/live-tracking-flutter-execution-plan.md`
3. `flutter/docs/live-capture-screen-implementation-spec.md`
4. `flutter/lib/features/create/data/live_tracking_runtime_repository.dart`
5. `flutter/lib/core/sync/tracking_sync_worker.dart`
6. `flutter/lib/core/network/live_tracking_api.dart`
7. `backend/app/api/v1/live_tracking.py`
8. `backend/app/services/live_tracking_service.py`

Run these validations for touched areas:

1. Flutter:
   - `cd flutter && flutter analyze --no-pub <touched files>`
   - `cd flutter && flutter test <touched tests>`
2. Backend (if touched):
   - `cd backend && alembic check`
   - `cd backend && pytest -q <touched tests>`

Update docs in same PR/commit when contracts change:

1. `docs/live-tracking-unified-system-architecture-plan.md`
2. `flutter/docs/live-capture-screen-implementation-spec.md`
3. `flutter/docs/live-tracking-flutter-execution-plan.md`
4. This document.

## 13. Why This Document Exists

The live-tracking stack now spans:

1. Backend idempotent command/data APIs.
2. Flutter local-first persistence.
3. Multi-worker sync and identity recovery.
4. Mapbox live runtime rendering.
5. Compiled projection editor merge.

Without a strict, code-anchored guideline, new agents can make contradictory assumptions from stale status trackers.  
This file is the guardrail against that.

