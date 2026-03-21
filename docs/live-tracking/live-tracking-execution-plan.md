# Live Tracking Detailed Execution Plan

Last updated: 2026-03-21  
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
- `flutter/docs/handoffs/2026-03-20-trip-sync-execution-tracker.md`
- `flutter/docs/handoffs/2026-03-20-trip-sync-m0-contract-freeze.md`
- `flutter/docs/handoffs/phase5-sync-remediation-plan.md`
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

## 5. Phase Board

| Phase | Name | Status | Planned Output | Validation Evidence |
|---|---|---|---|---|
| 0 | Contract Freeze | Not Started | Final API/state contracts | Signed request/response + state transitions |
| 1 | Backend Data Model | Not Started | Migrations + ORM updates | Migration tests + constraint checks |
| 2 | Backend APIs/Services | Not Started | Tracking/check-in/moment endpoints | API tests + auth/idempotency checks |
| 3 | Async Processing | Not Started | Workers for scoring/auto-end/moments | Retry/recovery tests + duplicate suppression |
| 4 | Flutter Storage/Sync | Not Started | Drift tables/DAOs + sync task wiring | DAO/queue tests + migration tests |
| 5 | Flutter Runtime | Not Started | Continuous tracking + batching lifecycle | Offline/restart/permission tests |
| 6 | Flutter UX/Map | Not Started | Live controls + candidate/moment UX | Widget/integration flows |
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

Exit criteria:

- Endpoint auth and ownership tests pass.
- Idempotent retries behave correctly.
- Contract generation stable for Flutter client use.

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
4. Enforce dedup uniqueness for per-batch and per-point ingestion identities.

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

## 9. Open Decisions (Must Resolve Early)

1. v1 tracking mode: foreground-only or full background on both platforms.
2. Default location cadence and adaptive throttling thresholds.
3. Auto-end detection thresholds (inactivity + movement).
4. Candidate notification strategy: push-first, in-app-first, or both.
5. Moment generation strictness: conservative vs broad suggestion.
6. Rollout strategy: Android-first, iOS-first, or parity.

## 10. Change Log (Execution Memory)

Use this section after each phase with dated entries:

- Date:
- Phase:
- Implemented:
- Key files:
- API or schema changes:
- Decisions made:
- Risks introduced:
- Next action:

## 11. Test Evidence Log

Use this section after each phase:

- Date:
- Phase:
- Automated tests run:
- Manual checks run:
- Result summary:
- Known failures/waivers:

## 12. Risk Register

Track only active risks:

| Risk | Impact | Likelihood | Mitigation | Status |
|---|---|---|---|---|
| Duplicate point ingestion under retries | High | Medium | idempotency keys + dedup window | Open |
| Session stuck active after app/system interruption | High | Medium | restart reconciliation + auto-end worker | Open |
| Auto-inference overriding manual edits | High | Low | strict precedence + tombstone cooldown | Open |
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
