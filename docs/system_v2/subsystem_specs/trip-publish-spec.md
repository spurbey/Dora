# Trip Publish Spec (V2)

Status: Draft for implementation lock
Version: v2.0
Last updated: 2026-04-10
Owner: Flutter editor team + backend publish team

## 1. Purpose

This spec defines how explicit trip save/upload works in Live System V2.

It covers:

1. Publish trigger rules from editor.
2. Local payload assembly from canonical journal and editorial state.
3. Publish job lifecycle and retry behavior.
4. Server interaction contract at high level.
5. Post-publish UX and consistency guarantees.

## 2. References

1. Master blueprint: [Master Blueprint](./master-blueprint.md)
2. Source of local truth: [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
3. Local timeline source: [Local Timeline Compiler Spec](./local-timeline-compiler-spec.md)
4. Session finalize dependency: [Session Commit Worker Spec](./session-commit-worker-spec.md)
5. Backend ingest/projection: [Backend Ingest and Projection Spec](./backend-ingest-and-projection-spec.md)
6. Subsystem index: [Subsystem Specs Index](./README.md)
7. System index: [System V2 Index](../README.md)

## 3. Depends On

1. Canonical local journal semantics and lock rules.
2. Session commit completion semantics for sealed sessions.
3. Backend publish API and idempotency behavior.

## 4. Used By

1. Editor save/upload UI.
2. Cross-device trip timeline visibility.
3. Long-term trip archival and server projection refresh.

## 5. Design Goals

1. Publish is explicit user intent only.
2. Publish payload is reproducible and idempotent.
3. No hidden background flood behavior.
4. Local edit/view remains intact regardless of publish failure.
5. Publish should preserve resolver/user decisions exactly.

## 6. Publish Trigger Rules

Publish job may be created when:

1. user explicitly taps `Save` or `Upload` in editor.
2. no active publish job is currently `publish_pending|publishing|publish_failed_retryable` for same trip.

Optional precondition policy (recommended):

1. all sealed sessions should be committed, or
2. publish payload includes any still-local sessions explicitly.

No automatic publish on app background/close.

## 7. Local Publish Job Table

### 7.1 `trip_publish_job`

Columns:

1. `publish_job_id` TEXT PRIMARY KEY
2. `trip_local_id` TEXT NOT NULL
3. `server_trip_id` TEXT NULL
4. `job_state` TEXT NOT NULL
- enum: `publish_pending`, `publishing`, `publish_failed_retryable`, `published`
5. `attempt_count` INTEGER NOT NULL DEFAULT 0
6. `next_retry_at` DATETIME NULL
7. `idempotency_key` TEXT NOT NULL
8. `payload_hash` TEXT NOT NULL
9. `last_error_code` TEXT NULL
10. `last_error_message` TEXT NULL
11. `created_at` DATETIME NOT NULL
12. `updated_at` DATETIME NOT NULL
13. `completed_at` DATETIME NULL

Indexes:

1. `(trip_local_id, job_state)`
2. `(job_state, next_retry_at)`

## 8. Publish Payload Canonical Contract

Publish payload is canonical raw + editorial metadata.

Top-level fields (logical):

1. `schema_version`
2. `client_job_id`
3. `idempotency_key`
4. `trip_local_id`
5. `server_trip_id` (if known)
6. `trip_editor_metadata` (title, description, tags, cover, ordering prefs)
7. `sessions[]`
8. `events[]`
9. `media[]`
10. `route_segments[]` or `route_points[]`
11. `resolver_decisions[]` (if not embedded in events)
12. `timeline_projection_snapshot` (optional non-canonical cache hint)
13. `payload_hash`

Rules:

1. Raw journal content is canonical.
2. Projection snapshot is optional optimization only.
3. Manual lock and decision_source must be preserved exactly.

## 9. Payload Assembly Rules

1. Source rows come from local journal canonical tables.
2. Include latest local editor metadata state.
3. Include resolver outcomes and lock markers.
4. For media:
- include server refs if already uploaded,
- include local refs only if publish endpoint supports deferred media stage.
5. Assembly must be deterministic:
- stable ordering by captured time + sequence IDs,
- stable object key ordering before hashing.

## 10. Publish Worker Lifecycle

### State flow

1. `publish_pending` -> `publishing` -> `published`
2. On transient failure: `publish_failed_retryable`
3. If user aborts UI action, keep job in `publish_pending` or `publish_failed_retryable` flow.

### Attempt behavior

1. Payload is snapshot-locked at job creation for deterministic replay.
2. Retries reuse the same payload hash and idempotency key.
3. If user edits trip after a failed publish, create a new publish job.

## 11. Idempotency and Conflict Rules

1. Same `idempotency_key` for same payload replay must be safe.
2. Backend should reject same idempotency key with different payload hash as conflict.
3. Client must surface conflict clearly and offer “create new publish attempt”.
4. Idempotency key format is fixed:
- `publish:{trip_local_id}:{publish_job_id}:{payload_hash}`

## 12. Retry Policy

Publish allows bounded retries only.

1. Retryable failures:
- network transient
- 429/5xx
- upstream timeout

2. Terminal failures:
- schema validation failure
- auth/permission failure
- permanent payload conflict

3. Backoff schedule (locked):
- attempt 1 retry after 15s
- attempt 2 retry after 60s
- attempt 3 retry after 180s

4. Attempt cap:
- max 3 auto attempts before remaining in `publish_failed_retryable`.

5. UI:
- `publish_failed_retryable` must show explicit retry CTA.

## 13. Editor UX Contract

1. Editor should show publish state chip:
- `Not published`
- `Publishing`
- `Publish failed - retry`
- `Published`

2. Publish action must not block local timeline editing.
3. On publish success:
- show success feedback,
- optionally show server version metadata.
4. On publish failure:
- preserve all local changes,
- no data rollback.

## 14. Server Response Handling

Expected response fields (logical):

1. `publish_status`
2. `trip_server_version`
3. `projection_refresh_token`
4. `accepted_counts`
5. `warnings[]` (optional)

On success:

1. mark job `published`.
2. store server version metadata locally.

On conflict/error:

1. keep local data untouched.
2. store structured error code for actionable UI.

## 15. Consistency Guarantees

1. Local timeline remains source of runtime view on current device.
2. Publish success guarantees server canonical snapshot is updated.
3. Cross-device should read updated server projection after publish pipeline completion.

## 16. Observability

Required metrics:

1. `trip_publish_job_created`
2. `trip_publish_job_published`
3. `trip_publish_job_failed_retryable`
4. `trip_publish_retry_count`
5. `trip_publish_latency_ms`

Required logs:

1. `trip_publish_started`
2. `trip_publish_payload_hashed`
3. `trip_publish_completed`
4. `trip_publish_failed`

## 17. Migration and Rollout

1. Enable publish worker only for V2 trips behind feature flag.
2. Keep legacy publish path for V1 trips during transition.
3. Add compare-mode diagnostics for first staged releases.
4. Retire legacy path after V2 stability gates pass.

## 18. Acceptance Criteria

This subsystem is complete only when:

1. Publish can be executed repeatedly without duplicate corruption.
2. Payload includes full resolver decision semantics and manual locks.
3. Publish failure never loses local timeline data.
4. Retry behavior is bounded and explicit.
5. Cross-device reflects published timeline after server projection update.

## 19. Locked Decisions

1. Publish states are strict and minimal:
  1. `publish_pending`
  2. `publishing`
  3. `publish_failed_retryable`
  4. `published`
2. Retry policy is fixed:
  1. max auto attempts = 3
  2. delay schedule = 15s, 60s, 180s
3. Publish retry semantics are snapshot-locked per job.
4. Idempotency key format is fixed:
  1. `publish:{trip_local_id}:{publish_job_id}:{payload_hash}`

