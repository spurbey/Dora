# Contract Freeze V2

Status: Locked baseline
Version: v2.0
Last updated: 2026-04-10

This file is the single freeze-pack for implementation-critical constants and enums.

## 1. Lane Split (Final)

1. Command lane:
- server-bound: `start`, `stop`
- local-only: `pause`, `resume`
2. Local journal lane:
- points/events/media/resolver local during active session
3. Commit lane:
- `session_finalize`
- `trip_publish`

## 2. Resolver Truth (Final)

Resolver states:

1. `geotag_unresolved`
2. `review_required`
3. `place_bound`
4. `geotag_final`

Geotag final reason:

1. `user_keep_geotag`
2. `no_reliable_candidate`
3. `manual_add_cancelled`

Rule:

1. `on_route` is compiler/view bucket, not resolver truth.

## 3. Manual Lock Invariant (Final)

1. Any user decision sets `manual_lock = true`.
2. If `manual_lock = true`, resolver/reconcile must never overwrite:
- resolver state
- place binding
- decision source

## 4. Resolver Provider Contract (Final)

1. Provider: ORS direct from app.
2. Calls: reverse + nearby POI in parallel.
3. Timeout: 1500ms per call.
4. Auto-bind requires all:
- score >= 0.60
- unique top (`top-second >= 0.05`)
- distance <= 100m
5. Ambiguous rule:
- `abs(top-second) <= 0.02` => `review_required`
6. UI shows top 2-3 candidates.

## 5. Retry and Idempotency (Final)

Retry schedule:

1. max auto attempts = 3
2. delay schedule = 15s, 60s, 180s

After max attempts:

1. commit -> `commit_failed_retryable`
2. publish -> `publish_failed_retryable`
3. user manual retry required

Idempotency key formats:

1. finalize: `finalize:{trip_local_id}:{session_id}:{seal_version}`
2. publish: `publish:{trip_local_id}:{publish_job_id}:{payload_hash}`

Command idempotency key formats:

1. start: `start:{trip_local_id}:{session_id}:{start_request_seq}`
2. stop: `stop:{trip_local_id}:{session_id}:{seal_version}`

Command idempotency rule:

1. `start_request_seq` is persisted in `session_journal`.
2. Retries of the same start attempt must reuse the same `start_request_seq`.
3. `start_request_seq` increments only when user explicitly retries start after a terminal failure.

## 6. Commit and Publish States (Final)

Commit states:

1. `commit_pending`
2. `committing`
3. `commit_failed_retryable`
4. `committed`

Publish states:

1. `publish_pending`
2. `publishing`
3. `publish_failed_retryable`
4. `published`

No `cancelled` terminal state in V2.
If user aborts UI action, keep job in pending/retryable flow.

## 7. Session Control Fields (Final)

`session_journal` required fields:

1. `control_state` (`planned|active|paused|sealed`)
2. `stop_server_pending`
3. `start_ack_at`
4. `stop_ack_at`
5. `seal_version`
6. `start_request_seq`

## 8. Source Specs

1. [Master Blueprint](./subsystem_specs/master-blueprint.md)
2. [Command Lane Spec](./subsystem_specs/command-lane-spec.md)
3. [Local Journal and Resolver Spec](./subsystem_specs/local-journal-and-resolver-spec.md)
4. [Session Commit Worker Spec](./subsystem_specs/session-commit-worker-spec.md)
5. [Trip Publish Spec](./subsystem_specs/trip-publish-spec.md)
6. [Backend Ingest and Projection Spec](./subsystem_specs/backend-ingest-and-projection-spec.md)
