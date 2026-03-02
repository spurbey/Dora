# PHASE 6 PRD: VIDEO EXPORT PLATFORM (REMOTION + DURABLE JOBS)

Last Updated: 2026-03-02
Owner: TBD
Status: Active - 6C in progress (6A and 6B complete)

---

## 1. Goal

Build a production-grade video export system where Flutter is the control UI and backend executes durable async exports using Remotion rendering (local first, AWS Lambda next), without regressing existing editor, media queue, and sync flows.

The system must be:
- **Scalable**: from a single VPS local render to concurrent Lambda cloud rendering.
- **Cost-effective**: deduplication, tier-gated quality caps, S3 lifecycle rules, and Lambda tuning prevent runaway costs.
- **Resilient**: crash/restart of any process must not lose jobs or produce duplicate artifacts.

---

## 2. Reality Snapshot (Current Repository State)

This PRD is anchored to what is currently implemented:

- Export entry points exist in UI, but export is not implemented:
  - `flutter/lib/features/trips/presentation/widgets/trip_context_menu.dart` ("Export Video")
  - `flutter/lib/features/trips/presentation/screens/my_trips_screen.dart` (`_showToast('Export studio coming soon')`)
  - `flutter/lib/features/create/presentation/screens/editor_screen.dart` (`onExport: () {}`)
  - `flutter/lib/features/create/presentation/widgets/editor_header.dart`
- Feature flag exists but no export pipeline behind it:
  - `flutter/lib/core/config/feature_flags.dart` (`enableExport`)
- Backend has no export router/service/worker:
  - `backend/app/main.py` registers auth/users/trips/places/media/search/metadata/routes/components only.
- Backend currently supports photos/media metadata and trip timeline primitives:
  - `backend/app/api/v1/media.py`
  - `backend/app/services/media_service.py`
  - `backend/app/api/v1/components.py`
  - `backend/app/models/trip_component.py`
  - `backend/app/models/route.py`
- Queue architecture already exists in Flutter and should be reused as pattern:
  - `flutter/lib/core/media/upload_queue_worker.dart`
  - `flutter/lib/core/media/media_queue_bootstrap.dart`
  - `flutter/lib/core/sync/entity_sync_worker.dart`
  - `flutter/lib/core/sync/entity_sync_bootstrap.dart`
- Export UX contract/design is already documented:
  - `flutter/docs/screens/screen6-12.md` (Screen 10/11/12)
  - `flutter/docs/architecture.md` (export abstractions, dark export studio concept)
- There is no Remotion service or FFmpeg export worker currently in repo.

### 2.1 Implementation Addendum (2026-03-01)

The bullet list above reflects the original pre-implementation baseline. Current committed state now includes:

- 6A completed:
  - backend export endpoints, schemas, migration, worker skeleton
  - Flutter export feature wiring and pre-submit guards
  - contract freeze artifacts
- `dora_api` export client regeneration and Flutter `ExportsApi` wiring completed (`a536af9`, `e419335`).
- 6B-1 completed:
  - local renderer service scaffold
  - real Remotion render pipeline in `video-renderer` with `Classic` composition
  - backend local renderer adapter and renderer lifecycle fix for worker loop
- 6B-2 completed:
  - worker stage helpers for snapshot-size defense, `asset_fetch`, and upload/finalize paths (`2737880`, `0f2762a`, `5307a41`)
- 6B-3 completed:
  - Flutter export UX implementation (`f30274d`) for template selection, polling/status matrix, cancel flow, and completion/share surface
  - post-review hardening fixes (`a345901`) for transport decoupling, completion navigation guard, cancel refresh behavior, and tracking tests
- 6B sign-off evidence completed (`25a8e05`) with docs sync follow-up (`d041ca6`).
- 6C started in local diff:
  - renderer Lambda backend scaffold + deploy scripts + exact Remotion pinning
  - backend `LambdaRemotionRenderer`, S3-aware output URL handling, queue/tier caps, and presigned download path

---

## 3. Scope

### In Scope

- Server-side async export jobs (`queued -> processing|cancel_requested -> completed|failed|canceled|blocked`).
- Export API control plane in FastAPI.
- Durable worker loop using DB claim/lock semantics.
- Remotion-based renderer integration:
  - Local renderer path for development and early MVP.
  - AWS Lambda renderer path for production scale.
- Flutter Export Studio flow (submit, poll, cancel, share).
- Export artifacts stored privately with signed URL access.
- Guardrails for quality, cost, concurrency, and reliability.

### Out of Scope (Phase 6)

- Full social publishing platform.
- Multi-language subtitle generation.
- Advanced AI video edits beyond template-based rendering.
- Full web export studio parity (can be added progressively after mobile MVP).
- Real-time progress streaming via WebSocket or SSE. Flutter polls at 2s intervals during active processing. A `GET /api/v1/exports/{job_id}/events` SSE endpoint is a planned future upgrade, out of scope for Phase 6.

---

## 4. Non-Negotiable Guardrails

1. Long-running render work must not run inside FastAPI request lifecycle.
2. `FastAPI BackgroundTasks` is not allowed for durable export rendering.
3. Export jobs must be persisted before any rendering starts.
4. Job claiming must be atomic and collision-safe using `SELECT ... FOR UPDATE SKIP LOCKED`.
   - SQLAlchemy implementation: `.with_for_update(skip_locked=True)` — standard `.with_for_update()` without `skip_locked=True` is NOT sufficient and will cause worker contention.
   - Raw SQL equivalent: `SELECT ... FOR UPDATE SKIP LOCKED`.
5. Export input must be snapshot-based (immutable payload per job attempt).
6. Export must be blocked when blocking sync/media work exists for that trip **and** when the trip has no backend server identity (`serverTripId` must be non-null before submission is allowed).
7. Output storage is private by default; public sharing is explicit, not implicit.
8. Vendor SDK usage stays behind adapters/interfaces (no direct Remotion/AWS logic in Flutter UI widgets).
9. Preserve existing architecture boundaries:
   - Flutter `features/**` should depend on providers/repositories, not direct transport.
   - Existing queue workers (`UploadQueueWorker`, `EntitySyncWorker`) must not regress.
10. Maintain current design language for export screens (dark studio mode from Screen 10/11/12 spec).
11. `snapshot_json` must use URL references for media assets, never base64 or binary data. Maximum snapshot payload size is 500KB. Enforce this in `export_service.py` before job insertion.
12. `blocked` is a server-side terminal status set only by the worker post-claim for non-retryable conditions. It is never set at job creation time. The Flutter pre-submit guard is a separate client-side check that prevents submission entirely — it does not create a `blocked` row.
13. The `video-renderer/` service communicates with the backend worker exclusively over HTTP REST. The protocol contract is defined in §5.2 and must be frozen before 6B implementation starts.

---

## 5. Target Architecture (Phase 6 End State)

## 5.1 Control Plane (Backend)

- New export job table: `export_jobs`.
- New API endpoints:
  - `POST /api/v1/trips/{trip_id}/export`
  - `GET /api/v1/exports/{job_id}`
  - `POST /api/v1/exports/{job_id}/cancel`
  - `GET /api/v1/exports/{job_id}/download-url`
  - `GET /api/v1/exports/{job_id}/share`
- New worker process (separate runtime from API server):
  - Claim jobs using `FOR UPDATE SKIP LOCKED`.
  - Build snapshot.
  - Trigger renderer via HTTP in both local and Lambda modes.
  - Track progress/stage.
  - Persist output metadata and failure reasons.

## 5.2 Render Plane (Remotion) — Protocol Definition

The backend worker communicates with the renderer through a typed HTTP REST contract. This contract must be frozen before 6B starts.

### Local Renderer (Development and VPS)

`video-renderer/` is a Node/Express HTTP service on a configurable port (`RENDERER_PORT`, default `3100`).

The backend `LocalRemotionRenderer` calls it via `httpx` (Python async HTTP client).

**Renderer HTTP API contract (frozen at 6A):**

```
POST /api/v1/render
  Body: RenderManifest (see §6.2)
  Response 202: { "render_id": "uuid", "status": "queued" }
  Response 422: { "error": "validation_error", "detail": "..." }

GET /api/v1/render/{render_id}
  Response 200: {
    "render_id": "uuid",
    "status": "queued|rendering|completed|failed",
    "progress": 0.0..1.0,
    "output_path": "{RENDER_OUTPUT_DIR}/{render_id}.mp4" | null,
    "error": null | "reason string"
  }

DELETE /api/v1/render/{render_id}
  Response 200: { "canceled": true }
  Response 404: { "error": "not_found" }
```

`output_path` must be inside `RENDER_OUTPUT_DIR`, and that directory must be readable by the export worker process. In containerized local development, mount the same named volume into both `worker` and `renderer` (see Section 5.6).

All requests include `X-Renderer-Version: 1` header. Version mismatch returns 400 to prevent silent contract drift.

### Lambda Renderer (Production)

`LambdaRemotionRenderer` is still an HTTP adapter on the Python side. The Node `video-renderer` service owns all `@remotion/lambda` SDK calls. Backend worker never calls AWS Lambda SDKs directly.

The interface is:
```python
class AbstractRemotionRenderer(ABC):
    async def render(self, manifest: RenderManifest) -> str:
        """Returns render_id"""

    async def get_status(self, render_id: str) -> RenderStatus:
        """Returns progress, status, output_path"""

    async def cancel(self, render_id: str) -> None:
        """Cancels in-progress render"""
```

Both `LocalRemotionRenderer` and `LambdaRemotionRenderer` implement this interface. The worker never calls renderer-specific code directly.

6C contract details for Lambda mode:
- Remotion package versions must be exact and identical (`remotion`, `@remotion/bundler`, `@remotion/renderer`, `@remotion/lambda`) with no version ranges (`^` or `~`).
- Custom output destination uses `outName: {bucketName, key}` in `renderMediaOnLambda`.
- `getRenderProgress` must use the `bucketName` returned by `renderMediaOnLambda` for progress polling context.
- Override manifest timing/dimensions with Lambda-supported force fields (`forceFps`, `forceDurationInFrames`, `forceWidth`, `forceHeight`).
- Renderer HTTP contract remains unchanged (`X-Renderer-Version: 1`, same request/response shape) regardless of local or Lambda execution.

### FFmpeg Usage

FFmpeg is used only as an optional post-processing step inside Remotion's pipeline (e.g., audio normalization, container remux). It is not used as a standalone export path and is not invoked directly by the backend worker.

## 5.3 Data Plane (Storage + Delivery)

- Private export bucket/path (`exports/private/{user_id}/{job_id}/output.mp4`).
- Optional publish path (`exports/public/{job_id}/output.mp4`), written only on explicit user publish action.
- Download access via two distinct mechanisms:
  - **Download URL TTL: 1 hour.** `GET /api/v1/exports/{job_id}/download-url` generates a fresh S3 presigned URL on each call. For in-app download only. Short TTL makes expiry-based access control acceptable.
  - **Share preview URL: proxy-based, not a raw presigned URL.** `GET /api/v1/exports/{job_id}/share` is a backend proxy endpoint backed by a revocable share token (7-day token lifetime). On each request, the backend checks ownership, `revoked_at`, token expiry, and trip privacy before issuing a short-lived (60s TTL) presigned redirect to S3. This gives true immediate revocation: when trip privacy changes to private, `revoked_at` is stamped and all subsequent calls to the share endpoint return `403`, regardless of when the share link was created. Previously issued S3 redirect URLs (60s TTL) expire naturally.
  - **Never give raw 7-day presigned S3 URLs directly to clients.** S3 presigned URLs cannot be revoked once issued, so a raw 7-day URL would remain valid even after the user revokes sharing.
- Job record tracks: artifact URL, thumbnail URL, codec, resolution, fps, file size (bytes), and timing metrics (started_at, completed_at, render_duration_ms).

## 5.4 Client Plane (Flutter First)

- Export module under `flutter/lib/features/export/**`.
- Export buttons wire to real flow:
  - My Trips context menu.
  - Editor top bar.
- Polling + cancellation + completion UX follows `screen6-12.md`.
- Export flow reuses existing app bootstrap style and provider conventions.
- Pre-submit guard order (all must pass before submission):
  1. `trip.serverTripId != null` — trip must have backend identity. Local-only trips cannot export.
  2. No pending or failed media queue items for this trip.
  3. No blocking sync tasks for this trip.
- In Phase 6A: template is hardcoded to `classic`. No template picker is shown.
- In Phase 6B: `TemplatePicker` is the first step of `ExportStudioScreen`.

## 5.5 Optional Client Plane (Web Follow-up)

Basic export status/history can be added in web app after mobile MVP:
- `frontend/src/services/exportService.ts`
- `frontend/src/hooks/useExports.ts`

## 5.6 Local Development Orchestration

Phase 6 requires three concurrently running processes in development. These must be documented and scripted before 6A closes.

**Option A — docker-compose (recommended):**

`docker-compose.dev.yml` at repo root:

```yaml
version: '3.8'
services:
  api:
    build: ./backend
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    env_file: backend/.env
    ports: ["8000:8000"]
    depends_on: [db]

  worker:
    build: ./backend
    command: python -m app.workers.export_worker
    env_file: backend/.env
    environment:
      RENDERER_URL: http://renderer:3100
      RENDER_OUTPUT_DIR: /render_artifacts
    volumes:
      - render_artifacts:/render_artifacts
    depends_on: [db, renderer]

  renderer:
    build: ./video-renderer
    command: npm run dev
    ports: ["3100:3100"]
    environment:
      PORT: 3100
      RENDER_OUTPUT_DIR: /render_artifacts
    volumes:
      - render_artifacts:/render_artifacts

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: dora_dev
      POSTGRES_USER: dora
      POSTGRES_PASSWORD: dora_dev
    ports: ["5432:5432"]
    volumes: ["pgdata:/var/lib/postgresql/data"]

volumes:
  pgdata:
  render_artifacts:   # shared between worker and renderer for artifact handoff
```

**Option B — Procfile (lightweight, no Docker):**

`Procfile.dev` at repo root:
```
api:      cd backend && uvicorn app.main:app --port 8000 --reload
worker:   cd backend && python -m app.workers.export_worker
renderer: cd video-renderer && npm run dev
```

Run with `overmind start -f Procfile.dev` or `honcho start -f Procfile.dev`.

Required env vars in `backend/.env` for non-container local development:
- `RENDERER_URL=http://localhost:3100`
- `RENDER_OUTPUT_DIR=/tmp/dora_render_artifacts` (must match the value set in `video-renderer/.env`)

---

## 6. Data and API Contracts

## 6.1 Export Job Schema (Backend DB)

Minimum required columns:

- `id` (UUID PK)
- `user_id` (UUID, indexed)
- `trip_id` (UUID, indexed)
- `status` — see §6.4 for valid values and transition rules
- `stage` (`snapshotting|asset_fetch|rendering|encoding|uploading|finalizing`)
- `progress` (`0.0..1.0`)
- `template` (e.g., `classic`, `cinematic`)
- `aspect_ratio` (`9:16|1:1|16:9`)
- `duration_sec`
- `quality` (`480p|720p|1080p`)
- `fps`
- `snapshot_json` (JSONB) — max 500KB; stores URL references only, never binary data; validated by `export_service.py` before insert
- `snapshot_hash` (idempotency/dedup key — SHA-256 of normalized snapshot + config)
- `output_url`
- `thumbnail_url`
- `pinned_at` (nullable datetime — reserved for lifecycle protection policy in 6D)
- `revoked_at` (nullable datetime — reserved for share revocation policy in 6D)
- `error_code`
- `error_message`
- `retry_count`
- `max_retries` (default: 3)
- `next_attempt_at` (nullable datetime — when the job is eligible for retry claiming; NULL means immediately claimable)
- `worker_session_id`
- `created_at`, `updated_at`, `started_at`, `completed_at`, `render_duration_ms`

**Indexes required:**
- `(user_id, status)` — for per-user concurrency checks
- `(status, next_attempt_at)` — for worker claim query
- `(trip_id)` — for pre-submit guard queries
- `(snapshot_hash)` — for dedup lookup

## 6.2 Snapshot Contract

Snapshot must include immutable render inputs:

- trip metadata (title, visibility, dates)
- ordered timeline components
- route geometry (`route_geojson` — pre-simplified to max 500 coordinate points per route)
- place coordinates and order
- media references as objects: `{id, url, thumbnail_url, width, height, mime_type, file_size_bytes}` — never embed base64 or full file bytes
- export config (template, aspect ratio, quality, duration, fps)

Snapshot must not depend on mutable in-memory state after job starts.

If the trip has more than 50 media items, snapshot includes only those items referenced by the export composition's timeline. The snapshotting stage is responsible for this filtering.

## 6.3 API Request/Response Baseline

**Create export:**

```
POST /api/v1/trips/{trip_id}/export
```

```json
{
  "template": "classic",
  "aspect_ratio": "9:16",
  "duration_sec": 15,
  "quality": "720p",
  "fps": 30
}
```

Response `202 Accepted`:

```json
{
  "job_id": "uuid",
  "status": "queued",
  "stage": null,
  "progress": 0.0
}
```

Error `409 Conflict` (active job already exists for same trip + config):

```json
{
  "error": "duplicate_job",
  "existing_job_id": "uuid",
  "detail": "An identical export is already queued or processing."
}
```

Error `422 Unprocessable` (pre-submit guard failed):

```json
{
  "error": "export_precondition_failed",
  "reason": "trip_not_synced|pending_media|pending_sync",
  "detail": "Human-readable explanation."
}
```

**Get status:**

```
GET /api/v1/exports/{job_id}
```

```json
{
  "job_id": "uuid",
  "status": "processing",
  "stage": "rendering",
  "progress": 0.64,
  "output_url": null,
  "thumbnail_url": null,
  "error_code": null,
  "error_message": null,
  "created_at": "2026-02-27T10:00:00Z",
  "started_at": "2026-02-27T10:00:05Z",
  "completed_at": null
}
```

**Get download URL:**

```
GET /api/v1/exports/{job_id}/download-url
```

```json
{
  "download_url": "https://storage.example.com/exports/private/.../output.mp4?token=...",
  "expires_at": "2026-02-27T11:00:00Z",
  "ttl_seconds": 3600
}
```

Only available when `status == completed`. Returns `409` for any other status.

**Get share URL (revocable):**

```
GET /api/v1/exports/{job_id}/share
```

```json
{
  "share_url": "https://api.dora.app/api/v1/shares/abc123",
  "expires_at": "2026-03-06T10:00:00Z",
  "ttl_seconds": 604800
}
```

`share_url` is a revocable backend URL, not a long-lived raw S3 presigned URL. On access, backend validates token + trip privacy and issues a short-lived S3 redirect URL (60s). If sharing is revoked or trip privacy is changed to private, this endpoint returns `403`.

**Cancel:**

```
POST /api/v1/exports/{job_id}/cancel
```

Response depends on current job status:
- `200 OK` - job was `queued`; canceled immediately and synchronously. Body: `{"status": "canceled"}`
- `202 Accepted` - job was `processing`; cancel is async. Status set to `cancel_requested`. Body: `{"status": "cancel_requested"}`. Client must continue polling until status resolves to `canceled` or `completed`.
- `202 Accepted` - job is already `cancel_requested`; idempotent response. Body: `{"status": "cancel_requested"}`.
- `409 Conflict` - job is already `completed`, `blocked`, or `canceled`. Body: `{"error": "invalid_transition", "current_status": "..."}`.
- `403 Forbidden` - requestor does not own this job.

## 6.4 Export Job Status State Machine

This is the authoritative status transition table. Any status transition not listed here is invalid and must be rejected by the service layer.

```
queued
  ├─→ processing          (worker claims job)
  └─→ canceled            (user cancels before worker picks up; immediate, no renderer involved)

processing
  ├─→ completed           (render success, artifact uploaded, metadata persisted)
  ├─→ failed              (render error; retry_count < max_retries → auto-requeue to queued)
  ├─→ blocked             (terminal non-retryable condition detected by worker post-claim)
  ├─→ cancel_requested    (user requests cancel while renderer is in-flight; see below)
  -> canceled            (worker settles canceled after cancel signal path)

cancel_requested
  -> canceled            (worker settles canceled immediately after cancel path)
  └─→ completed           (race: render completed before cancel was processed — accept the artifact)

failed
  └─→ queued              (automatic retry; worker sets next_attempt_at with backoff)

completed  → [terminal]
blocked    → [terminal — requires user action or support intervention]
canceled   → [terminal]
```

**Cancel semantics for distributed in-flight renders (frozen for 6C):**

1. User calls `POST /api/v1/exports/{job_id}/cancel`.
2. API service sets `status = cancel_requested` atomically. Returns `202 Accepted` immediately.
3. Worker checks for `cancel_requested` at stage boundaries and within rendering poll loop.
4. If render status is already `completed` when cancel is observed, worker accepts artifact and settles `status = completed` (race won by completion).
5. Otherwise worker calls `renderer.cancel(render_id)` and settles `status = canceled` immediately.

Lambda-specific note:
- Lambda cancel is best-effort and may be implemented as a no-op in the renderer backend.
- Even when worker settles `canceled`, underlying Lambda tasks may finish in AWS. These late artifacts are ignored by control plane state.

Flutter handles `cancel_requested` as a transitional display state ("Canceling...") until status resolves to `canceled` or `completed`.

**`blocked` semantics (server-side only):**

The worker sets `status = blocked` when it encounters a non-retryable terminal condition after claiming the job. Examples:
- Trip was deleted from the backend between job submission and job execution.
- Auth token for the service account is permanently revoked.
- Trip media references are all broken (all asset_fetch failures are 404).
- Quota exceeded at a tier that cannot be retried.

`blocked` is **never** set at job creation time. The Flutter pre-submit guard is a client-side check that prevents submission if preconditions are not met — it results in a `422` response, not a `blocked` row.

---

## 7. Sub-Phase Plan (6A, 6B, 6C, 6D)

## 7.1 Phase 6A - Control Plane and Product Wiring

Objective: Establish durable export job lifecycle with no rendering dependency risk.

**Backend deliverables:**

- `export_jobs` schema + Alembic migration with all indexes.
- `ExportJob` SQLAlchemy model and Pydantic schemas (request, response, status update).
- Export API router and service with all four endpoints.
- Job claim implementation using `.with_for_update(skip_locked=True)`.
- Worker skeleton process (separate from API server):
  - Claim loop with configurable poll interval.
  - Status/stage progression through mock render stages.
  - Retry metadata update with exponential backoff.
  - `worker_session_id` stamped on claim; stale session detection on restart.
- Router registration in `backend/app/main.py`.
- Pre-submit server-side validation in `export_service.py`:
  - Trip must exist and be owned by requesting user.
  - Dedup check against `snapshot_hash`.

**Flutter deliverables:**

- Export feature skeleton:
  - `flutter/lib/features/export/data/export_repository.dart`
  - `flutter/lib/features/export/domain/export_job.dart`
  - `flutter/lib/features/export/domain/export_state.dart`
  - `flutter/lib/features/export/presentation/providers/export_provider.dart`
- Route wiring in `routes.dart` and `app_router.dart`.
- Wire existing export entry points:
  - `my_trips_screen.dart` export action navigates to `ExportStudioScreen`.
  - `editor_screen.dart` export action navigates to `ExportStudioScreen`.
- Pre-submit guard (enforced in `export_provider.dart` before API call):
  1. `trip.serverTripId != null` — if null, show error: "Trip must be synced before exporting."
  2. No pending/failed media queue items for this trip — if present, show error: "Upload all media before exporting."
  3. No blocking sync tasks for this trip — if present, show error: "Trip changes are still syncing."
- 6A Export Studio screen: single-state "Preparing your video..." with hardcoded `classic` template. No template picker. A "Start Export" button submits the job with defaults.

**Renderer contract deliverable (6A freeze):**

- `video-renderer/` HTTP API contract frozen and documented (see §5.2).
- Contract document: `video-renderer/docs/renderer-api-contract.md`.
- Contract includes: endpoint specs, request/response schemas, version header, error codes.
- Backend `AbstractRemotionRenderer` interface implemented with a `MockRemotionRenderer` stub that simulates stage progression for 6A testing.

**`dora_api` client:**

- Regenerate Flutter OpenAPI client after export endpoints are added.
- Bump `dora_api` package version in `flutter/packages/dora_api/pubspec.yaml`.
- Add provider wiring in `flutter/lib/core/network/api_providers.dart`.

**Local dev orchestration:**

- Add `docker-compose.dev.yml` and `Procfile.dev` at repo root (see §5.6).
- Document startup procedure in `video-renderer/README.md`.

**Exit criteria:**

- User can submit export job from Flutter and observe status progression through mock stages.
- Cancel endpoint updates state correctly.
- Worker recovers queued jobs after restart (see §11 for required test).
- No regression in media upload/sync queue flows.

---

## 7.2 Phase 6B - Remotion MVP Renderer (Local First)

Objective: Render first real video template with deterministic quality.

**Pre-condition:** §5.2 renderer HTTP API contract must be frozen and signed off before any 6B work starts.

**Renderer deliverables:**

- `video-renderer/` Express + Remotion service implementing the frozen HTTP API contract.
- One composition: `classic` template.
  - Accepts `RenderManifest` as input props.
  - Renders map route animation, place cards, and photo sequence.
- Output profiles:
  - 480p and 720p
  - 9:16 and 16:9
  - 30fps
- Deterministic local render: same manifest always produces equivalent timeline, duration, and visual ordering (byte-for-byte MP4 identity is not required).
- Output written to a configurable local temp directory (`RENDER_OUTPUT_DIR` env var).

**Backend integration deliverables:**

- `LocalRemotionRenderer` implementation calling the `video-renderer/` HTTP API.
- Snapshot-to-`RenderManifest` mapping in `export_service.py`.
  - Route GeoJSON simplified to max 500 points.
  - Media list capped per §6.2 rules.
  - Snapshot size validated ≤ 500KB before insertion.
- Worker stage implementation:
  - `snapshotting`: build and validate snapshot, compute `snapshot_hash`.
  - `asset_fetch`: pre-fetch and verify all media URLs are reachable (HEAD requests).
  - `rendering`: call `LocalRemotionRenderer.render(manifest)`, poll progress.
  - `encoding`: no-op for local path (Remotion handles encoding inline).
  - `uploading`: upload MP4 to private storage path; set `thumbnail_url` from first snapshot media URL (6B shortcut, no thumbnail artifact upload).
  - `finalizing`: persist `output_url`, `thumbnail_url`, `render_duration_ms`, mark `completed`.
- Cancellation check: worker reads current `status` from DB before entering each stage. If `status == cancel_requested`, the worker initiates renderer cancellation and exits the stage loop. The worker never checks for `canceled` directly as the trigger — `canceled` is the outcome, not the signal.

**Flutter UX deliverables:**

- `TemplatePicker` as first step of `ExportStudioScreen` (replaces 6A hardcoded default).
- Full progress and state UI aligned with Screen 10/11/12:
  - `queued` → "Waiting in queue..."
  - `processing` with stage label and progress bar
  - `completed` → completion screen with download/share actions
  - `failed` → error screen with retry option
  - `canceled` → canceled screen with restart option
  - `blocked` → error screen with user-facing error copy and support link
- Polling: 2s interval while `status == processing`, back off to 10s while `status == queued`.
- Cancel confirmation dialog before cancel API call.

**`dora_api` re-check:**

- If any response schema changed during 6B (e.g., new stage values, new fields), regenerate `dora_api` client and bump version again.

**Exit criteria:**

- Real trip data renders to a playable, non-corrupt MP4 via local renderer.
- 15-second 720p export succeeds end-to-end from Flutter in local dev environment.
- Known failure paths return actionable user-facing messages.
- p95 success rate >= 95% for a smoke set of 5 test trips.
- No regression in media upload and entity sync flows.

---

## 7.3 Phase 6C - AWS Lambda Scale and Cost Controls

Objective: Move production rendering to scalable cloud execution with enforced cost limits.

**Pre-condition:** 6B render manifest schema must be stable. No manifest changes after 6C starts without explicit versioning.

**Scope decision (2026-03-02, branch execution):**

- 6C deferrals are explicitly accepted for this branch:
  - share-token revocation hardening stays in 6D
  - `pinned_at` lifecycle-protection wiring stays in 6D
  - current cancel semantics remain immediate worker settlement with race-accept
- These deferrals are tracked as 6D deliverables and are not considered 6C blockers for this branch.

**Lambda renderer deliverables:**

- `LambdaRemotionRenderer` adapter in backend (`export_renderer.py`) with extended HTTP timeouts only.
- Lambda backend implementation inside `video-renderer` using `@remotion/lambda`.
- Lambda function/site deployment scripts in `video-renderer/scripts/`.
- Lambda runtime configuration (frozen in 6C):
  - Memory: `2048MB` for ≤720p, `3008MB` for 1080p.
  - Timeout: `900s` (Lambda max).
  - `framesPerLambda`: `8`.
  - Region: configurable via `AWS_REGION`.
  - Output bucket: `dora-exports-{env}` S3 bucket.
  - Renderer call timeout: `renderMediaOnLambda.timeoutInMilliseconds = 240000` (delayRender watchdog), separate from Lambda function timeout.
- Remotion package pinning rule:
  - All `@remotion/*` plus `remotion` must use the same exact patch version (no `^`, `~`, or `x` ranges).

**IAM requirements (must be provisioned before 6C testing):**

Use principal split with least privilege:

- Renderer service principal (Node `video-renderer`) permissions:
  - `lambda:InvokeFunction` on remotion render functions.
  - S3 permissions required by Remotion Lambda internals and configured output bucket writes.
  - CloudWatch logging permissions for render diagnostics.
- Backend worker principal (Python API/worker) permissions:
  - S3 read access on export bucket objects required to generate presigned download URLs.
  - No direct Lambda invoke permission required for normal 6C flow.

Implementation notes:
- Roles must use minimum permissions and environment-specific resource ARNs.
- Role wiring and provisioning steps documented in `infra/remotion/README.md`.
- `AWS_WORKER_ROLE_ARN` remains the backend runtime role env var; renderer runtime role is documented separately.

**Cost controls:**

- Per-user active export limit: max 2 concurrent jobs (configurable via `EXPORT_MAX_CONCURRENT_PER_USER` env var).
- Global queue cap: max 50 active jobs (configurable via `EXPORT_GLOBAL_QUEUE_CAP` env var).
- Dedup by `snapshot_hash + quality + aspect_ratio`: if identical job already `queued` or `processing`, return existing `job_id` with `409 Conflict`.
- Retry policy: max 3 attempts, exponential backoff (30s, 120s, 480s).
- Quality caps by tier:
  - Free tier: ≤720p, ≤15s duration.
  - Paid tier: ≤1080p, ≤60s duration.
  - 6C implementation enforces free-tier caps at job creation. Paid entitlement branching is deferred until billing/user-plan integration in 6D.
- S3 lifecycle rule for 6C: unconditional auto-delete of export artifacts older than 30 days (`private/` prefix). `pinned_at` protection wiring is deferred to 6D.
- Target cost: <$0.15 per 720p/15s export (Lambda compute + S3 storage + transfer).

**Security deliverables:**

- Ownership check on all status/cancel/download-url endpoints: `job.user_id == requesting_user_id`.
- Download URL: S3 presigned URL with 1-hour TTL, generated fresh on each `GET /download-url` call.
- Share URL contract remains unchanged in 6C; full revocable-token persistence and privacy-revocation enforcement are completed in 6D.
- No public bucket ACLs — all S3 access via presigned URLs only.

**Observability deliverables:**

Structured log tags (use in every relevant log line):
- `[EXPORT_JOB]` — lifecycle events (created, claimed, completed, failed, blocked, canceled)
- `[EXPORT_RENDER]` — renderer calls, stage timing
- `[EXPORT_UPLOAD]` — artifact upload start/complete/fail
- `[EXPORT_FAIL]` — any error with error_code and retry context
- `[EXPORT_COST]` — Lambda invocation count, memory, duration per job

Minimum metrics to track:
- Queue wait time (claimed_at - created_at)
- Render duration per stage
- Overall job success/failure/cancellation rate
- Lambda invocation count per export (cost proxy)
- Artifact size distribution

**Exit criteria:**

- Lambda render path handles 5 concurrent jobs without deadlocks or duplicate artifacts.
- Cost and concurrency limits enforced and tested at API layer.
- Security checks and presigned URL flow validated.
- Observability logs and metrics visible in target environment.

---

## 7.4 Phase 6D - Quality, Templates, and Hardening

Objective: Reach product-grade export quality and operational confidence.

**Product quality deliverables:**

- Add at least one advanced template (`cinematic`):
  - Cinematic composition with letterbox aspect ratio support, Ken Burns effect on photos, smooth camera fly-over on route.
- Improve `classic` template:
  - Camera easing curve refinement (ease-in-out, not linear).
  - Route animation smoothness (spline interpolation, not step).
  - Text/label timing and fade polish.
  - Transition smoothness between place cards.
- Export history screen: list past exports with status, thumbnail, and re-export/share/delete actions.
- Share preview polish: native share sheet integration.

**Hardening deliverables:**

- Failure taxonomy finalized:
  - Retryable: `network_timeout`, `render_crash`, `upload_timeout`, `lambda_throttle`
  - Terminal (blocked): `trip_deleted`, `auth_revoked`, `quota_exceeded`, `asset_all_404`
  - User-facing copy for each error code in Flutter `export_error_strings.dart`.
- Cancel behavior consistent across all stages: worker checks cancel flag at entry of each stage.
- Stale job reaper: background task that marks jobs stuck in `processing` **or** `cancel_requested` for >30 minutes as `failed` with `error_code = worker_timeout`. Configurable via `EXPORT_WORKER_TIMEOUT_MINUTES` env var. (`cancel_requested` jobs are reaped with the same timeout to handle the case where the renderer never acknowledged the cancel or the worker crashed mid-cancel.)
- Storage lifecycle cleanup: `pinned_at` column used to protect shared artifacts from auto-delete.
- Share-token hardening:
  - Persist revocable share token records server-side.
  - Enforce `revoked_at` and trip privacy checks on every share request.
  - Issue short-lived (60s) S3 redirect URLs from share endpoint; never return long-lived raw S3 links.
- Replace 6B thumbnail shortcut with generated export thumbnail artifact:
  - Extend renderer API to emit thumbnail frame metadata.
  - Upload `thumbnail.jpg` under `exports/private/{user_id}/{job_id}/thumbnail.jpg`.
  - Persist `thumbnail_url` as export artifact URL rather than reused trip media URL.

**Regression deliverables:**

- Full regression pack:
  - Create/edit trip
  - Places/routes timeline
  - Media upload queue
  - Entity sync worker
  - Export flow (submit/poll/cancel/download/share)

**Exit criteria:**

- Quality sign-off against `screen6-12.md` expectations.
- No critical defects in export pipeline.
- No major regressions in create/media/sync architecture.
- Operational runbook documented in `flutter/docs/ops/export-runbook.md`.

---

## 8. Phase Dependency and Coupling Rules

1. 6B starts only after 6A API/DB/job contract freeze AND renderer HTTP API contract frozen and documented.
2. 6C starts only after 6B render manifest schema is stable. Manifest changes after 6C starts require explicit versioning.
3. 6D can begin partially in parallel with 6C for visual template tuning, but release requires 6C completion.
4. Any `export_jobs` schema or API contract changes after 6A require:
   - Explicit Alembic migration with rollback notes.
   - Updated Pydantic schemas.
   - `dora_api` client regeneration.
   - `dora_api` package version bump in `flutter/packages/dora_api/pubspec.yaml`.
5. Flutter `dora_api` client regeneration must happen after every export OpenAPI schema change, not just once at 6A.
6. IAM role and S3 bucket must be provisioned before any 6C cloud render testing begins.

---

## 9. Agent Execution Rules

These rules are mandatory for any agent implementing this phase.

### 9.1 Required Reading Before Coding

- `flutter/docs/architecture.md`
- `flutter/docs/rules.md`
- `flutter/docs/screens/screen6-12.md`
- `flutter/docs/phases/Phase-5-PRD.md`
- `flutter/docs/phases/Phase-5-Execution-Checklist.md`
- `backend/app/main.py`
- `backend/app/api/v1/components.py`
- `backend/app/services/media_service.py`
- `flutter/lib/core/media/upload_queue_worker.dart`
- `flutter/lib/core/sync/entity_sync_worker.dart`
- `video-renderer/docs/renderer-api-contract.md` (after 6A creates it)

### 9.2 Do Not Violate

- No direct renderer vendor SDK calls from Flutter widgets.
- No export rendering in API request thread.
- No undocumented status transitions (follow §6.4 exactly).
- No public artifact URL for private trips.
- No merging without migration + tests + rollback notes.
- No `.with_for_update()` without `skip_locked=True` for job claiming.
- No `snapshot_json` exceeding 500KB — validate before insert.
- Do not set `status = blocked` at job creation. It is a worker-set terminal state only.

### 9.3 Stop-the-Line Conditions

- Export causes data loss or duplicate side effects.
- Job status can become stuck in `processing` or `cancel_requested` with no retry/cancel/reaper path.
- Media upload/sync regressions appear in Phase 5 baseline.
- Ownership checks fail for export status/download endpoints.
- Private trip artifact becomes publicly accessible without explicit publish action.
- `snapshot_json` contains binary data or base64-encoded file content.

---

## 10. Quality, Performance, and Cost Targets

**Performance targets:**

- 15s 720p export: p95 total completion time ≤ 120s (local path), ≤ 90s (Lambda path after cold start).
- 30s 1080p export: p95 total completion time ≤ 240s (Lambda path).
- Lambda cold start: acceptable at ≤ 5s. Provisioned concurrency not required at MVP.
- Worker claim-to-render-start latency: ≤ 5s.
- Export success rate: ≥ 98% excluding user-canceled jobs.

**Cost targets:**

- 720p / 15s export: target ≤ $0.15 (Lambda compute + S3 storage + egress).
- Lambda invocations per 720p/15s export: target ≤ 80 function calls (at `framesPerLambda=8`).
- S3 storage: artifacts auto-deleted after 30 days unless pinned. Monthly storage cost capped by lifecycle rule.
- Deduplication prevents re-rendering identical `(snapshot_hash + quality + aspect_ratio)` exports.

**Concurrency limits:**

- Per-user active job cap: 2 (configurable).
- Global queue depth cap: 50 (configurable).
- Lambda concurrency: set `reservedConcurrentExecutions` to 20 in production to prevent runaway scaling.

**Quality floor:**

- All artifacts must be playable MP4 (H.264, AAC) without corruption.
- 6C minimum: every completed export must have non-empty `thumbnail_url`.
- 6D target: thumbnail must be a generated export artifact frame, not reused source media.
- Route animation must complete within the specified `duration_sec` without truncation.

---

## 11. Test Strategy

**Backend:**

- Unit tests:
  - State transition validation (all paths in §6.4).
  - Dedup logic (`snapshot_hash` collision returns existing job).
  - Permission checks (ownership, tier quality caps).
  - Snapshot size validation (rejects >500KB payloads).
  - Pre-submit guard logic (trip_not_synced, pending_media, pending_sync).
- Integration tests:
  - `POST /export` → `GET /status` → `POST /cancel` happy path.
  - `POST /export` with duplicate snapshot returns `409`.
  - `GET /download-url` returns signed URL with correct TTL.
  - `GET /download-url` on non-completed job returns `409`.
- Worker tests:
  - Claim/retry/failure handling with mock renderer.
  - `blocked` status set correctly for non-retryable failures.
  - **Restart-recovery test**: simulate worker claim → kill worker process → restart worker → verify job is re-claimed and not stuck in `processing` indefinitely. This test is mandatory for 6A exit criteria.
  - Stale job reaper marks long-running `processing` and `cancel_requested` jobs as `failed`.
  - Cancel flag checked correctly at each stage boundary.

**Flutter:**

- Provider tests:
  - Submit flow: pre-submit guard failures produce correct error states.
  - Poll flow: state transitions through all status values.
  - Cancel flow: cancel API call and state reset.
- Widget tests:
  - `ExportStudioScreen` renders correctly for each status/stage combination.
  - Pre-submit error messages render with correct copy.
  - Progress bar updates on poll.
- Integration tests:
  - Precondition guard blocks export for local-only trip (`trip.serverTripId == null`).
  - Precondition guard blocks export for trip with pending media queue items.
  - Precondition guard blocks export for trip with blocking sync tasks.

**Manual:**

- Happy path export from My Trips and Editor.
- Offline/online interruption during processing.
- Cancel-in-progress (cancel each stage: snapshotting, rendering, uploading).
- Failure/retry behavior — confirm retry with backoff.
- Signed URL access validation (expired URL, wrong user).
- Local-only trip export shows correct precondition error (`trip_not_synced`) in Flutter.

---

## 12. File Map (Planned)

**Backend (new/updated):**

- `backend/app/models/export_job.py` (new)
- `backend/app/schemas/export.py` (new)
- `backend/app/services/export_service.py` (new)
- `backend/app/services/export_renderer.py` (new — abstract interface + local/lambda adapters)
- `backend/app/api/v1/exports.py` (new)
- `backend/app/main.py` (update router registration)
- `backend/app/workers/export_worker.py` (new)
- `backend/alembic/versions/*_create_export_jobs.py` (new)
- `backend/tests/test_export_endpoints.py` (new)
- `backend/tests/test_export_worker.py` (new — includes restart-recovery test)

**Flutter (new/updated):**

- `flutter/lib/features/export/data/export_repository.dart` (new)
- `flutter/lib/features/export/domain/export_job.dart` (new)
- `flutter/lib/features/export/domain/video_template.dart` (new)
- `flutter/lib/features/export/domain/export_state.dart` (new)
- `flutter/lib/features/export/domain/export_error_strings.dart` (new — user-facing copy for all error codes)
- `flutter/lib/features/export/presentation/screens/export_studio_screen.dart` (new)
- `flutter/lib/features/export/presentation/screens/template_picker_screen.dart` (new — 6B)
- `flutter/lib/features/export/presentation/screens/share_preview_screen.dart` (new)
- `flutter/lib/features/export/presentation/providers/export_provider.dart` (new)
- `flutter/lib/core/navigation/routes.dart` (update)
- `flutter/lib/core/navigation/app_router.dart` (update)
- `flutter/lib/features/trips/presentation/screens/my_trips_screen.dart` (update)
- `flutter/lib/features/create/presentation/screens/editor_screen.dart` (update)
- `flutter/lib/core/config/feature_flags.dart` (update if extra flags added)
- `flutter/packages/dora_api/pubspec.yaml` (version bump after each export OpenAPI change)

**Renderer/infra (new):**

- `video-renderer/` (new Remotion + Express service)
- `video-renderer/docs/renderer-api-contract.md` (frozen HTTP API contract)
- `video-renderer/README.md` (local dev setup instructions)
- `infra/remotion/iam.json` and/or `infra/remotion/iam.tf|iam.ts` (IAM policy/role definition)
- `infra/remotion/s3_lifecycle.json` (S3 lifecycle rule for artifact cleanup)
- `infra/remotion/README.md` (Lambda deployment and IAM provisioning guide)
- `docker-compose.dev.yml` (repo root — three-service local dev stack)
- `Procfile.dev` (repo root — lightweight alternative to docker-compose)

**Ops (new):**

- `flutter/docs/ops/export-runbook.md` (6D — operational runbook)
- `flutter/docs/handoffs/phase6-contract-freeze.md` (required before 6A — see §6.4 and Checklist)
- `flutter/docs/handoffs/phase6c-kickoff-procedure.md` (required before 6C implementation starts)

---

## 13. References

**Internal references:**

- `flutter/docs/architecture.md`
- `flutter/docs/rules.md`
- `flutter/docs/screens/screen6-12.md`
- `flutter/docs/phases/Phase-5-PRD.md`
- `flutter/docs/phases/Phase-5-Execution-Checklist.md`
- `backend/app/main.py`
- `backend/app/api/v1/components.py`
- `backend/app/models/route.py`
- `backend/app/services/media_service.py`
- `flutter/lib/core/media/upload_queue_worker.dart`
- `flutter/lib/core/sync/entity_sync_worker.dart`

**External references (official):**

- Remotion Lambda docs and SSR comparison:
  - https://www.remotion.dev/docs/lambda
  - https://www.remotion.dev/docs/lambda/api
  - https://www.remotion.dev/docs/lambda/rendermediaonlambda
  - https://www.remotion.dev/docs/lambda/getrenderprogress
  - https://www.remotion.dev/docs/lambda/deleterender
  - https://www.remotion.dev/docs/lambda/custom-output
  - https://www.remotion.dev/docs/compare-ssr
  - https://www.remotion.dev/docs/lambda/concurrency
  - https://www.remotion.dev/docs/lambda/limits
- SQLAlchemy `with_for_update`: https://docs.sqlalchemy.org/en/20/orm/queryguide/select.html#sqlalchemy.orm.Query.with_for_update
- httpx async HTTP client (for LocalRemotionRenderer calls): https://www.python-httpx.org/async/
- AWS Presigned URLs: https://docs.aws.amazon.com/AmazonS3/latest/userguide/ShareObjectPreSignedURL.html


