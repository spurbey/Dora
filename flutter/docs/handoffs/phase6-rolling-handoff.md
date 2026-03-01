# Phase 6 Rolling Handoff

Last Updated: 2026-03-01
Branch: `phase-6-video-export`
Owner: Codex

## 1. Purpose

Continuity log across Phase 6 subphases (6A, 6B, 6C, 6D). Keep this file current after each milestone so follow-up agents can resume without re-discovery.

## 2. Source of Truth

- PRD: `flutter/docs/phases/Phase-6-PRD.md`
- Checklist: `flutter/docs/phases/Phase-6-Execution-Checklist.md`
- 6A contract freeze: `flutter/docs/handoffs/phase6-contract-freeze.md`
- 6C kickoff: `flutter/docs/handoffs/phase6c-kickoff-procedure.md`
- Renderer contract: `video-renderer/docs/renderer-api-contract.md`

## 3. Subphase Status

### 6A - Control Plane and Product Wiring

Status: Completed

Delivered:
- Backend export DB/model/schema/service/router/worker stack.
- Endpoints:
  - `POST /api/v1/trips/{trip_id}/export`
  - `GET /api/v1/exports/{job_id}`
  - `POST /api/v1/exports/{job_id}/cancel`
  - `GET /api/v1/exports/{job_id}/download-url`
  - `GET /api/v1/exports/{job_id}/share`
- Worker base behaviors:
  - atomic claim via `.with_for_update(skip_locked=True)`
  - cancel_requested semantics and race handling
  - retry/backoff and stale processing recovery
- Flutter 6A export wiring and guards.
- `dora_api` regeneration completed and `ExportsApi` wired in Flutter (`a536af9`, `e419335`).

### 6B - Remotion MVP Renderer

Status: **Completed** — see `phase6b-remotion-mvp-report.md`

Completed in 6B-1:
- Local renderer service scaffold with frozen endpoints and contract validation.
- Real Remotion rendering pipeline wired in `video-renderer` (`a11c855`):
  - bundling at startup
  - `Classic` composition
  - output profile handling for 480p/720p and 9:16/16:9/1:1
  - cooperative cancel signal wiring
- Backend local renderer adapter (`LocalRemotionRenderer`) and env-driven renderer selection.
- Renderer lifecycle fix for worker loop (`ab93058`): renderer scoped per `asyncio.run()` and explicitly closed.

Completed in 6B-2 (backend stage pipeline):
- Stage helpers implemented in worker (`2737880`, `0f2762a`):
  - snapshot size validation (<=500KB)
  - asset_fetch HEAD checks with terminal `asset_all_404` path
  - uploading path with Supabase storage integration
  - finalizing with metadata persistence
- Non-retryable terminal blocked handling for `asset_all_404`.
- Upload path aligned to private layout and thumbnail extraction from snapshot (6B shortcut; generated export thumbnail artifact deferred to 6D).
- Worker test coverage expanded for stage helpers and terminal behavior.
- Doc/code alignment commit (`5307a41`) corrected asset_fetch exception docstring and explicitly documented thumbnail shortcut intent in worker.

Completed in 6B-3 (Flutter UX):
- Full Export Studio flow from configure -> tracking -> completion surface (`f30274d`):
  - template picker (Classic + Cinematic preview)
  - job-status polling via provider (10s queued, 2s active)
  - status/state UI for queued, processing, cancel_requested, completed, failed, canceled, blocked
  - cancel confirmation + cancel API call integration
  - completion/share surface (`SharePreviewScreen`) with download/share actions
- Post-review hardening fixes (`a345901`):
  - domain-level `ExportTemplate` enum to decouple UI/repository from generated transport enums
  - one-shot completion navigation guard to avoid repeated completion-route scheduling
  - immediate polling invalidation after cancel request
  - test coverage updated to validate real tracking flow (shim removed)
  - blocked-state support CTA wiring

6B closure:
- Evidence report written: `flutter/docs/handoffs/phase6b-remotion-mvp-report.md`.
- Renderer smoke tests passed: 3 trips, 2 aspect ratios, cancel verified.
- Flutter analyze: 0 issues. Widget tests cover all 7 status states.

### 6C - AWS Lambda Scale

Status: In progress (6C-1 renderer cloud path started)

Entry constraints frozen for 6C:
- Renderer remains HTTP-only from backend (`LambdaRemotionRenderer` is an HTTP adapter; Node renderer owns `@remotion/lambda` usage).
- Exact Remotion version pinning is mandatory across all Remotion packages (no ranges).
- Lambda output contract uses `outName: {bucketName, key}` and progress polling must use the `bucketName` returned by `renderMediaOnLambda`.
- Cancel semantics are frozen to current worker behavior: `cancel_requested -> completed` race accepted; otherwise worker settles `canceled` immediately after cancel path.
- IAM is split by runtime principal (renderer runtime for Lambda invoke path, backend runtime for presigned URL path).
- Share-token revocation and `pinned_at` retention wiring are scoped to 6D hardening.

Current 6C-1 implementation progress (local diff):
- Added Lambda backend implementation: `video-renderer/src/lambda-renderer.js`
- Refactored renderer runtime switch in `video-renderer/src/server.js` (`RENDER_BACKEND=local|lambda`)
- Added deploy scripts:
  - `video-renderer/scripts/deploy-function.js`
  - `video-renderer/scripts/deploy-site.js`
- Added renderer env template: `video-renderer/.env.example`
- Updated `video-renderer/package.json` with exact Remotion version pinning and deploy scripts.
- Added backend Lambda HTTP adapter: `backend/app/services/export_renderer.py` (`LambdaRemotionRenderer`)
- Updated worker output URL normalization for non-file renderer outputs (supports `s3://...`): `backend/app/workers/export_worker.py`
- Added 6C service guardrails and S3 download presign path: `backend/app/services/export_service.py`
- Updated backend env/dependency templates for Lambda mode:
  - `backend/.env.example`
  - `backend/requirements.txt` (adds `boto3`)
- Added 6C infra policy artifacts:
  - `infra/remotion/iam.json`
  - `infra/remotion/s3_lifecycle.json`
  - `infra/remotion/README.md`

### 6D - Quality + Hardening

Status: Not started

## 4. Verification Log

Validated in user dependency-ready environment (earlier 6A milestone):
- Backend export tests: `17/17` passed (8 endpoint + 9 worker).
- Flutter 6A export tests: passed after guard/error-string alignment.

Current sandbox limitation:
- Backend pytest execution is blocked here by missing dependency: `sqlalchemy`.
- Latest 6B-2 worker tests are committed but not re-run in this sandbox.
- `video-renderer/package-lock.json` refresh is blocked here (`npm install` fails with `ENOTCACHED`).

## 5. Commit Trail (latest first)

- `4e6d687` chore(renderer): update README and add lockfile
- `d041ca6` docs(phase6): sync 6B docs with latest 6B-3 commits
- `25a8e05` docs(phase6b): write evidence report and close 6B gate
- `a345901` fix(export): apply 5 post-review fixes to 6B-3 Flutter UX
- `f30274d` feat(6b-3): Flutter export UX — TemplatePicker, polling, all status states, SharePreviewScreen
- `5307a41` fix(6b-2): correct asset_fetch docstring and annotate thumbnail shortcut
- `0f2762a` fix(6b-2): address 5 audit findings in export worker
- `2737880` feat(6b-2): implement stage-accurate worker pipeline (asset_fetch, uploading)
- `a11c855` feat(6b-1): wire real Remotion render pipeline into video-renderer
- `ab93058` fix(export): scope renderer lifecycle to each asyncio.run() call
- `1fa2ccc` feat(phase6b): scaffold local renderer service and backend adapter
- `e419335` feat(export): wire generated ExportsApi, drop manual bridge
- `a536af9` feat(dora_api): regenerate client v1.1.0 with export endpoints
- `a8ee884` fix(flutter): harden phase 6A export guards and routing gates
- `19b11ad` feat(flutter): scaffold phase 6A export studio and guard checks
- `70326a0` feat(phase6a): scaffold export control plane, worker, and contracts

## 6. Next Actions

1. Execute 6C-1 renderer cloud path: implement Lambda backend in `video-renderer` + deploy scripts + exact Remotion pinning.
2. Execute 6C-2 backend path: `LambdaRemotionRenderer`, queue/tier guardrails, S3 output handling, presigned download URLs.
3. Execute 6C-3 infra/evidence: IAM split docs, lifecycle rule, concurrency/load evidence, and 6C cloud-scale report.
