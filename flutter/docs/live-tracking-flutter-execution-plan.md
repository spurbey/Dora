# Live Tracking Flutter Execution Plan (Phases 4-6)

Last updated: 2026-03-23  
Status: Ready for implementation  
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
7. Map UI exists in editor and trip detail surfaces, but no live-tracking overlays/controls yet.
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
