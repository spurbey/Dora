# Live Tracking System Truth Spec

Status: Permanent reference
Audience: Product, engineering, QA, on-call, and new team members
Last updated: 2026-04-07

---

## 1) Why this document exists

This is the single source-of-truth description of how live tracking actually works today across:

1. Flutter UI and local database
2. Sync workers and retry behavior
3. Backend APIs and backend database
4. Editor compiled storyline read path

This document is not a temporary handoff or memory note. It is a canonical behavior and load reference.

---

## 2) Plain-language overview (non-technical)

Think of the system as 3 lanes:

1. Command lane: Start/Pause/Resume/Stop tracking
2. Data lane: Capture things (note/photo/media/points), save locally first, upload later
3. Read lane: Show map route and compiled storyline in editor

Key truth:

1. Capture is local-first. User sees success before server upload finishes.
2. Lifecycle commands are server-first. If server trip identity is missing, command is blocked.
3. Editor storyline tries server compiled data first; if unavailable, it can show local fallback.

---

## 3) System boundaries and major modules

### Flutter (client)

1. Live screen UI: `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
2. Runtime command coordinator:
   `flutter/lib/features/create/data/live_tracking_capture_coordinator.dart`
3. Runtime command repository:
   `flutter/lib/features/create/data/live_tracking_runtime_repository.dart`
4. Event/media capture repository:
   `flutter/lib/features/live_capture/data/live_tracking_event_repository.dart`
5. Resolver engine:
   `flutter/lib/features/live_capture/data/live_tracking_event_resolver.dart`
6. Sync workers:
   `flutter/lib/core/sync/tracking_sync_worker.dart`
   `flutter/lib/core/sync/entity_sync_worker.dart`
   `flutter/lib/core/media/upload_queue_worker.dart`
7. Read providers:
   `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
   `flutter/lib/features/create/presentation/providers/compiled_projection_provider.dart`
8. API wrapper:
   `flutter/lib/core/network/live_tracking_api.dart`

### Backend (server)

1. Live tracking API routes:
   `backend/app/api/v1/live_tracking.py`
2. Compiled projection API routes:
   `backend/app/api/v1/compiled_projection.py`
3. Live tracking service:
   `backend/app/services/live_tracking_service.py`
4. Projection compiler service:
   `backend/app/services/trip_projection_compiler.py`
5. Live tracking worker:
   `backend/app/workers/live_tracking_worker.py`

---

## 4) Canonical end-to-end flow (user action -> UI result)

## 4.1 Start/Pause/Resume/Stop (command lane)

### What user does

1. Taps Start/Pause/Resume/Stop on live screen.

### Flutter flow

1. Button handlers: `live_capture_screen.dart:393`, `:404`, `:419`, `:434`
2. Wrapped by `_runLiveTrackingAction`: `live_capture_screen.dart:852`
3. Coordinator command methods:
   `live_tracking_capture_coordinator.dart:60`, `:78`, `:92`, `:107`
4. Repository server command methods:
   `live_tracking_runtime_repository.dart:141`, `:194`, `:236`, `:282`
5. Trip server ID resolution requires existing mapping:
   `live_tracking_runtime_provider.dart:35` (`allowCreate: false`)

### Backend flow

1. Endpoints:
   `live_tracking.py:64`, `:93`, `:120`, `:147`
2. Service methods:
   `live_tracking_service.py:428`, `:473`, `:498`, `:523`
3. Idempotent mutation wrapper:
   `live_tracking_service.py:154`

### What user sees

1. Snackbar from `_runLiveTrackingAction`.
2. Runtime state updates from local session stream (`live_tracking_runtime_snapshot_provider`).

### Hard rule

1. Commands are not deferred data tasks.
2. If server trip identity is missing/stale, command fails with sync-recovery message.

---

## 4.2 Note/Warn/Tag capture (data lane)

### What user does

1. Taps Note/Warn/Tag in action dock.

### Flutter flow

1. UI capture path:
   `live_capture_screen.dart:940`
2. Local event write + sync task enqueue:
   `live_tracking_event_repository.dart:139`, `:166`
3. Async resolver starts:
   `live_tracking_event_repository.dart:172`
4. Worker upload:
   `tracking_sync_worker.dart:613` -> API `live_tracking_api.dart:509`

### Backend flow

1. Endpoint: `POST /tracking/events:batch` in `live_tracking.py:208`
2. Service ingest:
   `live_tracking_service.py:646`
3. Projection dirty mark on accepted items:
   `live_tracking_service.py:857`

### What user sees

1. Immediate local success message.
2. Later sync status may change to synced/failed/blocked.

---

## 4.3 Photo/Media capture (data lane with binary upload)

### What user does

1. Taps Photo or Media.

### Flutter flow

1. Permission/file/GPS checks:
   `live_capture_screen.dart:1014`
2. Local event + local media rows written immediately:
   `live_tracking_event_repository.dart:184`, `:235`
3. Event task + media task enqueued:
   `live_tracking_event_repository.dart:222`, `:266`
4. Local resolver now, network reconcile async:
   `live_tracking_event_repository.dart:276`, `:300`
5. Media worker dependency chain:
   `tracking_sync_worker.dart:728`
   parent event dependency: `:753`
   place dependency when place-mode: `:790`
   binary upload: `:822`
   metadata batch: `:868`

### Backend flow

1. Binary upload endpoint:
   `POST /tracking/media:upload` -> `live_tracking_service.py:1159`
2. Metadata ingest endpoint:
   `POST /tracking/media:batch` -> `live_tracking_service.py:871`
3. Rejects unsynced parent event with `event_not_synced`:
   `live_tracking_service.py:943`
4. Dirty mark on accepted media:
   `live_tracking_service.py:1145`

### What user sees

1. “Saved locally / captured” immediately.
2. Backend sync is eventual.

---

## 4.4 Editor compiled storyline read (read lane)

### What user does

1. Opens editor.

### Flutter flow

1. Remote projection provider starts immediate fetch:
   `compiled_projection_provider.dart:153`
2. Also listens to debounced sync-task signal:
   `compiled_projection_provider.dart:40`, debounce `:88`
3. Also runs fallback poll every 90s:
   `compiled_projection_provider.dart:148`
4. Repository resolves local trip ID -> server trip ID boundary:
   `compiled_projection_repository.dart:51`
5. If missing server trip ID, fallback local merge view:
   `compiled_projection_provider.dart:209`, merge factory `:244`

### Backend flow

1. Endpoint:
   `GET /trips/{trip_id}/compiled/projection` (`compiled_projection.py:24`)
2. Compiler service:
   `trip_projection_compiler.py:250`
3. If dirty, compile-on-read happens:
   `trip_projection_compiler.py:254`, compile body `:282`

### What user sees

1. Backend compiled storyline when available.
2. Local fallback when remote unavailable.

---

## 4.5 Place confirm / keep on route

### Live screen confirm

1. Confirm action:
   `live_capture_screen.dart:1092`
2. Local resolver decision written:
   `live_tracking_event_repository.dart:359` -> resolver `live_tracking_event_resolver.dart:99`
3. Synced route-media IDs are rebind candidates:
   `live_tracking_event_repository.dart:391`
4. Rebind loop sends one call per media ID:
   `live_capture_screen.dart:1118` -> repo `compiled_projection_repository.dart:68`

### Keep on route

1. Live keep action:
   `live_capture_screen.dart:1163`
2. Local-only decision update:
   `live_tracking_event_repository.dart:399`
3. No backend rebind is sent in this path.

### Editor assign

1. Assign-place action:
   `editor_screen.dart:1466`, rebind `:1563`, invalidate `:1583`

---

## 5) API inventory and trigger cadence

## 5.1 Core live/editor API endpoints

1. `POST /api/v1/trips/{trip_id}/tracking/start`
2. `POST /api/v1/trips/{trip_id}/tracking/pause`
3. `POST /api/v1/trips/{trip_id}/tracking/resume`
4. `POST /api/v1/trips/{trip_id}/tracking/stop`
5. `POST /api/v1/trips/{trip_id}/tracking/points:batch`
6. `POST /api/v1/trips/{trip_id}/tracking/events:batch`
7. `POST /api/v1/trips/{trip_id}/tracking/media:upload`
8. `POST /api/v1/trips/{trip_id}/tracking/media:batch`
9. `GET /api/v1/trips/{trip_id}/tracking/path`
10. `GET /api/v1/trips/{trip_id}/compiled/projection`
11. `POST /api/v1/trips/{trip_id}/compiled/rebind`

## 5.2 Background/legacy still active

1. `POST /api/v1/checkins/{candidate_id}/confirm`
2. `POST /api/v1/checkins/{candidate_id}/reject`
3. `POST /api/v1/checkins/{candidate_id}/snooze`
4. `POST /api/v1/trips/{trip_id}/moments`
5. `PATCH /api/v1/moments/{moment_id}`
6. Push token register/deactivate endpoints

## 5.3 Built-in polling/heartbeat rates

1. Live map remote path polling:
   12s active, 30s paused, 60s ended/planned
   (`live_tracking_runtime_provider.dart:60`, `:62`, `:64`)
2. Compiled projection fallback poll:
   90s (`compiled_projection_provider.dart:148`)
3. Worker heartbeats:
   tracking/entity/media each every 20s
   (`tracking_sync_bootstrap.dart:10`, `entity_sync_bootstrap.dart:10`, `media_queue_bootstrap.dart:10`)
4. Live resolver periodic reconcile:
   45s (`live_capture_screen.dart:126`)

---

## 6) Local DB and server DB write/read behavior

## 6.1 Client local DB writes (immediate)

1. Capture event writes `tracking_events`.
2. Capture media writes `tracking_event_media`.
3. Point stream writes `tracking_point_batches`.
4. Every write enqueues corresponding sync task row in `sync_tasks`.

This guarantees offline capture continuity, but does not mean server persistence already happened.

## 6.2 Worker-driven local status updates

1. `tracking_sync_worker` marks per-row `synced`, `pending`, `blocked`, or retry state.
2. Media worker and entity worker do similar transitions for their lanes.
3. Stale 409 point-session conflicts can be auto-terminated as dropped stale session.

## 6.3 Server DB behavior

1. Lifecycle endpoints mutate `trip_tracking_sessions` and trip tracking timestamps.
2. Event/media/point ingest endpoints write raw tracking tables with partial-accept semantics.
3. Accepted ingest marks projection as dirty.
4. Projection endpoint may trigger compile and rewrite projection artifact tables.

---

## 7) Retry and backoff model

## 7.1 Tracking sync worker

1. Retry delays: 15s, 60s, then 180s
   (`tracking_sync_worker.dart:57`, `:58`, backoff `:1471`)
2. Max attempts bounded (worker checks attempt count and terminal transition logic).

## 7.2 Entity sync worker

1. Retry delays: 15s, 60s
   (`entity_sync_worker.dart:40`, `:41`, backoff `:428`)

## 7.3 Media upload queue worker

1. Retry delays: 10s, 30s
2. Dependency retry: 5s
   (`upload_queue_worker.dart:44`, `:45`, `:46`)

---

## 8) Request volume model (how server gets drained)

These are formulas for understanding traffic pressure:

1. Live path polling load per active user:
   approximately `60/12 = 5 GET /tracking/path per minute`
2. Compiled projection background load per open editor:
   approximately `0.67 GET/min` from 90s poll
   plus immediate fetch
   plus signal-triggered fetches
3. Worker heartbeat wake-ups:
   3 workers * every 20s = 9 heartbeat cycles/min even when no user action
4. Rebind fan-out:
   1 confirm action can cause N `POST /compiled/rebind` calls (current loop per media ID)
5. Capture burst:
   high capture rates produce many single-item event/media batch calls if not coalesced.

## 8.1 Quantified cost per user action (practical estimates)

These numbers are intentionally approximate but operationally useful.

### Client-side (Flutter local DB + tasks)

1. Start/Pause/Resume/Stop tap:
   - local writes: about 1 `tracking_sessions` upsert
   - sync task writes: 0 lifecycle sync tasks (command lane is write-through)
   - network requests: 1 command API call

2. Note/Warn/Tag capture:
   - local writes: 1 `tracking_events` upsert
   - sync task writes: 1 `sync_tasks` row (`tracking_event/upload`)
   - network requests eventually: ~1 `events:batch`

3. Photo/Media capture:
   - local writes: 1 `tracking_events` + 1 `tracking_event_media`
   - sync task writes: 2 (`tracking_event/upload` + `tracking_event_media/upload`)
   - network requests eventually:
     1. ~1 `events:batch` (event identity)
     2. ~1 `media:upload` (binary)
     3. ~1 `media:batch` (metadata)

4. GPS point ingest while active:
   - local writes: repeated upserts to rolling `tracking_point_batches`
   - sync task writes: at least 1 queued task per mutable batch window
   - network requests eventually: ~1 `points:batch` per flushed batch
   - batching policy defaults:
     - max 25 points per batch
     - max 20 seconds window per batch

### Backend-side (query/write pattern estimates)

1. `start/pause/resume/stop`:
   - reads: trip ownership + session lookup (typically 1-2 queries)
   - writes: session state + trip tracking timestamps (typically 1-2 row updates/inserts)

2. `points:batch`:
   - reads: session check + duplicate point-id check query
   - writes: N point inserts + 1 session update
   - plus projection dirty mark update

3. `events:batch`:
   - per-item reads: duplicate check (and optional session validation)
   - per-item writes: accepted rows inserted
   - plus projection dirty mark update

4. `media:batch`:
   - per-item reads: parent event lookup + duplicate check (+ place lookup when place mode)
   - per-item writes: accepted media rows inserted
   - plus projection dirty mark update

5. `compiled/projection`:
   - when clean: mostly read compiled artifact rows
   - when dirty: full compile path (raw table reads + compiled artifact rewrite)

---

## 9) What is going wrong right now (confirmed)

## 9.1 Data integrity / behavior mismatches

1. Manual decision lock is not enforced end-to-end.
2. `keep on route` from live is local-only, backend compiled truth can lag.
3. UI can claim success while backend action is still pending or failed.

## 9.2 Load/flood design pressure

1. Compiled projection has multiple fetch triggers (immediate + signal + poll + manual invalidation).
2. Live screen path polling is frequent by design.
3. Three worker heartbeats run continuously.
4. Live rebind loop is per-item (can burst requests).

## 9.3 Backend-side hot path risk

1. `GET compiled/projection` can compile-on-read when dirty (expensive under repeat calls).
2. Full rebuild pattern in compiler (delete/reinsert artifacts).
3. Batch ingest service paths still do heavy per-item checks/flushes.

---

## 10) Unused/redundant/cluttered code inventory

## 10.1 Clearly redundant or clutter-prone

1. Legacy command sync path still exists in tracking worker while runtime repo already does write-through command lane.
2. Legacy `moment` and `checkin_decision` sync lanes are still active beside new `tracking_event`/`tracking_event_media` lanes.
3. Projection refresh still watches `checkin_decision` even when advisory lane is considered deferred.
4. Sync status SQL logic is duplicated in multiple providers.
5. Path shaping logic is split across local overlay and remote path stabilization.

## 10.1 Specific currently low-value or rarely-used surfaces

1. `hasReviewPrompt` helper is currently not used by the main live screen flow.
2. Some pass-through repository helpers in live event repo are not used by primary live UI path.
3. `TrackingPointBatchDao` claim helper methods are not used by the main tracking sync worker claim path (worker claims from `sync_tasks`).

## 10.2 Known low-value wrappers/helpers

1. `hasReviewPrompt` getter currently unused path indicator in provider layer.
2. Some repository pass-through helpers are currently not used by primary live screen path.

Note: These should be cleaned only after locking integrity behavior, not before.

---

## 11) Single source-of-truth rules (must follow)

1. Local IDs are canonical in Flutter state and local DB.
2. Remote IDs must be resolved only at API boundaries.
3. Capture success message must distinguish:
   local saved vs server synced.
4. Manual user decisions must be lock-protected against auto-reconcile overwrite.
5. `on_route_unresolved` is a valid product outcome, not a failure state.

---

## 12) Recommended immediate hardening order (small commits)

1. Manual decision lock enforcement across resolver/reconcile paths.
2. Truthful UX messaging for local-only vs remote-confirmed outcomes.
3. Success-gated projection invalidation only after remote success.
4. Projection trigger trim (remove nonessential trigger entities if advisory deferred).
5. Rebind call coalescing (avoid per-item bursts).
6. Worker heartbeat and polling gating improvements.

---

## 13) Acceptance checks for future changes

Every live/editor change must prove:

1. Which lane it touches (command/data/read)
2. Local DB writes count
3. Sync task effects
4. Backend endpoint call count and retry impact
5. Whether it increases poll/heartbeat/invalidations
6. Whether UI claim text matches backend truth timing

---

## 14) Appendix: key code reference index

### Flutter

1. Live screen:
   `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
2. Runtime coordinator:
   `flutter/lib/features/create/data/live_tracking_capture_coordinator.dart`
3. Runtime repo:
   `flutter/lib/features/create/data/live_tracking_runtime_repository.dart`
4. Event/media repo:
   `flutter/lib/features/live_capture/data/live_tracking_event_repository.dart`
5. Resolver:
   `flutter/lib/features/live_capture/data/live_tracking_event_resolver.dart`
6. Tracking worker:
   `flutter/lib/core/sync/tracking_sync_worker.dart`
7. Entity worker:
   `flutter/lib/core/sync/entity_sync_worker.dart`
8. Media worker:
   `flutter/lib/core/media/upload_queue_worker.dart`
9. Projection provider:
   `flutter/lib/features/create/presentation/providers/compiled_projection_provider.dart`
10. Runtime provider:
    `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
11. API wrapper:
    `flutter/lib/core/network/live_tracking_api.dart`

### Backend

1. Live API routes:
   `backend/app/api/v1/live_tracking.py`
2. Projection API routes:
   `backend/app/api/v1/compiled_projection.py`
3. Live service:
   `backend/app/services/live_tracking_service.py`
4. Projection compiler:
   `backend/app/services/trip_projection_compiler.py`
5. Live worker:
   `backend/app/workers/live_tracking_worker.py`
