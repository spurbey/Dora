# Phase 6 Rolling Handoff

Last Updated: 2026-03-01
Branch: `phase-6-video-export`
Owner: Codex

## 1. Purpose

Continuity log across Phase 6 subphases (6A, 6B, 6C, 6D). Keep this file updated after each subphase milestone so follow-up agents can resume without re-discovery.

## 2. Source of Truth

- PRD: `flutter/docs/phases/Phase-6-PRD.md`
- Checklist: `flutter/docs/phases/Phase-6-Execution-Checklist.md`
- 6A contract freeze: `flutter/docs/handoffs/phase6-contract-freeze.md`
- Renderer contract: `video-renderer/docs/renderer-api-contract.md`

## 3. Subphase Status

### 6A - Control Plane and Product Wiring

Status: Completed

Delivered backend scope:
- Export DB/model/schema/service/router/worker stack.
- Endpoints:
  - `POST /api/v1/trips/{trip_id}/export`
  - `GET /api/v1/exports/{job_id}`
  - `POST /api/v1/exports/{job_id}/cancel`
  - `GET /api/v1/exports/{job_id}/download-url`
  - `GET /api/v1/exports/{job_id}/share`
- Worker behaviors:
  - atomic claim via `.with_for_update(skip_locked=True)`
  - six-stage progression scaffold
  - cancel_requested semantics and cancel race handling
  - retry/backoff + stale processing recovery
- Migration and tests:
  - `backend/alembic/versions/b1e4c7d9f2a1_create_export_jobs.py`
  - `backend/tests/test_export_endpoints.py`
  - `backend/tests/test_export_worker.py`

Delivered Flutter scope:
- Export module at `flutter/lib/features/export/**`.
- Wiring from Trips + Editor to Export Studio.
- Pre-submit guard evaluation + submit-time revalidation.
- 409/422 nested error envelope parsing hardening.
- Route delete dependency fix for sync-blocking precheck.
- Route-level feature-flag guard in router.
- Tests:
  - `flutter/test/features/export/export_repository_precheck_test.dart`
  - `flutter/test/features/export/export_provider_test.dart`
  - `flutter/test/features/export/export_studio_screen_test.dart`
  - `flutter/test/features/create/route_repository_dependency_test.dart`

6A carry-forward items:
- Regenerate `dora_api` for export endpoints and bump package version.

### 6B - Remotion MVP Renderer

Status: In progress (6B-1 complete — real Remotion wired)

Delivered in current pass (pass 1 — scaffold):
- `video-renderer/` service scaffold with frozen renderer endpoints:
  - `POST /api/v1/render`
  - `GET /api/v1/render/{render_id}`
  - `DELETE /api/v1/render/{render_id}`
- Contract enforcement:
  - `X-Renderer-Version: 1` header validation (`400 version_mismatch` if invalid)
  - manifest enum and structure validation (`422 validation_error`)
  - output path constrained to `RENDER_OUTPUT_DIR`
- Runtime artifacts:
  - `video-renderer/package.json`
  - `video-renderer/src/server.js`
  - `video-renderer/Dockerfile`
  - `video-renderer/.dockerignore`
  - `video-renderer/.gitignore`
- Backend integration:
  - `LocalRemotionRenderer` HTTP adapter in `backend/app/services/export_renderer.py`
  - worker selects renderer via `RENDER_BACKEND` (`mock` default, `local` supported)
  - worker docker-compose service sets `RENDER_BACKEND=local`
  - `aclose()` lifecycle on adapters; `_run_job_once_managed()` scopes renderer to asyncio loop
- Adapter tests: `backend/tests/test_export_renderer.py`

Delivered in current pass (pass 2 — real Remotion):
- Replaced timer-based stub with real Remotion render pipeline:
  - `video-renderer/package.json` bumped to `0.2.0`, `"type": "module"`, added `@remotion/bundler`, `@remotion/renderer`, `remotion`, `react`, `react-dom`
  - `video-renderer/src/remotion/index.jsx` — Remotion bundle entry (`registerRoot`)
  - `video-renderer/src/remotion/Root.jsx` — registers `Classic` composition (720×1280, 30fps defaults)
  - `video-renderer/src/remotion/Classic.jsx` — Classic template: title card → Ken Burns place slides → end card
  - `video-renderer/src/server.js` — ESM rewrite: `bundle()` at startup (503 until ready), `renderMedia()` per request, `makeCancelSignal()` for cooperative cancel, `getDimensions()` output profile helper (480p/720p × 9:16/16:9/1:1)
  - `video-renderer/Dockerfile` — switched from `node:20-alpine` to `node:20-bookworm-slim`, installed `chromium` + `fonts-liberation`, set `REMOTION_CHROME_EXECUTABLE=/usr/bin/chromium`
- `chromiumOptions: { gl: 'swangle' }` used everywhere for Docker software rendering compatibility

### 6C - AWS Lambda Scale

Status: Not started

### 6D - Quality + Hardening

Status: Not started

## 4. Verification Log

Validated in user dependency-ready environment:
- Backend export tests: `17/17` passed (8 endpoint + 9 worker).
- Flutter export tests: passed after latest guard/error-string alignment.

Attempted in this sandbox:
- `cd backend; pytest tests/test_export_endpoints.py tests/test_export_worker.py -q`
  - Failed before tests due missing dependency: `ModuleNotFoundError: No module named 'sqlalchemy'`.

## 5. Commit Trail (Phase 6)

- `a8ee884` fix(flutter): harden phase 6A export guards and routing gates
- `19b11ad` feat(flutter): scaffold phase 6A export studio and guard checks
- `eff1807` fix(phase6a-worker): persist output_url and harden stale tests with mocked time
- `1698b8d` fix(phase6a-worker): preserve late-cancel completion and clear stale renderer ids
- `06ea1bd` fix(phase6a): harden export worker recovery, race handling, and status contract
- `70326a0` feat(phase6a): scaffold export control plane, worker, and contracts

## 6. Next Actions

1. ~~Install renderer dependencies (`npm install`) and run container/local smoke tests for endpoint behavior.~~ — done: real Remotion pipeline wired.
2. ~~Add `exportsApiProvider` migration path in Flutter~~ — done: `dora_api` v1.1.0 regenerated, `ExportsApi` wired in `api_providers.dart`, manual `ExportApi` bridge removed (commit `e419335`).
3. Execute 6B-2: stage-accurate backend worker integration — `asset_fetch` (HEAD media URLs), `uploading` (persist MP4 to storage), `finalizing` (persist `output_url` + `thumbnail_url`).
4. Execute 6B-3: Flutter progress/share UX upgrades — `TemplatePicker`, full status/stage display states, cancel confirmation dialog, poll back-off (2s processing / 10s queued), `SharePreviewScreen`.
5. Smoke-test `video-renderer` locally: `npm install && node src/server.js`, submit a render with a real trip snapshot, confirm MP4 is produced.
6. Capture 6B evidence artifact set (3 trips × 2 aspect ratios, render logs) and write `phase6b-remotion-mvp-report.md`.
