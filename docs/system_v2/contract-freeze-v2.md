# Contract Freeze V2

Status: Locked baseline
Version: v2.2
Last updated: 2026-04-12

This file is the freeze-pack for implementation-critical constants and enums.

## 1. Lane Split (Final)

1. Command lane:
   - server-bound: `start`, `stop`
   - local-only: `pause`, `resume`
2. Local journal lane:
   - points/events/media/resolver local during active sessions
3. Commit/publish lane:
   - session-stop local staging (`session_commit_*` local artifacts)
   - server ingest on explicit `trip_publish` only

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

Rule: `on_route` is compiler/view bucket, not resolver truth.

## 3. Manual Lock Invariant (Final)

1. Any user decision sets `manual_lock=true`.
2. Auto resolver/reconcile must never overwrite locked state.

## 4. Resolver Provider Contract (Final)

1. Provider: ORS direct.
2. reverse + nearby calls in parallel.
3. timeout: 1500ms per call.
4. auto-bind requires:
   - score >= 0.60
   - top-second >= 0.05
   - distance <= 100m
5. ambiguous tie: `abs(top-second) <= 0.02` -> `review_required`.

## 5. Retry Constants (Final)

1. max auto attempts: 3
2. schedule: 15s, 60s, 180s

## 6. Idempotency Keys (Final)

### Command

1. start: `start:{trip_local_id}:{session_id}:{start_request_seq}`
2. stop: `stop:{trip_local_id}:{session_id}:{seal_version}`

### Publish

1. `publish:start:{trip_id}:{publish_job_id}:{snapshot_digest}`
2. `publish:media-complete:{trip_id}:{publish_job_id}:{media_manifest_digest}`
3. `publish:payload-chunk:{trip_id}:{publish_job_id}:{chunk_index}:{chunk_content_hash}`
4. `publish:commit:{trip_id}:{publish_job_id}:{snapshot_digest}:{accepted_chunks_digest}`

Mandatory rule: all mutating V2 endpoints require `Idempotency-Key`.

## 7. State Enums (Final)

Commit staging states:

1. `commit_pending`
2. `committing`
3. `commit_failed_retryable`
4. `committed`

Publish states:

1. `publish_pending`
2. `publishing`
3. `publish_failed_retryable`
4. `published`

No `cancelled` terminal state.

## 8. Publish Integrity and Limits (Final)

1. chunk size cap: `128 KiB`
2. total payload cap: `64 MiB`
3. server must recompute `chunk_content_hash`
4. chunk bounds: `0 <= chunk_index < total_chunks`, `total_chunks > 0`
5. immutable `media_manifest` from `publish:start` is source-of-truth for `publish:media-complete`

## 9. Publish Security and Replay (Final)

1. publish token bound to `user_id + trip_id + publish_job_id + schema_version`
2. token mismatch -> `403 token_scope_mismatch`
3. same key + same fingerprint -> replay-safe success
4. same key + different fingerprint -> `409 idempotency_conflict`

## 10. Projection and Read Bounds (Final)

1. sync compile guardrails:
   - `MAX_EVENTS=10000`
   - `MAX_MEDIA=2000`
   - `MAX_POINTS=200000`
   - `MAX_PROJECTION_COMPILE_MS=10000`
2. timeline API: cursor, `limit 1..200`, order `captured_at ASC, entry_id ASC`
3. route API: `limit_segments 1..20` (default 10), `max_points_returned=5000`, `is_simplified` flag when applied

## 11. Session Fields (Final)

`session_journal` required fields:

1. `control_state` (`planned|active|paused|sealed`)
2. `stop_server_pending`
3. `start_ack_at`
4. `stop_ack_at`
5. `seal_version`
6. `start_request_seq`

## 12. Source Specs

1. [Master Blueprint](./subsystem_specs/master-blueprint.md)
2. [Command Lane Spec](./subsystem_specs/command-lane-spec.md)
3. [Local Journal and Resolver Spec](./subsystem_specs/local-journal-and-resolver-spec.md)
4. [Session Commit Worker Spec](./subsystem_specs/session-commit-worker-spec.md)
5. [Trip Publish Spec](./subsystem_specs/trip-publish-spec.md)
6. [Backend Ingest and Projection Spec](./subsystem_specs/backend-ingest-and-projection-spec.md)
