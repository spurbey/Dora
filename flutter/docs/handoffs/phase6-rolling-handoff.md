# Phase 6 Rolling Handoff

Last Updated: 2026-02-27  
Branch: `phase-6-video-export`  
Owner: Codex (handoff for continuation)

## 1. Purpose

Single continuity document for Phase 6 execution across subphases (6A, 6B, 6C, 6D).  
This file records what is already implemented, what is validated, and what remains.

## 2. Source of Truth

- PRD: `flutter/docs/phases/Phase-6-PRD.md`
- Checklist: `flutter/docs/phases/Phase-6-Execution-Checklist.md`
- Contract freeze doc (required by checklist): `flutter/docs/handoffs/phase6-contract-freeze.md` (must exist and be signed before closing 6A)

## 3. Subphase Status

### 6A - Control Plane and Product Wiring

Status: **In Progress**

Completed in this pass (backend-first scaffold):

- Added export job model:
  - `backend/app/models/export_job.py`
- Added export schemas:
  - `backend/app/schemas/export.py`
- Added renderer abstraction and 6A mock renderer:
  - `backend/app/services/export_renderer.py`
- Added export service with:
  - trip ownership checks
  - dedup check (409)
  - precondition hooks (pending media/sync placeholders for 6A)
  - snapshot hash and 500KB size validation
  - cancel semantics (`queued -> canceled`, `processing -> cancel_requested`)
  - download/share response builders
  - file: `backend/app/services/export_service.py`
- Added export API router endpoints:
  - `POST /api/v1/trips/{trip_id}/export`
  - `GET /api/v1/exports/{job_id}`
  - `POST /api/v1/exports/{job_id}/cancel`
  - `GET /api/v1/exports/{job_id}/download-url`
  - `GET /api/v1/exports/{job_id}/share`
  - file: `backend/app/api/v1/exports.py`
- Registered exports router in `backend/app/main.py`.
- Added worker skeleton with:
  - `with_for_update(skip_locked=True)` claim
  - stage progression
  - cancel-request handling
  - retry backoff (30/120/480)
  - restart recovery helper for stale `processing` / `cancel_requested`
  - file: `backend/app/workers/export_worker.py`
- Added Alembic migration:
  - `backend/alembic/versions/b1e4c7d9f2a1_create_export_jobs.py`
  - includes `cancel_requested` in status constraint
  - includes required indexes:
    - `(user_id, status)`
    - `(status, next_attempt_at)`
    - `(trip_id)`
    - `(snapshot_hash)`
- Added tests:
  - `backend/tests/test_export_endpoints.py`
  - `backend/tests/test_export_worker.py`
  - includes stale recovery + cancel race acceptance coverage in worker tests
- Added renderer contract + local orchestration artifacts:
  - `video-renderer/docs/renderer-api-contract.md`
  - `docker-compose.dev.yml`
  - `Procfile.dev`
- Updated model/schema exports:
  - `backend/app/models/__init__.py`
  - `backend/app/schemas/__init__.py`

Pending for 6A completion:

- Apply migration in runtime/test DB and run new tests in a dependency-ready backend environment.
- Add/confirm `phase6-contract-freeze.md` against checklist-required structure.
- Implement Flutter 6A skeleton wiring and pre-submit guard UX.
- Regenerate and version bump `dora_api`.

### 6B - Remotion MVP Renderer

Status: Not Started  
Precondition remains: freeze renderer HTTP contract before implementation.

### 6C - AWS Lambda Scale

Status: Not Started

### 6D - Quality + Hardening

Status: Not Started

## 4. Verification Log

Executed:

- `python -m py_compile backend/app/models/export_job.py backend/app/schemas/export.py backend/app/services/export_renderer.py backend/app/services/export_service.py backend/app/api/v1/exports.py backend/app/workers/export_worker.py backend/tests/test_export_endpoints.py backend/tests/test_export_worker.py backend/alembic/versions/b1e4c7d9f2a1_create_export_jobs.py`
  - Result: pass (syntax-level validation)

Attempted but blocked by local environment dependencies:

- `cd backend; pytest tests/test_export_endpoints.py tests/test_export_worker.py -v`
  - Result: failed before test run (`ModuleNotFoundError: No module named 'sqlalchemy'`)

## 5. Known Gaps / Assumptions

- Backend precondition checks for `pending_media` and `pending_sync` are implemented as 6A hooks returning `False` because backend currently has no durable queue state tables for these checks.
- `download-url` and `share` are functional control-plane responses, but full storage token revocation mechanics remain for 6C.
- Worker restart recovery is implemented via stale-job reset helper; full stale reaper policy hardening remains for later subphases.
- Worker includes cancel race handling in mock path ("cancel_requested" with renderer already `completed` accepts artifact), but this still needs integration validation against real renderer backends in 6B/6C.

## 6. Next Action Plan

1. Finish 6A contract artifacts (`phase6-contract-freeze.md`, renderer API contract doc, local orchestration docs).
2. Run migration + tests in a backend environment with dependencies installed.
3. Implement Flutter 6A wiring and `dora_api` regeneration/version bump.
4. Gate 6B start on frozen renderer contract and clean 6A evidence pack.
