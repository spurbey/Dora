# Phase 6C Kickoff Procedure

Date: 2026-03-01  
Phase: 6C - AWS Lambda Scale and Cost Controls  
Branch: `phase-6-video-export`

## 1. Objective

Move export rendering from local-only capacity to production-grade Lambda scale while preserving the frozen backend/Flutter API contract.

## 2. Frozen 6C Contract (Must Not Drift)

- Backend worker talks to renderer over HTTP only (`LambdaRemotionRenderer` is an HTTP adapter).
- Node `video-renderer` owns all `@remotion/lambda` calls.
- Remotion packages must use exact matching patch versions (`remotion` + all `@remotion/*`, no ranges).
- Lambda output destination uses `outName: {bucketName, key}`.
- `getRenderProgress` must use the `bucketName` returned by `renderMediaOnLambda`.
- Manifest output overrides use `forceFps`, `forceDurationInFrames`, `forceWidth`, `forceHeight`.
- Cancel semantics stay aligned with current worker behavior:
  - accept `cancel_requested -> completed` race when render already completed
  - otherwise settle `canceled` immediately after cancel path
- 6C lifecycle policy is unconditional 30-day cleanup under `private/`.
- `pinned_at` retention wiring and share-token revocation hardening are 6D scope.

## 3. Runtime Responsibility Split

- Renderer runtime principal:
  - Lambda invoke for Remotion render function
  - S3 access required by Remotion internals and output writes
  - CloudWatch logs for renderer diagnostics
- Backend runtime principal:
  - S3 read capability sufficient for generating download presigned URLs
  - no direct Lambda invoke in normal 6C flow

## 4. Execution Sequence

### 6C-0 Contract Lock (Docs Only)

Deliverables:
- PRD 6C section synced with frozen contract.
- Checklist 6C tasks synced to implementation reality.
- Rolling handoff updated with 6C entry constraints.

Exit criteria:
- No open contract ambiguity around version pinning, bucket semantics, cancel semantics, or IAM split.

### 6C-1 Renderer Cloud Path

Deliverables:
- `video-renderer` Lambda backend implementation.
- deploy scripts (`deploy:function`, `deploy:site`).
- exact Remotion package version pinning.
- env-driven runtime switch (`RENDER_BACKEND=local|lambda`) with unchanged HTTP route contract.

Exit criteria:
- Renderer can submit, poll, and report completion from Lambda path.
- Output path resolves to `s3://.../private/{user_id}/{job_id}/output.mp4`.

### 6C-2 Backend Cloud Integration

Deliverables:
- `LambdaRemotionRenderer` in backend service layer.
- Export guardrails:
  - per-user concurrent cap
  - global queue cap
  - quality/duration tier caps
- Worker upload stage recognizes `s3://` output and skips Supabase re-upload.
- Download endpoint returns S3 presigned URL (1h TTL) for S3-backed artifacts.
- Structured logs for job/render/upload/fail/cost tags.

Exit criteria:
- End-to-end Lambda render succeeds from existing export API flow.
- Presigned download path works and expires correctly.

### 6C-3 Infra, Verification, and Evidence

Deliverables:
- IAM policy docs and lifecycle rule artifacts in `infra/remotion/`.
- Environment templates updated for backend and renderer services.
- Load/concurrency notes and cost estimate documented.
- Evidence report: `flutter/docs/handoffs/phase6c-cloud-scale-report.md`.

Exit criteria:
- 5 concurrent job run completes without duplicate artifacts or deadlocks.
- Checklist 6C gate items closed with evidence.

## 5. Stop-The-Line Conditions

- Any Remotion package range (`^`, `~`, `x`) introduced.
- `outBucket` used instead of `outName`.
- `getRenderProgress` polled with wrong bucket context.
- Backend directly invoking AWS Lambda SDK for render path.
- Share-token revocation work pulled into 6C scope without explicit decision.
- Lifecycle pinning tied to `pinned_at` in 6C without 6D migration plan.

## 6. Evidence Template (6C Report Minimum)

- commit list and changed files
- env var matrix (backend vs renderer)
- IAM policy summary and principal mapping
- renderer Lambda integration logs (submit/status/cancel smoke)
- backend API test results (queue caps, tier caps, presigned URLs)
- concurrency run notes (5-job test)
- cost estimate for 720p/15s export
