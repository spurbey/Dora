# Phase 5 Milestones Handoff (Running Memory)

## Purpose
Single running handoff document for Phase 5 so milestone context is preserved across sessions/agents.

## Source References
- `flutter/docs/phases/Phase-5-PRD.md`
- `flutter/docs/phases/Phase-5-Execution-Checklist.md`

## Update Rules
1. Update this file at the end of every milestone (Step 0 to Step 6).
2. Keep entries factual: what changed, what was validated, what is blocked.
3. Always include file paths and test evidence.
4. Never delete prior milestone history; append updates.
5. If there is a blocker, mark milestone `Blocked` and include owner + next action.

---

## Milestone Status Board

| Milestone | Checklist Step | Status | Last Updated | Owner | Notes |
|---|---|---|---|---|---|
| M0 Contract Freeze | Step 0 | Done | 2026-02-20 | Codex | Contract freeze captured in `phase5-step0-contract-freeze.md` |
| M1 Schema + DAO Migration | Step 1 | In Progress | 2026-02-21 | Codex | v7 migration + queue columns live; migration/runtime validation still pending on device |
| M2 Place Identity Binding | Step 2 | In Progress | 2026-02-21 | Codex | `serverPlaceId` flow wired; runtime validation pending |
| M3 Core Media Pipeline | Step 3 | In Progress | 2026-02-21 | Codex | enqueue/copy/compress/thumbnail/uploader wired; Android gallery permission flow softened |
| M4 Queue Worker Reliability | Step 4 | In Progress | 2026-02-21 | Codex | claim/session guards + retry gates added; cleanup and failure handling improved |
| M5 UI + Editor Integration | Step 5 | In Progress | 2026-02-21 | Codex | media screen + place preview integration wired; UX polish + full validation pending |
| M6 Hardening + RC | Step 6 | Not Started | 2026-02-21 | TBD | full failure matrix/regression pack pending |

Legend: `Not Started` | `In Progress` | `Blocked` | `Done`

---

## M0 Contract Freeze (Step 0)

### Scope
- Lock API usage and upload state machine.
- Lock place identity strategy and migration target.
- Confirm Phase 4 baseline contract for regression.

### Decisions
- Status: Complete
- API Contract: Upload via generated OpenAPI `MediaApi.uploadMediaApiV1MediaUploadPost(...)` only.
- Upload State Machine: `queued -> compressing -> uploading -> uploaded | failed | canceled`.
- Place Identity Strategy: Add `serverPlaceId` and call `ensureRemotePlaceId(localPlaceId)` before upload.
- Phase 4 Baseline Contract: Phase 4C route/editor behavior is locked as regression baseline.

### Files Changed
- `flutter/docs/phases/Phase-5-PRD.md`
- `flutter/docs/phases/Phase-5-Execution-Checklist.md`
- `flutter/docs/handoffs/phase5-step0-contract-freeze.md`

### Validation Evidence
- Commands: Documentation-level verification only.
- Manual checks: Cross-checked checklist vs PRD for migration/version/place identity consistency.
- Notes: This milestone intentionally contains no runtime code changes.

### Blockers / Risks
- Drift/freezed codegen will be required in subsequent schema/model milestones.
- Backend place/media identity mismatch remains a known risk until Step 2 implementation.

### Handoff to Next Milestone (M1)
- Ready to start M1 when: Schema/DAO migration changes are scoped to `v6 -> v7` only.
- Owner: Codex

---

## M1 Schema + DAO Migration (Step 1)

### Scope
- Add queue metadata schema and migration.
- Extend DAO for queue reads/writes/claims.

### Implementation Summary
- Status: In Progress
- Migration: `schemaVersion` updated to `7` with `from >= 6 && from < 7` migration block.
- Backfill behavior:
  - `url` present -> `upload_status='uploaded'`, `upload_progress=1.0`, `uploaded_at` fallback to `created_at`
  - no `url` -> `upload_status='queued'`, `upload_progress=0.0`
- DAO updates:
  - queue fetch/watch methods
  - failed/pending query helpers
  - claim + state + release helpers for worker-safe flow

### Files Changed
- `flutter/lib/core/storage/tables/media_table.dart`
- `flutter/lib/core/storage/tables/places_table.dart`
- `flutter/lib/core/storage/drift_database.dart`
- `flutter/lib/core/storage/daos/media_dao.dart`

### Validation Evidence
- Commands: Pending (requires local `dart` command execution by user/CI).
- Migration checks: Pending.
- Notes: Build/codegen sync required before runtime validation.

### Blockers / Risks
- Drift generated files are not yet regenerated for new schema fields.
- Runtime validation blocked until local Dart tooling runs format/build_runner/tests.

### Handoff to Next Milestone (M2)
- Ready to start M2 when: place identity mapping implementation begins in create place flow.
- Owner: Codex

---

## M2 Place Identity Binding (Step 2)

### Scope
- Ensure media upload always uses backend place UUID.
- Add `serverPlaceId` flow and idempotent mapping.

### Implementation Summary
- Status: In Progress
- `serverPlaceId` storage/model mapping:
  - Added to `Places` table.
  - Added to `Place` domain model.
  - Added to repository row-model mapping and companion writes.
- `ensureRemotePlaceId(...)` behavior:
  - checks existing `serverPlaceId`
  - serializes remote creation request via `PlacesApi.createPlaceApiV1PlacesPost`
  - persists returned backend ID
  - protects duplicate in-flight requests with per-local-id in-memory future map

### Files Changed
- `flutter/lib/features/create/domain/place.dart`
- `flutter/lib/features/create/data/place_repository.dart`
- `flutter/lib/features/create/presentation/providers/editor_provider.dart`

### Validation Evidence
- Commands: Pending (requires local `dart` command execution by user/CI).
- Identity mapping scenarios: Pending execution (unsynced local place, existing mapped place, missing auth token).
- Notes: Requires generated files sync after `Place` model change.

### Blockers / Risks
- Codegen is required because `Place` freezed/json classes are now stale after model changes.
- Backend place create path assumptions must be validated with real token and trip ownership.

### Handoff to Next Milestone (M3)
- Ready to start M3 when: schema/model codegen and Step 1/2 validations pass.
- Owner: Codex

---

## M3 Core Media Pipeline (Step 3)

### Scope
- Implement permissions, compression, thumbnails, uploader adapter, repository.

### Implementation Summary
- Status: Pending
- Services:
- Repository contract:
- Enqueue-first behavior:

### Files Changed
- 

### Validation Evidence
- Commands:
- Unit/provider checks:
- Notes:

### Blockers / Risks
- 

### Handoff to Next Milestone (M4)
- Ready to start M4 when:
- Owner:

---

## M4 Queue Worker Reliability (Step 4)

### Scope
- Build idempotent queue worker with retry/backoff and lifecycle bootstrap.

### Implementation Summary
- Status: Pending
- Claim/lock semantics:
- Retry policy:
- Bootstrap wiring:

### Files Changed
- 

### Validation Evidence
- Commands:
- Restart/connectivity scenarios:
- Notes:

### Blockers / Risks
- 

### Handoff to Next Milestone (M5)
- Ready to start M5 when:
- Owner:

---

## M5 UI + Editor Integration (Step 5)

### Scope
- Add media upload screen/widgets/providers and editor integration points.

### Implementation Summary
- Status: Pending
- Navigation wiring:
- Screen 9 contract coverage:
- Editor integration updates:

### Files Changed
- 

### Validation Evidence
- Commands:
- UI/manual scenarios:
- Notes:

### Blockers / Risks
- 

### Handoff to Next Milestone (M6)
- Ready to start M6 when:
- Owner:

---

## M6 Hardening + Release Candidate (Step 6)

### Scope
- Run failure-path hardening + Phase 4 regression pack.
- Produce release candidate go/no-go.

### Implementation Summary
- Status: Pending
- Failure-path coverage:
- Regression coverage:
- RC decision:

### Files Changed
- 

### Validation Evidence
- Commands:
- Test summary:
- Notes:

### Blockers / Risks
- 

### Phase Closure
- Final checklist status:
- Residual risks:
- Next phase handoff target:

---

## Session Update 2026-02-21

### What was completed in this session
- Queue reliability hardening:
  - Worker now re-checks row/session before finalize and before failure persistence.
  - Canceled/removed rows are protected from stale in-flight finalization.
  - Pending counter excludes `failed` items; only `queued|compressing|uploading` are counted.
  - Failed rows now reset progress to `0.0` to avoid "stuck at 10%" perception.
- File lifecycle hardening:
  - Selected media is copied to app-managed upload path before enqueue to avoid cache-path disappearance.
- Editor/place integration hardening:
  - Place update/save now preserves system-managed fields (`serverPlaceId`, `photoUrls`) to avoid autosave clobber.
  - Place detail panel now renders media rows with local-first previews and status badges.
- Error clarity:
  - `ensureRemotePlaceId(...)` now maps backend place-create failures to concise user-facing reasons.
  - `404 Trip not found` now surfaces explicit "trip not available on backend" guidance.
- Android permission flow:
  - Gallery selection on Android now uses non-blocking flow (photo picker path) to avoid permission-handler manifest mismatch loops.

### Current blocker
- Blocker: Backend trip identity mapping is incomplete for local-only trips.
- Evidence: Upload flow fails during remote place creation with backend `404 Trip not found`.
- Impact: Media upload succeeds only when the editor trip already exists on backend under the signed-in account.
- Owner: Codex + Product decision.
- Next action:
  - Option A (future): Introduce `serverTripId` mapping (`v7 -> v8`) and resolve remote trip ID before `ensureRemotePlaceId`.
  - Option B: Keep current behavior and explicitly gate media upload to backend-backed trips only (no local-only upload).

### Files touched this session
- `flutter/lib/core/media/upload_queue_worker.dart`
- `flutter/lib/core/storage/daos/media_dao.dart`
- `flutter/lib/features/create/data/media_repository.dart`
- `flutter/lib/features/create/data/place_repository.dart`
- `flutter/lib/features/create/presentation/screens/editor_screen.dart`
- `flutter/lib/features/create/presentation/widgets/place_detail_form.dart`
- `flutter/lib/core/media/media_permissions.dart`

### Validation status
- Dart/Flutter command validation: Pending (intentionally not run by agent per workspace constraint).
- Device manual validation: pending latest patch verification for:
  - backend-backed trip upload success path
  - `Trip not found` failure clarity path
  - no retry flood/no log loop on non-retryable errors

---

## Session Update 2026-02-21 (Trip Identity Mapping)

### What was completed in this session
- Added persistent backend trip mapping for media/place dependency chain:
  - `Trips.serverTripId` column introduced.
  - Drift migration advanced to `schemaVersion = 8` with `from < 8` trip mapping migration.
  - Trip domain/repository now support `serverTripId`.
- Implemented `TripRepository.ensureRemoteTripId(localTripId)`:
  - Uses cached `serverTripId` when available.
  - Probes for legacy same-id remote trips before creating new backend trip.
  - Creates backend trip lazily via `TripsApi.createTripApiV1TripsPost(...)` when needed.
  - Persists resolved `serverTripId` locally.
- Updated place identity binding:
  - `PlaceRepository.ensureRemotePlaceId(...)` now resolves backend trip id first.
  - Remote place creation now uses backend `trip_id` (never local-only trip id).
  - Added one-time stale trip-id self-heal path:
    - on `404 Trip not found`, clear cached `serverTripId`, re-resolve, retry once.
- Provider wiring updated:
  - `TripRepository` now injected with `TripsApi`.
  - `PlaceRepository` now receives `TripRepository` in both editor and media providers.
- Retry semantics improved for offline-first behavior:
  - transient trip/place identity failures rethrow `DioException` so queue retry/backoff still applies.
  - non-retryable auth/permission/contract failures remain explicit and terminal.

### Blocker status
- Previous blocker (`Trip not found` for local-only trips) is addressed in code path.
- Remaining work is runtime verification on device/CI after codegen/migration run.

### Files touched this session
- `flutter/lib/core/storage/tables/trips_table.dart`
- `flutter/lib/core/storage/drift_database.dart`
- `flutter/lib/features/create/domain/trip.dart`
- `flutter/lib/features/create/data/trip_repository.dart`
- `flutter/lib/features/create/data/place_repository.dart`
- `flutter/lib/features/create/presentation/providers/editor_provider.dart`
- `flutter/lib/features/create/presentation/providers/media_upload_provider.dart`

### Validation status
- Agent-run validation: not executed (`flutter`/`dart` commands intentionally skipped by constraint).
- Required local validation after this patch:
  - regenerate codegen artifacts (drift/freezed/riverpod where needed),
  - run migration path from v7 to v8 on device,
  - verify upload success on local-only trip and backend-backed trip.
