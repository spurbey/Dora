# Backend Ingest and Projection Spec (V2)

Status: Draft for implementation lock
Version: v2.2
Last updated: 2026-04-12
Owner: Backend API + compiler team

## 1. Purpose

This spec defines the Phase 6 backend lane for V2.

Scope:

1. command endpoints (`start/stop`),
2. publish-only data ingest,
3. canonical raw storage,
4. synchronous projection compile,
5. bounded read APIs,
6. idempotency/replay/error contracts.

Out of scope for this phase:

1. session-finalize ingest endpoints,
2. publish incremental-delta protocol,
3. advisory lane backend.

## 2. Core Contract

1. V2 data-plane ingest happens only on explicit publish.
2. V2 requests must never silently fall back into V1 ingest/projection services.
3. Raw rows are canonical truth; projection rows are derived.
4. One active publish manifest per `trip_id` by status (`started|failed_retryable`).

## 3. Endpoint Set (Canonical)

### 3.1 Commands

1. `POST /api/v2/trips/{trip_id}/sessions:start`
2. `POST /api/v2/trips/{trip_id}/sessions/{client_session_id}:stop`

### 3.2 Publish ingest

1. `POST /api/v2/trips/{trip_id}/publish:start`
2. `POST /api/v2/trips/{trip_id}/publish:media-complete`
3. `POST /api/v2/trips/{trip_id}/publish:payload-chunk`
4. `POST /api/v2/trips/{trip_id}/publish:commit`

### 3.3 Read APIs

1. `GET /api/v2/trips/{trip_id}/timeline`
2. `GET /api/v2/trips/{trip_id}/route`

## 4. Request Preconditions and Eligibility

Mutating V2 requests require:

1. authenticated user,
2. trip ownership/permission,
3. trip V2 capability,
4. supported `schema_version`,
5. required fields for endpoint,
6. `Idempotency-Key` header.

Response mapping:

1. trip not V2-enabled -> `409`.
2. unsupported schema -> `422` (terminal).
3. missing required fields -> `400` (terminal).
4. unknown trip/session/job -> `404`.
5. same key + different fingerprint -> `409 idempotency_conflict` (terminal).
6. token scope mismatch -> `403 token_scope_mismatch`.

## 5. Stop Contract

Canonical identity is path `client_session_id`.

Stop body:

1. `seal_version`
2. `stop_client_event_id`
3. `stopped_at`
4. `reason` (optional opaque string)

Rules:

1. `stop_client_event_id` is scoped to `(client_session_id, seal_version)`.
2. Optional body echo of `client_session_id` is audit-only; mismatch with path -> `400`.

## 6. Canonical Tables

### 6.1 Raw tables

1. `trip_session_raw`
2. `trip_event_raw`
3. `trip_media_raw`
4. `trip_route_raw_point`
5. `trip_publish_manifest`

### 6.2 Derived tables

1. `trip_timeline_projection_v2`
2. `trip_route_projection_v2`

### 6.3 Required constraints

1. `(trip_server_id, client_session_id)` unique on session raw.
2. `(trip_server_id, client_event_id)` unique on event raw.
3. `(trip_server_id, client_media_id)` unique on media raw.
4. `(trip_server_id, operation_kind, idempotency_key)` unique on manifest.
5. FKs from event/media/point to session raw.
6. Timeline read index `(trip_server_id, captured_at, entry_id)`.

## 7. Publish Flow

### 7.1 `publish:start`

1. validate eligibility and ownership,
2. enforce active publish uniqueness by status,
3. persist immutable snapshot metadata:
   - `publish_job_id`
   - `snapshot_digest`
   - `media_manifest`
   - `media_manifest_digest`
   - summary counts/hash
4. persist request fingerprint,
5. return `publish_token` + storage upload instructions.

Snapshot freeze rule: commit must use the frozen manifest/chunk set from this step.

### 7.2 `publish:media-complete`

1. request must include `publish_token`, `client_job_id`, `schema_version`,
2. verify token scope binds to `user_id + trip_id + client_job_id + schema_version`,
3. verify uploads against frozen media manifest only,
4. verify object existence + ownership via storage adapter,
5. reject if any required media invalid/missing (all-or-nothing policy).

### 7.3 `publish:payload-chunk`

1. request must include `publish_token`, `client_job_id`, `schema_version`,
2. verify token scope binds to `user_id + trip_id + client_job_id + schema_version`,
3. accept `chunk_index`, `total_chunks`, `chunk_content_hash`, `chunk_json`,
4. enforce chunk size `<= 128 KiB`,
5. enforce total payload cap `<= 64 MiB`,
6. validate `0 <= chunk_index < total_chunks`,
7. recompute `chunk_content_hash` server-side and reject mismatch,
8. store/reassemble using streaming or temp storage (no full-memory requirement).

### 7.4 `publish:commit`

1. request must include `publish_token`, `client_job_id`, `schema_version`,
2. validate token scope + frozen manifest + chunk completeness,
3. perform raw ingest transaction,
4. perform projection compile transaction,
5. reconcile pending stop ack before final success,
6. mark manifest `committed` only after projection and stop reconciliation succeed.

Replay checkpoint rule:

1. if phase is `raw_ingest_completed`, replay skips raw reinsert,
2. reruns projection + finalization only.

## 8. Manifest Model

### 8.1 Status enum

1. `started`
2. `failed_retryable`
3. `failed_terminal`
4. `idempotency_conflict`
5. `committed`

### 8.2 Phase enum

1. `start_received`
2. `media_verified`
3. `chunks_complete`
4. `raw_ingest_completed`
5. `projection_compiled`
6. `finalized`

Rules:

1. active publish uniqueness is based on status only (`started|failed_retryable`).
2. `committed` requires `phase=finalized`.
3. terminal states have no outgoing transitions.

## 9. Idempotency and Fingerprints

1. `Idempotency-Key` required on all mutating endpoints.
2. Fingerprint algorithm: SHA-256 hex over canonical JSON.
3. Same key + same fingerprint: replay accepted with stable response.
4. Same key + different fingerprint: `409 idempotency_conflict`.

Locked publish key formats:

1. `publish:start:{trip_id}:{publish_job_id}:{snapshot_digest}`
2. `publish:media-complete:{trip_id}:{publish_job_id}:{media_manifest_digest}`
3. `publish:payload-chunk:{trip_id}:{publish_job_id}:{chunk_index}:{chunk_content_hash}`
4. `publish:commit:{trip_id}:{publish_job_id}:{snapshot_digest}:{accepted_chunks_digest}`

## 10. Error Classification

Terminal:

1. `400` missing/invalid required fields,
2. `403 token_scope_mismatch`,
3. `404` not found,
4. `409 active_publish_exists|idempotency_conflict`,
5. `413 payload/chunk too large`,
6. `422 schema/hash/index validation failure`.

Retryable:

1. `503` projection timeout or transient dependency failure,
2. transient `5xx` infra/storage errors.

## 11. Projection and Read Contracts

### 11.1 Synchronous projection guardrails

1. `MAX_EVENTS=10000`
2. `MAX_MEDIA=2000`
3. `MAX_POINTS=200000`
4. `MAX_PROJECTION_COMPILE_MS=10000`

Implementation note: timeout guard covers full compile path, including route projection.

Performance note: compile must pre-group points by session once; avoid O(sessions x points) rescans.

### 11.2 Timeline read

1. cursor pagination,
2. request `limit 1..200`,
3. stable order `captured_at ASC, entry_id ASC`,
4. response includes `entries`, `next_cursor`, `has_more`, `compiled_at`, `compiler_version`.

### 11.3 Route read

1. bounded only,
2. `limit_segments 1..20` (default 10),
3. `max_points_returned=5000` after simplification,
4. include `is_simplified=true` when simplification applied,
5. never dump unbounded raw points.

## 12. Storage Adapter Contract

1. backend issues upload targets,
2. backend verifies uploaded refs,
3. canonical media identity is neutral `storage_ref`,
4. provider-specific URL/path semantics are not canonical data.

## 13. Observability

Required logs:

1. `publish_start_received`
2. `publish_media_verified`
3. `publish_chunk_accepted`
4. `publish_raw_ingest_completed`
5. `publish_projection_compiled`
6. `publish_committed`

Required counters:

1. publish attempts/success/retryable/terminal,
2. idempotency replay/conflict,
3. projection duration and timeout rate,
4. read p95 and error rates.

## 14. Acceptance Criteria

1. publish flow is idempotent and replay-safe,
2. no duplicate raw rows on replay,
3. stop reconciliation enforced before commit success,
4. projection/read contracts remain bounded,
5. V2 endpoints never invoke V1 ingest/projection paths.
