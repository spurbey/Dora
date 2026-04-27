# Dora Backend API Reference

Last updated: 2026-04-03  
Source of truth: `backend/app/api/v1/*`, `backend/app/schemas/*`, `backend/app/services/*`, `backend/tests/*`

## 1) API Contract Overview

- Base URL (local): `http://localhost:8000`
- Version prefix: `/api/v1`
- OpenAPI UI: `/docs`
- OpenAPI JSON: `/openapi.json`
- Content type:
  - JSON for most endpoints
  - `multipart/form-data` for media binary uploads
- Auth:
  - All `/api/v1/*` routes require `Authorization: Bearer <supabase_jwt>`
  - JWT is verified against Supabase JWKS (`ES256`) in `backend/app/dependencies.py`
  - User records are auto-provisioned on first valid token if missing in `users`

## 2) Cross-Cutting API Rules

### 2.1 Idempotency (Live Tracking + Device Token APIs)

The following mutation endpoints require `X-Idempotency-Key`:

- `/trips/{trip_id}/tracking/start`
- `/trips/{trip_id}/tracking/pause`
- `/trips/{trip_id}/tracking/resume`
- `/trips/{trip_id}/tracking/stop`
- `/trips/{trip_id}/tracking/points:batch`
- `/trips/{trip_id}/tracking/events:batch`
- `/trips/{trip_id}/tracking/media:batch`
- `/checkins/{candidate_id}/confirm`
- `/checkins/{candidate_id}/reject`
- `/checkins/{candidate_id}/snooze`
- `/trips/{trip_id}/moments` (POST)
- `/moments/{moment_id}` (PATCH)
- `/trips/{trip_id}/auto-finalize/commit`
- `/notifications/device-tokens/register`
- `/notifications/device-tokens/deactivate`

Behavior:

- Same key + same normalized payload -> response replayed.
- Same key + different payload -> `409` with `detail.error_code = "idempotency_conflict"`.
- Replay signal:
  - Header `Idempotency-Replayed: true|false`
  - Some batch responses also include `idempotency_replayed` in response body.
- TTL: 72 hours (stored in `api_idempotency_records`).
- Path params are included in idempotency hash material to avoid collisions across resources.

### 2.2 Common Response and Error Patterns

- Success shapes are typed by Pydantic schemas in `backend/app/schemas/*`.
- Error detail may be:
  - string, for simple errors, or
  - object, for structured errors (`duplicate_job`, `export_precondition_failed`, `idempotency_conflict`, etc.).

### 2.3 Pagination and Filtering

Used by list endpoints:

- `page` is 1-indexed.
- `page_size` max is usually `100`.
- Typical response envelope:
  - `total`, `page`, `page_size`, `total_pages`.

### 2.4 Time and Coordinates

- Timestamps are ISO-8601 UTC.
- Coordinates are WGS84:
  - latitude `[-90, 90]`
  - longitude `[-180, 180]`

## 3) Health and Non-Versioned Endpoints

| Method | Path | Purpose | Auth |
|---|---|---|---|
| GET | `/` | API metadata (`message`, `version`, docs path) | No |
| GET | `/health` | Liveness probe | No |
| GET | `/ready` | Readiness probe (DB connectivity) | No |

## 4) Domain Endpoint Reference

## 4.1 Auth

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| GET | `/api/v1/auth/me` | Fetch current authenticated user + basic counts | Header: Bearer token | `200 MeResponse` | `401` |

`MeResponse` includes:

- `user` (`UserResponse`)
- `trip_count`
- `place_count`

## 4.2 Users

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| GET | `/api/v1/users/me` | Get current profile | Auth header | `200 UserResponse` | `401` |
| PATCH | `/api/v1/users/me` | Partial profile update | `UserUpdate` body | `200 UserResponse` | `400`, `401` |
| GET | `/api/v1/users/me/stats` | Dashboard metrics | Auth header | `200 UserStats` | `401` |
| GET | `/api/v1/users/me/profile` | Profile + stats in one call | Auth header | `200 UserProfileResponse` | `401` |
| DELETE | `/api/v1/users/me` | Permanent account deletion (Supabase auth + backend row) | Auth header | `204` | `401`, `502` |

`UserUpdate` key constraints:

- `username`: 3-50 chars, letters/numbers/underscore only.
- `bio`: max 500 chars.

## 4.3 Trips

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| POST | `/api/v1/trips` | Create trip | `TripCreate` | `201 TripResponse` | `400`, `401`, `403` |
| GET | `/api/v1/trips` | List owned trips or global public feed | Query params | `200 TripListResponse` | `401` |
| GET | `/api/v1/trips/{trip_id}` | Get trip details | Path `trip_id` | `200 TripResponse` | `401`, `403`, `404` |
| PATCH | `/api/v1/trips/{trip_id}` | Partial update | Path + `TripUpdate` | `200 TripResponse` | `400`, `401`, `403`, `404` |
| DELETE | `/api/v1/trips/{trip_id}` | Delete trip | Path | `204` | `401`, `403`, `404` |
| GET | `/api/v1/trips/{trip_id}/bounds` | Bounding box for map fitting | Path | `200` object or `null` | `401`, `403`, `404` |

Key query params on list:

- `page` (default `1`, min `1`)
- `page_size` (default `20`, max `100`)
- `visibility` (`private|unlisted|public`, optional)
- `public_only` (`false` default; when true returns global public feed)

## 4.4 Places

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| POST | `/api/v1/places` | Add place to trip | `PlaceCreate` | `201 PlaceResponse` | `400`, `401`, `403`, `404` |
| GET | `/api/v1/places` | List places in trip | Query: `trip_id` | `200 PlaceListResponse` | `401`, `403`, `404` |
| GET | `/api/v1/places/nearby` | Spatial search around point | Query: `lat`, `lng`, `radius` | `200 PlaceListResponse` | `400`, `401` |
| GET | `/api/v1/places/{place_id}` | Get place detail | Path | `200 PlaceResponse` | `401`, `403`, `404` |
| PATCH | `/api/v1/places/{place_id}` | Partial place update | Path + `PlaceUpdate` | `200 PlaceResponse` | `400`, `401`, `403`, `404` |
| DELETE | `/api/v1/places/{place_id}` | Delete place | Path | `204` | `401`, `403`, `404` |

Nearby query limits:

- `radius` defaults to `5.0` km.
- Min `0.1`, max `50.0`.

## 4.5 Media

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| POST | `/api/v1/media/upload` | Upload media to place | multipart form | `201 MediaResponse` | `400`, `401`, `403`, `404` |
| GET | `/api/v1/media/{media_id}` | Media detail + access check | Path | `200 MediaResponse` | `401`, `403`, `404` |
| DELETE | `/api/v1/media/{media_id}` | Delete media and storage object | Path | `204` | `401`, `403`, `404` |

Upload form fields:

- `file` (required)
- `trip_place_id` (required UUID)
- `caption` (optional)
- `taken_at` (optional ISO datetime)

## 4.6 Search

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| GET | `/api/v1/search/places` | Unified local + Foursquare search with ranking | Query params | `200 SearchResponse` | `400`, `401`, `500` |

Query params:

- `query` (1-100 chars)
- `lat`, `lng`
- `radius_km` (default `5.0`, min `0.1`, max `50`)
- `limit` (default `10`, max `50`)
- `debug` (include score breakdown)

## 4.7 Trip and Place Metadata

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| POST | `/api/v1/trips/{trip_id}/metadata` | Create trip metadata | `TripMetadataCreate` | `201 TripMetadataResponse` | `403`, `404`, `409`, `422` |
| GET | `/api/v1/trips/{trip_id}/metadata` | Read trip metadata | Path | `200 TripMetadataResponse` | `403`, `404` |
| PATCH | `/api/v1/trips/{trip_id}/metadata` | Update trip metadata | `TripMetadataUpdate` | `200 TripMetadataResponse` | `403`, `404`, `422` |
| DELETE | `/api/v1/trips/{trip_id}/metadata` | Delete trip metadata | Path | `204` | `403`, `404` |
| POST | `/api/v1/places/{place_id}/metadata` | Create place metadata | `PlaceMetadataCreate` | `201 PlaceMetadataResponse` | `403`, `404`, `409`, `422` |
| GET | `/api/v1/places/{place_id}/metadata` | Read place metadata | Path | `200 PlaceMetadataResponse` | `403`, `404` |
| PATCH | `/api/v1/places/{place_id}/metadata` | Update place metadata | `PlaceMetadataUpdate` | `200 PlaceMetadataResponse` | `403`, `404`, `422` |
| DELETE | `/api/v1/places/{place_id}/metadata` | Delete place metadata | Path | `204` | `403`, `404` |

## 4.8 Routes, Waypoints, Route Metadata

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| GET | `/api/v1/trips/{trip_id}/routes` | List routes in trip | Path | `200 RouteListResponse` | `403`, `404` |
| POST | `/api/v1/trips/{trip_id}/routes` | Create route | `RouteCreate` | `201 RouteResponse` | `400`, `403`, `404` |
| GET | `/api/v1/routes/{route_id}` | Route detail | Path | `200 RouteResponse` | `403`, `404` |
| PATCH | `/api/v1/routes/{route_id}` | Route update | `RouteUpdate` | `200 RouteResponse` | `400`, `403`, `404` |
| DELETE | `/api/v1/routes/{route_id}` | Delete route | Path | `204` | `403`, `404` |
| POST | `/api/v1/routes/{route_id}/waypoints` | Add waypoint | `WaypointCreate` | `201 WaypointResponse` | `403`, `404` |
| GET | `/api/v1/routes/{route_id}/waypoints` | List waypoints | Path | `200 WaypointListResponse` | `403`, `404` |
| PATCH | `/api/v1/waypoints/{waypoint_id}` | Update waypoint | `WaypointUpdate` | `200 WaypointResponse` | `403`, `404` |
| DELETE | `/api/v1/waypoints/{waypoint_id}` | Delete waypoint | Path | `204` | `403`, `404` |
| POST | `/api/v1/routes/generate` | Generate route via Mapbox Directions | `RouteGenerateRequest` | `200 RouteGenerateResponse` | `400`, `503` |
| POST | `/api/v1/routes/{route_id}/metadata` | Create route metadata | `RouteMetadataCreate` | `201 RouteMetadataResponse` | `403`, `404`, `409` |
| GET | `/api/v1/routes/{route_id}/metadata` | Get route metadata | Path | `200 RouteMetadataResponse` | `403`, `404` |
| PATCH | `/api/v1/routes/{route_id}/metadata` | Update route metadata | `RouteMetadataUpdate` | `200 RouteMetadataResponse` | `403`, `404` |
| DELETE | `/api/v1/routes/{route_id}/metadata` | Delete route metadata | Path | `204` | `403`, `404` |

## 4.9 Components (Unified Timeline View)

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| GET | `/api/v1/trips/{trip_id}/components` | List trip timeline (`place` + `route`) | Path | `200 TripComponentListResponse` | `403`, `404` |
| PATCH | `/api/v1/trips/{trip_id}/components/reorder` | Bulk reorder timeline components | `ComponentReorderRequest` | `200 ComponentReorderResponse` | `403`, `404`, `422` |
| GET | `/api/v1/trips/{trip_id}/components/{component_id}` | Detailed polymorphic component fetch | Path | `200 TripComponentDetailResponse` | `403`, `404` |

## 4.10 Exports

### Endpoints

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| POST | `/api/v1/trips/{trip_id}/export` | Create export job | `ExportCreateRequest` | `202 ExportCreateResponse` | `403`, `404`, `409`, `422`, `429`, `503` |
| GET | `/api/v1/exports/{job_id}` | Poll export status | Path | `200 ExportStatusResponse` | `403`, `404` |
| GET | `/api/v1/exports` | List user exports | Query params | `200 ExportJobListResponse` | `401` |
| POST | `/api/v1/exports/{job_id}/cancel` | Cancel export | Path | `200/202 ExportCancelResponse` | `403`, `404`, `409` |
| GET | `/api/v1/exports/{job_id}/download-url` | Resolve download URL | Path | `200 ExportDownloadUrlResponse` | `403`, `404`, `409`, `500` |
| GET | `/api/v1/exports/{job_id}/share` | Create/reuse share token URL | Path | `200 ExportShareUrlResponse` | `403`, `404`, `409` |
| GET | `/api/v1/shares/{token}` | Resolve share token to temporary redirect | Path token | `307 Redirect` | `403`, `404`, `409` |

### Export Request Contract

`ExportCreateRequest`:

- `template`: `classic|cinematic`
- `aspect_ratio`: `9:16|1:1|16:9`
- `duration_sec`: `1..60`
- `quality`: `480p|720p|1080p`
- `fps`: `1..60`

### Export Operational Semantics

- Duplicate active export detection:
  - same user + trip + snapshot hash + quality + aspect ratio
  - returns `409` with:
    - `detail.error = "duplicate_job"`
    - `detail.existing_job_id`
- Preconditions:
  - returns `422` with `detail.error = "export_precondition_failed"` and `reason`.
- Queue/plan limits:
  - `429` when per-user active cap reached.
  - `503` when global queue cap reached.
  - `403` when requested quality/duration exceeds free-tier limit.
- Cancel semantics:
  - `queued -> canceled` immediately (`200`)
  - `processing -> cancel_requested` (`202`)

## 4.11 Live Tracking

### Endpoint Matrix

| Method | Path | Scenario | Success | Common Errors |
|---|---|---|---|---|
| POST | `/api/v1/trips/{trip_id}/tracking/start` | Start tracking session | `200 TrackingSessionResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/tracking/pause` | Pause active session | `200 TrackingSessionResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/tracking/resume` | Resume paused session | `200 TrackingSessionResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/tracking/stop` | Stop session | `200 TrackingSessionResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/tracking/points:batch` | Batch ingest GPS points | `202 TrackingPointsBatchResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/tracking/events:batch` | Batch ingest live events | `202 TrackingEventsBatchResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/tracking/media:batch` | Batch ingest media references | `202 TrackingMediaBatchResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/tracking/media:upload` | Upload binary media blob | `201 TrackingMediaUploadResponse` | `400`, `401`, `403`, `404`, `503` |
| GET | `/api/v1/trips/{trip_id}/tracking/path` | Fetch cleaned path polyline points | `200 TrackingPathResponse` | `401`, `403`, `404` |
| GET | `/api/v1/trips/{trip_id}/checkins/pending` | Get pending/snoozed-expired candidates | `200 PendingCheckinsResponse` | `401`, `403`, `404` |
| POST | `/api/v1/checkins/{candidate_id}/confirm` | Confirm candidate, optionally override place | `200 CheckinActionResponse` | `400`, `401`, `403`, `404`, `409` |
| POST | `/api/v1/checkins/{candidate_id}/reject` | Reject candidate and set cooldown | `200 CheckinActionResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/checkins/{candidate_id}/snooze` | Snooze candidate until datetime | `200 CheckinActionResponse` | `401`, `403`, `404`, `409`, `422` |
| GET | `/api/v1/trips/{trip_id}/moments` | List moments | `200 MomentListResponse` | `401`, `403`, `404` |
| POST | `/api/v1/trips/{trip_id}/moments` | Create manual moment | `201 MomentResponse` | `401`, `403`, `404`, `409` |
| PATCH | `/api/v1/moments/{moment_id}` | Update moment, lock edited fields | `200 MomentResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/trips/{trip_id}/auto-finalize/commit` | Finalize trip after tracking | `200 AutoFinalizeCommitResponse` | `401`, `403`, `404`, `409` |
| POST | `/api/v1/notifications/device-tokens/register` | Register/upsert push token | `200 DeviceTokenActionResponse` | `401`, `409`, `500` |
| POST | `/api/v1/notifications/device-tokens/deactivate` | Deactivate push token | `200 DeviceTokenActionResponse` | `401`, `404`, `409` |

### Live Tracking Request Contract Highlights

- Session start:
  - `client_session_id`, `started_at`, optional `timezone`, `device_context`.
- Session transitions:
  - pause/resume/stop accept optional `session_id` and transition timestamps.
- Points batch:
  - `session_id`, `client_batch_id`, `sent_at`, `points[]`.
  - each point requires `point_id`, `recorded_at`, `latitude`, `longitude`.
- Events batch:
  - up to 250 events.
  - accepted event types: `note|warn|tag|photo|media`.
- Media batch:
  - up to 100 rows.
  - `media_type`: `photo|media`.
  - `bind_mode`: `place|route`.
  - `place` mode requires `trip_place_id`.
  - `route` mode requires `location`.

### Live Tracking Behavior Notes

- Path filtering drops:
  - invalid coordinates
  - poor accuracy (threshold from `TRACKING_POINT_MAX_ACCURACY_M`)
  - jitter points
  - physically implausible jumps/speeds
- Candidate actions update inbox notification state and append action events in `trip_tracking_notification_events`.
- Candidate reject applies cooldown (`REJECT_COOLDOWN_HOURS`, currently 24h).
- Moment updates lock edited fields in `locked_fields`; `auto` source can become `edited_auto`.

## 4.12 Compiled Projection

| Method | Path | Scenario | Request | Success | Common Errors |
|---|---|---|---|---|---|
| GET | `/api/v1/trips/{trip_id}/compiled/projection` | Compile or fetch storyline projection for editor | Path | `200 CompiledProjectionResponse` | `403`, `404`, `503` |
| POST | `/api/v1/trips/{trip_id}/compiled/rebind` | Manual bind/unbind of source item to place | `CompiledRebindRequest` | `200 CompiledProjectionResponse` | `403`, `404`, `422` |

`CompiledRebindRequest`:

- `source_kind`: `tracking_event|tracking_event_media`
- `action`: `bind|unbind`
- `source_event_id` or `source_media_id` (depends on `source_kind`)
- `trip_place_id` required when `action=bind`

`CompiledProjectionResponse` includes:

- `timeline_entries`
- `timeline_groups` (place vs on-route per day)
- `route_segments`
- `stats` (drift indicators and deltas)

## 5) High-Value Workflow Scenarios

## 5.1 Trip Authoring Flow

1. `POST /trips`
2. `POST /places` (repeat)
3. `POST /trips/{trip_id}/routes` and waypoints
4. `PATCH /trips/{trip_id}/components/reorder`
5. metadata endpoints for trip/place/route enrichment

## 5.2 Live Capture Flow (Mobile)

1. `POST /trips/{trip_id}/tracking/start` with `X-Idempotency-Key`
2. periodic `points:batch`, `events:batch`, `media:batch`
3. optional binary upload via `tracking/media:upload`
4. candidate moderation (`confirm|reject|snooze`)
5. `POST /trips/{trip_id}/tracking/stop`
6. `POST /trips/{trip_id}/auto-finalize/commit`
7. consume `/compiled/projection` for editor timeline

## 5.3 Export Flow

1. `POST /trips/{trip_id}/export`
2. Poll `GET /exports/{job_id}`
3. Optional `POST /exports/{job_id}/cancel`
4. On completion:
   - `GET /exports/{job_id}/download-url`
   - `GET /exports/{job_id}/share`
   - share consumer hits `/shares/{token}` and gets `307` redirect

## 6) Related Documents

- Database schema: `docs/schemas/database.md`
- Migration history and runbook: `docs/schemas/migrations.md`
- DB governance: `docs/db-schema-contract.md`
- Drift matrix: `docs/db-source-of-truth-matrix.md`
