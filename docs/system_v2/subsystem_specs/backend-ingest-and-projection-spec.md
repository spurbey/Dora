# Backend Ingest and Projection Spec (V2)

Status: Draft for implementation lock
Version: v2.0
Last updated: 2026-04-10
Owner: Backend API + compiler team

## 1. Purpose

This spec defines the backend contract for Live System V2.

It covers:

1. Raw canonical ingest model.
2. Session finalize ingest APIs.
3. Trip publish ingest APIs.
4. Server-side timeline projection compilation.
5. Cross-device read APIs.
6. Idempotency, reliability, and load controls.

## 2. References

1. Master blueprint: [Master Blueprint](./master-blueprint.md)
2. Command behavior source: [Command Lane Spec](./command-lane-spec.md)
3. Local input source: [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
4. Commit producer: [Session Commit Worker Spec](./session-commit-worker-spec.md)
5. Local compiler model: [Local Timeline Compiler Spec](./local-timeline-compiler-spec.md)
6. Subsystem index: [Subsystem Specs Index](./README.md)
7. System index: [System V2 Index](../README.md)

## 3. Depends On

1. V2 local journal and resolver state/decision semantics.
2. V2 session commit worker phase model and idempotency behavior.

## 4. Used By

1. `trip-publish-spec.md`
2. Mobile cross-device timeline fetch flows.
3. Admin/ops diagnostics and replay tooling.

## 5. Backend Responsibilities

1. Persist raw session and publish payloads as canonical truth.
2. Guarantee idempotent commit/publish replay behavior.
3. Materialize compiled timeline projection for fast read.
4. Preserve user manual decisions and lock semantics.
5. Expose bounded, query-efficient read endpoints.

## 6. Canonical Storage Policy

1. Canonical truth is raw journal data plus final resolver/user decisions.
2. Compiled timeline projection is a derived read model.
3. Compiler outputs can be regenerated from canonical raw data.

## 7. Core Backend Tables

Names are logical and may map to physical names by backend conventions.

### 7.1 `trip_session_raw`

Columns:

1. `session_server_id` UUID PRIMARY KEY
2. `trip_server_id` UUID NOT NULL
3. `client_session_id` TEXT NOT NULL
4. `device_id` TEXT NOT NULL
5. `started_at` TIMESTAMP NOT NULL
6. `ended_at` TIMESTAMP NULL
7. `status` TEXT NOT NULL
8. `commit_token` TEXT NULL
9. `created_at` TIMESTAMP NOT NULL
10. `updated_at` TIMESTAMP NOT NULL

Indexes:

1. `(trip_server_id, started_at)`
2. `(trip_server_id, client_session_id)` UNIQUE

### 7.2 `trip_event_raw`

Columns:

1. `event_server_id` UUID PRIMARY KEY
2. `trip_server_id` UUID NOT NULL
3. `session_server_id` UUID NOT NULL
4. `client_event_id` TEXT NOT NULL
5. `event_type` TEXT NOT NULL
6. `captured_at` TIMESTAMP NOT NULL
7. `latitude` DOUBLE PRECISION NOT NULL
8. `longitude` DOUBLE PRECISION NOT NULL
9. `resolver_state` TEXT NOT NULL
10. `decision_source` TEXT NULL
11. `manual_lock` BOOLEAN NOT NULL DEFAULT FALSE
12. `place_bind_kind` TEXT NULL
13. `place_bind_id` TEXT NULL
14. `place_bind_name` TEXT NULL
15. `payload_json` JSONB NULL
16. `created_at` TIMESTAMP NOT NULL
17. `updated_at` TIMESTAMP NOT NULL

Indexes:

1. `(trip_server_id, captured_at)`
2. `(trip_server_id, resolver_state, captured_at)`
3. `(trip_server_id, client_event_id)` UNIQUE

### 7.3 `trip_media_raw`

Columns:

1. `media_server_id` UUID PRIMARY KEY
2. `trip_server_id` UUID NOT NULL
3. `session_server_id` UUID NOT NULL
4. `event_server_id` UUID NOT NULL
5. `client_media_id` TEXT NOT NULL
6. `captured_at` TIMESTAMP NOT NULL
7. `media_type` TEXT NOT NULL
8. `storage_ref` TEXT NOT NULL
9. `mime_type` TEXT NULL
10. `bytes_size` BIGINT NULL
11. `width_px` INTEGER NULL
12. `height_px` INTEGER NULL
13. `duration_ms` INTEGER NULL
14. `created_at` TIMESTAMP NOT NULL
15. `updated_at` TIMESTAMP NOT NULL

Indexes:

1. `(trip_server_id, captured_at)`
2. `(event_server_id)`
3. `(trip_server_id, client_media_id)` UNIQUE

### 7.4 `trip_route_raw_point` or `trip_route_raw_segment`

Implementation may store points or compressed segments. Must support recompile.

Minimum columns:

1. `trip_server_id` UUID NOT NULL
2. `session_server_id` UUID NOT NULL
3. `captured_at` TIMESTAMP NOT NULL
4. `latitude` DOUBLE PRECISION NOT NULL
5. `longitude` DOUBLE PRECISION NOT NULL
6. `accuracy_m` DOUBLE PRECISION NULL
7. `point_seq` INTEGER NOT NULL

Indexes:

1. `(session_server_id, point_seq)`
2. `(trip_server_id, captured_at)`

### 7.5 `trip_commit_manifest`

Tracks finalize and publish idempotent transactions.

Columns:

1. `manifest_id` UUID PRIMARY KEY
2. `trip_server_id` UUID NOT NULL
3. `client_job_id` TEXT NOT NULL
4. `idempotency_key` TEXT NOT NULL
5. `operation_kind` TEXT NOT NULL
- enum: `session_finalize`, `trip_publish`
6. `status` TEXT NOT NULL
- enum: `started`, `media_uploaded`, `payload_uploaded`, `finalized`, `failed`
7. `request_fingerprint` TEXT NOT NULL
8. `response_fingerprint` TEXT NULL
9. `error_code` TEXT NULL
10. `created_at` TIMESTAMP NOT NULL
11. `updated_at` TIMESTAMP NOT NULL

Indexes:

1. `(trip_server_id, idempotency_key, operation_kind)` UNIQUE
2. `(trip_server_id, created_at DESC)`

### 7.6 `trip_timeline_projection`

Derived read model consumed by remote devices.

Columns:

1. `projection_id` UUID PRIMARY KEY
2. `trip_server_id` UUID NOT NULL
3. `entry_kind` TEXT NOT NULL
- enum: `event`, `media`
4. `source_server_id` UUID NOT NULL
5. `captured_at` TIMESTAMP NOT NULL
6. `bucket_type` TEXT NOT NULL
- enum: `place`, `on_route`, `needs_review`
7. `place_bind_name` TEXT NULL
8. `place_bind_id` TEXT NULL
9. `decision_source` TEXT NULL
10. `manual_lock` BOOLEAN NOT NULL
11. `anchor_latitude` DOUBLE PRECISION NOT NULL
12. `anchor_longitude` DOUBLE PRECISION NOT NULL
13. `route_segment_key` TEXT NULL
14. `route_distance_m` DOUBLE PRECISION NULL
15. `title` TEXT NOT NULL
16. `subtitle` TEXT NULL
17. `render_payload_json` JSONB NULL
18. `compiler_version` INTEGER NOT NULL
19. `compiled_at` TIMESTAMP NOT NULL

Indexes:

1. `(trip_server_id, captured_at DESC)`
2. `(trip_server_id, bucket_type, captured_at DESC)`
3. `(trip_server_id, entry_kind, source_server_id)` UNIQUE

## 8. Command and Finalize API Contracts (High Level)

### 8.0 Command API Contract

Server-bound command endpoints for V2:

1. `POST /api/v2/trips/{trip_id}/sessions:start`
2. `POST /api/v2/trips/{trip_id}/sessions/{client_session_id}:stop`

Rules:

1. `start` is online-required and fail-fast.
2. `stop` is idempotent and may be acknowledged during finalize if stop was pending offline.

### 8.1 Start finalize

`POST /api/v2/trips/{trip_id}/sessions/{client_session_id}/finalize:start`

Request:

1. `client_job_id`
2. `idempotency_key`
3. `session_summary` (counts/hash/timestamps)
4. `media_manifest` (client media ids + metadata)

Response:

1. `session_commit_token`
2. upload instructions/presigned refs for media if needed
3. accepted manifest summary

### 8.2 Upload media

Client uploads media and confirms refs.

`POST /api/v2/trips/{trip_id}/sessions/{client_session_id}/finalize:media-complete`

### 8.3 Upload payload chunks

`POST /api/v2/trips/{trip_id}/sessions/{client_session_id}/finalize:payload-chunk`

Request includes:

1. `chunk_index`
2. `total_chunks`
3. `content_hash`
4. `chunk_json`

### 8.4 Finalize ack

`POST /api/v2/trips/{trip_id}/sessions/{client_session_id}/finalize:commit`

Response:

1. `commit_status`
2. `session_server_id`
3. accepted counts and checksum summary

## 9. Trip Publish API Contract (High Level)

`POST /api/v2/trips/{trip_id}/publish`

Request includes:

1. `client_job_id`
2. `idempotency_key`
3. optional editorial metadata
4. raw journal references or raw payload pack
5. publish intent flags

Response includes:

1. publish status
2. projection rebuild token/version
3. resulting trip version metadata

## 10. Idempotency and Replay Rules

1. Same `idempotency_key` + `operation_kind` + `trip_id` must be replay-safe.
2. Duplicate requests return consistent accepted response.
3. Request fingerprint mismatch under same key must reject with deterministic conflict error.
4. Partial progress is tracked in `trip_commit_manifest` and resumable.

## 11. Projection Compiler Rules (Server)

Server compiler must mirror local semantic outcomes.

1. Manual lock has highest precedence.
2. Bucket mapping uses resolver state from canonical raw rows.
3. Compiler is pure derived process and must not mutate raw source semantics.
4. Compiler version is persisted per projection row.
5. Recompile can be triggered by:
- finalize commit success
- publish success
- explicit admin/maintenance recompile

## 12. Cross-Device Read APIs

### 12.1 Timeline projection read

`GET /api/v2/trips/{trip_id}/timeline`

Response:

1. timeline entries sorted by captured time
2. bucket type and place/on-route metadata
3. projection version and compiled timestamp

### 12.2 Route projection read

`GET /api/v2/trips/{trip_id}/route`

Response:

1. route segments/polyline for trip timeline map
2. segment metadata

### 12.3 Unresolved summary read (optional)

`GET /api/v2/trips/{trip_id}/timeline/unresolved-summary`

For remote display parity where needed.

## 13. Error Model

Stable error categories:

1. `invalid_payload`
2. `idempotency_conflict`
3. `auth_forbidden`
4. `trip_not_found`
5. `session_not_found`
6. `media_ref_invalid`
7. `chunk_out_of_order`
8. `transient_upstream_failure`

Responses must include machine-readable code and user-safe message.

## 14. Load and Scalability Controls

1. No server endpoint should assume high-frequency heartbeat writes.
2. Ingest endpoints are optimized for bounded burst at stop/publish milestones.
3. Chunking limits must protect request size and DB transaction boundaries.
4. Projection reads must be index-backed and paginatable.

## 15. Security Baseline

1. Authenticate all finalize/publish/read endpoints.
2. Enforce trip ownership and role checks.
3. Validate upload refs ownership before linking media rows.
4. Sanitize JSON payloads and enforce schema version constraints.

## 16. Versioning and Compatibility

1. Every finalize/publish request includes `schema_version`.
2. Backend supports rolling compatibility for staged app rollout.
3. Compiler version increments must be traceable.

## 17. Migration and Rollout

1. Deploy V2 ingest and projection tables/endpoints first.
2. Keep V1 APIs untouched during migration period.
3. Enable V2 app clients behind feature flag.
4. Compare V2 ingestion metrics and projection correctness before broad rollout.

## 18. Observability

Required metrics:

1. finalize start rate
2. finalize success rate
3. finalize retry and failure rates
4. publish success rate
5. projection compile duration
6. timeline read latency and error rate

Required logs:

1. `finalize_start_received`
2. `finalize_media_completed`
3. `finalize_payload_chunk_accepted`
4. `finalize_committed`
5. `publish_committed`
6. `projection_compile_completed`

## 19. Acceptance Criteria

This subsystem is complete only when:

1. Session finalize is idempotent and resumable.
2. Raw canonical rows fully preserve resolver/user decision semantics.
3. Server projection reproduces timeline correctly on a new device.
4. Read APIs are stable and index-efficient.
5. No high-frequency write flood pattern exists in backend logs.

## 20. Locked and Remaining Decisions

Locked:

1. Finalize metadata chunk max size = 256 KB.
2. Publish endpoint accepts full raw snapshot payload (canonical raw contract).
3. Retry schedule is fixed client-side at 15s, 60s, 180s with max 3 auto attempts.

Remaining:

1. All-or-nothing vs partial-accept policy for media issues.
2. Projection freshness SLA after finalize/publish.
3. Retention policy for raw point-level route data.

