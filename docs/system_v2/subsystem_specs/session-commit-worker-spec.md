# Session Commit Worker Spec (V2)

Status: Phase 5 foundation implemented (backend ingest deferred)
Version: v2.0
Last updated: 2026-04-12
Owner: Flutter sync/runtime team + backend ingest team

## 1. Purpose

This spec defines the V2 session-end commit worker.

It replaces continuous live entity syncing with one bounded, idempotent finalize process per stopped session.

It covers:

1. Local job schema.
2. Commit phases.
3. Chunking and idempotency.
4. Retry policy.
5. UI state contract.
6. Backend interaction contract at high level.

## 2. References

1. Master blueprint: [Master Blueprint](./master-blueprint.md)
2. Command lane contract: [Command Lane Spec](./command-lane-spec.md)
3. Local journal + resolver source data: [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
4. Subsystem index: [Subsystem Specs Index](./README.md)
5. System index: [System V2 Index](../README.md)

## 3. Depends On

1. Session/event/media/resolver local tables and lock semantics from local-journal spec.
2. V2 command lane stop/seal behavior from master blueprint.

## 4. Used By

1. `trip-publish-spec.md`
2. `backend-ingest-and-projection-spec.md`
3. Runtime sync status UI on live/editor screens.

## 5. Design Goals

1. One commit job per sealed session.
2. No continuous background flood loops.
3. Crash-safe and resumable.
4. Media-safe (chunked, resumable uploads).
5. Idempotent server writes for duplicate attempts.
6. User-visible, actionable failure states.

## 6. Local Job Tables

### 6.1 `session_commit_job`

One row per session finalize attempt lifecycle.

Columns:

1. `job_id` TEXT PRIMARY KEY
2. `session_id` TEXT NOT NULL
3. `trip_local_id` TEXT NOT NULL
4. `server_trip_id` TEXT NULL
5. `job_state` TEXT NOT NULL
- enum: `commit_pending`, `committing`, `commit_failed_retryable`, `committed`
6. `phase` TEXT NOT NULL
- enum: `prepare`, `media_upload`, `payload_upload`, `finalize_ack`, `done`
7. `attempt_count` INTEGER NOT NULL DEFAULT 0
8. `next_retry_at` DATETIME NULL
9. `last_error_code` TEXT NULL
10. `last_error_message` TEXT NULL
11. `idempotency_key` TEXT NOT NULL
12. `session_commit_token` TEXT NULL
13. `is_executing` INTEGER NOT NULL DEFAULT 0
14. `execution_started_at` DATETIME NULL (last heartbeat timestamp)
15. `execution_owner_id` TEXT NULL
16. `lease_version` INTEGER NOT NULL DEFAULT 0
17. `snapshot_hash` TEXT NULL
18. `snapshot_created_at` DATETIME NULL
19. `snapshot_event_count` INTEGER NOT NULL DEFAULT 0
20. `snapshot_media_count` INTEGER NOT NULL DEFAULT 0
21. `snapshot_point_count` INTEGER NOT NULL DEFAULT 0
22. `snapshot_payload_bytes` INTEGER NOT NULL DEFAULT 0
23. `created_at` DATETIME NOT NULL
24. `updated_at` DATETIME NOT NULL
25. `completed_at` DATETIME NULL

Indexes:

1. `(job_state, next_retry_at)`
2. `(session_id)`
3. `(trip_local_id, created_at DESC)`
4. `(is_executing, execution_started_at)`

### 6.2 `session_commit_media_item`

Per-media upload status for job resumption.

Columns:

1. `item_id` TEXT PRIMARY KEY
2. `job_id` TEXT NOT NULL
3. `media_id` TEXT NOT NULL
4. `upload_state` TEXT NOT NULL
- enum: `pending`, `uploading`, `uploaded`, `failed_retryable`, `failed_terminal`
5. `upload_ref` TEXT NULL
6. `remote_checksum` TEXT NULL
7. `attempt_count` INTEGER NOT NULL DEFAULT 0
8. `last_error_code` TEXT NULL
9. `last_error_message` TEXT NULL
10. `created_at` DATETIME NOT NULL
11. `updated_at` DATETIME NOT NULL

Indexes:

1. `(job_id, upload_state)`
2. `(media_id)`

### 6.3 `session_commit_chunk`

Tracks payload chunks for large metadata/event payload upload.

Columns:

1. `chunk_id` TEXT PRIMARY KEY
2. `job_id` TEXT NOT NULL
3. `chunk_index` INTEGER NOT NULL
4. `total_chunks` INTEGER NOT NULL
5. `byte_size` INTEGER NOT NULL
6. `content_hash` TEXT NOT NULL
7. `chunk_state` TEXT NOT NULL
- enum: `pending`, `uploaded`, `failed_retryable`, `failed_terminal`
8. `attempt_count` INTEGER NOT NULL DEFAULT 0
9. `last_error_code` TEXT NULL
10. `created_at` DATETIME NOT NULL
11. `updated_at` DATETIME NOT NULL

Indexes:

1. `(job_id, chunk_index)` UNIQUE
2. `(job_id, chunk_state)`

## 7. Commit Trigger Rules

A session commit job is created when all are true:

1. session is in `sealed` state.
2. no existing active job for that session in `commit_pending|committing|commit_failed_retryable`.
3. user has stopped session or explicit finalize trigger fired.

Allowed triggers:

1. `session_stopped`
2. `manual_retry`
3. `network_recovered`
4. `app_restart_recovery`

Forbidden:

1. periodic auto polling that creates duplicate jobs.
2. one job per entity model.

### 7.1 Deterministic identity + uniqueness lock

1. Job id is deterministic: `commit:{session_id}:{seal_version}`.
2. Active-job uniqueness is code-enforced inside one transaction:
   1. find existing active (`commit_pending|committing|commit_failed_retryable`) for same session;
   2. reuse/reactivate if same deterministic id;
   3. insert only when no active job conflicts.
3. New seal version may create a new deterministic job id.

## 8. Commit Phase Pipeline

The worker executes deterministic phases.

### Phase 1: `prepare`

1. Validate session is sealed.
2. Snapshot local journal rows for session (immutable view for this job).
3. Build media item queue.
4. Build metadata/event payload and chunk plan.
5. Ensure `idempotency_key` exists.
6. Idempotency key format is fixed:
- `finalize:{trip_local_id}:{session_id}:{seal_version}`
7. Snapshot is immutable per job once persisted.
8. Snapshot payload shape is contract-complete for ingest:
  - session metadata,
  - full event rows (resolver/binding/manual-lock fields included),
  - full media rows,
  - full route-point rows.

### Phase 2: `media_upload`

1. Upload media items first.
2. Each successful upload produces `upload_ref`.
3. Persist per-item state after each item.
4. Continue from remaining items on retry.

### Phase 3: `payload_upload`

1. Upload event/resolution/route/session metadata in chunked requests if size threshold exceeded.
2. Include media `upload_ref` links in payload rows.
3. Persist per-chunk state.

### Phase 4: `finalize_ack`

1. Send finalize request referencing all uploaded chunks and media refs.
2. If `stop_server_pending = true`, finalize includes stop-ack completion step.
3. Backend returns stable `session_commit_token` and accepted summary.
4. Mark job committed only after positive finalize ack.

### Phase 5: `done`

1. Set `job_state = committed`, `phase = done`, `completed_at` set.
2. Mark local journal rows for that session as committed.
3. Emit success signal for UI refresh.

## 9. Idempotency Contract

1. `idempotency_key` is generated once per job and reused on every retry.
2. Backend must treat duplicate finalize calls with same key as safe replay.
3. Client must not rotate idempotency key during retries.
4. Duplicate app restarts must resume same job row, not create new active job.
5. Stop command idempotency is seal-version scoped:
  - one `stop_client_event_id` is persisted for a given `(session_id, seal_version)`,
  - when `seal_version` increments, a new `stop_client_event_id` is generated.

## 10. Chunking Policy

1. Media uploads are itemized (one media item per upload unit).
2. Metadata payload uses chunking when serialized payload exceeds threshold.
3. Locked defaults:
- metadata chunk max: 256 KB.
- media upload chunking delegated to storage provider for large files.
4. Chunk table is source-of-truth for resume progress.

## 11. Retry Policy

V2 allows bounded, explicit retries only for commit lane.

1. Retryable failures:
- transient network errors
- 429 / 5xx responses
- provider timeout

2. Terminal failures:
- malformed payload validation errors after schema lock
- unauthorized/forbidden that requires re-auth
- missing local media file unrecoverable

3. Backoff schedule (locked):
- attempt 1 retry after 15s
- attempt 2 retry after 60s
- attempt 3 retry after 180s

4. Attempt cap:
- max 3 auto attempts before job remains `commit_failed_retryable` and waits for manual action.

5. Manual retry:
- user can trigger retry from live/editor sync panel.

### 11.1 Lease and takeover lock

1. Lease TTL is 5 minutes from **last heartbeat timestamp** (`execution_started_at`).
2. Heartbeat updates happen at phase boundaries and explicit lease refresh points.
3. Takeover is allowed only when lease is stale (`now - execution_started_at > 5 minutes`).

## 12. UI State Contract

UI must reflect commit state, not legacy entity-sync state.

States:

1. `commit_pending`: “Session saved locally. Waiting to upload.”
2. `committing`: progress summary (media X/Y, payload chunks A/B).
3. `commit_failed_retryable`: “Upload paused. Retry required.”
4. `committed`: “Session uploaded.”

Rules:

1. No generic “sync blocked” copy from V1 entity model.
2. Show actionable retry CTA on retryable failure.
3. Preserve local timeline visibility regardless of commit state.
4. Backend-ingest-off mode must not show false long-running “committing” state.
   1. Local `prepare` may run briefly.
   2. Steady-state remains `commit_pending` with upload-pending copy.

## 12.1 Backend-deferred execution policy (Phase 5)

1. With `enable_v2_backend_ingest=false`, worker runs local `prepare` only.
2. No network upload/finalize phases are executed in this phase.
3. Jobs remain `commit_pending` without retry churn.

## 13. Crash and Recovery Behavior

1. On app launch, worker scans jobs in `committing|commit_pending|commit_failed_retryable`.
2. Resume from last persisted phase and per-item/per-chunk progress.
3. Never restart from zero when resumable state exists.
4. If local media file missing at resume time, mark item terminal and surface explicit message.

## 14. Integrity Rules

1. Commit job cannot run for unsealed session.
2. `committed` requires successful finalize ack token.
3. All media refs included in payload must map to uploaded media rows or explicit skipped/terminal policy.
4. Session commit must include final resolver states and decision sources.
5. Manual-locked decisions must be preserved exactly as local truth.

## 15. Observability

Required counters:

1. `session_commit_job_created`
2. `session_commit_job_committed`
3. `session_commit_job_failed_retryable`
4. `session_commit_retry_count`
5. `session_commit_media_upload_failed`
6. `session_commit_payload_chunk_failed`

Required logs:

1. `session_commit_phase_started`
2. `session_commit_phase_completed`
3. `session_commit_retry_scheduled`
4. `session_commit_finalize_ack_received`

## 16. API Expectations (High Level)

Detailed request/response contracts belong to backend ingest spec, but worker requires:

1. Endpoint for media upload (resumable or itemized with refs).
2. Endpoint for chunked metadata ingest.
3. Endpoint for finalize ack with idempotency key.
4. Deterministic replay behavior for duplicate idempotency keys.

## 17. Migration and Cutover

1. Worker is enabled only for V2 sessions behind feature flag.
2. V1 entity sync workers remain disabled for V2 session entities.
3. Rollout stages:
- internal test
- staged beta
- full release
4. Decommission V1 live entity sync only after V2 soak passes.

## 18. Acceptance Criteria

This subsystem is complete only when:

1. Exactly one active commit job exists per sealed session.
2. Media + payload + finalize phases resume correctly after app restart.
3. No continuous background server flood is produced.
4. Retry behavior is bounded and user-actionable.
5. Session commit success reliably transitions local state to committed.
6. Failed commit does not hide local timeline data.

## 19. Locked Decisions

1. Commit states are strict and minimal:
  1. `commit_pending`
  2. `committing`
  3. `commit_failed_retryable`
  4. `committed`
2. Retry policy is fixed:
  1. max auto attempts = 3
  2. delay schedule = 15s, 60s, 180s
3. Idempotency key format is fixed:
  1. `finalize:{trip_local_id}:{session_id}:{seal_version}`

