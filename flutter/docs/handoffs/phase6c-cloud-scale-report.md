# Phase 6C Cloud Scale Report (Execution Checklist + Evidence Ledger)

Date Opened: 2026-03-07
Phase: 6C
Branch: `phase-6-video-export`
Status: `completed`

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
| A3 | Lambda export single-flow completion | done | Consecutive completed exports validated in Lambda mode |
| B1 | Retry/backoff stability under throttle pressure | done | Stable settings confirmed (`framesPerLambda` + render polling defaults) |
| B2 | 5-concurrent export validation | done | Concurrent run completed without deadlocks/duplicate artifacts |
| B3 | Presigned download URL validation | done | `/download-url` verified with signed URL + expected TTL behavior |
| C1 | Snapshot includes trip-rich media/timeline payload | done | Snapshot builder now emits real places/media/routes/timeline payloads |
| C2 | 3 trip-specific playable outputs | done | Three real-trip outputs verified playable and trip-specific |
| D1 | Rolling handoff sync | done | Rolling handoff updated for 6D start |
| D2 | Final 6C sign-off summary | done | 6C closure captured in this report and checklist/PRD sync |

## 3. Incident Ledger (Observed -> Action)

| Incident | Observed In | Root Cause | Action Taken | Verification State |
|---|---|---|---|---|
| `AWS Concurrency limit reached (Rate Exceeded)` | renderer + worker logs during rendering | Fan-out exceeded account concurrency budget | Increased `framesPerLambda` for account quota profile | done |
| `s3:PutObject AccessDenied` | Lambda runtime while writing output | Missing object-level permissions on export bucket | Updated Lambda role permissions for bucket/object actions | done |
| `The bucket does not allow ACLs` | renderer/Lambda output stage | ACL operation incompatible with bucket ownership mode | Shifted to ACL-safe output path/policy behavior | done |

## 4. Run Log

| Timestamp (UTC) | Scenario | Action | Result | Evidence |
|---|---|---|---|---|
| 2026-03-07 | Export submit + poll | `POST /api/v1/trips/{trip_id}/export`, `GET /api/v1/exports/{job_id}` | API accepted, job moved `queued` -> `processing` -> `rendering` | App logs + Uvicorn logs |
| 2026-03-07 | Lambda render attempt | Worker submitted Lambda render | Failed with concurrency rate limit | Worker + renderer `[EXPORT_FAIL]` logs |
| 2026-03-07 | Lambda render attempt after tuning | Adjusted renderer fan-out configuration | Moved past initial throttle, then hit S3/IAM path | Renderer logs |
| 2026-03-07 | Bucket write attempt | Lambda output write to `dora-exports-dev/private/.../output.mp4` | Failed with `AccessDenied`, then ACL error | Renderer logs |
| 2026-03-07 | Post-policy rerun | Updated IAM/bucket behavior and retried | Video artifact generated (baseline placeholder) | Manual playback confirmation |
| 2026-03-08 | Trip-rich snapshot patch | Enriched backend snapshot with real places/media/routes/timeline + renderer fallback to `snapshot.places` | Lambda run validated with trip-specific output | `backend/app/services/export_service.py`, `video-renderer/src/remotion/Classic.jsx` |
| 2026-03-08 | 6C validation closure | Completed scale/download/quality validation set and synced reports | All 6C evidence gates passed | This report + checklist + rolling handoff updates |

## 5. Artifact Validation Table

| Job ID | Final Status | Output Path | Playable | Trip-Specific Content | Notes |
|---|---|---|---|---|---|
| `fb5a3d26-8a73-4bc8-a5d6-bdf109602f18` | completed | `s3://dora-exports-dev/private/{user}/{job}/output.mp4` | yes | yes | Lambda completed and uploaded to private bucket path |
| `40a7907e-a285-4d25-8773-a32b8e04e15e` | completed | `s3://dora-exports-dev/private/{user}/{job}/output.mp4` | yes | yes | Presigned download validated from completed job |
| `3b29e2a5-1945-41b0-9399-125d585d0353` | completed | `s3://dora-exports-dev/private/{user}/{job}/output.mp4` | yes | yes | Trip-rich snapshot path validated |
| `batch-5x-concurrency` | completed | mixed `s3://...` outputs | yes | yes | 5 concurrent jobs completed without deadlock/duplication |

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

All 6C closure items are complete.

Carry-forward items for 6D:
1. Advanced route/map visual choreography (cinematic fly-over + classic route smoothing).
2. Generated thumbnail artifact path (`thumbnail.jpg`) replacing 6B shortcut.
3. Share-token revocation hardening + `pinned_at` lifecycle protection integration.

## 8. Decision Log

| Date | Decision | Why | Impact |
|---|---|---|---|
| 2026-03-07 | Keep Node renderer as sole Lambda SDK owner | Preserve backend/renderer separation contract | Python worker remains HTTP-only client |
| 2026-03-07 | Use private S3 output path + signed download | Security baseline for export artifacts | No public object exposure |
| 2026-03-07 | Tune fan-out to account quota before scale tests | Prevent retry storms/cost spikes | Required before B2 validation |

## 9. 6C Sign-Off Block

Status: `ready`

Completion summary:
- Infra unblock: complete
- Scale validation: complete
- Output quality baseline: complete for 6C scope
- Remaining risks: none blocking 6D kickoff

Go/No-Go for 6D: `GO`
