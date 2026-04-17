# Dora Database Schema Reference

Last updated: 2026-04-03  
Source of truth: `backend/app/models/*` + applied Alembic revisions

## 1) Platform and Storage Baseline

- Engine: PostgreSQL
- Spatial extension: PostGIS (`trip_places.location`)
- Key JSON-heavy tables use `JSONB`
- Migration framework: Alembic (`backend/alembic/versions`)

## 2) Domain Table Inventory

## 2.1 Identity and Core Trips

| Table | Purpose | Key Columns | Important Constraints/Indexes |
|---|---|---|---|
| `users` | User projection from Supabase auth | `id`, `email`, `username`, `is_premium`, `is_verified` | unique email/username indexes |
| `trips` | Top-level trip entities | `id`, `user_id`, `title`, `visibility`, `status`, `tracking_*` | visibility/status checks, `idx_trips_status` |
| `trip_places` | Places within trips | `trip_id`, `user_id`, `name`, `lat/lng`, `source`, `candidate_id` | PostGIS location, source check, `idx_trip_places_search`, source/candidate indexes |
| `media_files` | Uploaded place media | `trip_place_id`, `user_id`, `file_url`, `file_type` | FK cascade to place/user, per-place/user indexes |

## 2.2 Route and Timeline Authoring

| Table/View | Purpose | Key Columns | Important Constraints/Indexes |
|---|---|---|---|
| `routes` | Route segments between/around places | `trip_id`, `user_id`, `route_geojson`, `transport_mode`, `route_category`, `source` | transport/category/source checks, trip+order indexes |
| `waypoints` | Ordered points for a route | `route_id`, `trip_id`, `lat/lng`, `waypoint_type`, `order_in_route` | waypoint type + coordinate checks, `idx_waypoints_route` |
| `route_metadata` | Optional route enrichment | `route_id`, safety/scenic/cost fields | checks on rating/cost enums/ranges, highlights GIN index |
| `trip_metadata` | Optional trip enrichment | traveler/profile dimensions + `is_discoverable` | enum/range checks, GIN tags/focus indexes |
| `place_metadata` | Optional place enrichment | component/profile dimensions + `is_public` | enum/range checks, GIN tags indexes |
| `trip_components_view` | Unified timeline read model (`place` + `route`) | `component_type`, `order_in_trip` | view only; query with explicit `ORDER BY` |

## 2.3 Search Signal Collection

| Table | Purpose | Key Columns | Important Constraints/Indexes |
|---|---|---|---|
| `search_events` | Search telemetry | `user_id`, `query`, `lat/lng`, `results_count` | user + created indexes |
| `place_views` | Place view signal | `user_id`, `place_id`, `source` | user/place indexes |
| `place_saves` | Save/bookmark signal | `user_id`, `place_id` | user/place indexes |

## 2.4 Export System

| Table | Purpose | Key Columns | Important Constraints/Indexes |
|---|---|---|---|
| `export_jobs` | Export control plane state machine | `status`, `stage`, snapshot/config fields, output/error fields | status/stage/quality/aspect checks, queue indexes |
| `export_share_tokens` | Public-share indirection | `token`, `job_id`, `trip_id`, `expires_at`, `revoked_at` | unique token, active token lookup index |

## 2.5 Live Tracking and Inference

| Table | Purpose | Key Columns | Important Constraints/Indexes |
|---|---|---|---|
| `trip_tracking_sessions` | Tracking lifecycle sessions | `trip_id`, `user_id`, `client_session_id`, `state`, inference markers | unique active session partial index, state indexes |
| `trip_location_points` | Raw GPS points | `session_id`, `trip_id`, `point_id`, `recorded_at`, `lat/lng` | unique `(session_id, point_id)`, session/time and trip/time indexes |
| `trip_checkin_candidates` | Candidate inferred stops/places | `fingerprint`, `status`, `confidence`, `cooldown/snooze` | partial unique active fingerprint index |
| `trip_moments` | User-visible moments | `source`, `captured_at`, `media_refs`, `linked_trip_place_id` | source/confidence/coordinate checks |
| `trip_auto_entity_tombstones` | Cooldown for auto-generated entities | `entity_type`, `entity_fingerprint`, `cooldown_expires_at` | unique per trip/user/type/fingerprint |
| `api_idempotency_records` | Idempotency replay store | endpoint signature + idempotency key + request hash | unique `(user_id, endpoint_signature, idempotency_key)` |
| `trip_tracking_events` | Captured tracking events | `client_event_id`, `event_type`, `captured_at`, `payload` | unique trip/user/client_event, event type check |
| `trip_tracking_event_media` | Event-linked media metadata | `client_media_id`, `bind_mode`, `upload_ref`, anchors | bind-mode checks, unique trip/user/client_media |
| `trip_tracking_notifications` | Notification delivery state | `candidate_id`, `channel`, `delivery_state` | unique `(candidate_id, channel)`, delivery state checks |
| `trip_tracking_notification_events` | Append-only notification audit log | `notification_id`, `event_type`, `delivery_state` | event/channel checks + notification/user/candidate indexes |
| `user_device_tokens` | Push token lifecycle | `push_token`, `platform`, `is_active`, `last_seen_at` | globally unique `push_token` |

## 2.6 Compiled Projection

| Table | Purpose | Key Columns | Important Constraints/Indexes |
|---|---|---|---|
| `trip_compiled_projection_state` | Compiler state and drift baseline | `trip_id`, `compiler_version`, `dirty`, `stale`, counters | per-trip primary key |
| `trip_compiled_projection_items` | Compiled timeline entries | `entry_id`, `source_kind`, `source_id`, bind bucket, payload | unique `(trip_id, entry_id, compiler_version)` |
| `trip_compiled_route_segments` | Compiled route geometry segments | `segment_key`, `session_id`, distance/point counts, geometry | unique `(trip_id, segment_key, compiler_version)` |
| `trip_compiled_projection_overrides` | Manual bind/unbind overrides | `source_kind`, `source_id`, `action`, `trip_place_id` | unique source override per trip |

## 3) Relationship Map (High Level)

- `users` 1-N `trips`
- `trips` 1-N `trip_places`, `routes`, `trip_tracking_sessions`, `trip_tracking_events`, `trip_moments`, `export_jobs`
- `trip_places` 1-N `media_files`
- `routes` 1-N `waypoints`
- `trip_tracking_sessions` 1-N `trip_location_points`, optional links from `trip_tracking_events`
- `trip_tracking_events` 1-N `trip_tracking_event_media`
- `trip_checkin_candidates` optionally linked to `trip_places` via confirmation
- `export_jobs` 1-N `export_share_tokens`
- compiled projection tables keyed by `trip_id` and fed from tracking events/points/media

## 4) Data Integrity and Ownership Rules

- Owner checks in service layer enforce `user_id` scope for mutating APIs.
- Critical uniqueness:
  - one active tracking session per `(trip_id, user_id)`
  - one idempotency key per `(user_id, endpoint_signature)`
  - one tracking event per `(trip_id, user_id, client_event_id)`
  - one tracking media row per `(trip_id, user_id, client_media_id)`
  - one active check-in fingerprint per trip/user in pending/snoozed states
  - one globally unique push token (`user_device_tokens.push_token`)
- Most child entities are `ON DELETE CASCADE` from `trips` or `users`.

## 5) Operational Notes

- `trip_components_view` is a read model only; route queries must include explicit sorting.
- Live-tracking and compiled projection are eventually consistent by design:
  - ingestion marks projection state `dirty`
  - compiler updates materialized projection tables
- Export jobs are immutable by snapshot hash and model a queue/worker lifecycle.

## 6) Related Documentation

- API reference: `docs/apis/backend-api.md`
- Migration history and runbook: `docs/schemas/migrations.md`
- Alembic governance contract: `docs/db-schema-contract.md`
- Drift matrix and reconciliation notes: `docs/db-source-of-truth-matrix.md`
