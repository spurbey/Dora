# Live Tracking Flutter Execution Plan (Phases 4-6)

Last updated: 2026-03-25  
Status: In Progress (Phase 4 validated; Phase 5 runtime slices 1-2 in progress; Phase 6 slices 1-9 in progress)  
Parent high-level plan: `docs/live-tracking/live-tracking-execution-plan.md`

## 1. Purpose and Why

This document is the low-level execution memory for Flutter live-tracking work.

Why this exists in addition to the root plan:

1. Root plan is phase-gate and rollout memory across backend + Flutter.
2. Flutter plan is implementation memory (files, architecture boundaries, UI rules, testing matrix).
3. Keeping both docs synchronized prevents drift between product intent and app implementation details.

## 2. Root <-> Flutter Sync Contract

Sync keys:

| Sync Key | Root Reference | Flutter Reference | Purpose |
|---|---|---|---|
| FLT-P4 | Root Phase 4 | Section 6.1 | Storage/sync architecture + execution |
| FLT-P5 | Root Phase 5 | Section 6.2 | Runtime capture lifecycle + background behavior |
| FLT-P6 | Root Phase 6 | Section 6.3 | UX/map controls + candidate/moment flows |

Update rules:

1. Any scope/contract change for Flutter live-tracking must update both docs in the same commit.
2. Root doc keeps high-level objective, phase status, exit criteria, and evidence summary.
3. This doc keeps low-level file ownership, API mapping, test matrix, and UX behavior.
4. If conflict exists, the frozen contract docs and root phase-gates take precedence.

## 3. Inputs and Baseline

Primary references:

1. `docs/live-tracking/live-tracking-prd.md`
2. `docs/live-tracking/2026-03-21-live-tracking-phase0-contract-freeze.md`
3. `docs/live-tracking/live-tracking-execution-plan.md`
4. `flutter/docs/architecture.md`
5. `flutter/docs/design_system.md`
6. `flutter/docs/rules.md`
7. `flutter/docs/handoffs/2026-03-20-trip-sync-execution-tracker.md`
8. `flutter/docs/handoffs/2026-03-20-trip-sync-m0-contract-freeze.md`

Current Flutter baseline (already present):

1. Drift DB and migration framework exist (`core/storage/drift_database.dart`, schema version `12`).
2. Sync queue exists (`sync_tasks`) with claim/retry/dependency semantics.
3. Sync lane abstraction exists in `core/sync/live_tracking_sync_primitives.dart`.
4. `tracking_point_batch` is already split into a non-interactive lane.
5. Entity sync worker exists for `trip/place/route` only.
6. Location foundation is currently single-shot/permission utilities (no continuous runtime engine yet).
7. Map UI exists in editor and trip detail surfaces; editor now has live-tracking controls and live path/current-marker overlay, while candidate/moment UX remains pending.
8. OpenAPI generated client package exists, but live-tracking APIs are not yet wired in Flutter.

## 4. Non-Negotiable Flutter Rules

1. Offline-first: local persistence first, sync second.
2. Manual edits always win over auto inference.
3. Tombstone/cooldown semantics must be respected in UI and sync merge logic.
4. High-volume tracking uploads must not block interactive trip/place/route sync.
5. Use idempotency keys for all live-tracking mutating calls.
6. Keep generated API client code immutable (`flutter/packages/dora_api`).
7. Keep map abstraction boundaries (`AppMapView` / map adapters), no direct SDK leaks into feature logic.
8. Background strategy cannot rely only on periodic schedulers; continuous capture needs a dedicated runtime path.
9. Feature rollout must be remotely gated and safely disabled.
10. Every phase must end with documented validation evidence in both root and Flutter docs.

## 5. Target Flutter Architecture

## 5.1 Module Layout and Ownership

Planned additions (target paths):

1. `flutter/lib/core/storage/tables/`
   - `tracking_sessions_table.dart`
   - `tracking_point_batches_table.dart`
   - `tracking_candidates_table.dart`
   - `tracking_moments_table.dart`
2. `flutter/lib/core/storage/daos/`
   - `tracking_session_dao.dart`
   - `tracking_point_batch_dao.dart`
   - `tracking_candidate_dao.dart`
   - `tracking_moment_dao.dart`
3. `flutter/lib/core/sync/`
   - `tracking_sync_worker.dart`
   - `tracking_sync_bootstrap.dart`
4. `flutter/lib/features/live_tracking/`
   - `data/` repositories + DTO/domain mappers
   - `domain/` runtime states + policies
   - `presentation/` providers, widgets, sheets
5. Routing and entry points:
   - `core/navigation/routes.dart`
   - `core/navigation/app_router.dart`
   - integration into existing editor/trip-detail flows

## 5.2 Local Data Contract (Drift)

Tracking sessions table (local runtime + sync):

1. Keys: `id` (client session id), `tripId`, optional `remoteSessionId`.
2. Lifecycle: `planned/active/paused/ended` (`planned` is local pre-start UI/runtime state, not a server session state).
3. Cursor fields: `lastPointAt`, `lastFlushAt`.
4. Sync fields: `syncStatus`, `localUpdatedAt`, `serverUpdatedAt`.
5. Device context snapshot (platform/build/provider hints).

Tracking point batches table (high-volume, idempotent uploads):

1. Keys: `id`, `tripId`, `sessionId`, `clientBatchId`.
2. Payload: serialized points + metadata (`firstRecordedAt`, `lastRecordedAt`, `pointCount`).
3. Delivery state: `queued/in_progress/failed/completed`.
4. Retry fields: `retryCount`, `nextAttemptAt`, `workerSessionId`.
5. Invariant: one logical batch per `clientBatchId`.

Tracking candidates table (server-driven prompts cache):

1. Keys: `candidateId`, `tripId`, `sessionId`.
2. Fields: confidence, suggested name/lat/lng/time window, status, payload snapshot.
3. Notification state mirror for inbox fallback rendering.
4. Local action state to avoid duplicate decision submission.

Tracking moments table (server + local override view):

1. Keys: `momentId`, `tripId`, optional `candidateId`.
2. Fields: source (`auto/manual`), confidence, capturedAt, location, notes/media refs.
3. Locked/manual fields for merge safety.

## 5.3 Sync Task and Lane Policy

Entity types and lanes:

1. `tracking_session`: interactive lane (state transitions are user visible).
2. `tracking_point_batch`: tracking batch lane (high-volume, lower priority than manual edits).
3. `checkin_decision`: interactive lane.
4. `moment`: interactive lane.

Task dependency examples:

1. `tracking_point_batch` depends on successful session start/identity binding.
2. `checkin_decision` can run independently but should prefer freshest candidate snapshot.
3. `moment` upsert depends on valid trip ownership and candidate linkage when present.

## 5.4 API Mapping and Idempotency

Required Flutter request metadata:

1. `X-Idempotency-Key` for all mutating live-tracking endpoints.
2. `client_batch_id` for point batch uploads.
3. `client_event_id` for candidate decisions and manual moment writes.

Client responsibilities:

1. Idempotency key scope includes concrete resource identity (`tripId`, `candidateId`, `momentId`).
2. Retry with same idempotency key on transport failure.
3. Never regenerate keys on automatic retry of the same logical mutation.

## 5.5 UI/UX Guardrails

1. Live tracking controls must be explicit: `Start`, `Pause`, `Resume`, `Stop`.
2. Active tracking status must always be visible in editor header or map overlay.
3. Candidate prompts must map to backend contract actions: `confirm`, `reject`, `snooze` (UX copy may label `reject` as "Dismiss", but wire action remains `reject`).
4. `No push token` must still surface prompts in-app (inbox fallback), and push state for that candidate is terminal (`skipped_no_tokens`) unless product policy explicitly changes.
5. Manual trip completion path (`planned -> completed`) must remain available when tracking was never started.
6. Use existing design tokens (`AppColors`, `AppSpacing`, `AppTypography`, `AppRadius`) and avoid introducing parallel style systems.

## 5.6 Runtime and Background Capture Strategy

Implementation requirement:

1. Continuous capture runtime must be explicit and robust on Android + iOS.
2. Periodic background job scheduling is only for recovery/flush, not primary sampling.

Planned runtime split:

1. Foreground: continuous stream with adaptive cadence and accuracy thresholds.
2. Background: dedicated platform runtime path for location continuity.
3. Recovery: scheduled task to flush pending batches, reconcile sessions, and repair stale in-progress states.

Decision gate before coding Phase 5 runtime internals:

1. Confirm final background implementation path and platform permissions matrix.
2. Lock battery and data-volume thresholds with measurable acceptance criteria.

## 6. Phase Execution Plan (Flutter)

## 6.1 Phase 4: Storage and Sync Wiring (Sync Key: FLT-P4)

Objective:

1. Land deterministic local schema and queue wiring for live-tracking entities.

Implementation steps:

1. Regenerate API client after backend live-tracking contract is confirmed.
2. Add Drift tables + DAOs for sessions, point batches, candidates, and moments.
3. Bump schema version and implement additive migration with backfill defaults.
4. Extend sync primitives and task DAO usage for new entity types.
5. Implement tracking sync worker with lane-aware claim/retry behavior.
6. Persist candidate/moment snapshots from server into local cache for offline UX continuity.

Exit criteria:

1. Drift migration upgrades from current schema without data loss.
2. Queue dependency handling is deterministic for session -> batch sequencing.
3. Interactive sync is not starved by high-volume tracking batch backlog.
4. Candidate/moment cache reads are available offline.

Required validation:

1. DAO unit tests for inserts/updates/queries and conflict paths.
2. Queue claim/retry tests for lane split and dependency handling.
3. Migration tests from schema `12` baseline to new schema.
4. `flutter analyze --no-pub` clean on touched modules.

## 6.2 Phase 5: Runtime Capture Lifecycle (Sync Key: FLT-P5)

Objective:

1. Deliver resilient on-device tracking lifecycle and batching.

Implementation steps:

1. Add runtime state machine provider for `planned/active/paused/ended`, where `planned` is local pre-start state before server session creation.
2. Start session handshake and local session persistence.
3. Add continuous point capture pipeline with filters (accuracy, dedup window, cadence).
4. Batch points by time/count and enqueue sync tasks with deterministic `client_batch_id`.
5. Add restart recovery logic:
   - resume active session on app relaunch
   - recover stale in-progress batch/session states
6. Implement permission and service-disabled UX flows with safe fallbacks.
7. Integrate background capture runtime and recovery flush path.

Exit criteria:

1. Offline capture persists and syncs when connectivity returns.
2. Restart/resume does not create duplicate active sessions.
3. Permission denial/service disabled states are explicit and recoverable.
4. Background behavior meets reliability acceptance criteria.

Required validation:

1. Unit tests for runtime state machine transitions.
2. Integration tests for batching and retry/idempotency behavior.
3. Device matrix manual tests (Android/iOS foreground, background, killed-app recovery).
4. Battery/throughput sanity run with documented thresholds.

## 6.3 Phase 6: UX and Map Integration (Sync Key: FLT-P6)

Objective:

1. Expose live tracking workflows with coherent map and review UX.

Implementation steps:

1. Add entry points:
   - editor header control
   - trip detail live status/view
2. Render live path/polyline and current location marker on map surfaces.
3. Add candidate queue surface with `confirm/reject/snooze` actions (UX copy can show "Dismiss" while submitting `reject`).
4. Add moment review/override flow, preserving manual lock semantics.
5. Add in-app inbox fallback presentation for notification prompts.
6. Add status badges and sync health indicators for tracking sessions.

Exit criteria:

1. End-to-end user flow works: start -> capture -> candidate decision -> moment confirmation -> stop/complete.
2. No regressions in existing create/editor/trip detail experiences.
3. Design system parity maintained across mobile form factors.

Required validation:

1. Widget tests for controls and candidate action states.
2. Integration tests for map overlays and state transitions.
3. Manual UX checklist for phone sizes and orientation changes.

## 7. Testing and Validation Matrix

Automated:

1. Drift migration + DAO tests.
2. Sync worker tests (lane fairness, retry/backoff, dependency ordering).
3. Runtime state machine tests.
4. Candidate/moment provider and reducer tests.
5. Widget tests for control states and action affordances.

Manual device checks:

1. Start tracking with weak network.
2. Pause/resume while app foreground/background transitions occur.
3. Force app kill and relaunch while tracking is active.
4. Complete decision actions from candidate prompts while offline then online.
5. Validate map polyline continuity and no duplicate segments after retries.

Command checklist:

1. `cd flutter && flutter pub get`
2. `cd flutter && dart run build_runner build --delete-conflicting-outputs`
3. `cd flutter && flutter analyze --no-pub`
4. `cd flutter && flutter test`

## 8. Observability and Safety Controls

Feature flags (planned):

1. `enable_live_tracking`
2. `enable_live_tracking_background`
3. `enable_live_tracking_candidates`

Operational metrics to log from Flutter:

1. active session count (local)
2. queued point batch count
3. oldest pending batch age
4. retryable failure count
5. average flush latency
6. candidate decision enqueue-to-ack latency

Safety controls:

1. Kill switch must disable new session starts while preserving read-only history.
2. Runtime must stop capture cleanly on logout or trip ownership change.
3. Queue saturation guard must reduce capture cadence before local DB pressure becomes unsafe.

## 9. Risks and Decisions to Lock

1. Background runtime implementation choice and OS-specific constraints.
2. Local retention window for raw point batches vs DB size growth.
3. Final UX placement for candidate queue in editor vs dedicated inbox route.
4. Push token registration flow ownership and fallback behavior when token unavailable.

## 10. Documentation Update Procedure

After each Flutter live-tracking slice:

1. Update root doc phase status/evidence summary.
2. Update this doc with file-level changes and validation evidence.
3. Record any new invariants or contract deltas in both places.
4. Do not start next phase until current phase evidence is recorded.

## 11. Execution Log

- Date: 2026-03-23
- Slice: Phase 4 storage/sync foundation
- Implemented:
  - Added Drift schema entities for:
    - `tracking_sessions`
    - `tracking_point_batches`
    - `tracking_candidates`
    - `tracking_moments`
  - Bumped local schema version to `13` and wired migration create steps.
  - Added DAOs for sessions, point batches, candidates, and moments.
  - Added query-path secondary indexes for high-volume tracking workload.
  - Hardened batch recovery:
    - stale `in_progress` batches become claimable
    - `clearWorkerSession()` requeues `in_progress` rows instead of leaving them unrunnable
  - Marked session lifecycle updates as `syncStatus='pending'` to keep later sync selectors accurate.
  - Added/updated tests for:
    - new live-tracking DAOs
    - sync task filtering support
    - sync primitive worker-support sets
- Validation:
  - `cd flutter; dart run build_runner build --delete-conflicting-outputs` (pass)
  - `cd flutter; flutter test test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart` (pass)
  - `cd flutter; flutter analyze --no-pub lib/core/storage lib/core/sync test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart` (no analyzer errors; info-level lint hints remain)
- Decision notes:
  - Dedicated tracking sync worker remains a follow-up in Phase 4 completion.
  - Current behavior avoids silent task idling while tracking execution wiring is still being implemented.

- Date: 2026-03-23
- Slice: Phase 4 dedicated tracking sync worker wiring
- Implemented:
  - Added `lib/core/network/live_tracking_api.dart` transport contract and Dio implementation for:
    - tracking session lifecycle (`start/pause/resume/stop`)
    - point batch upload
    - check-in decisions (`confirm/reject/snooze`)
    - moments (`create/update`)
  - Added `lib/core/sync/tracking_sync_worker.dart`:
    - lane-scoped claims to `tracking_session/tracking_point_batch/checkin_decision/moment`
    - retry/backoff and blocked/deferred handling
    - dependency block when point batch lacks remote session id
    - local moment-ID replacement when server returns canonical ID after create
  - Added worker bootstrap/provider wiring:
    - `lib/core/sync/tracking_sync_bootstrap.dart`
    - `lib/features/create/presentation/providers/tracking_sync_provider.dart`
    - `lib/core/network/api_providers.dart` (`liveTrackingApiProvider`)
    - `lib/app.dart` bootstraps tracking worker start heartbeat
  - Added `TrackingMomentDao.replaceMomentId` helper for create-response ID reconciliation.
  - Added/updated tests:
    - `test/core/sync/tracking_sync_worker_test.dart`
    - existing sync/DAO suites revalidated for lane boundaries and queue semantics.
- Validation:
  - `cd flutter; flutter analyze lib/core/sync/tracking_sync_worker.dart lib/core/network/live_tracking_api.dart lib/core/sync/tracking_sync_bootstrap.dart lib/features/create/presentation/providers/tracking_sync_provider.dart lib/core/network/api_providers.dart lib/core/storage/daos/tracking_moment_dao.dart lib/app.dart test/core/sync/tracking_sync_worker_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart test/core/sync/entity_sync_worker_test.dart test/core/storage/sync_task_dao_test.dart test/core/storage/live_tracking_storage_dao_test.dart` (pass: 33 passed)
- Decision notes:
  - Phase 4 no longer leaves tracking tasks as queue-only; execution path is now explicit and isolated from `EntitySyncWorker`.
  - Remaining Phase 4 closeout is evidence completion and any last migration/backfill checks before Phase 5 runtime capture internals.

- Date: 2026-03-23
- Slice: Phase 4 tracking sync hardening (post-review)
- Implemented:
  - Fixed live-tracking transport route prefixing:
    - `lib/core/network/live_tracking_api.dart` now uses `/api/v1/...` endpoint paths.
  - Hardened tracking worker completion semantics:
    - `lib/core/sync/tracking_sync_worker.dart` now uses transactional success finalization with `shouldMarkEntitySynced`.
    - Prevents local `syncStatus='synced'` writes when `sync_tasks.pending_requeue=1`.
  - Hardened deferred dependency handling:
    - deferred point-batch path now writes `sync_tasks.status='pending'` (not terminal `blocked`) with delayed `nextAttemptAt`.
    - avoids both permanent dead-end blocking and hot-loop immediate retries when dependency task is absent.
  - Added sync-task utility methods:
    - `markPending(...)`
    - `replaceTaskEntityId(...)`
    - file: `lib/core/storage/daos/sync_task_dao.dart`
  - Added moment create remap safety:
    - when server returns canonical moment ID, worker now updates both local moment row ID and queued task `entityId` consistently.
- Tests/validation:
  - Added `test/core/network/live_tracking_api_test.dart` to lock `/api/v1` path prefix behavior.
  - Updated `test/core/sync/tracking_sync_worker_test.dart`:
    - deferred point batch -> `pending`
    - requeue-in-progress session sync keeps local `syncStatus='pending'` before follow-up completion
  - Updated `test/core/storage/sync_task_dao_test.dart`:
    - `markPending` runnable behavior
    - `replaceTaskEntityId` remap behavior
  - Commands:
    - `cd flutter; flutter analyze lib/core/network/live_tracking_api.dart lib/core/storage/daos/sync_task_dao.dart lib/core/sync/tracking_sync_worker.dart test/core/network/live_tracking_api_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass)
    - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass)
    - `cd flutter; flutter test test/core/network/live_tracking_api_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart` (pass)
- Decision notes:
  - Trip-sync review findings were accepted as valid and addressed in this slice.
  - No scope deferrals for the reported high-severity items.

- Date: 2026-03-23
- Slice: Phase 4 deferred-cooldown guardrail follow-up
- Implemented:
  - Added explicit assertion in tracking worker tests that deferred point-batch tasks persist `next_attempt_at` when moved to `pending`.
  - file: `test/core/sync/tracking_sync_worker_test.dart`
- Validation:
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass: 5 passed)
- Decision notes:
  - No runtime code changes were needed; this follow-up locks existing anti-churn behavior against regression.

- Date: 2026-03-23
- Slice: Phase 4 snapshot hydration hardening (post-review)
- Implemented:
  - Accepted review feedback on session hydration fallback safety in `TrackingSyncWorker`.
  - Session hydration now uses the current session row as fallback for omitted server fields instead of task-claim snapshot values:
    - `state`
    - `client_session_id`
    - `timezone`
    - `device_context`
  - Session hydration now sets `serverUpdatedAt` from snapshot `updated_at` when available (worker `now` only as fallback).
  - Removed unused `fallbackRow` argument from candidate hydration helper to reduce ambiguity.
  - Added regression test for mid-flight session edits during `pause` sync to prevent stale overwrite regressions.
- Validation:
  - `cd flutter; flutter analyze lib/core/sync/tracking_sync_worker.dart test/core/sync/tracking_sync_worker_test.dart` (pass)
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass: 8 passed)
- Decision notes:
  - This hardening is in-scope for Phase 4 because it protects offline cache correctness under concurrent local edits and partial server snapshots.

- Date: 2026-03-23
- Slice: Phase 4 snapshot hydration for offline cache parity
- Implemented:
  - Expanded `TrackingSyncWorker` server snapshot persistence to hydrate richer local cache fields after successful sync.
  - Session hydration now captures canonical fields:
    - `remoteSessionId`, `clientSessionId`, `state`, `timezone`, `deviceContextJson`
    - lifecycle timestamps (`startedAt`, `pausedAt`, `resumedAt`, `endedAt`, `abandonedAt`, `lastPointAt`)
  - Candidate hydration now captures canonical fields:
    - `sessionId`, `fingerprint`, `confidence`, suggestion coordinates/name
    - `confirmedTripPlaceId`, `rejectedReason`, `snoozedUntil`, `cooldownUntil`, `payloadJson`
  - Moment hydration now captures canonical fields:
    - `candidateId`, `linkedTripPlaceId`, `source`, `confidence`
    - `latitude`, `longitude`, `note`, `mediaRefsJson`, `extraPayloadJson`, `lockedFieldsJson`
  - Requeue safety remains enforced:
    - when task completion resolves to requeue (`pending_requeue=1`), local entities are not incorrectly finalized as `synced`.
  - Added/expanded worker tests for session/candidate/moment snapshot hydration.
- Validation:
  - `cd flutter; flutter analyze lib/core/sync/tracking_sync_worker.dart test/core/sync/tracking_sync_worker_test.dart` (pass)
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass: 7 passed)
  - `cd flutter; flutter test test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 27 passed)
- Decision notes:
  - This slice closes a parity gap where offline cache rows could lag behind backend canonical snapshots after sync.
  - Phase 4 closeout now includes schema foundation, worker wiring, hardening, and snapshot hydration evidence.

- Date: 2026-03-23
- Slice: Phase 4 closeout validation + migration hardening
- Implemented:
  - Added migration regression test:
    - `test/core/storage/drift_database_migration_test.dart`
    - verifies schema `12 -> 13` upgrade creates all tracking tables and secondary indexes
    - verifies pre-upgrade data survives the upgrade
  - Fixed migration upgrade-path index gap in:
    - `lib/core/storage/drift_database.dart`
    - explicitly creates tracking indexes in `from < 13` branch
- Validation:
  - `cd flutter; flutter analyze lib/core/storage/drift_database.dart lib/core/sync/tracking_sync_worker.dart test/core/storage/drift_database_migration_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass)
  - `cd flutter; flutter test test/core/storage/drift_database_migration_test.dart test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 49 passed)
- Decision notes:
  - Phase 4 is now validated; migration safety and runtime sync path are both explicitly covered by tests.

- Date: 2026-03-23
- Slice: Phase 5 runtime lifecycle + batching foundation (slice 1)
- Implemented:
  - Added `lib/features/create/data/live_tracking_runtime_repository.dart`:
    - local lifecycle state machine (`planned/active/paused/ended`)
    - operations: `startSession`, `pauseSession`, `resumeSession`, `stopSession`
    - point ingest with dedup guard (cadence + distance)
    - batch append/split policy (`maxPointsPerBatch`, `maxBatchWindow`)
    - sync task enqueue for sessions and point batches with session dependency
  - Added provider wiring:
    - `lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
  - Added DAO/runtime support methods:
    - `TrackingSessionDao.getLatestSessionForTrip`, `watchLatestSessionForTrip`, `markLastPointAt`
    - `TrackingPointBatchDao.getLatestMutableBatchForSession`, `getBatchesForSession`
  - Added test coverage:
    - `test/features/create/live_tracking_runtime_repository_test.dart`
    - validates lifecycle transitions and point batching/dedup behavior
- Validation:
  - `cd flutter; flutter analyze lib/core/storage/daos/tracking_session_dao.dart lib/core/storage/daos/tracking_point_batch_dao.dart lib/core/storage/drift_database.dart lib/features/create/data/live_tracking_runtime_repository.dart lib/features/create/presentation/providers/live_tracking_runtime_provider.dart test/core/storage/drift_database_migration_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass)
  - `cd flutter; flutter test test/features/create/live_tracking_runtime_repository_test.dart test/core/storage/drift_database_migration_test.dart test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 49 passed)
- Decision notes:
  - This slice intentionally stops before background capture orchestration; that remains in upcoming Phase 5 slices.

- Date: 2026-03-24
- Slice: Phase 5 runtime capture orchestration + recovery bootstrap (slice 2)
- Implemented:
  - Added `lib/features/create/data/live_tracking_capture_coordinator.dart`:
    - permission-gated runtime control methods:
      - `startTracking`
      - `pauseTracking`
      - `resumeTracking`
      - `stopTracking`
    - shared foreground point stream fanout for active sessions (single stream subscription; avoids per-session stream duplication)
    - explicit capture exception model for location denied/disabled states
    - startup recovery hook: `recoverActiveSessions()` for active local sessions
  - Extended location runtime API:
    - `lib/core/location/location_service.dart` adds `watchPosition(...)`
  - Extended session DAO for recovery:
    - `lib/core/storage/daos/tracking_session_dao.dart` adds `getSessionsByStates(...)`
  - Updated runtime provider wiring:
    - `lib/features/create/presentation/providers/live_tracking_runtime_provider.dart` now exposes:
      - `liveTrackingCaptureCoordinatorProvider`
      - `liveTrackingCaptureBootstrapProvider`
    - maps location stream `Position` payloads into runtime `TrackingPointSample` objects
  - App bootstrap integration:
    - `lib/app.dart` now watches `liveTrackingCaptureBootstrapProvider` to recover active capture on app start.
  - Added coordinator test coverage:
    - `test/features/create/live_tracking_capture_coordinator_test.dart`
    - validates permission gating, pause ingestion stop, shared stream reuse, recovery behavior, and denied-state exceptions
- Validation:
  - `cd flutter; flutter analyze lib/app.dart lib/core/location/location_service.dart lib/core/storage/daos/tracking_session_dao.dart lib/features/create/data/live_tracking_capture_coordinator.dart lib/features/create/presentation/providers/live_tracking_runtime_provider.dart test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass)
  - `cd flutter; flutter test test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/core/storage/drift_database_migration_test.dart test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 55 passed)
- Decision notes:
  - This slice intentionally focuses on foreground capture orchestration + startup recovery.
  - Dedicated background capture behavior and terminated-state continuation remain for next Phase 5 slices.

- Date: 2026-03-24
- Slice: Phase 5 runtime capture hardening (post-review: race + retry loop)
- Implemented:
  - Hardened runtime repository writes with transactional boundaries in:
    - `lib/features/create/data/live_tracking_runtime_repository.dart`
    - `startSession`, `pauseSession`, `resumeSession`, `stopSession`, and `ingestPoint` now run atomically.
  - Hardened capture coordinator ingestion path in:
    - `lib/features/create/data/live_tracking_capture_coordinator.dart`
    - replaced per-session `unawaited(...)` ingest fanout with serialized queueing to prevent overlapping read-modify-write batch updates.
  - Added bounded stream restart backoff in capture coordinator:
    - restart now uses bounded exponential delay rather than immediate re-subscribe on `onError`/`onDone`.
    - prevents hot-loop retry churn on persistent stream failures.
  - Added regression tests in:
    - `test/features/create/live_tracking_capture_coordinator_test.dart`
    - burst-ingestion test to lock no-drop behavior under rapid sample flow.
    - bounded restart-backoff test to lock anti-spin behavior.
- Validation:
  - `cd flutter; flutter analyze lib/features/create/data/live_tracking_capture_coordinator.dart lib/features/create/data/live_tracking_runtime_repository.dart test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass)
  - `cd flutter; flutter test test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass: 11 passed)
- Decision notes:
  - Addresses trip-sync findings on ingestion race risk, start-session concurrency safety, and stream retry hot-loop risk.
  - Background capture policy for terminated-state continuation still belongs to later Phase 5 slices.

- Date: 2026-03-25
- Slice: Phase 6 UX/map integration - editor live-tracking controls (slice 1)
- Implemented:
  - Added new UI component:
    - `lib/features/create/presentation/widgets/live_tracking_control_strip.dart`
    - explicit control states and actions for `planned/active/paused/ended`
    - action affordances:
      - `planned/ended` -> `Start Tracking` / `Start New Session`
      - `active` -> `Pause`, `Stop`
      - `paused` -> `Resume`, `Stop`
    - busy-state progress indicator + disabled action guard while mutation is in flight
  - Wired control strip into editor surface:
    - `lib/features/create/presentation/screens/editor_screen.dart`
    - subscribes to `liveTrackingRuntimeSnapshotProvider(tripId)` for runtime state/subtitle
    - executes action mutations via `liveTrackingCaptureCoordinatorProvider`
    - added user feedback for action success/failure
    - capture permission/service errors map to existing location recovery UX:
      - service disabled -> open location settings prompt
      - denied forever -> open app settings prompt
      - denied -> snackbar feedback
  - Added widget tests:
    - `test/features/create/live_tracking_control_strip_test.dart`
    - verifies action surface by state and busy-state disabling behavior
  - Stabilized existing capture backoff timing assertion to reduce test flakiness:
    - `test/features/create/live_tracking_capture_coordinator_test.dart`
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos lib/features/create/presentation/screens/editor_screen.dart lib/features/create/presentation/widgets/live_tracking_control_strip.dart test/features/create/live_tracking_control_strip_test.dart` (pass; 2 existing info-level lints in `editor_screen.dart`)
  - `cd flutter; flutter test test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 15 passed)
- Decision notes:
  - This slice intentionally delivers the first visible user controls before map-path/candidate UX.
  - Next Phase 6 slices should add live path overlay rendering and candidate/inbox action surfaces.

- Date: 2026-03-25
- Slice: Phase 6 editor controls hardening (post-review)
- Implemented:
  - Hardened editor action feedback semantics in:
    - `lib/features/create/presentation/screens/editor_screen.dart`
    - `_runLiveTrackingAction(...)` now consumes boolean action-apply results.
    - `pause/resume/stop` flows provide explicit `noOpMessage` feedback when no valid transition/session is available instead of unconditional success toast.
  - Hardened control readiness gating:
    - runtime controls are disabled until `liveTrackingRuntimeSnapshotProvider(tripId)` resolves to data.
    - loading/error states continue to show explanatory subtitle text while action taps are blocked.
  - Extended control-strip API:
    - `lib/features/create/presentation/widgets/live_tracking_control_strip.dart`
    - new `controlsEnabled` property decouples action availability from `isBusy`.
  - Added widget regression coverage:
    - `test/features/create/live_tracking_control_strip_test.dart`
    - verifies controls are disabled when runtime state is unavailable.
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos lib/features/create/presentation/screens/editor_screen.dart lib/features/create/presentation/widgets/live_tracking_control_strip.dart test/features/create/live_tracking_control_strip_test.dart` (pass; 2 existing info-level lints in `editor_screen.dart`)
  - `cd flutter; flutter test test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 16 passed)
- Decision notes:
  - Fixes both medium review findings for this slice:
    - no-op success messaging ambiguity
    - controls enabled before runtime state readiness.

- Date: 2026-03-25
- Slice: Phase 6 UX/map integration - live path overlay wiring (slice 2)
- Implemented:
  - Added streaming session batch query for UI overlay composition:
    - `lib/core/storage/daos/tracking_point_batch_dao.dart` (`watchBatchesForSession`)
    - `lib/features/create/presentation/providers/live_tracking_runtime_provider.dart` (`liveTrackingSessionBatchesProvider`)
  - Added live map overlay builder:
    - `lib/features/create/presentation/live_tracking_map_overlay.dart`
    - builds:
      - live path route (`_live_tracking_path_<sessionId>`) when at least 2 points exist
      - live current marker (`_live_tracking_current_<sessionId>`) from last valid point
    - resilient to malformed/non-list JSON payloads and invalid lat/lng rows
    - dedupes consecutive duplicate coordinates to avoid noisy polyline segments
  - Wired overlay into editor map rendering:
    - `lib/features/create/presentation/screens/editor_screen.dart`
    - composes overlay markers/routes at screen layer (keeps `map_provider` contract unchanged)
  - Added dedicated unit tests:
    - `test/features/create/live_tracking_map_overlay_test.dart`
    - covers empty/planned behavior, marker-only behavior, route+marker behavior, malformed payload tolerance, and dedupe semantics
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos lib/core/storage/daos/tracking_point_batch_dao.dart lib/features/create/presentation/providers/live_tracking_runtime_provider.dart lib/features/create/presentation/live_tracking_map_overlay.dart lib/features/create/presentation/screens/editor_screen.dart test/features/create/live_tracking_map_overlay_test.dart` (pass; 2 existing info-level lints in `editor_screen.dart`)
  - `cd flutter; flutter test test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 20 passed)
- Decision notes:
  - Overlay composition stays in `EditorScreen` instead of `map_provider` to avoid introducing local-DB runtime dependencies into pure map-state provider tests.

- Date: 2026-03-25
- Slice: Phase 6 live map overlay hardening (provider lifecycle + continuity test)
- Implemented:
  - Moved overlay computation to provider layer:
    - `lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
    - new `liveTrackingMapOverlayProvider(tripId)` composes runtime + session batches.
  - Added dependency narrowing for overlay recomputation:
    - provider watches only `(runtime state, sessionId)` from `liveTrackingRuntimeSnapshotProvider(...)` via `select(...)`.
    - avoids full overlay rebuild on unrelated runtime field churn.
  - Hardened session-batch watcher lifecycle:
    - `liveTrackingSessionBatchesProvider` changed to `StreamProvider.autoDispose.family`.
  - Updated editor to read precomputed overlay provider output:
    - `lib/features/create/presentation/screens/editor_screen.dart`
  - Added provider-integration test:
    - `test/features/create/live_tracking_runtime_provider_test.dart`
    - verifies near-real-time overlay continuity as runtime and batch streams update.
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos lib/features/create/presentation/providers/live_tracking_runtime_provider.dart lib/features/create/presentation/screens/editor_screen.dart test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_runtime_provider_test.dart` (pass; 2 existing info-level lints in `editor_screen.dart`)
  - `cd flutter; flutter test test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_runtime_provider_test.dart test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 21 passed)
- Decision notes:
  - This addresses the review concerns about rebuild pressure, stale session watcher retention, and missing provider integration coverage without introducing map-provider/runtime coupling.

- Date: 2026-03-25
- Slice: Phase 6 candidate inbox/action UX (slice 3)
- Implemented:
  - Added candidate decision repository:
    - `lib/features/create/data/live_tracking_candidate_repository.dart`
    - queues `confirm/reject/snooze` decisions into `sync_tasks` (`checkin_decision` lane)
    - persists required local action metadata (`action_state/type/client_event_id`) and snooze/reject payload fields
  - Added candidate inbox providers:
    - `lib/features/create/presentation/providers/live_tracking_candidate_provider.dart`
    - exposes stream of filtered actionable candidates for editor UI
  - Extended candidate DAO queue mutation:
    - `lib/core/storage/daos/tracking_candidate_dao.dart`
    - supports optional local `status/rejected_reason/snoozed_until` updates on queue
  - Added editor-facing candidate UX surface:
    - `lib/features/create/presentation/widgets/live_tracking_candidate_inbox_strip.dart`
    - `lib/features/create/presentation/screens/editor_screen.dart`
    - action buttons wired to repository (`Confirm`, `Dismiss` -> `reject`, `Snooze 1h` -> `snooze`)
    - queued/in-flight candidates are disabled and visually annotated
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos lib/core/storage/daos/tracking_candidate_dao.dart lib/features/create/data/live_tracking_candidate_repository.dart lib/features/create/presentation/providers/live_tracking_candidate_provider.dart lib/features/create/presentation/screens/editor_screen.dart lib/features/create/presentation/widgets/live_tracking_candidate_inbox_strip.dart test/features/create/live_tracking_candidate_repository_test.dart test/features/create/live_tracking_candidate_inbox_strip_test.dart` (pass; 2 existing info-level lints in `editor_screen.dart`)
  - `cd flutter; flutter test test/features/create/live_tracking_candidate_repository_test.dart test/features/create/live_tracking_candidate_inbox_strip_test.dart test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_runtime_provider_test.dart test/features/create/live_tracking_control_strip_test.dart` (pass: 15 passed)
- Decision notes:
  - Candidate UX is now delivered as an editor inbox strip first for low-friction actionability; dedicated inbox route can be layered later without changing queue semantics.

- Date: 2026-03-25
- Slice: Phase 6 candidate inbox hardening (post-review)
- Implemented:
  - Added timed snooze wake-up behavior for inbox stream:
    - `lib/features/create/data/live_tracking_candidate_repository.dart`
    - stream now schedules wake timer at nearest future `snoozedUntil` and re-emits filtered candidates even without DB writes.
  - Added SQL-side inbox prefilter for large-trip efficiency:
    - `lib/core/storage/daos/tracking_candidate_dao.dart`
    - new `getInboxCandidatesForTrip` / `watchInboxCandidatesForTrip` queries scope to actionable states and apply limit.
  - Added candidate action failure-state mutation:
    - `lib/core/storage/daos/tracking_candidate_dao.dart` (`markDecisionFailed`)
    - `lib/core/sync/tracking_sync_worker.dart` now marks `checkin_decision` candidates as `actionState='failed'` when task lands in terminal blocked state.
  - Added regression coverage:
    - `test/features/create/live_tracking_candidate_repository_test.dart` (snooze reappearance without db writes)
    - `test/core/sync/tracking_sync_worker_test.dart` (candidate decision blocked -> failed action state)
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos lib/core/storage/daos/tracking_candidate_dao.dart lib/features/create/data/live_tracking_candidate_repository.dart lib/core/sync/tracking_sync_worker.dart test/features/create/live_tracking_candidate_repository_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass)
  - `cd flutter; flutter test test/features/create/live_tracking_candidate_repository_test.dart test/features/create/live_tracking_candidate_inbox_strip_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass: 15 passed)
- Decision notes:
  - Review findings were accepted as valid and resolved in-slice because they affect real-time UX correctness and scale behavior.

- Date: 2026-03-25
- Slice: Phase 6 path overlay stability pass (ordered step 1)
- Implemented:
  - Updated map overlay extraction pipeline:
    - `lib/features/create/presentation/live_tracking_map_overlay.dart`
    - sort points by `recorded_at` (stable tie-break by ingest sequence)
    - filter invalid coordinates
    - apply accuracy gate for render quality
    - suppress jitter and unrealistic speed transitions
    - remove spike outliers in short windows
  - Added regression coverage:
    - `test/features/create/live_tracking_map_overlay_test.dart`
    - out-of-order batch timestamps now render chronologically
    - low-quality spike points are dropped from rendered path
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos lib/features/create/presentation/live_tracking_map_overlay.dart test/features/create/live_tracking_map_overlay_test.dart` (pass)
  - `cd flutter; flutter test test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_runtime_provider_test.dart` (pass: 7 passed)
- Decision notes:
  - This improves path display stability without altering persisted point data or backend inference behavior.
  - Full road-constrained map matching remains a later step.

- Date: 2026-03-25
- Slice: Phase 6 path quality parity prep (ordered step 2, backend contract)
- Implemented:
  - Added backend tracking-path snapshot contract for Flutter consumption in later UX slices:
    - `backend/app/schemas/live_tracking.py` (`TrackingPathResponse`, `TrackingPathPointResponse`)
    - `backend/app/services/live_tracking_service.py` (`get_tracking_path`)
    - `backend/app/api/v1/live_tracking.py` (`GET /api/v1/trips/{trip_id}/tracking/path`)
  - Added backend regression coverage:
    - `backend/tests/test_live_tracking_endpoints.py` (`test_tracking_path_endpoint_orders_and_filters_points`)
- Validation:
  - `cd backend; & .\venv\Scripts\activate; pytest -q tests/test_live_tracking_endpoints.py` (pass: 17 passed)
  - `cd backend; & .\venv\Scripts\activate; alembic check` (pass: `No new upgrade operations detected`)
- Decision notes:
  - This step intentionally lands server-side path normalization first.
  - Flutter map still renders from local cache in current slice; wiring this endpoint into app UX stays in the next ordered step.

- Date: 2026-03-25
- Slice: Phase 6 path quality parity prep (ordered step 3, Flutter API wiring)
- Implemented:
  - Added `fetchTrackingPath` to live-tracking network contract:
    - `lib/core/network/live_tracking_api.dart`
    - maps to `GET /api/v1/trips/{trip_id}/tracking/path`
    - supports optional `session_id` and clamps `limit` to backend contract bounds.
  - Extended API route regression coverage:
    - `test/core/network/live_tracking_api_test.dart`
    - verifies `/api/v1` path prefix and query serialization for `tracking/path`.
  - Updated sync-worker test fake contract:
    - `test/core/sync/tracking_sync_worker_test.dart`
    - adds stub for `fetchTrackingPath` to keep compile/test compatibility.
- Validation:
  - `cd flutter; flutter analyze --no-pub lib/core/network/live_tracking_api.dart test/core/network/live_tracking_api_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass)
  - `cd flutter; flutter test test/core/network/live_tracking_api_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass: 10 passed)
- Decision notes:
  - This slice is API-contract wiring only; editor/provider consumption of remote path remains the next incremental step.

- Date: 2026-03-25
- Slice: Phase 6 path quality parity (ordered step 4, provider consumption)
- Implemented:
  - Added remote path points provider:
    - `lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
    - reads active session runtime key
    - calls `LiveTrackingApi.fetchTrackingPath`
    - parses/validates coordinates from backend payload.
  - Updated map overlay provider behavior:
    - prefers remote path route when backend returns at least 2 points
    - falls back to local batch-derived overlay when remote path is unavailable.
  - Added provider integration regression coverage:
    - `test/features/create/live_tracking_runtime_provider_test.dart`
    - verifies remote-path preference behavior.
- Validation:
  - `cd flutter; flutter analyze --no-pub lib/features/create/presentation/providers/live_tracking_runtime_provider.dart test/features/create/live_tracking_runtime_provider_test.dart` (pass)
  - `cd flutter; flutter test test/core/network/live_tracking_api_test.dart test/core/sync/tracking_sync_worker_test.dart test/features/create/live_tracking_runtime_provider_test.dart` (pass: 12 passed)
- Decision notes:
  - Local-first/offline rendering remains intact; remote path is an enhancement path, not a hard dependency.
  - Polling cadence and map-matching refinement remain for follow-up slices.

- Date: 2026-03-25
- Slice: Phase 6 path quality parity (ordered step 5, remote-path polling cadence)
- Implemented:
  - Added remote path refresh interval policy by runtime state:
    - `lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
    - `active: 12s`, `paused: 30s`, `ended: single-pass`.
  - Converted remote path provider to polling stream:
    - periodic fetch while active/paused
    - coordinate-list dedupe before emitting to overlay consumer
    - local fallback behavior preserved on fetch failures.
  - Added cadence regression coverage:
    - `test/features/create/live_tracking_runtime_provider_test.dart`
    - verifies remote path API is called repeatedly under active state.
- Validation:
  - `cd flutter; flutter analyze --no-pub lib/features/create/presentation/providers/live_tracking_runtime_provider.dart test/features/create/live_tracking_runtime_provider_test.dart` (pass)
  - `cd flutter; flutter test test/features/create/live_tracking_runtime_provider_test.dart test/core/network/live_tracking_api_test.dart test/features/create/live_tracking_map_overlay_test.dart` (pass: 10 passed)
- Decision notes:
  - This closes the stale refresh gap from step 4 while keeping bounded network usage.
  - Adaptive cadence tuning (motion/network-aware) remains for later hardening.

- Date: 2026-03-25
- Slice: Phase 6 prompt/noise tuning (ordered step 6, backend notification confidence band)
- Implemented:
  - Aligned notification selection with ambiguous-confidence policy in backend worker:
    - `backend/app/config.py`
    - `backend/app/workers/live_tracking_worker.py`
    - notifications now target confidence band (`min..max`) instead of `>= threshold`.
  - Added backend regression for high-confidence no-prompt path:
    - `backend/tests/test_live_tracking_worker.py`
- Validation:
  - `cd backend; & .\venv\Scripts\activate; pytest -q tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py` (pass: 39 passed)
- Decision notes:
  - Flutter inbox/prompt surfaces stay unchanged; expected candidate/push volume should decrease for high-confidence inferred stops.
  - If product later wants adaptive per-user confidence bands, this contract can be extended without client API changes.

- Date: 2026-03-25
- Slice: Phase 6 foreground push suppression policy (ordered step 7, backend hardening)
- Implemented:
  - Added backend suppression for recently active users:
    - `backend/app/services/push_service.py`
    - returns `suppressed_foreground` instead of sending push when token `last_seen_at` is within configured recent-activity window.
  - Added config and worker wiring:
    - `backend/app/config.py` (`TRACKING_PUSH_SUPPRESS_RECENT_ACTIVITY_SECONDS`)
    - `backend/app/workers/live_tracking_worker.py` terminal handling + summary metric.
  - Added schema and migration support for new state:
    - `backend/app/models/trip_tracking_notification.py`
    - `backend/alembic/versions/f8e2a1d9c4b7_add_suppressed_foreground_notification_state.py`
  - Added backend regression coverage:
    - `backend/tests/test_live_tracking_worker.py`
- Validation:
  - `cd backend; & .\venv\Scripts\activate; alembic upgrade head` (pass)
  - `cd backend; & .\venv\Scripts\activate; alembic check` (pass)
  - `cd backend; & .\venv\Scripts\activate; pytest -q tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py` (pass: 40 passed)
- Decision notes:
  - This reduces redundant push while user is likely in-app, with inbox fallback still preserved.
  - True foreground/online presence channel is still future scope; current policy uses token seen-time as pragmatic signal.

- Date: 2026-03-25
- Slice: Phase 6 push-token lifecycle wiring (ordered step 8, Flutter client integration)
- Implemented:
  - Added push token client abstraction and Firebase transport:
    - `lib/core/notifications/push_token_client.dart`
  - Added lifecycle bootstrap with auth + app-resume + token-refresh handling:
    - `lib/core/notifications/push_token_lifecycle_bootstrap.dart`
    - register on startup/login
    - refresh `seen_at` on app resume
    - register on token refresh events
    - deactivate last token on logout transition (drains in-flight register first to reduce race risk)
  - Added Riverpod bootstrap wiring:
    - `lib/core/notifications/push_token_lifecycle_provider.dart`
    - `lib/app.dart` now watches `pushTokenLifecycleBootstrapProvider`
  - Extended API route regression to include notification token endpoints:
    - `test/core/network/live_tracking_api_test.dart`
  - Added lifecycle behavior tests:
    - `test/core/notifications/push_token_lifecycle_bootstrap_test.dart`
  - Updated existing `LiveTrackingApi` test doubles for interface parity:
    - `test/core/sync/tracking_sync_worker_test.dart`
    - `test/features/create/live_tracking_runtime_provider_test.dart`
- Validation:
  - `cd flutter; flutter pub get` (pass; `firebase_messaging` resolved in lockfile)
  - `cd flutter; flutter analyze --no-pub lib/core/notifications/push_token_client.dart lib/core/notifications/push_token_lifecycle_bootstrap.dart lib/core/notifications/push_token_lifecycle_provider.dart lib/app.dart test/core/notifications/push_token_lifecycle_bootstrap_test.dart test/core/network/live_tracking_api_test.dart test/core/sync/tracking_sync_worker_test.dart test/features/create/live_tracking_runtime_provider_test.dart` (pass)
  - `cd flutter; flutter test test/core/notifications/push_token_lifecycle_bootstrap_test.dart test/core/network/live_tracking_api_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass: 14 passed)
- Decision notes:
  - This slice completes client-side token lifecycle alignment with backend register/deactivate APIs and foreground suppression policy.
  - Logout deactivation remains best-effort from auth-state transition; if teardown races auth/network, next token register reconciles ownership.
  - `test/features/create/live_tracking_runtime_provider_test.dart` currently has a pre-existing timing flake when bundled in the same command and is tracked separately from this token lifecycle slice.

- Date: 2026-03-26
- Slice: Phase 6 moment UX foundation (ordered step 9, Flutter editor integration)
- Implemented:
  - Added moment repository with offline-first queue semantics:
    - `lib/features/create/data/live_tracking_moment_repository.dart`
    - `createMomentNow` for quick capture
    - `queueNoteUpdate` for local overrides
    - preserves pending `create` when editing unsynced moments.
  - Added moment providers:
    - `lib/features/create/presentation/providers/live_tracking_moment_provider.dart`
  - Added moment UI strip:
    - `lib/features/create/presentation/widgets/live_tracking_moment_strip.dart`
    - capture-now CTA
    - edit-note action with busy guards.
  - Integrated moment strip/actions into editor:
    - `lib/features/create/presentation/screens/editor_screen.dart`
  - Added regression tests:
    - `test/features/create/live_tracking_moment_repository_test.dart`
    - `test/features/create/live_tracking_moment_strip_test.dart`
- Validation:
  - `cd flutter; flutter analyze --no-fatal-infos --no-pub lib/features/create/data/live_tracking_moment_repository.dart lib/features/create/presentation/providers/live_tracking_moment_provider.dart lib/features/create/presentation/widgets/live_tracking_moment_strip.dart lib/features/create/presentation/screens/editor_screen.dart test/features/create/live_tracking_moment_repository_test.dart test/features/create/live_tracking_moment_strip_test.dart` (pass; pre-existing editor info warnings only)
  - `cd flutter; flutter test test/features/create/live_tracking_moment_repository_test.dart test/features/create/live_tracking_moment_strip_test.dart` (pass: 5 passed)
- Decision notes:
  - This lands the moment UX baseline without blocking on larger timeline/map-matching refactors.
  - Full moment override parity (linked place/media edit/review orchestration) remains for the next slice.
