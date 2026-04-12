# Session Commit Worker Spec (V2)

Status: Phase 5 foundation implemented (local staging lane)
Version: v2.2
Last updated: 2026-04-12
Owner: Flutter runtime team

## 1. Purpose

This spec defines the V2 session-stop local staging worker.

In the publish-only Phase 6 architecture, this worker is **not** a server upload lane.
It creates deterministic, immutable local artifacts used later by trip publish.

## 2. References

1. [Master Blueprint](./master-blueprint.md)
2. [Command Lane Spec](./command-lane-spec.md)
3. [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
4. [Trip Publish Spec](./trip-publish-spec.md)
5. [Backend Ingest and Projection Spec](./backend-ingest-and-projection-spec.md)

## 3. Local Tables

1. `session_commit_job`
2. `session_commit_media_item`
3. `session_commit_chunk`

These remain local-only staging artifacts for V2 publish lane.

## 4. Design Rules

1. One deterministic job per sealed session attempt:
   - `commit:{session_id}:{seal_version}`
2. Snapshot is immutable per job once prepared.
3. Lease/takeover behavior stays crash-safe.
4. No network upload/finalize phases for V2 publish lane.
5. No false uploaded-success semantics from this lane.

## 5. Trigger Rules

A commit staging job is created when:

1. session enters `sealed`,
2. no active local job exists for same session attempt,
3. trigger source is stop/manual retry/recovery.

## 6. Pipeline (Publish-Only Lane)

### Active phase

1. `prepare`
   - snapshot session/event/media/route rows,
   - compute snapshot hashes/counts,
   - stage media and payload chunk metadata,
   - persist deterministic idempotency artifacts.

### Disabled phases in this lane

1. `media_upload`
2. `payload_upload`
3. `finalize_ack`

These are deprecated for V2 publish-only architecture and must not execute network calls.

## 7. Idempotency and Stop Lock

1. Staging id is deterministic and reused on restart/retry.
2. `stop_client_event_id` is seal-version scoped:
   - same `(session_id, seal_version)` reuses same stop id,
   - new seal version rotates stop id.

## 8. Retry and Lease

1. Backoff constants remain 15s/60s/180s, max 3.
2. Lease TTL is 5 minutes from last heartbeat timestamp.
3. Stale lease may be taken over safely.
4. Retries in this lane apply to local staging/recovery only.

## 9. UI Contract

Session commit chip semantics for V2 lane:

1. `commit_pending`: "Saved locally. Upload on publish."
2. `committing`: optional brief local preparation state only.
3. `commit_failed_retryable`: local staging failed, retry CTA.
4. `committed`: local staging completed (not server-uploaded).

Rule: stop action must never imply remote upload success.

## 10. Observability

1. `session_commit_job_created`
2. `session_commit_prepare_completed`
3. `session_commit_job_failed_retryable`
4. lease takeover events

No `finalize_ack_received` telemetry in publish-only lane.

## 11. Acceptance Criteria

1. one local staging job per sealed session attempt,
2. immutable snapshot artifacts survive restart/recovery,
3. no network upload path triggered by this worker,
4. local timeline remains visible regardless of staging state.
