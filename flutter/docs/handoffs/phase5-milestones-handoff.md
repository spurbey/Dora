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
| M1 Schema + DAO Migration | Step 1 | In Progress | 2026-02-20 | Codex | Schema bumped to v7, queue columns and DAO methods added; validation pending |
| M2 Place Identity Binding | Step 2 | In Progress | 2026-02-20 | Codex | `serverPlaceId` path and `ensureRemotePlaceId(...)` added; codegen/validation pending |
| M3 Core Media Pipeline | Step 3 | Not Started | 2026-02-20 | TBD | permissions, compression, thumbnail, repository |
| M4 Queue Worker Reliability | Step 4 | Not Started | 2026-02-20 | TBD | idempotent worker, retry, bootstrap |
| M5 UI + Editor Integration | Step 5 | Not Started | 2026-02-20 | TBD | media screen, providers, editor wiring |
| M6 Hardening + RC | Step 6 | Not Started | 2026-02-20 | TBD | failures, regressions, release decision |

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
