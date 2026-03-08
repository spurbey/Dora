# Phase 6C Kickoff Procedure (Execution Blueprint)

Date: 2026-03-07
Phase: 6C - AWS Lambda Scale + Cost Control
Branch: `phase-6-video-export`
Status: Historical reference (6C closed on 2026-03-08)

> Active execution now continues in `flutter/docs/handoffs/phase6d-kickoff-procedure.md`.

## 1. Objective

This document is the locked execution blueprint for Phase 6C.
It defines exactly:
- what to implement,
- what evidence is required,
- what is considered done,
- and what must stop execution.

## 2. Scope

In scope for 6C:
- Lambda-backed rendering via `video-renderer` service (`RENDER_BACKEND=lambda`).
- Stable end-to-end export completion from Flutter -> backend -> worker -> renderer -> S3.
- Guardrails: queue cap, per-user cap, free-tier limits, worker recovery.
- Download URL for private export artifacts via short-lived presigned URL.
- Cloud observability via tagged logs.

Out of scope for 6C (carry to 6D):
- Advanced cinematic templates and transitions.
- Pinning retention workflow (`pinned_at` -> S3 object tags).
- Share-token hardening beyond current signed download flow.

## 3. Architecture Contract (No Drift)

1. Flutter is control UI only (submit job, poll, preview/share).
2. FastAPI is control plane only (durable jobs, auth, status, signed URL).
3. Python worker executes lifecycle stages and never calls Remotion SDK directly.
4. Node `video-renderer` service is the render plane and owns `@remotion/lambda` usage.
5. Renderer contract remains HTTP:
- `POST /api/v1/render`
- `GET /api/v1/render/{render_id}`
- `DELETE /api/v1/render/{render_id}`
6. Artifacts remain private under `s3://<exports-bucket>/private/{user_id}/{job_id}/output.mp4`.

## 4. Current Reality (Verified)

From current runs:
- Export request path is functional (`202 Accepted`, polling works).
- Worker reaches `rendering` and Lambda submit succeeds.
- Known resolved/partially resolved runtime issues:
  - `AWS Concurrency limit reached` (mitigated by higher `framesPerLambda` for low-quota accounts).
  - `s3:PutObject AccessDenied` (fixed by role permissions).
  - `The bucket does not allow ACLs` (fixed by ACL-safe bucket/role path).
- Current output baseline is renderer-generic text video; trip-rich timeline composition is next required step.

## 5. Execution Gates

### Gate A - Cloud Unblock

Goal: make Lambda export stable for single job flow.

Actions:
1. Confirm S3 bucket exists and public access is blocked.
2. Confirm lifecycle policy from `infra/remotion/s3_lifecycle.json` is applied.
3. Confirm Lambda function and serve site are deployed.
4. Confirm Lambda execution role has object-level permission on exports bucket.
5. Confirm renderer `.env` points to deployed function/site and output bucket.

Exit criteria:
- 3 consecutive single exports finish as `completed`.
- Output object exists at expected `private/{user}/{job}/output.mp4` key.

### Gate B - Scale and Cost Control

Goal: eliminate retry storms and keep predictable runtime cost.

Actions:
1. Tune `framesPerLambda` to account concurrency quota.
2. Keep worker poll interval sane (`EXPORT_RENDER_POLL_SECONDS`), avoid API thrash.
3. Validate per-user and global caps return expected errors.
4. Validate retry/backoff behavior does not produce deadlocks or duplicate final artifacts.

Exit criteria:
- 5 concurrent jobs complete without stuck `processing` state.
- No repeated `render_crash` due to platform throttle under validated config.

### Gate C - Output Quality Baseline

Goal: make output reflect actual trip content, not placeholder-only composition.

Actions:
1. Ensure snapshot contains timeline/media/place inputs required by composition.
2. Update Remotion `Classic` composition to consume real snapshot fields.
3. Validate rendering across at least 3 real trips and 2 aspect ratios.

Exit criteria:
- 3 sample videos are playable and visibly trip-specific.
- Fallback-only generic video appears only for empty/invalid snapshots.

### Gate D - Evidence and Sign-off

Goal: preserve context for any follow-up agent and 6D handoff.

Actions:
1. Log each run in `phase6c-cloud-scale-report.md`.
2. Sync any contract-impacting decisions in `phase6-rolling-handoff.md`.
3. Record unresolved risks and explicit carry-forward items.

Exit criteria:
- Evidence file contains command trace, job IDs, outcomes, and failure/fix table.
- Go/No-Go for 6D documented with owner/date.

## 6. Operator Run Sequence

Use 3 terminals:

1. Renderer:
```bash
cd video-renderer && npm run dev
```

2. API:
```bash
cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

3. Worker:
```bash
cd backend && python -m app.workers.export_worker
```

Expected sequence after pressing Export in app:
1. `POST /api/v1/trips/{trip_id}/export` -> `202` + `job_id`.
2. Worker claims job (`queued` -> `processing`).
3. Stage progression: `snapshotting` -> `rendering` -> `uploading` -> `finalizing`.
4. Job reaches `completed` with `output_url` and `render_duration_ms`.

## 7. Stop-The-Line Conditions

Stop and fix before further execution if any occurs:
- `AccessDenied` on export bucket writes.
- ACL-related bucket errors.
- Job stuck in `processing` beyond stale timeout policy.
- Duplicate artifacts for same `job_id`.
- Private artifacts accessible publicly without signed URL.

## 8. Required Evidence for 6C Completion

Minimum evidence set:
- 3 consecutive successful single exports.
- 5 concurrent export run results.
- Presigned URL validation and expiry behavior.
- Error/fix ledger for every cloud incident encountered.
- Quality notes for 3 real-trip outputs.

## 9. Handoff Discipline

After each gate:
1. update `phase6c-cloud-scale-report.md` with run outcomes,
2. update `phase6-rolling-handoff.md` only for contract or risk changes,
3. mark next gate entry criteria,
4. record open risks explicitly.

No gate can be marked complete without evidence.
