# Live Tracking Detailed Execution Plan

Last updated: 2026-03-25  
Status: Active execution plan (phase-gated)

## 1. Purpose

This document is the execution memory for implementing live tracking end-to-end.  
It defines a strict sequence:

1. Complete the current phase.
2. Run validation and tests for that phase.
3. Update this document with evidence and decisions.
4. Only then start the next phase.

## 2. Scope

In scope:

- Backend APIs, models, migrations, workers for live tracking.
- Flutter local storage, sync, runtime tracking, and UI integration.
- Check-in candidate flow, moment suggestions, auto-end logic.
- Rollout safety, observability, and rollback plan.

Out of scope for this track:

- Frontend web implementation.
- Non-travelogue product areas not linked to trip creation/editing.

## 3. Source of Truth Inputs

Primary references:

- `docs/live-tracking/live-tracking-prd.md`
- `docs/live-tracking/2026-03-21-live-tracking-phase0-contract-freeze.md`
- `flutter/docs/handoffs/2026-03-20-trip-sync-execution-tracker.md`
- `flutter/docs/handoffs/2026-03-20-trip-sync-m0-contract-freeze.md`
- `flutter/docs/handoffs/phase5-sync-remediation-plan.md`
- `flutter/docs/live-tracking-flutter-execution-plan.md`
- `backend/README.md`
- `flutter/README.md`

Important current baseline:

- M6 compatibility baseline is already merged (`6d5fc98`).
- M7 from execution tracker is pending and should be absorbed into hardening and rollout phases below.

## 4. Execution Rules

1. Manual edits always win over auto inference.
2. Respect tombstones and cooldown windows to avoid resurrecting removed entities.
3. Use idempotency keys for point batch ingestion and confirmation actions.
4. Keep local-first behavior on Flutter, with eventual sync reconciliation.
5. No phase transition without explicit pass/fail evidence.
6. Enforce "one active session per trip per user" with a DB-level invariant (not only service logic).
7. Persist manual-lock and tombstone semantics in schema/service contracts (not inferred only in memory).
8. Treat `workmanager` as supplementary scheduling, not the sole continuous-location runtime.
9. Apply explicit backfill/mapping for legacy trip status values to live-tracking lifecycle states.
10. Use numeric rollout gates for canary progression and rollback decisions.
11. Treat candidate cooldown as mandatory service-level invariant backed by explicit tests.
12. Support manual-only trip completion path (`planned -> completed`) with explicit transition handling/tests.
13. Keep root and Flutter live-tracking docs synchronized: root is phase-gate memory, Flutter doc is low-level execution memory.

## 5. Phase Board

| Phase | Name | Status | Planned Output | Validation Evidence |
|---|---|---|---|---|
| 0 | Contract Freeze | Validated | Final API/state contracts | Accepted Phase 0 contract freeze with state/API/DB/idempotency/decision locks |
| 1 | Backend Data Model | Validated | Migrations + ORM updates | Migration chain reconciled; `alembic check` clean and targeted backend suite green |
| 2 | Backend APIs/Services | Validated | Tracking/check-in/moment endpoints | Phase 2 router/service/schemas shipped; targeted endpoint/service tests + `alembic check` green |
| 3 | Async Processing | Validated | Workers for scoring/auto-end/moments | Worker foundations + push/inbox parity + append-only notification history + backlog control/alerting + targeted stress/retry tests green |
| 4 | Flutter Storage/Sync | Validated | Drift tables/DAOs + sync task wiring | Schema v13 + tracking DAOs/tables + dedicated tracking sync worker path + snapshot hydration/hardening landed; schema `12 -> 13` migration regression added and index-upgrade drift fixed; targeted storage/sync/worker/analyze suites green |
| 5 | Flutter Runtime | In Progress | Continuous tracking + batching lifecycle | Phase 5 slice 1+2 landed: lifecycle repository + batching/dedup + foreground capture coordinator with permission gating and active-session recovery bootstrap; targeted runtime/storage/sync tests green |
| 6 | Flutter UX/Map | In Progress | Live controls + candidate/moment UX | Widget/integration flows |
| 7 | Hardening | Not Started | Metrics, limits, reconciliation | Load/chaos checks + regression suite |
| 8 | Rollout | Not Started | Canary -> staged release | SLO monitoring + rollback drill |

Status values allowed: `Not Started`, `In Progress`, `Blocked`, `Validated`, `Done`.

## 6. Detailed Phase Plan

## Phase 0: Contract Freeze

Objective:

- Lock live-tracking state machine and API contracts before implementation.

Work:

- Define session lifecycle states and transitions.
- Define batch ingest contract with idempotency and dedup behavior.
- Define check-in candidate and confirmation contract.
- Define moment suggestion and override contract.
- Freeze schema-level manual-lock and tombstone representation.
- Freeze DB invariants for session uniqueness and retry idempotency retention.
- Freeze background capture strategy per platform (foreground and background behavior).
- Freeze legacy status backfill/mapping plan.
- Freeze numeric SLO/SLI pass-fail gates for rollout.

Exit criteria:

- Sequence diagrams complete.
- Error model complete (auth, ownership, validation, conflict).
- OpenAPI delta approved.
- DB constraint matrix approved (including partial unique index for active sessions).
- Idempotency wire contract approved with request/response examples.
- Status migration/backfill mapping approved for backend and Flutter.
- Background reliability acceptance criteria approved for both platforms.
- Numeric canary gates approved.

Doc updates required:

- Update this file Phase 0 row to `Validated` or `Done`.
- Add unresolved questions to section 9.

## Phase 1: Backend Data Model

Objective:

- Introduce persistent structures needed for tracking, candidates, and moments.

Work:

- Add/extend models and migrations for:
  - tracking sessions
  - tracking points
  - check-in candidates and resolution state
  - trip moments and provenance
  - trip tracking lifecycle metadata
- Add schema fields for manual locks and tombstones on auto-generated entities.
- Add DB partial unique index to guarantee one active session per trip per user.
- Add idempotency ledger storage keyed by user + endpoint + idempotency key (TTL/retention defined in Phase 0).
- Add indexes for trip/session/time-based retrieval.
- Enforce ownership and FK integrity.

Exit criteria:

- Alembic migration up/down clean.
- Critical read/write queries remain efficient.
- Existing trip/place/route/media behavior unaffected.
- Invariant tests prove duplicate active sessions cannot be created under race conditions.
- Invariant tests prove tombstoned entities cannot be silently regenerated within cooldown.

Doc updates required:

- Record migration IDs and key schema decisions in section 10.
- Attach test evidence in section 11.

## Phase 2: Backend APIs and Services

Objective:

- Deliver server endpoints and business logic for tracking lifecycle and auto suggestions.

Work:

- Add routers and schemas for:
  - start/stop session
  - ingest point batch
  - list/confirm/reject candidates
  - list/override moments
- Enforce idempotency wire format:
  - `X-Idempotency-Key` required on mutating live-tracking endpoints.
  - `client_batch_id` required for `points:batch`.
  - `client_event_id` required for confirm/reject/snooze and create-moment operations.
- Implement idempotency and dedup in services.
- Implement manual-over-auto conflict protection.
- Enforce candidate cooldown checks before candidate recreation and action side effects.
- Implement trip completion transition policy for both tracked and manual-only flows.

Exit criteria:

- Endpoint auth and ownership tests pass.
- Idempotent retries behave correctly.
- Contract generation stable for Flutter client use.
- Candidate cooldown invariant tests pass (no recreation before cooldown expiry).
- Trip completion transition tests pass for both `review_pending -> completed` and `planned -> completed`.

Doc updates required:

- Capture endpoint list and examples in section 10.
- Update risks in section 12.

## Phase 3: Async Processing

Objective:

- Build reliable worker flows for inference and lifecycle automation.

Work:

- Implement worker jobs for:
  - candidate scoring
  - moment generation
  - auto-end detection
  - notification trigger handoff
- Use durable claim/retry/recovery patterns.
- Add stale-claim recovery and duplicate suppression.

Exit criteria:

- Worker retry and recovery tests pass.
- No duplicate candidate/moment side effects under retries.
- Graceful behavior under partial failures.

Doc updates required:

- Record queue names/job types and retry policy.
- Log failure-mode test outcomes.

Phase 3 queue/job and retry snapshot (2026-03-21):

- Job type: `inference_scan` over `trip_tracking_sessions` rows (row-lock claim with `FOR UPDATE SKIP LOCKED`).
- Job type: `candidate_notification_handoff` over pending candidates above confidence threshold.
- Job type: `candidate_notification_dispatch` over handed-off candidates with retry/backoff state in candidate payload.
- Job type: `auto_end_pass` over active/paused sessions using inactivity + trip end-date policies.
- Retry policy: worker loop backoff `5s -> 20s -> 60s` on unhandled cycle failures, then repeat.
- Duplicate suppression: candidate fingerprint checks + cooldown/tombstone checks + moment-by-candidate existence checks + notification handoff marker in candidate payload.

## Phase 4: Flutter Storage and Sync Wiring

Objective:

- Add local schema and integrate with existing sync lanes/queues.

Work:

- Add Drift tables/DAOs for session state, local point batches, candidates, moments.
- Wire sync task creation and claiming for new task types.
- Integrate with existing live-tracking sync primitives.

Exit criteria:

- Drift migrations pass from prior schema versions.
- Queue ordering, dependencies, and retries validated.
- Tombstone/manual lock behavior preserved.

Doc updates required:

- Record schema version bump and migration notes.
- Add DAO and sync test matrix results.

## Phase 5: Flutter Tracking Runtime

Objective:

- Implement capture engine and lifecycle transitions on device.

Work:

- Add continuous location stream orchestration.
- Apply batching, flush, and retry logic.
- Handle app restart and interrupted-session resume.
- Implement dedicated background location capture strategy; use `workmanager` for recovery/flush tasks, not primary sampling.
- Align Android/iOS permission manifests with runtime behavior.

Exit criteria:

- Offline capture then sync works reliably.
- Restart/resume behavior verified.
- Permission-denied flows fail safely with clear UX.
- Background capture reliability meets agreed Phase 0 thresholds on Android and iOS test matrix.

Doc updates required:

- Record cadence/batch defaults and rationale.
- Record platform-specific constraints.

## Phase 6: Flutter UX and Map Integration

Objective:

- Expose live tracking and suggestion workflows in UI.

Work:

- Add start/stop controls and live status indicators.
- Add map polyline and current progress rendering.
- Add candidate confirmation/dismiss flow.
- Add moment review/override flow.

Exit criteria:

- End-to-end create/edit journey remains coherent.
- No regressions in existing trip editor baseline.
- UI behavior matches design tokens/patterns.

Doc updates required:

- Add UX acceptance checklist and outcomes.
- Record known edge behaviors.

Flutter plan synchronization (2026-03-23):

- High-level Flutter gates remain in this root document (Phases 4, 5, 6).
- Low-level implementation details now live in:
  - `flutter/docs/live-tracking-flutter-execution-plan.md`
- Sync keys between docs:
  - `FLT-P4` for Flutter storage/sync wiring
  - `FLT-P5` for runtime capture lifecycle
  - `FLT-P6` for UX/map integration
- Update protocol:
  - Any Flutter live-tracking scope change must update both docs in the same commit.
  - Root doc stores phase status + evidence summary; Flutter doc stores file-level plan + test matrix.
- Contract alignment locks (Flutter, 2026-03-23):
  - Candidate decision wire actions remain `confirm/reject/snooze` (UI copy may display "Dismiss" for `reject`).
  - `planned` is a local pre-start runtime/UI state and not a persisted backend session state.
  - `no_tokens` push outcome is terminal for that candidate push flow (`skipped_no_tokens`) unless policy changes.

## Phase 7: Hardening and Operational Safety

Objective:

- Ensure reliability and debuggability before broad release.

Work:

- Add telemetry and observability for capture, ingest, inference, and sync.
- Add rate limiting/backpressure protections.
- Add reconciliation jobs and drift detection.
- Execute regression and resilience sweeps (M7 intent).

Exit criteria:

- Error budgets and reliability thresholds met.
- Backlog growth remains bounded during stress runs.
- Regression suite clean for critical paths.

Doc updates required:

- Capture SLO/SLI readings and decision to proceed.

## Phase 8: Rollout

Objective:

- Release safely using staged rollout and kill switches.

Work:

- Internal dogfood -> small cohort -> incremental expansion.
- Monitor ingest latency, queue backlog, app stability, battery impact.
- Validate rollback switches and data safety under rollback.

Exit criteria:

- Rollout metrics stable at each stage.
- Rollback drill completed successfully.
- Final signoff recorded.

Doc updates required:

- Record rollout timeline, cohort sizes, and outcomes.

## 7. Required Validation Loop (Per Phase)

This loop is mandatory and sequential:

1. Implement only the scoped phase changes.
2. Run targeted automated tests for that phase.
3. Run manual validation for user-visible or lifecycle behavior.
4. Update this document:
  - phase status
  - what changed
  - tests executed and pass/fail
  - issues found and decisions taken
5. Gate review:
  - if passed, move to next phase
  - if failed, stay in phase and fix

## 8. Testing Matrix

Backend:

- Unit tests for scoring, dedup, and lifecycle transitions.
- API tests for auth/ownership/validation/idempotency.
- Worker reliability tests for retry/stale-claim/recovery.

Flutter:

- Drift migration tests across supported versions.
- DAO/sync queue tests for ordering and dependency behavior.
- Integration tests for offline capture, resume, and sync reconciliation.
- Widget/integration tests for tracking controls and candidate/moment UX.

Cross-layer:

- Contract compatibility tests for generated API client.
- End-to-end tests for start -> ingest -> candidate/moment -> finalize flow.
- Regression checks for existing trip/place/route/media behavior.

## 8.1 Contract Freeze Details (Required Before Phase 1)

Schema invariants:

1. Enforce one active session via DB partial unique index on `trip_tracking_sessions(trip_id, user_id)` where state is active.
2. Persist manual-lock semantics on auto-capable entities (place/route/moment linkage fields).
3. Persist tombstones for deleted auto entities with cooldown metadata to prevent immediate regeneration.
4. Enforce DB dedup uniqueness for per-point identity (`session_id`, `point_id`); enforce per-batch replay safety via idempotency/service logic on `client_batch_id`.

Idempotency wire format:

1. `X-Idempotency-Key` is mandatory for mutating live-tracking endpoints.
2. `POST /trips/{trip_id}/tracking/points:batch` requires `client_batch_id` (UUID) and per-point `point_id` (UUID).
3. Candidate actions (`confirm/reject/snooze`) require `client_event_id` (UUID).
4. Replayed requests must return the original result body and include replay metadata header/field.
5. Retention window for idempotency records is fixed in Phase 0 and validated in worker/service tests.

Status migration mapping:

1. Existing backend trips with no status migrate to `planned`.
2. Flutter/UserTrips legacy `editing` maps to:
   - `tracking_active` when active session exists
   - `tracking_paused` when latest session is paused
   - `planned` otherwise
3. Legacy `completed` remains `completed`.
4. Legacy `shared` remains `shared`.
5. Mapping must be forward/backward compatible for mixed app versions during rollout.

Background runtime contract:

1. Continuous capture must function in foreground and supported background scenarios on both platforms.
2. `workmanager` handles periodic flush/recovery and cannot be the sole sampling engine.
3. Platform permission prompts and fallback UX are part of acceptance criteria.

## 8.2 Numeric Rollout Gates (Initial Targets)

Canary progression requires all of the following:

1. Tracking points ingest API p95 latency under 500 ms.
2. Successful point-batch ingest rate at least 99.0%.
3. Duplicate active session creation incidents equal to 0.
4. Stuck-active sessions after inactivity grace window below 0.5%.
5. Candidate confirmation pipeline success (create -> notify -> action persist) at least 98.0%.
6. Crash-free active-tracking sessions at least 99.5%.
7. Queue backlog drains to steady-state within 15 minutes after network restoration in validation scenarios.
8. Rollback drill completes with no data corruption and no orphan active sessions.

## 9. Resolved Decisions (Locked Baseline)

Resolved on 2026-03-21 in:
`docs/live-tracking/2026-03-21-live-tracking-phase0-contract-freeze.md` (section 12)

1. v1 supports foreground + background tracking where granted, with foreground fallback.
2. Adaptive cadence defaults:
   - 5s fast movement (>= 8 m/s)
   - 10s walking/normal movement (1-8 m/s)
   - 60s stationary (< 1 m/s for >= 120s)
   - flush every 30s or 25 points
3. Auto-end defaults:
   - 6h inactivity threshold
   - meaningful movement baseline >= 250m in rolling 30 minutes
   - 30-minute prompt grace before auto-end commit
4. Candidate strategy:
   - in-app first when foreground
   - push + inbox when background/terminated
5. Moment strategy: conservative default with strict auto-link thresholds.
6. Rollout strategy:
   - internal parity dogfood
   - Android-first external canary
   - iOS expansion after 7-day stable Android canary.

## 10. Change Log (Execution Memory)

Use this section after each phase with dated entries:

- Date: 2026-03-21
- Phase: 0 (Contract Freeze)
- Implemented: Created detailed phase-0 freeze artifact with state machine, API matrix, idempotency wire format, DB invariants, migration/backfill mapping, and rollout gates.
- Key files:
  - `docs/live-tracking/2026-03-21-live-tracking-phase0-contract-freeze.md`
  - `docs/live-tracking/live-tracking-execution-plan.md`
- API or schema changes: Documentation contract only (no runtime code changes yet).
- Decisions made:
  - Mandatory `X-Idempotency-Key` for mutating live-tracking endpoints.
  - DB-level single-active-session invariant via partial unique index.
  - Tombstone table + manual-lock schema contract required before auto inference rollout.
  - `workmanager` treated as recovery/flush support, not primary sampling engine.
  - Product defaults locked (sampling, auto-end, notifications, moments strictness, retention, rollout order).
- Risks introduced:
  - None beyond baseline implementation risks already listed in section 12.
- Next action:
  - Start Phase 1 backend migrations and model updates per locked contract.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Implemented: Added Phase 1 schema migration + new tracking domain models + Trip/Place/Route model extensions for lifecycle/provenance/manual-lock/tombstone compatibility.
- Key files:
  - `backend/alembic/versions/e9b3f0a7c1d2_add_live_tracking_phase1_schema.py`
  - `backend/app/models/trip.py`
  - `backend/app/models/place.py`
  - `backend/app/models/route.py`
  - `backend/app/models/trip_tracking_session.py`
  - `backend/app/models/trip_location_point.py`
  - `backend/app/models/trip_checkin_candidate.py`
  - `backend/app/models/trip_moment.py`
  - `backend/app/models/trip_auto_entity_tombstone.py`
  - `backend/app/models/api_idempotency_record.py`
  - `backend/app/models/__init__.py`
- API or schema changes:
  - Added tracking sessions/points/candidates/moments/tombstones/idempotency tables.
  - Added live-tracking lifecycle columns to `trips`.
  - Added provenance/manual-lock fields to `trip_places` and `routes`.
  - Added DB invariants including partial unique active-session index.
- Decisions made:
  - Implemented contract-locked invariants from Phase 0 as migration-level constraints.
- Risks introduced:
  - `alembic check` reports large pre-existing autogenerate drift across legacy tables/index/comments.
  - `alembic check` drift prevents strict migration-signoff in current repository baseline.
- Next action:
  - Triage `alembic check` drift policy (baseline vs required cleanup) and resolve failing trip endpoint tests before Phase 1 validation signoff.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Implemented: Revalidated Phase 1 after Alembic recovery changes merged; migration baseline is now clean.
- Key files:
  - `backend/alembic/env.py`
  - `backend/alembic/versions/*` (reconciliation revisions through current head)
  - `.github/workflows/backend-ci.yml`
  - `docs/live-tracking/live-tracking-execution-plan.md`
- API or schema changes:
  - No new live-tracking API surface in this entry.
  - Validation baseline moved from drift-failing to drift-clean (`alembic check` pass).
- Decisions made:
  - Phase 1 status moved to `Validated`.
  - Carry cooldown/manual-completion edge cases as explicit Phase 2 service-test gates.
- Risks introduced:
  - None new; primary risk moved from migration drift to Phase 2 service-logic correctness.
- Next action:
  - Start Phase 2 backend APIs/services.
- Date: 2026-03-21
- Phase: 2 (Backend APIs/Services)
- Implemented: Added Phase 2 live-tracking API/router/service stack with idempotent mutation handling and core lifecycle/candidate/moment flows.
- Key files:
  - `backend/app/schemas/live_tracking.py`
  - `backend/app/services/live_tracking_service.py`
  - `backend/app/api/v1/live_tracking.py`
  - `backend/app/main.py`
  - `backend/tests/test_live_tracking_endpoints.py`
- API or schema changes:
  - Added tracking lifecycle endpoints: start/pause/resume/stop + points batch ingestion.
  - Added check-in workflows: pending list + confirm/reject/snooze actions.
  - Added moments workflows: list/create/update.
  - Added manual/auto finalize commit endpoint.
  - Enforced `X-Idempotency-Key` on mutating live-tracking routes with replay headers.
- Decisions made:
  - Idempotency is enforced via `api_idempotency_records` and deterministic payload hashing.
  - Cooldown remains service-enforced invariant with explicit helper and test coverage.
  - Manual completion transition (`planned -> completed`) is handled in Phase 2 finalize flow.
- Risks introduced:
  - Candidate creation pipeline is still async-worker deferred (Phase 3); current APIs operate on pre-existing candidates.
  - Some contract-matrix endpoints remain intentionally deferred outside this phase slice.
- Next action:
  - Continue Phase 2 completion pass (remaining contract endpoints) or move to Phase 3 worker pipelines per release scope.
- Date: 2026-03-21
- Phase: 3 (Async Processing)
- Implemented: Added Phase 3 live-tracking worker foundation for stay inference, candidate scoring, auto moment generation, notification handoff marking, and auto-end lifecycle automation.
- Key files:
  - `backend/app/config.py`
  - `backend/app/workers/live_tracking_worker.py`
  - `backend/tests/test_live_tracking_worker.py`
  - `docs/live-tracking/live-tracking-execution-plan.md`
- API or schema changes:
  - No new API endpoints in this phase slice.
  - Added worker/runtime settings for inference thresholds, notification threshold, auto-end inactivity, and worker poll cadence.
- Decisions made:
  - Worker uses DB row-lock claim (`FOR UPDATE SKIP LOCKED`) on tracking sessions for concurrency-safe scan loops.
  - Candidate pipeline remains retry-safe through fingerprint/cooldown/tombstone checks and DB uniqueness enforcement.
  - Notification stage currently performs durable handoff marking; transport dispatch integration remains decoupled for next slice.
- Risks introduced:
  - Push transport delivery is not wired yet; only handoff markers are persisted.
  - Inference queue is DB-scan based in this phase and may require dedicated queue infrastructure under high volume.
- Next action:
  - Wire notification transport dispatch and production worker process rollout hooks.
- Date: 2026-03-21
- Phase: 2 (Backend APIs/Services)
- Implemented: Hardened Phase 2 idempotency/lifecycle/concurrency behaviors based on review findings.
- Key files:
  - `backend/app/api/v1/live_tracking.py`
  - `backend/app/services/live_tracking_service.py`
  - `backend/tests/test_live_tracking_endpoints.py`
- API or schema changes:
  - No schema changes.
  - Idempotency hash scope now includes concrete path params (`trip_id`/`candidate_id`/`moment_id`) to prevent cross-resource replay with same key/body.
  - `start_tracking` transition gate tightened to allow new starts only from `planned` trip status (contract-aligned).
  - Constraint-aware `IntegrityError` mapping added for deterministic `409` behavior on known business uniqueness races.
- Decisions made:
  - Keep template endpoint signatures but make payload hash resource-scoped via path-param inclusion.
  - Preserve idempotent active-session replay while enforcing lifecycle transition contract for new starts.
  - Treat known business constraint races as conflict responses, not generic server failures.
- Risks introduced:
  - None new; this change reduces Phase 2 correctness risk and narrows replay/race ambiguity.
- Next action:
  - Continue Phase 3 notification transport integration and queue hardening.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Implemented: Fixed Alembic runtime reliability issue where migrations appeared to run but did not persist, and hardened backend settings parsing for shared monorepo env variables.
- Key files:
  - `backend/alembic/env.py`
  - `backend/app/config.py`
  - `docs/live-tracking/live-tracking-execution-plan.md`
- API or schema changes:
  - No live-tracking API contract changes in this entry.
  - Alembic migration boundary now commits pre-migration implicit transaction opened by `SHOW/SET search_path`, so `upgrade head` persists revision and schema updates.
  - Backend `DEBUG` now accepts profile-style string values (`release`/`profile`/`debug`) to prevent settings boot crashes during CLI/test tooling.
- Decisions made:
  - Keep the search_path guard but explicitly reset transaction boundary before Alembic begins migration transaction handling.
  - Normalize `DEBUG` parsing at config layer instead of requiring per-command env overrides.
- Risks introduced:
  - None new; this reduces migration tooling instability risk.
- Next action:
  - Keep migration validation in standard loop (`upgrade head` + `check`) without ad-hoc env patching.
- Date: 2026-03-21
- Phase: 3 (Async Processing)
- Implemented: Added push notification transport slice with Firebase-backed dispatch, per-user device token persistence, token lifecycle APIs, and worker retry/backoff state transitions.
- Key files:
  - `backend/alembic/versions/c2d4f6a8b0e1_add_user_device_tokens_for_push.py`
  - `backend/app/models/user_device_token.py`
  - `backend/app/models/__init__.py`
  - `backend/app/services/push_service.py`
  - `backend/app/services/live_tracking_service.py`
  - `backend/app/schemas/live_tracking.py`
  - `backend/app/api/v1/live_tracking.py`
  - `backend/app/workers/live_tracking_worker.py`
  - `backend/tests/test_live_tracking_endpoints.py`
  - `backend/tests/test_live_tracking_worker.py`
  - `backend/requirements.txt`
- API or schema changes:
  - Added `user_device_tokens` table with ownership FK, platform/failure constraints, and active-token lookup indexes.
  - Added `POST /api/v1/notifications/device-tokens/register` and `POST /api/v1/notifications/device-tokens/deactivate` (idempotent mutation contract).
  - Worker now executes `candidate_notification_dispatch` with persisted attempt counters, backoff schedule, status markers, and error/sent timestamps in candidate payload.
- Decisions made:
  - Push transport remains optional and environment-driven (`FIREBASE_PUSH_ENABLED` + credentials), with deterministic fallback statuses when unavailable.
  - Invalid token responses deactivate token rows; retryable transport failures use configurable backoff and max-attempt limits.
  - Notification dispatch state is persisted on candidates for crash-safe resume and retry determinism.
- Risks introduced:
  - Inbox fallback delivery path is still separate from this transport slice.
  - Firebase credential/runtime misconfiguration degrades to retryable/terminal dispatch statuses until corrected.
- Next action:
  - Add inbox parity + operational alerting for retry saturation, then continue queue-scaling hardening.
- Date: 2026-03-22
- Phase: 3 (Async Processing)
- Implemented: Hardened worker scalability and failure-isolation paths based on Phase 3 review findings.
- Key files:
  - `backend/app/models/trip_tracking_session.py`
  - `backend/alembic/versions/b7c2e1d4f9a3_add_inference_progress_to_tracking_sessions.py`
  - `backend/app/workers/live_tracking_worker.py`
  - `backend/tests/test_live_tracking_worker.py`
  - `docs/live-tracking/live-tracking-execution-plan.md`
- API or schema changes:
  - Added `trip_tracking_sessions.inference_cursor_at` and `trip_tracking_sessions.inference_updated_at` for incremental inference progress tracking.
  - Added `idx_tracking_sessions_inference_progress` index for claim/query efficiency.
  - Session claim now skips fully processed sessions and prioritizes fresh work.
  - Notification handoff now filters eligible candidates in SQL before `LIMIT` to avoid backlog starvation.
  - Worker cycle now isolates per-session and per-phase failures using nested transaction boundaries.
- Decisions made:
  - Kept ended sessions eligible only when unprocessed data exists (`last_point_at > inference_cursor_at`) so final trailing points can still be inferred.
  - Added overlap-window incremental rescans at cursor boundaries to preserve stay detection continuity.
  - Flush handoff payload updates before dispatch query to guarantee same-cycle visibility.
- Risks introduced:
  - Inference cursor strategy adds statefulness to sessions and requires migration compatibility checks in future schema refactors.
- Next action:
  - Continue with inbox fallback parity and queue/throughput hardening under production-like data volume.
- Date: 2026-03-22
- Phase: 3 (Async Processing)
- Implemented: Closed late-arriving-point correctness gap so out-of-order/same-timestamp points are not skipped by inference gating.
- Key files:
  - `backend/alembic/versions/d4e9c2a1b7f0_add_uninferred_marker_to_tracking_sessions.py`
  - `backend/app/models/trip_tracking_session.py`
  - `backend/app/services/live_tracking_service.py`
  - `backend/app/workers/live_tracking_worker.py`
  - `backend/tests/test_live_tracking_worker.py`
  - `backend/tests/test_live_tracking_endpoints.py`
  - `docs/live-tracking/live-tracking-execution-plan.md`
- API or schema changes:
  - Added `trip_tracking_sessions.oldest_uninferred_point_at` marker + `idx_tracking_sessions_uninferred_marker`.
  - Ingest now records earliest accepted point timestamp in `oldest_uninferred_point_at`, even when `last_point_at` does not advance.
  - Inference claim query now includes sessions with uninferred marker regardless of `last_point_at > inference_cursor_at`.
  - Inference scan start now considers marker timestamp (plus overlap window), then clears marker on successful pass.
- Decisions made:
  - Use explicit marker state instead of relying on monotonic `recorded_at` ordering from clients.
  - Preserve scale behavior by keeping cursor gating and only widening scan window when marker indicates late data.
- Risks introduced:
  - Marker maintenance correctness is now part of ingest/inference contract and must remain covered by regression tests.
- Next action:
  - Continue Phase 3 hardening with inbox fallback parity and throughput tuning.

## 11. Test Evidence Log

Use this section after each phase:

- Date: 2026-03-21
- Phase: 0 (Contract Freeze)
- Automated tests run:
  - Not applicable (documentation phase).
- Manual checks run:
  - Cross-checked PRD requirements vs Phase 0 contract artifact.
  - Cross-checked execution plan rules vs Phase 0 contract sections (idempotency, uniqueness, tombstones, status mapping, rollout gates).
- Result summary:
  - Phase 0 contract is validated and internally consistent with PRD + execution plan.
- Known failures/waivers:
  - None for Phase 0 documentation gate.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Automated tests run:
  - `python -m py_compile` on modified/new model files and migration file (pass).
  - `alembic check` (blocked: `alembic` CLI not available in current environment).
  - `pytest -q tests/test_trip_endpoints.py` (blocked: `sqlalchemy` missing in current environment).
- Manual checks run:
  - Reviewed migration constraints/indexes against Phase 0 contract freeze requirements.
  - Reviewed ORM model changes for alignment with migration schema.
- Result summary:
  - Static validation passes; runtime DB/test validation blocked by missing dependencies.
- Known failures/waivers:
  - Environment waiver required until backend dependency stack is available.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic upgrade head` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic current` -> `e9b3f0a7c1d2 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic check` (fail: `New upgrade operations detected`, broad pre-existing metadata drift)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_trip_endpoints.py` (fail: 2 failed, 29 passed)
- Manual checks run:
  - Verified migration applied to DB head revision.
  - Reviewed failing pytest cases to confirm failures are in existing trip endpoint expectations, not migration syntax/runtime crash.
- Result summary:
  - Phase 1 schema migration is executable and applied; signoff remains blocked on repository `alembic check` drift policy and failing trip endpoint test baseline.
- Known failures/waivers:
  - `test_create_trip_free_tier_limit` expected `403`, observed `201`.
  - `test_list_trips_public_only_returns_global_public` includes extra titles from current test DB state.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_trip_endpoints.py` (pass: 31 passed)
- Manual checks run:
  - Verified free-tier guard invocation in `TripService.create_trip`.
  - Hardened public-only test expectation to remain valid in non-empty shared DB while preserving behavior checks.
- Result summary:
  - Targeted trip endpoint suite is green after fixes.
  - Remaining blocker for strict Phase 1 signoff is `alembic check` repository drift baseline.
- Known failures/waivers:
  - `alembic check` still reports broad pre-existing drift unrelated to only this phase's new schema.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic heads` -> `f3a7b8c9d0e1 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic current` -> `f3a7b8c9d0e1 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic upgrade head` (pass; no-op at head)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic check` (pass: `No new upgrade operations detected.`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_trip_endpoints.py` (pass: 31 passed)
- Manual checks run:
  - Verified previous Phase 1 blocker is cleared and migration baseline is stable for Phase 2 work.
- Result summary:
  - Phase 1 blocker is closed; phase moved to `Validated`.
- Known failures/waivers:
  - Non-blocking deprecation warnings (Pydantic/FastAPI) remain in test output.
- Date: 2026-03-21
- Phase: 2 (Backend APIs/Services)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m py_compile app/schemas/live_tracking.py app/services/live_tracking_service.py app/api/v1/live_tracking.py tests/test_live_tracking_endpoints.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_live_tracking_endpoints.py` (pass: 8 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_trip_endpoints.py` (pass: 31 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic check` (pass: `No new upgrade operations detected.`)
- Manual checks run:
  - Verified idempotency replay header behavior and conflict semantics via endpoint tests.
  - Verified manual completion path and cooldown enforcement behavior in Phase 2 flows.
- Result summary:
  - Phase 2 foundation endpoints/services are implemented and validated with targeted suite coverage.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-21
- Phase: 3 (Async Processing)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m py_compile app/config.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_live_tracking_worker.py` (pass: 6 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_live_tracking_endpoints.py` (pass: 8 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/config.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic check` (pass: `No new upgrade operations detected.`)
- Manual checks run:
  - Verified inference retry safety by rerunning identical session inference and confirming no duplicate candidate/moment insertion.
  - Verified cooldown and tombstone suppression behavior blocks candidate recreation.
  - Verified auto-end pass updates `trip_tracking_sessions.state`, `trips.status`, and `trips.auto_end_reason` as expected.
- Result summary:
  - Phase 3 worker foundation is implemented and validated for scoring/moment/auto-end/handoff core flows.
  - Notification transport integration and higher-volume queue hardening remain for next iteration.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-21
- Phase: 2 (Backend APIs/Services)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m py_compile app/api/v1/live_tracking.py app/services/live_tracking_service.py tests/test_live_tracking_endpoints.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/api/v1/live_tracking.py app/services/live_tracking_service.py tests/test_live_tracking_endpoints.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_live_tracking_endpoints.py` (pass: 11 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m pytest -q tests/test_live_tracking_worker.py` (pass: 6 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; $env:DEBUG='false'; python -m alembic check` (pass: `No new upgrade operations detected.`)
- Manual checks run:
  - Verified idempotency behavior no longer replays across different resource IDs with same key/body.
  - Verified `start_tracking` rejects non-`planned` statuses for new starts.
  - Verified known business uniqueness races are mapped to deterministic conflict responses.
- Result summary:
  - Phase 2 hardening findings are addressed and regression-covered.
  - Endpoint suite increased from 8 to 11 passing tests with added safety checks.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-21
- Phase: 1 (Backend Data Model)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `f3a7b8c9d0e1` before fix (observed non-persisting upgrade symptom)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic upgrade head` (pass after `env.py` transaction-boundary fix)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `c2d4f6a8b0e1 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
- Manual checks run:
  - Verified `alembic_version` now advances to head and `user_device_tokens` schema is persisted post-upgrade.
  - Verified backend config bootstrap no longer crashes when shell exports `DEBUG=release`.
- Result summary:
  - Root Alembic reliability blocker resolved; migration chain is now deterministic under standard backend venv commands.
- Known failures/waivers:
  - `alembic check` still emits non-blocking comment-diff info logs, but these are stripped from generated ops and do not fail check.
- Date: 2026-03-21
- Phase: 3 (Async Processing)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m py_compile app/config.py alembic/env.py app/models/user_device_token.py app/services/push_service.py app/services/live_tracking_service.py app/api/v1/live_tracking.py app/schemas/live_tracking.py app/workers/live_tracking_worker.py tests/test_live_tracking_endpoints.py tests/test_live_tracking_worker.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/config.py alembic/env.py app/models/user_device_token.py app/services/push_service.py app/services/live_tracking_service.py app/api/v1/live_tracking.py app/schemas/live_tracking.py app/workers/live_tracking_worker.py tests/test_live_tracking_endpoints.py tests/test_live_tracking_worker.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_endpoints.py` (pass: 12 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_worker.py` (pass: 8 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic heads` -> `c2d4f6a8b0e1 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `c2d4f6a8b0e1 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
- Manual checks run:
  - Verified device token register/deactivate endpoints are idempotent and token ownership-scoped.
  - Verified worker dispatch updates notification status/attempt/backoff/sent metadata on candidates deterministically.
  - Verified optional Firebase transport fallback returns non-crashing status paths when not configured.
- Result summary:
  - Phase 3 notification transport slice is integrated and regression-covered.
  - Remaining hardening scope is inbox parity and scale/ops tuning.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-22
- Phase: 3 (Async Processing)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m py_compile app/models/trip_tracking_session.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py alembic/versions/b7c2e1d4f9a3_add_inference_progress_to_tracking_sessions.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/models/trip_tracking_session.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py alembic/versions/b7c2e1d4f9a3_add_inference_progress_to_tracking_sessions.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic upgrade head` (pass; upgraded `c2d4f6a8b0e1 -> b7c2e1d4f9a3`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic heads` -> `b7c2e1d4f9a3 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `b7c2e1d4f9a3 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_worker.py` (pass: 12 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_endpoints.py` (pass: 12 passed)
- Manual checks run:
  - Verified claim query only pulls sessions with unprocessed points and deprioritizes ended sessions.
  - Verified handoff/dispatch no longer stalls when older already-handed-off rows dominate pending backlog.
  - Verified a single session-level inference exception is isolated and does not abort all worker progress for the cycle.
- Result summary:
  - All three review findings are addressed with code + regression coverage.
  - Worker behavior is now safer for backlog growth and poison-record scenarios.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-22
- Phase: 3 (Async Processing)
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m py_compile app/models/trip_tracking_session.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py alembic/versions/d4e9c2a1b7f0_add_uninferred_marker_to_tracking_sessions.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/models/trip_tracking_session.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py alembic/versions/d4e9c2a1b7f0_add_uninferred_marker_to_tracking_sessions.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic upgrade head` (pass; upgraded `b7c2e1d4f9a3 -> d4e9c2a1b7f0`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic heads` -> `d4e9c2a1b7f0 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `d4e9c2a1b7f0 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_worker.py` (pass: 14 passed)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_endpoints.py` (pass: 13 passed)
- Manual checks run:
  - Verified late/out-of-order point ingestion sets session marker even when `last_point_at` remains unchanged.
  - Verified claim set includes sessions with marker so worker revisits them.
  - Verified inference clears marker after successful reprocessing.
- Result summary:
  - Late-arriving-point data-loss path is closed without regressing starvation protections from previous hardening.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-22
- Phase: 3 (Async Processing) + Push Notification Hardening
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m py_compile app/models/user_device_token.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_endpoints.py tests/test_live_tracking_worker.py alembic/versions/f1c5a9e2d4b6_harden_user_device_token_ownership.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/models/user_device_token.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_endpoints.py tests/test_live_tracking_worker.py alembic/versions/f1c5a9e2d4b6_harden_user_device_token_ownership.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic upgrade head` (pass; upgraded `d4e9c2a1b7f0 -> f1c5a9e2d4b6`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic heads` -> `f1c5a9e2d4b6 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `f1c5a9e2d4b6 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_endpoints.py tests/test_live_tracking_worker.py` (pass: 30 passed)
- Manual checks run:
  - Verified device token registration now enforces single-owner semantics globally by `push_token`, including account-switch reassignment.
  - Verified worker handoff/dispatch queries now claim rows with `FOR UPDATE SKIP LOCKED` to reduce duplicate concurrent sends.
  - Verified dispatch eligibility (`notification_next_attempt_at`) is filtered in SQL before `LIMIT`, so not-due backlog rows do not starve ready candidates.
  - Verified idempotency integrity mapping includes token uniqueness constraints for deterministic conflict behavior under race paths.
- Result summary:
  - Closed remaining production blockers from push notification review: cross-account token leakage risk, duplicate-send concurrency gap, dispatch starvation path, and token registration race ambiguity.
  - Existing session-level worker fault isolation remains intact from prior hardening.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-22
- Phase: 3 (Async Processing) + Inbox Fallback Parity
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m py_compile app/models/trip_tracking_notification.py app/models/__init__.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_endpoints.py tests/test_live_tracking_worker.py alembic/versions/a7d9c4e1f2b3_add_trip_tracking_notifications_table.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/models/trip_tracking_notification.py app/models/__init__.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_endpoints.py tests/test_live_tracking_worker.py alembic/versions/a7d9c4e1f2b3_add_trip_tracking_notifications_table.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic upgrade head` (pass; upgraded `f1c5a9e2d4b6 -> a7d9c4e1f2b3`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic heads` -> `a7d9c4e1f2b3 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `a7d9c4e1f2b3 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py` (pass: 32 passed)
- Manual checks run:
  - Added `trip_tracking_notifications` table (`inbox|push` channels) as durable audit/log + inbox parity state store per candidate.
  - Worker handoff now upserts inbox rows (`pending`) so candidates always have in-app inbox representation independent of push transport success.
  - Worker dispatch now upserts push channel status (`sent`, `retryable_failure`, `transport_unavailable`, `no_tokens`, `terminal_failure`) with attempts/errors.
  - Candidate actions (`confirm|reject|snooze`) now mark inbox channel notifications as `acted` with acknowledgment timestamp.
  - Worker cycle summary now exposes `notifications_terminal_failures`, `notifications_skipped_no_tokens`, and `notifications_transport_unavailable` for operational visibility.
- Result summary:
  - Backend parity for contract rule `push + inbox entry` is implemented with deterministic state transitions and regression coverage.
  - Canonical actionable queue remains `/checkins/pending`; notification table provides delivery/audit state and fallback guarantees.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-22
- Phase: 3 (Async Processing) + Notification History & Policy Lock
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m py_compile app/models/trip_tracking_notification_event.py app/models/__init__.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py alembic/versions/b3f1d8c7e2a4_add_trip_tracking_notification_events_table.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/models/trip_tracking_notification_event.py app/models/__init__.py app/services/live_tracking_service.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py alembic/versions/b3f1d8c7e2a4_add_trip_tracking_notification_events_table.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic upgrade head` (pass; upgraded `a7d9c4e1f2b3 -> b3f1d8c7e2a4`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic heads` -> `b3f1d8c7e2a4 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic current` -> `b3f1d8c7e2a4 (head)` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py` (pass: 34 passed)
- Manual checks run:
  - Added append-only `trip_tracking_notification_events` table so per-attempt/per-transition timeline is durable and queryable.
  - Worker now emits transition events on notification state changes (`handoff`, `dispatch`) for both inbox and push channels.
  - Candidate actions emit `action` notification events while marking inbox snapshot rows as `acted`.
  - Locked current product behavior for `no_tokens`: candidate push state is terminal (`skipped_no_tokens`) for that candidate unless future product policy introduces explicit requeue semantics.
- Result summary:
  - Previous design ambiguity is removed: snapshot table remains current-state view, and events table is immutable history.
  - `no_tokens` behavior is now explicitly tested and documented to avoid future implementation divergence.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-22
- Phase: 3 (Async Processing) Closeout - Ops Hardening + Exit Validation
- Automated tests run:
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m py_compile app/config.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m ruff check app/config.py app/workers/live_tracking_worker.py tests/test_live_tracking_worker.py` (pass)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic upgrade head` (pass; no-op at `b3f1d8c7e2a4`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; python -m alembic check` (pass: `No new upgrade operations detected.`)
  - `cd backend; . .\venv\Scripts\Activate.ps1; pytest -q tests/test_live_tracking_worker.py tests/test_live_tracking_endpoints.py` (pass: 37 passed)
- Manual checks run:
  - Added adaptive worker batch sizing for inference/handoff/dispatch using live backlog counts and bounded multipliers.
  - Added operational alert thresholds and warning hooks for:
    - retryable backlog saturation
    - dispatch lag (oldest due age)
    - stuck active sessions
    - inference backlog saturation
  - Added worker summary fields for backlog/limit/lag/stuck-session visibility to support monitoring and canary decisions.
  - Executed backlog/retry behavior tests validating:
    - bounded adaptive scaling under backlog
    - alert emission on threshold breach
    - retry/no-token policy behavior remains deterministic.
- Result summary:
  - Phase 3 closeout items are complete:
    - inbox fallback parity
    - queue/backlog control + alerting hooks
    - exit validation under retry/backlog scenarios
  - Phase 3 status moved to `Validated`.
- Known failures/waivers:
  - Non-blocking framework deprecation warnings remain in shared backend stack.
- Date: 2026-03-23
- Phase: 4 (Flutter Storage/Sync) foundation slice
- Automated tests run:
  - `cd flutter; dart run build_runner build --delete-conflicting-outputs` (pass)
  - `cd flutter; flutter analyze --no-pub lib/core/storage lib/core/sync test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart` (no errors; info-level lint hints remain)
  - `cd flutter; flutter test test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart` (pass)
- Manual checks run:
  - Added local Drift schema for tracking sessions, point batches, candidates, and moments (schema version `13`).
  - Added DAO coverage for session lifecycle, point batch claiming/retry/recovery, candidate decision queue state, and moment pending-write state.
  - Added secondary indexes for high-volume tracking query patterns (trip/state/order + claim/retry paths).
  - Hardened point-batch recovery so cleared/stale `in_progress` rows become runnable again.
  - Marked session lifecycle updates as `syncStatus='pending'` to prevent missed transitions.
  - Scoped `EntitySyncWorker` claims to `trip/place/route` only; in this foundation slice, tracking task types were intentionally left queued (not blocked as unsupported) pending dedicated tracking worker wiring.
- Result summary:
  - Phase 4 has started with storage/sync foundation and regression tests in place.
  - Next slice is to wire tracking task execution paths (session, point batch, decisions, moments) end-to-end.
- Known failures/waivers:
  - Analyzer still reports pre-existing info-level lint hints in older storage/test files; no new analyzer errors in this slice.

- Date: 2026-03-23
- Phase: 4 (Flutter Storage/Sync) tracking worker slice
- Automated tests run:
  - `cd flutter; flutter analyze lib/core/sync/tracking_sync_worker.dart lib/core/network/live_tracking_api.dart lib/core/sync/tracking_sync_bootstrap.dart lib/features/create/presentation/providers/tracking_sync_provider.dart lib/core/network/api_providers.dart lib/core/storage/daos/tracking_moment_dao.dart lib/app.dart test/core/sync/tracking_sync_worker_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart test/core/sync/entity_sync_worker_test.dart test/core/storage/sync_task_dao_test.dart test/core/storage/live_tracking_storage_dao_test.dart` (pass: 33 passed)
- Manual checks run:
  - Added `LiveTrackingApi` transport wrapper for session lifecycle, point batch upload, check-in decisions, and moment create/update endpoints with idempotency header support.
  - Added dedicated `TrackingSyncWorker` lane that only claims tracking entity types and executes:
    - session `start/pause/resume/stop`
    - point batch upload with remote-session dependency blocking
    - check-in `confirm/reject/snooze`
    - moment `create/update`
  - Added tracking bootstrap/provider wiring so worker heartbeat starts with app lifecycle (`app.dart` + provider bootstrap).
  - Added moment ID reconciliation helper (`replaceMomentId`) so local temporary IDs can be replaced by server IDs after create.
  - Added worker-focused tests for successful processing, dependency-block behavior, entity-type lane isolation, and decision sync transitions.
  - Updated worker UUID namespace generation to non-deprecated `Namespace.url.value`.
- Result summary:
  - Tracking tasks are now processed intentionally by a dedicated worker path, not merely queued.
  - `EntitySyncWorker` remains scoped to `trip/place/route`, preventing cross-lane contention and unsupported-entity churn.
  - Phase 4 now has both schema foundation and executable tracking sync path in place; remaining work is closeout validation and transition to Phase 5 runtime capture.
- Known failures/waivers:
  - None in this slice.

- Date: 2026-03-23
- Phase: 4 (Flutter Storage/Sync) hardening slice
- Automated tests run:
  - `cd flutter; flutter analyze lib/core/network/live_tracking_api.dart lib/core/storage/daos/sync_task_dao.dart lib/core/sync/tracking_sync_worker.dart test/core/network/live_tracking_api_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass: 5 passed)
  - `cd flutter; flutter test test/core/network/live_tracking_api_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart` (pass: 27 passed)
- Manual checks run:
  - Updated live-tracking Dio routes to use `/api/v1` prefix parity with existing direct Dio repositories and backend router mounting.
  - Refactored `TrackingSyncWorker` success handling to transactional `shouldMarkEntitySynced` semantics so local rows are not marked `synced` when `pending_requeue=1`.
  - Added deferred-task handling via `markPending` (instead of terminal `blocked`) with `nextAttemptAt` delay to avoid both dead-end blocking and tight retry loops.
  - Added task entity-id remap support for moment create responses (`replaceTaskEntityId`) to keep requeued tasks consistent after local ID -> server ID replacement.
- Result summary:
  - The two high-severity review findings are resolved:
    - `/api/v1` routing mismatch
    - requeue-safe local sync-state consistency
  - Deferred point-batch flow is now retryable and dependency-aware without worker starvation loops.
- Known failures/waivers:
  - None in this slice.

- Date: 2026-03-23
- Phase: 4 (Flutter Storage/Sync) follow-up guardrail
- Automated tests run:
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass: 5 passed)
- Manual checks run:
  - Added explicit regression assertion that deferred point-batch tasks set `next_attempt_at` (cooldown) when written as `pending`.
- Result summary:
  - Deferred-task anti-churn backoff is now locked by test coverage (not only implementation intent).
- Known failures/waivers:
  - None in this slice.

- Date: 2026-03-23
- Phase: 4 (Flutter Storage/Sync) snapshot hydration slice
- Automated tests run:
  - `cd flutter; flutter analyze lib/core/sync/tracking_sync_worker.dart test/core/sync/tracking_sync_worker_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass: 7 passed)
  - `cd flutter; flutter test test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 27 passed)
- Manual checks run:
  - Expanded `TrackingSyncWorker` to hydrate richer server snapshots into local cache rows after successful sync:
    - sessions: timezone/device-context/client-session + lifecycle timestamps
    - candidates: confidence/suggestion/status/cooldown/payload + server timestamps
    - moments: source/confidence/location/note/media/extra/locked-fields + timestamps
  - Preserved requeue safety:
    - when `pending_requeue=1`, local rows remain `syncStatus='pending'` while avoiding stale completion semantics.
  - Added snapshot-focused worker tests for session/candidate/moment hydration.
- Result summary:
  - Local tracking cache is now materially closer to backend canonical state after sync, improving offline UX parity.
  - Phase 4 closeout now has schema, worker execution, hardening, and snapshot hydration in place.
- Known failures/waivers:
  - None in this slice.

- Date: 2026-03-23
- Phase: 4 (Flutter Storage/Sync) snapshot hydration hardening follow-up
- Automated tests run:
  - `cd flutter; flutter analyze lib/core/sync/tracking_sync_worker.dart test/core/sync/tracking_sync_worker_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/core/sync/tracking_sync_worker_test.dart` (pass: 8 passed)
- Manual checks run:
  - Accepted trip-sync review finding on stale session fallback semantics.
  - Session hydration now uses current DB row values as fallback for omitted server fields (`client_session_id`, `timezone`, `device_context`, `state`) to avoid mid-flight stale overwrite.
  - Session `serverUpdatedAt` now prefers server snapshot `updated_at` when present, with worker-time fallback.
  - Removed unused `fallbackRow` parameter from candidate hydration to reduce maintenance ambiguity.
  - Added regression test covering mid-flight session edits during pause sync to lock stale-overwrite prevention.
- Result summary:
  - Snapshot hydration semantics are now safer under concurrency and partial server payloads.
  - Phase 4 closeout evidence includes post-review hardening for this slice.
- Known failures/waivers:
  - None in this slice.

- Date: 2026-03-23
- Phase: 4 (Flutter Storage/Sync) closeout validation and migration hardening
- Automated tests run:
  - `cd flutter; flutter analyze lib/core/storage/drift_database.dart lib/core/sync/tracking_sync_worker.dart test/core/storage/drift_database_migration_test.dart test/core/sync/tracking_sync_worker_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/core/storage/drift_database_migration_test.dart test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 49 passed)
- Manual checks run:
  - Added explicit migration regression test for schema `12 -> 13`:
    - validates tracking tables are created on upgrade
    - validates all tracking secondary indexes exist after upgrade
    - validates pre-upgrade non-tracking data remains intact
  - Fixed upgrade-path index gap by explicitly creating tracking indexes inside `from < 13` migration branch.
- Result summary:
  - Phase 4 exit criteria are now fully evidenced (schema migration + DAO/sync validation + worker execution path + hardening + snapshot hydration).
  - Phase 4 status moved to `Validated`; execution moved to Phase 5 runtime.
- Known failures/waivers:
  - Repo-wide `flutter analyze --no-pub` still includes pre-existing info-level lint hints outside live-tracking scope.

- Date: 2026-03-23
- Phase: 5 (Flutter Runtime) slice 1 foundation
- Automated tests run:
  - `cd flutter; flutter analyze lib/core/storage/daos/tracking_session_dao.dart lib/core/storage/daos/tracking_point_batch_dao.dart lib/core/storage/drift_database.dart lib/features/create/data/live_tracking_runtime_repository.dart lib/features/create/presentation/providers/live_tracking_runtime_provider.dart test/core/storage/drift_database_migration_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/features/create/live_tracking_runtime_repository_test.dart test/core/storage/drift_database_migration_test.dart test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 49 passed)
- Manual checks run:
  - Added runtime lifecycle repository with explicit local state machine (`planned/active/paused/ended`) and operations:
    - `startSession`, `pauseSession`, `resumeSession`, `stopSession`
  - Added runtime batching ingest path:
    - point dedup guard (cadence + distance threshold)
    - queued batch append/split by policy (`maxPointsPerBatch`, `maxBatchWindow`)
    - deterministic sync-task enqueue with dependency on tracking session
  - Added local runtime providers for future UI/runtime integration:
    - repository provider
    - runtime snapshot stream provider
  - Added DAO utilities needed by runtime:
    - latest session lookups/watch
    - `markLastPointAt`
    - latest mutable batch lookup + session batch listing
- Result summary:
  - Phase 5 runtime work has started with deterministic local lifecycle and point-batching foundation, while preserving Phase 4 storage/sync guarantees.
- Known failures/waivers:
  - Background continuous capture runtime (foreground stream + background worker orchestration) is still pending in later Phase 5 slices.

- Date: 2026-03-24
- Phase: 5 (Flutter Runtime) slice 2 capture orchestration + recovery bootstrap
- Automated tests run:
  - `cd flutter; flutter analyze lib/app.dart lib/core/location/location_service.dart lib/core/storage/daos/tracking_session_dao.dart lib/features/create/data/live_tracking_capture_coordinator.dart lib/features/create/presentation/providers/live_tracking_runtime_provider.dart test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/core/storage/drift_database_migration_test.dart test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/live_tracking_sync_primitives_test.dart test/core/sync/entity_sync_worker_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/network/live_tracking_api_test.dart` (pass: 55 passed)
- Manual checks run:
  - Added foreground capture coordinator:
    - permission-gated `startTracking/pauseTracking/resumeTracking/stopTracking`
    - shared point-stream fanout to active sessions (single stream subscription, multi-session support)
    - explicit error contract for denied/disabled location states
  - Added startup recovery path:
    - app bootstrap now triggers `recoverActiveSessions()`
    - active local sessions reattach to capture stream without forcing permission prompt on app launch
  - Extended location service:
    - added `watchPosition(...)` stream API for continuous capture runtime
  - Extended runtime session DAO support:
    - added `getSessionsByStates(...)` for active-session recovery query
  - Added dedicated coordinator tests:
    - permission gating behavior
    - pause stops ingestion
    - shared stream behavior across multiple active sessions
    - recovery bootstrap behavior
- Result summary:
  - Phase 5 now has both deterministic local lifecycle/batching (slice 1) and foreground capture orchestration with recovery bootstrap (slice 2).
- Known failures/waivers:
  - Background capture runtime specifics (platform background modes, restart reconciliation under terminated state, and cadence throttling policy) remain for next Phase 5 slices.

- Date: 2026-03-24
- Phase: 5 (Flutter Runtime) slice 2 hardening follow-up (capture race + restart backoff)
- Automated tests run:
  - `cd flutter; flutter analyze lib/features/create/data/live_tracking_capture_coordinator.dart lib/features/create/data/live_tracking_runtime_repository.dart test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass: no issues)
  - `cd flutter; flutter test test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart` (pass: 11 passed)
- Manual checks run:
  - Hardened runtime repository mutations with DB transactions:
    - `startSession`, `pauseSession`, `resumeSession`, `stopSession`, and `ingestPoint` now execute atomically to reduce race windows for idempotent session creation and point batching.
  - Hardened capture coordinator ingestion path:
    - replaced per-session `unawaited(...)` fanout with serialized ingestion queue to avoid overlapping read-modify-write batch updates.
  - Added bounded resubscribe backoff:
    - capture stream failures now schedule restart with bounded exponential delay instead of immediate hot-loop retry.
  - Added regression coverage:
    - burst sample ingestion test to lock no-drop behavior under rapid point events.
    - restart backoff timing test to lock anti-spin behavior after repeated stream failures.
- Result summary:
  - Addressed the trip-sync review risks for capture ingestion races, start-session concurrency safety, and retry hot-loop risk.
  - Phase 5 slice 2 is now hardened for higher-load foreground capture behavior.
- Known failures/waivers:
  - Full background capture/terminated-state runtime policy is still pending later Phase 5 slices.

- Date: 2026-03-25
- Phase: 6 (Flutter UX/Map) slice 1 editor control surface
- Automated tests run:
  - `cd flutter; flutter analyze --no-fatal-infos lib/features/create/presentation/screens/editor_screen.dart lib/features/create/presentation/widgets/live_tracking_control_strip.dart test/features/create/live_tracking_control_strip_test.dart` (pass; existing info-level lint reminders in `editor_screen.dart` remain)
  - `cd flutter; flutter test test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 15 passed)
- Manual checks run:
  - Added visible live-tracking control strip to editor UI:
    - file: `flutter/lib/features/create/presentation/widgets/live_tracking_control_strip.dart`
    - explicit state/action surface for `planned/active/paused/ended`
    - actions: `Start`, `Pause`, `Resume`, `Stop`
  - Wired control strip into `EditorScreen`:
    - file: `flutter/lib/features/create/presentation/screens/editor_screen.dart`
    - reads runtime state from `liveTrackingRuntimeSnapshotProvider`
    - executes control actions through `liveTrackingCaptureCoordinatorProvider`
    - shows action progress + success feedback
    - maps capture permission/service errors to existing location recovery UX dialogs/snackbars
  - Added widget coverage for control-state rendering and busy-state disabling:
    - file: `flutter/test/features/create/live_tracking_control_strip_test.dart`
- Result summary:
  - First user-visible Phase 6 slice is in place: editor now exposes live-tracking controls and current runtime status.
  - UX integration remains incremental; map polyline overlays and candidate/inbox interaction surfaces are next Phase 6 slices.
- Known failures/waivers:
  - Existing non-blocking `editor_screen.dart` info-level lints (`WillPopScope` deprecation and async-context advisory) remain outside this live-tracking slice scope.

- Date: 2026-03-25
- Phase: 6 (Flutter UX/Map) slice 2 hardening follow-up (overlay provider lifecycle + integration coverage)
- Automated tests run:
  - `cd flutter; flutter analyze --no-fatal-infos lib/features/create/presentation/providers/live_tracking_runtime_provider.dart lib/features/create/presentation/screens/editor_screen.dart test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_runtime_provider_test.dart` (pass; existing info-level lint reminders in `editor_screen.dart` remain)
  - `cd flutter; flutter test test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_runtime_provider_test.dart test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 21 passed)
- Manual checks run:
  - Accepted review finding that overlay decoding work should not run on every `EditorScreen` rebuild.
  - Moved overlay computation into provider layer:
    - `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
    - added `liveTrackingMapOverlayProvider(tripId)` with `select(...)` dependency narrowing to `(state, sessionId)` so unrelated runtime field updates do not force overlay rebuild.
  - Hardened session batch watcher lifecycle:
    - changed `liveTrackingSessionBatchesProvider` to `autoDispose` family to avoid stale session stream watchers accumulating in long-lived containers.
  - Updated editor rendering path to consume precomputed overlay provider output:
    - `flutter/lib/features/create/presentation/screens/editor_screen.dart`
  - Added provider-integration test for near-real-time continuity under stream updates:
    - `flutter/test/features/create/live_tracking_runtime_provider_test.dart`
- Result summary:
  - Overlay rebuild pressure is now decoupled from generic screen rebuilds and narrowed to relevant provider dependency changes.
  - Session batch stream lifecycle is scoped to active listeners, reducing stale watcher retention risk.
  - Integration-level provider continuity is now covered in tests alongside pure overlay builder tests.
- Known failures/waivers:
  - Existing non-blocking `editor_screen.dart` info-level lints (`WillPopScope` deprecation and async-context advisory) remain outside this live-tracking slice scope.

- Date: 2026-03-25
- Phase: 6 (Flutter UX/Map) slice 1 hardening follow-up (control readiness + no-op feedback)
- Automated tests run:
  - `cd flutter; flutter analyze --no-fatal-infos lib/features/create/presentation/screens/editor_screen.dart lib/features/create/presentation/widgets/live_tracking_control_strip.dart test/features/create/live_tracking_control_strip_test.dart` (pass; existing info-level lint reminders in `editor_screen.dart` remain)
  - `cd flutter; flutter test test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 16 passed)
- Manual checks run:
  - Addressed no-op success feedback ambiguity in editor tracking actions:
    - `pause/resume/stop` handlers now return whether a state mutation was actually applied.
    - success snackbar is shown only when applied; otherwise a no-op message is shown.
    - file: `flutter/lib/features/create/presentation/screens/editor_screen.dart`
  - Addressed premature control enablement while runtime state is unresolved:
    - live-tracking control strip is disabled unless runtime snapshot is loaded.
    - loading/error subtitle remains visible, but actions are not tappable.
    - files:
      - `flutter/lib/features/create/presentation/screens/editor_screen.dart`
      - `flutter/lib/features/create/presentation/widgets/live_tracking_control_strip.dart`
  - Added widget regression for unavailable-runtime disabled controls:
    - file: `flutter/test/features/create/live_tracking_control_strip_test.dart`
- Result summary:
  - Phase 6 control surface now avoids misleading no-op success messaging and blocks actions until runtime state is known.
  - This closes the medium-severity UX correctness findings from review for the current slice.
- Known failures/waivers:
  - Existing non-blocking `editor_screen.dart` info-level lints (`WillPopScope` deprecation and async-context advisory) remain outside this live-tracking slice scope.

- Date: 2026-03-25
- Phase: 6 (Flutter UX/Map) slice 2 live map overlay wiring
- Automated tests run:
  - `cd flutter; flutter analyze --no-fatal-infos lib/core/storage/daos/tracking_point_batch_dao.dart lib/features/create/presentation/providers/live_tracking_runtime_provider.dart lib/features/create/presentation/live_tracking_map_overlay.dart lib/features/create/presentation/screens/editor_screen.dart test/features/create/live_tracking_map_overlay_test.dart` (pass; existing info-level lint reminders in `editor_screen.dart` remain)
  - `cd flutter; flutter test test/features/create/live_tracking_map_overlay_test.dart test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/features/create/live_tracking_capture_coordinator_test.dart` (pass: 20 passed)
- Manual checks run:
  - Added streaming DAO/provider path for session point batches:
    - `flutter/lib/core/storage/daos/tracking_point_batch_dao.dart`
    - `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
  - Added map overlay builder for live path + current marker, with malformed payload tolerance and consecutive-point dedupe:
    - `flutter/lib/features/create/presentation/live_tracking_map_overlay.dart`
  - Wired overlay rendering into editor map while keeping map provider state untouched:
    - `flutter/lib/features/create/presentation/screens/editor_screen.dart`
    - live route/marker overlays are composed in UI from runtime snapshot + session batches
  - Added focused overlay unit tests:
    - `flutter/test/features/create/live_tracking_map_overlay_test.dart`
- Result summary:
  - Phase 6 now includes both control surface and live path/current-location map rendering on editor.
  - Overlay integration avoids cross-provider DB coupling in map-provider tests by composing at the screen layer.
- Known failures/waivers:
  - Existing non-blocking `editor_screen.dart` info-level lints (`WillPopScope` deprecation and async-context advisory) remain outside this live-tracking slice scope.

## 12. Risk Register

Track only active risks:

| Risk | Impact | Likelihood | Mitigation | Status |
|---|---|---|---|---|
| Duplicate point ingestion under retries | High | Medium | idempotency keys + dedup window | Open |
| Session stuck active after app/system interruption | High | Medium | restart reconciliation + auto-end worker | In Progress |
| Auto-inference overriding manual edits | High | Low | strict precedence + tombstone cooldown | Open |
| Notification delivery gaps when push transport is unavailable or tokens are inactive | Medium | Medium | dispatch retries + token lifecycle APIs + `trip_tracking_notifications` inbox fallback + notification event history + planned alerting | In Progress |
| Queue backlog growth during weak network | Medium | Medium | adaptive batching + backpressure + observability | Open |

## 13. Implementation Workflow and Codegen Discipline

Use this exact workflow for each phase. Do not skip generation or targeted validation.

General coding rules:

1. Source-of-truth precedence: code/tests first, then latest 2026 handoff/ops docs.
2. Never hand-edit generated outputs (`*.g.dart`, Drift generated parts, `flutter/packages/dora_api/**` generated files).
3. Generated artifacts must be deterministic and committed with the phase change when contracts/schema changed.

Backend change workflow:

1. Implement schema/model/API/service/worker changes.
2. Create Alembic migration with forward + rollback notes.
3. Run migration checks:
   - `cd backend && alembic upgrade head`
   - `cd backend && alembic check`
4. Run targeted backend tests, then broader suite when phase scope is complete:
   - `cd backend && pytest -v`

Flutter generation workflow (`.g.dart` / Drift / Freezed / Riverpod / json):

1. After Flutter schema/domain/provider changes:
   - `cd flutter && flutter pub get`
   - `cd flutter && dart run build_runner build --delete-conflicting-outputs`
2. Run analyzer and targeted tests for touched areas:
   - `cd flutter && flutter analyze --no-pub`
   - `cd flutter && flutter test`

OpenAPI client workflow (`packages/dora_api`):

1. After backend OpenAPI contract changes:
   - `curl http://localhost:8000/openapi.json -o flutter/openapi.json`
   - `cd flutter && npx @openapitools/openapi-generator-cli generate -c openapi-generator-config.yaml`
   - `cd flutter && flutter pub get`
   - `cd flutter && dart run build_runner build --delete-conflicting-outputs`
2. If generated API changed, bump `flutter/packages/dora_api/pubspec.yaml` version.
3. Validate Flutter compile/tests against regenerated client before phase signoff.

Phase gate enforcement:

1. No transition to next phase until:
   - implementation complete for current phase
   - required generation complete
   - required tests pass
   - sections 10 and 11 updated with evidence
