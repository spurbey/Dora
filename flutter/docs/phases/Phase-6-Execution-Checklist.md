# PHASE 6 EXECUTION CHECKLIST (6A-6D)

Phase: Video Export Platform (Remotion + Durable Jobs)
Duration Target: 4 sub-phases (6A, 6B, 6C, 6D)
Owner: TBD
Last Updated: 2026-03-01

---

## How To Use This Checklist

- Execute in order: 6A → 6B → 6C → 6D.
- Do not advance until current sub-phase exit criteria are fully met.
- Attach evidence notes at each gate.
- Follow all guardrails in `Phase-6-PRD.md`.
- For every `dora_api` client regeneration: also bump `flutter/packages/dora_api/pubspec.yaml` version.

---

## Implementation Progress Snapshot (2026-03-01)

This checklist remains the canonical gate list. Current implementation state from committed work:

- 6A implementation: completed (control plane, worker skeleton, Flutter wiring, contract freeze docs, `dora_api` regeneration and provider migration).
- 6B-1 implementation: completed (local renderer service plus real Remotion pipeline and backend local renderer adapter wiring).
- 6B-2 implementation: in progress with committed stage helpers and worker updates (`asset_fetch`, upload/finalize logic, terminal blocked handling), pending dependency-ready verification and evidence capture.
- 6B-3 implementation: pending (Flutter template/progress/share UX).
- 6B final evidence/sign-off: pending (`phase6b-remotion-mvp-report.md`).

Use this snapshot for quick orientation, then drive execution by the checkbox gates below.

---

## Global Readiness Gate (Before 6A)

### Baseline Stability Tasks

- [ ] Confirm Phase 5 RC is fully signed off:
  - [ ] `phase5-rc-report.md` RC Decision is `GO`
  - [ ] All automated tests green (Section 2 of RC report)
  - [ ] All manual hardening matrix scenarios completed (Section 3 of RC report)
- [ ] Confirm export entry points still map to placeholder behavior:
  - [ ] `my_trips_screen.dart` shows toast only
  - [ ] `editor_screen.dart` `onExport` is empty callback only
- [ ] Confirm backend has no export router yet (`backend/app/main.py` baseline).

### Contract Freeze Tasks

- [ ] Freeze status model and stage model for export jobs (see §6.4 in PRD).
- [ ] Freeze API contract for create/status/cancel/download-url (see §6.3 in PRD).
- [ ] Freeze storage privacy model:
  - [ ] private by default
  - [ ] in-app download URL is presigned with 1hr TTL
  - [ ] share URL is a revocable backend token (7-day token lifetime) that issues short-lived (60s) presigned redirects
- [ ] Freeze quality/cost caps for MVP (720p free tier max, per-user concurrency=2, global cap=50).
- [ ] Freeze pre-submit guard contract (trip.serverTripId, pending media, pending sync — all three required).
- [ ] Document renderer HTTP API contract stub in `video-renderer/docs/renderer-api-contract.md` (even if renderer doesn't exist yet — the contract must be written before 6B starts).

### Exit Criteria

- [ ] Written `flutter/docs/handoffs/phase6-contract-freeze.md` exists and contains:
  - [ ] Export job status enum with all values and transition rules (copy from §6.4)
  - [ ] Export job stage enum with all values
  - [ ] Full API request/response contracts for all 5 endpoints (copy from §6.3)
  - [ ] URL/token TTL values (1hr download presigned URL, 7-day share token lifetime, 60s share redirect presigned URL)
  - [ ] Quality caps per tier (free: ≤720p/≤15s; paid: ≤1080p/≤60s)
  - [ ] Per-user and global concurrency caps
  - [ ] Pre-submit guard conditions (all three)
  - [ ] `blocked` semantics statement: server-only, worker-set, never at creation
  - [ ] Renderer HTTP API contract reference (link to `renderer-api-contract.md`)
  - [ ] Sign-off note with date
- [ ] No unresolved blockers for DB migration and worker implementation.

### Evidence

- [ ] `flutter/docs/handoffs/phase6-contract-freeze.md`

---

## Phase 6A - Control Plane and Product Wiring

### Backend Tasks

- [ ] Create export job DB migration:
  - [ ] `export_jobs` table with all columns from §6.1 including `next_attempt_at` (nullable datetime)
  - [ ] indexes: `(user_id, status)`, `(status, next_attempt_at)`, `(trip_id)`, `(snapshot_hash)`
  - [ ] check constraints for valid `status` values — must include `cancel_requested` as a valid transitional status
  - [ ] migration rollback notes in migration file header
- [ ] Add model + schemas:
  - [ ] `backend/app/models/export_job.py` — SQLAlchemy model
  - [ ] `backend/app/schemas/export.py` — Pydantic request/response/status schemas
- [ ] Add renderer abstraction:
  - [ ] `AbstractRemotionRenderer` interface in `backend/app/services/export_renderer.py`
  - [ ] `MockRemotionRenderer` stub that simulates 6 stage progressions for testing
- [ ] Add service + router:
  - [ ] `backend/app/services/export_service.py` with pre-submit validation, snapshot size check, dedup logic
  - [ ] `backend/app/api/v1/exports.py` with all 5 endpoints
  - [ ] register router in `backend/app/main.py`
- [ ] Implement endpoints:
  - [ ] `POST /api/v1/trips/{trip_id}/export` — with 409 dedup and 422 precondition responses
  - [ ] `GET /api/v1/exports/{job_id}` — ownership check required
  - [ ] `POST /api/v1/exports/{job_id}/cancel` — ownership check required
  - [ ] `GET /api/v1/exports/{job_id}/download-url` — stub allowed in 6A; ownership + status==completed check required
  - [ ] `GET /api/v1/exports/{job_id}/share` — ownership check required; returns revocable share URL/token
- [ ] Add worker skeleton:
  - [ ] separate process in `backend/app/workers/export_worker.py`
  - [ ] claim loop using `.with_for_update(skip_locked=True)` — standard `.with_for_update()` is NOT allowed
  - [ ] `worker_session_id` stamped on claim
  - [ ] status/stage progression through all 6 stages using `MockRemotionRenderer`
  - [ ] exponential backoff on retry (30s, 120s, 480s)
  - [ ] cancel flag checked at each stage boundary: reads `status` and treats `cancel_requested` as a cancel signal
  - [ ] `POST /cancel` sets `status = cancel_requested` (not `canceled` directly) when job is `processing`
  - [ ] `POST /cancel` sets `status = canceled` directly when job is still `queued`
  - [ ] worker calls `renderer.cancel(render_id)` on detecting `cancel_requested`; transitions to `canceled` after confirm or timeout
  - [ ] race condition handled: if renderer completes while `cancel_requested`, accept artifact and set `completed`

### Flutter Tasks

- [ ] Add export feature skeleton:
  - [ ] `flutter/lib/features/export/data/export_repository.dart`
  - [ ] `flutter/lib/features/export/domain/export_job.dart`
  - [ ] `flutter/lib/features/export/domain/export_state.dart`
  - [ ] `flutter/lib/features/export/domain/export_error_strings.dart` (user-facing copy for all error codes)
  - [ ] `flutter/lib/features/export/presentation/providers/export_provider.dart`
- [ ] Add routes:
  - [ ] `flutter/lib/core/navigation/routes.dart`
  - [ ] `flutter/lib/core/navigation/app_router.dart`
- [ ] Wire export actions:
  - [ ] `my_trips_screen.dart` export action navigates to `ExportStudioScreen`
  - [ ] `editor_screen.dart` export action navigates to `ExportStudioScreen`
- [ ] Add pre-submit guards (all three required):
  - [ ] block when `trip.serverTripId == null` with message: "Trip must be synced before exporting"
  - [ ] block when media queue has pending/failed items for this trip
  - [ ] block when sync queue has blocking tasks for this trip
- [ ] 6A Export Studio screen:
  - [ ] "Preparing your video..." single-state UI
  - [ ] "Start Export" button submits with hardcoded `classic` template
  - [ ] no template picker in 6A (that is a 6B deliverable)

### API Client Tasks

- [ ] Regenerate Flutter OpenAPI client (`dora_api`) with export endpoints.
- [ ] Bump `dora_api` package version in `flutter/packages/dora_api/pubspec.yaml`.
- [ ] Add provider wiring in `flutter/lib/core/network/api_providers.dart`.

### Renderer Contract Tasks

- [ ] Create `video-renderer/docs/renderer-api-contract.md` with:
  - [ ] `POST /api/v1/render` request/response schema
  - [ ] `GET /api/v1/render/{render_id}` response schema
  - [ ] `DELETE /api/v1/render/{render_id}` response schema
  - [ ] `X-Renderer-Version` header spec
  - [ ] error codes and HTTP status mappings
- [ ] Contract reviewed and signed off before any 6B implementation begins.

### Local Dev Orchestration Tasks

- [ ] Add `docker-compose.dev.yml` at repo root (api + worker + renderer + db services).
- [ ] Add `Procfile.dev` at repo root (lightweight alternative).
- [ ] Document startup procedure in `video-renderer/README.md`.

### 6A Exit Criteria

- [ ] User can submit export job from Flutter and observe all 6 stage progressions (mock renderer).
- [ ] Cancel endpoint updates state correctly; Flutter reflects canceled state.
- [ ] Worker restart-recovery: after kill + restart, queued jobs are re-claimed without getting stuck in `processing`. Evidence must be captured in test output (see mandatory tests below).
- [ ] `status = blocked` is never set at job creation — verify in service unit tests.
- [ ] Pre-submit guard rejects local-only trip (`trip.serverTripId == null`) with correct 422 response.
- [ ] No regression in media upload/sync queue flows.
- [ ] Renderer HTTP API contract document exists and is signed off.

### 6A Evidence

- [ ] `flutter/docs/handoffs/phase6a-control-plane-report.md`
- [ ] API request/response examples captured for all 5 endpoints
- [ ] Migration file with rollback steps
- [ ] `video-renderer/docs/renderer-api-contract.md` signed off

---

## Phase 6B - Remotion MVP Renderer (Local First)

### Pre-Condition Gate

- [ ] §5.2 renderer HTTP API contract is frozen (from 6A exit).
- [ ] `video-renderer/docs/renderer-api-contract.md` exists and is not pending changes.
- [ ] 6A exit criteria are fully met.

### Renderer Tasks

- [ ] Create `video-renderer/` Express + Remotion service:
  - [ ] implements all endpoints in the frozen HTTP API contract
  - [ ] `X-Renderer-Version: 1` validation middleware
  - [ ] one composition: `classic` template
  - [ ] `RenderManifest` input props schema with validation
  - [ ] deterministic render characteristics (same manifest -> same timeline ordering, duration, fps, and visual sequencing; byte-identical MP4 is not required)
- [ ] Implement output profiles:
  - [ ] 480p and 720p
  - [ ] 9:16 and 16:9
  - [ ] 30fps
- [ ] Configure output path via `RENDER_OUTPUT_DIR` env var (no hardcoded paths).

### Backend Integration Tasks

- [ ] Implement `LocalRemotionRenderer` in `export_renderer.py`:
  - [ ] calls `video-renderer/` HTTP API using `httpx` (async)
  - [ ] maps backend `RenderManifest` model to renderer request body
  - [ ] polls renderer progress endpoint during `rendering` stage
  - [ ] calls cancel endpoint when job is canceled
- [ ] Implement all 6 worker stages:
  - [ ] `snapshotting` — build manifest, validate ≤500KB, compute `snapshot_hash`
  - [ ] `asset_fetch` — HEAD request all media URLs; fail fast if all 404
  - [ ] `rendering` — call `LocalRemotionRenderer.render(manifest)`, poll until complete
  - [ ] `encoding` — no-op for local path (Remotion handles inline)
  - [ ] `uploading` — upload MP4 + thumbnail to private storage path
  - [ ] `finalizing` — persist output_url, thumbnail_url, render_duration_ms, mark completed
- [ ] Cancel check at entry of each stage: read `status` from DB before proceeding.
- [ ] Persist artifact metadata in `export_jobs` on completion.

### Flutter UX Tasks

- [ ] Build `TemplatePicker` as first step of `ExportStudioScreen` (replaces 6A hardcoded default).
- [ ] Build Screen 10/11/12-aligned progress UI:
  - [ ] `export_studio_screen.dart` (submit + progress states)
  - [ ] `share_preview_screen.dart` (completion + download + share)
- [ ] Implement all status/stage display states:
  - [ ] `queued` → "Waiting in queue..." (poll at 10s intervals)
  - [ ] `processing` → stage label + progress bar (poll at 2s intervals)
  - [ ] `completed` → completion screen with download and share actions
  - [ ] `failed` → error screen with retry button
  - [ ] `cancel_requested` → "Canceling..." spinner (transitional, polls at 2s until resolved)
  - [ ] `canceled` → canceled screen with restart option
  - [ ] `blocked` → error screen with user-facing copy from `export_error_strings.dart` + support link
- [ ] Cancel confirmation dialog before cancel API call.
- [ ] Poll back-off: 2s during `processing`, 10s during `queued`.

### API Client Re-Check

- [ ] After 6B: verify `dora_api` generated types match current export OpenAPI spec.
- [ ] If any schema changed during 6B: regenerate `dora_api` client and bump version.

### 6B Exit Criteria

- [ ] Real trip data renders to a playable, non-corrupt MP4 via local renderer.
- [ ] 15-second 720p export completes end-to-end from Flutter in local dev.
- [ ] All 6 worker stages execute and progress is visible in Flutter UI.
- [ ] All failure states show actionable user-facing messages.
- [ ] p95 success rate ≥ 95% for smoke set of 5 test trips.
- [ ] No regression in media upload and entity sync behavior.

### 6B Evidence

- [ ] `flutter/docs/handoffs/phase6b-remotion-mvp-report.md`
- [ ] Sample artifact set: at least 3 trips, 2 aspect ratios, all artifacts playable without corruption
- [ ] Render logs with stage timestamps for at least one full end-to-end run
- [ ] Confirmation that all 6 stages complete without errors in logs

---

## Phase 6C - AWS Lambda Scale and Cost Controls

### Pre-Condition Gate

- [ ] 6B render manifest schema is stable and signed off.
- [ ] No manifest schema changes pending.
- [ ] 6B exit criteria are fully met.

### IAM and Infrastructure Tasks (must complete before Lambda testing)

- [ ] Provision IAM role with minimum permissions (see §7.3 in PRD for exact policy).
- [ ] Create `dora-exports-{env}` S3 bucket with:
  - [ ] no public ACLs
  - [ ] versioning disabled (artifacts are immutable once written)
  - [ ] S3 lifecycle rule: delete objects older than 30 days where `pinned_at` tag is not set
- [ ] Create IaC definitions in `infra/remotion/`:
  - [ ] `iam.tf` or `iam.ts` — IAM role and policy
  - [ ] `s3_lifecycle.json` — lifecycle rule
  - [ ] `README.md` — provisioning steps and role ARN documentation
- [ ] Store `AWS_WORKER_ROLE_ARN` and `AWS_LAMBDA_REGION` in `backend/.env.production` template.

### Cloud Rendering Tasks

- [ ] Implement `LambdaRemotionRenderer` in `export_renderer.py`.
- [ ] Configure Lambda via `@remotion/lambda` tooling:
  - [ ] memory: 2048MB (720p), 3008MB (1080p)
  - [ ] `framesPerLambda`: 8
  - [ ] timeout: 900s
  - [ ] `reservedConcurrentExecutions`: 20
- [ ] Configure cloud output destination and persist artifact metadata.
- [ ] Switch renderer based on `RENDER_BACKEND` env var (`local` vs `lambda`).

### Cost Control Tasks

- [ ] Enforce per-user active job limit (default: 2) in `export_service.py`.
- [ ] Enforce global queue cap (default: 50) in `export_service.py`.
- [ ] Implement dedup by `snapshot_hash + quality + aspect_ratio` — return 409 with existing job_id.
- [ ] Enforce quality caps by tier: free ≤720p/≤15s, paid ≤1080p/≤60s.
- [ ] Add retry policy: max 3 attempts, backoffs 30s/120s/480s.
- [ ] Add `pinned_at` column support in `export_jobs` to protect shared artifacts from lifecycle cleanup.

### Reliability Tasks

- [ ] Implement stale job reaper:
  - [ ] background task marks jobs stuck in `processing` for > `EXPORT_WORKER_TIMEOUT_MINUTES` as `failed`
  - [ ] `error_code = worker_timeout`
- [ ] Add retry for transient Lambda failures: `lambda_throttle`, `lambda_timeout`, `lambda_5xx`.

### Security Tasks

- [ ] Ownership check on all status/cancel/download-url endpoints.
- [ ] Download URL: S3 presigned URL, 1-hour TTL.
- [ ] Share URL model:
  - [ ] 7-day backend share token (revocable)
  - [ ] each share request issues a 60s S3 presigned redirect URL
- [ ] Share URL invalidation: hook into trip visibility update — revoke shared artifacts when trip becomes private.
- [ ] No public bucket ACLs at any time.

### Observability Tasks

- [ ] Add structured log tags to all relevant log lines:
  - [ ] `[EXPORT_JOB]`
  - [ ] `[EXPORT_RENDER]`
  - [ ] `[EXPORT_UPLOAD]`
  - [ ] `[EXPORT_FAIL]`
  - [ ] `[EXPORT_COST]` (Lambda invocation count + duration per job)
- [ ] Track minimum metrics:
  - [ ] queue wait time
  - [ ] render duration per stage
  - [ ] job success/failure/cancellation rate
  - [ ] Lambda invocation count per export
  - [ ] artifact size distribution

### 6C Exit Criteria

- [ ] Lambda render path handles 5 concurrent jobs without deadlocks or duplicate artifacts.
- [ ] Cost and concurrency limits enforced and confirmed in API layer tests.
- [ ] IAM role uses minimum permissions — confirmed via policy review.
- [ ] URL flow validated (download URL expires, share token revocation works, share redirect URL expires in 60s).
- [ ] Share URL invalidation works when trip privacy changes to private.
- [ ] Observability logs visible and tagged correctly.

### 6C Evidence

- [ ] `flutter/docs/handoffs/phase6c-cloud-scale-report.md`
- [ ] Load test notes (5 concurrent jobs)
- [ ] Cost estimation for 720p/15s export (Lambda + S3)
- [ ] IAM policy review sign-off
- [ ] Guardrail verification (concurrency cap, quality cap, dedup)

---

## Phase 6D - Quality, Templates, and Hardening

### Product Quality Tasks

- [ ] Add `cinematic` template to `video-renderer/`:
  - [ ] letterbox aspect ratio support
  - [ ] Ken Burns effect on photos
  - [ ] smooth camera fly-over on route animation
- [ ] Polish `classic` template:
  - [ ] camera easing: ease-in-out curve (not linear)
  - [ ] route animation: spline interpolation (not step)
  - [ ] text/label timing and fade
  - [ ] transition smoothness between place cards
- [ ] Build export history screen: list past exports with status, thumbnail, re-export/share/delete.
- [ ] Integrate native share sheet for share action.

### Hardening Tasks

- [ ] Finalize failure taxonomy in `export_error_strings.dart`:
  - [ ] retryable codes: `network_timeout`, `render_crash`, `upload_timeout`, `lambda_throttle`
  - [ ] terminal (blocked) codes: `trip_deleted`, `auth_revoked`, `quota_exceeded`, `asset_all_404`, `worker_timeout`
  - [ ] user-facing copy for each code
- [ ] Verify cancel works at every stage boundary (test each stage individually).
- [ ] Verify stale job reaper fires correctly for stuck `processing` jobs.
- [ ] Add `pinned_at` UI control: "Keep this video" option on completion screen sets `pinned_at`.
- [ ] Storage lifecycle cleanup confirmed working (artifacts ≥30 days without `pinned_at` are deleted).

### Regression Tasks

- [ ] Full regression on:
  - [ ] create/edit trip
  - [ ] places/routes timeline
  - [ ] media upload queue
  - [ ] entity sync worker
  - [ ] export flow (submit/poll/cancel/download/share)

### Documentation Tasks

- [ ] Write `flutter/docs/ops/export-runbook.md` with:
  - [ ] how to restart the worker
  - [ ] how to manually unblock a stuck job
  - [ ] how to revoke a shared URL
  - [ ] Lambda concurrency and cost monitoring steps
  - [ ] on-call escalation for export failures

### 6D Exit Criteria

- [ ] Quality sign-off against `screen6-12.md` expectations for both templates.
- [ ] No critical defects in export pipeline.
- [ ] No major regressions in create/media/sync architecture.
- [ ] Operational runbook complete and reviewed.

### 6D Evidence

- [ ] `flutter/docs/handoffs/phase6d-quality-hardening-report.md`
- [ ] Final go/no-go checklist with defect summary
- [ ] Regression matrix signed off

---

## Mandatory Test Gates

### Backend

- [ ] Add tests:
  - [ ] `backend/tests/test_export_endpoints.py`
  - [ ] `backend/tests/test_export_worker.py` — must include restart-recovery test
- [ ] Run:
  - [ ] `cd backend && pytest tests/test_export_endpoints.py -v`
  - [ ] `cd backend && pytest tests/test_export_worker.py -v`

### Flutter

- [ ] Add tests:
  - [ ] export repository/provider tests (pre-submit guard for all 3 conditions including `trip.serverTripId == null`)
  - [ ] export screen widget tests (all status/stage states)
  - [ ] precondition guard tests
- [ ] Run:
  - [ ] `cd flutter && flutter test test/features/export/ -r expanded`
  - [ ] `cd flutter && flutter analyze`

### Frontend (if touched)

- [ ] Run:
  - [ ] `cd frontend && npm run lint`
  - [ ] `cd frontend && npm run build`

---

## Stop-The-Line Conditions

If any of these occur, halt the phase immediately and publish a remediation plan before continuing.

- [ ] Duplicate export artifacts generated for the same job.
- [ ] Job stuck in `processing` or `cancel_requested` with no retry/reaper/cancel path.
- [ ] Private trip export becomes publicly accessible without explicit publish action.
- [ ] Export implementation regresses Phase 5 media/sync baseline.
- [ ] `snapshot_json` contains binary or base64 data (violates §4 Guardrail 11).
- [ ] Job claim uses `.with_for_update()` without `skip_locked=True` (violates §4 Guardrail 4).
- [ ] `status = blocked` is set at job creation time (violates §4 Guardrail 12).
- [ ] Ownership check missing on any export endpoint (security regression).
