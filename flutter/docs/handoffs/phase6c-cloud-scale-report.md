# Phase 6C Cloud Scale Report (Execution Checklist + Evidence Ledger)

Date Opened: 2026-03-07
Phase: 6C
Branch: `phase-6-video-export`
Status: `in_progress`

## 1. Purpose

This is the live evidence ledger for Phase 6C.
Every run must record:
- what was executed,
- what failed or passed,
- what was changed,
- and proof links/identifiers.

## 2. Current Gate Status

| Gate | Description | Status (`todo/in_progress/done`) | Notes |
|---|---|---|---|
| A1 | S3 bucket + lifecycle + privacy baseline | done | `dora-exports-dev` created, lifecycle applied, public block verified |
| A2 | Lambda function + serve site deployed | done | Function and serve URL generated via deploy scripts |
| A3 | Lambda export single-flow completion | in_progress | Export reaches rendering; cloud issues fixed iteratively |
| B1 | Retry/backoff stability under throttle pressure | in_progress | Throttle observed and mitigated by `framesPerLambda` tuning |
| B2 | 5-concurrent export validation | todo | Pending controlled concurrency run |
| B3 | Presigned download URL validation | todo | Pending end-to-end completion sample |
| C1 | Snapshot includes trip-rich media/timeline payload | in_progress | Backend snapshot enrichment patch added; pending runtime validation evidence |
| C2 | 3 trip-specific playable outputs | todo | Pending composition and snapshot enrichment |
| D1 | Rolling handoff sync | in_progress | Must update after each gate close |
| D2 | Final 6C sign-off summary | todo | Complete only after all gate evidence is attached |

## 3. Incident Ledger (Observed -> Action)

| Incident | Observed In | Root Cause | Action Taken | Verification State |
|---|---|---|---|---|
| `AWS Concurrency limit reached (Rate Exceeded)` | renderer + worker logs during rendering | Fan-out exceeded account concurrency budget | Increased `framesPerLambda` for low-quota account profile | in_progress |
| `s3:PutObject AccessDenied` | Lambda runtime while writing output | Missing object-level permissions on export bucket | Updated Lambda role permissions for bucket/object actions | in_progress |
| `The bucket does not allow ACLs` | renderer/Lambda output stage | ACL operation incompatible with bucket ownership mode | Shifted to ACL-safe output path/policy behavior | in_progress |

## 4. Run Log

| Timestamp (UTC) | Scenario | Action | Result | Evidence |
|---|---|---|---|---|
| 2026-03-07 | Export submit + poll | `POST /api/v1/trips/{trip_id}/export`, `GET /api/v1/exports/{job_id}` | API accepted, job moved `queued` -> `processing` -> `rendering` | App logs + Uvicorn logs |
| 2026-03-07 | Lambda render attempt | Worker submitted Lambda render | Failed with concurrency rate limit | Worker + renderer `[EXPORT_FAIL]` logs |
| 2026-03-07 | Lambda render attempt after tuning | Adjusted renderer fan-out configuration | Moved past initial throttle, then hit S3/IAM path | Renderer logs |
| 2026-03-07 | Bucket write attempt | Lambda output write to `dora-exports-dev/private/.../output.mp4` | Failed with `AccessDenied`, then ACL error | Renderer logs |
| 2026-03-07 | Post-policy rerun | Updated IAM/bucket behavior and retried | Video artifact generated (baseline placeholder) | Manual playback confirmation |
| 2026-03-08 | Trip-rich snapshot patch | Enriched backend snapshot with real places/media/routes/timeline + renderer fallback to `snapshot.places` | Code merged locally; pending Lambda validation run | `backend/app/services/export_service.py`, `video-renderer/src/remotion/Classic.jsx` |

## 5. Artifact Validation Table

| Job ID | Final Status | Output Path | Playable | Trip-Specific Content | Notes |
|---|---|---|---|---|---|
| `15187eec-fa9a-4622-b8c6-8af26354aecd` | failed/retried | n/a | n/a | n/a | Rate limit failures observed |
| `fc8b87fe-a396-4487-afa0-4cc5e68da679` | failed (intermediate) | n/a | n/a | n/a | ACL error observed |
| `<latest-success-job-id>` | completed | `s3://dora-exports-dev/private/{user}/{job}/output.mp4` | yes | no | Current composition still generic placeholder |

## 6. Commands and Runtime Evidence

Primary runtime commands:

```bash
cd video-renderer && npm run dev
cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
cd backend && python -m app.workers.export_worker
```

Validation commands used during infra bring-up:

```bash
aws sts get-caller-identity
aws s3api get-public-access-block --bucket dora-exports-dev
aws s3api get-bucket-lifecycle-configuration --bucket dora-exports-dev
```

## 7. Open Items to Close 6C

1. Lock stable `framesPerLambda` + poll interval combo that avoids rate limits in your AWS quota.
2. Complete 3 consecutive successful Lambda exports with zero retries.
3. Complete 5-concurrent export run and capture per-job outcomes.
4. Validate `/api/v1/exports/{job_id}/download-url` returns working presigned URL (`ttl_seconds=3600`).
5. Validate trip-rich output on Lambda with 3 real trips and capture artifact notes/screenshots in Section 5.

## 8. Decision Log

| Date | Decision | Why | Impact |
|---|---|---|---|
| 2026-03-07 | Keep Node renderer as sole Lambda SDK owner | Preserve backend/renderer separation contract | Python worker remains HTTP-only client |
| 2026-03-07 | Use private S3 output path + signed download | Security baseline for export artifacts | No public object exposure |
| 2026-03-07 | Tune fan-out to account quota before scale tests | Prevent retry storms/cost spikes | Required before B2 validation |

## 9. 6C Sign-Off Block

Status: `not_ready`

Completion summary:
- Infra unblock: partial complete
- Scale validation: pending
- Output quality baseline: pending
- Remaining risks: quota sensitivity, composition still generic

Go/No-Go for 6D: `NO-GO (until open items in Section 7 are complete)`
