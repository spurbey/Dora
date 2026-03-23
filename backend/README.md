# Dora Backend

Backend service for Dora, built on FastAPI + PostgreSQL/PostGIS + Supabase auth/storage integration.

## What This Service Owns

- User identity projection from Supabase JWTs (JWKS-based verification).
- Core trip/place/media/routes/metadata APIs.
- Search orchestration (local-first + Foursquare fallback).
- Export control plane (`export_jobs`), including queueing, status, cancel, download/share URLs.
- Durable export worker loop with renderer adapters (`mock`, `local`, `lambda`).

## Runtime Topology

- API process: `app.main:app`
- Worker process: `python -m app.workers.export_worker`
- Live-tracking worker process: `python -m app.workers.live_tracking_worker`
- Renderer process (separate service): `video-renderer/` over HTTP
- Database: PostgreSQL with PostGIS
- Storage: Supabase Storage for media, S3/presigned URL flow for cloud export artifacts

## Project Structure

```text
backend/
  app/
    api/v1/          HTTP routes
    models/          SQLAlchemy models
    schemas/         Pydantic schemas
    services/        business logic
    workers/         export worker runtime
    config.py        env-backed settings
    database.py      SQLAlchemy engine/session
    dependencies.py  auth + shared dependencies
    main.py          FastAPI app setup
  alembic/
    versions/        DB migrations
  tests/             pytest suite
```

## API Surface (high-level)

- Auth
  - `GET /api/v1/auth/me`
- Users
  - `GET/PATCH /api/v1/users/me`
  - `GET /api/v1/users/me/stats`
  - `GET /api/v1/users/me/profile`
  - `DELETE /api/v1/users/me`
- Trips
  - `POST/GET /api/v1/trips`
  - `GET/PATCH/DELETE /api/v1/trips/{trip_id}`
  - `GET /api/v1/trips/{trip_id}/bounds`
- Places
  - `POST/GET /api/v1/places`
  - `GET /api/v1/places/nearby`
  - `GET/PATCH/DELETE /api/v1/places/{place_id}`
- Media
  - `POST /api/v1/media/upload`
  - `GET/DELETE /api/v1/media/{media_id}`
- Search
  - `GET /api/v1/search/places`
- Routes/Waypoints/Route metadata
  - `GET/POST /api/v1/trips/{trip_id}/routes`
  - `GET/PATCH/DELETE /api/v1/routes/{route_id}`
  - `POST /api/v1/routes/{route_id}/waypoints`
  - `GET /api/v1/routes/{route_id}/waypoints`
  - `PATCH/DELETE /api/v1/waypoints/{waypoint_id}`
  - `POST /api/v1/routes/generate`
  - `POST/GET/PATCH/DELETE /api/v1/routes/{route_id}/metadata`
- Trip/place metadata
  - `POST/GET/PATCH/DELETE /api/v1/trips/{trip_id}/metadata`
  - `POST/GET/PATCH/DELETE /api/v1/places/{place_id}/metadata`
- Components timeline
  - `GET /api/v1/trips/{trip_id}/components`
  - `PATCH /api/v1/trips/{trip_id}/components/reorder`
  - `GET /api/v1/trips/{trip_id}/components/{component_id}`
- Exports
  - `POST /api/v1/trips/{trip_id}/export`
  - `GET /api/v1/exports`
  - `GET /api/v1/exports/{job_id}`
  - `POST /api/v1/exports/{job_id}/cancel`
  - `GET /api/v1/exports/{job_id}/download-url`
  - `GET /api/v1/exports/{job_id}/share`
  - `GET /api/v1/shares/{token}` (redirect endpoint, hidden from schema)

## Export Pipeline Details

### Job status model

- Status: `queued`, `processing`, `cancel_requested`, `completed`, `failed`, `canceled`, `blocked`
- Stage: `snapshotting`, `asset_fetch`, `rendering`, `encoding`, `uploading`, `finalizing`

### Worker mechanics

- Atomic claim: `.with_for_update(skip_locked=True)`
- Retry backoff: 30s, 120s, 480s
- Stale recovery: recovers `processing`/`cancel_requested` jobs after configured timeout
- Cancel race handling: if render finishes before cancel settles, completion can still win

### Renderer adapters

- `MockRemotionRenderer`: deterministic test-friendly behavior
- `LocalRemotionRenderer`: calls `video-renderer` HTTP API
- `LambdaRemotionRenderer`: same HTTP contract, longer timeouts, cloud-oriented polling defaults

### Artifact behavior

- Local mode can persist `file://` artifact paths then upload to Supabase exports bucket when configured.
- Lambda mode uses `s3://...` outputs and backend generates presigned download URLs.
- Share URLs are tokenized backend URLs (`/api/v1/shares/{token}`), not long-lived raw S3 URLs.

## Environment Configuration

Copy and edit:

```powershell
copy .env.example .env
```

Key variables:

- Core
  - `APP_NAME`, `DEBUG`, `ENVIRONMENT`, `SECRET_KEY`, `ALLOWED_ORIGINS`, `SENTRY_DSN`
- Supabase
  - `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_DB_URL`, `SUPABASE_SERVICE_ROLE_KEY`
- External APIs
  - `FOURSQUARE_API_KEY`, `MAPBOX_API_KEY`
- Export/renderer
  - `RENDER_BACKEND` (`mock|local|lambda`)
  - `RENDERER_URL`
  - `EXPORT_WORKER_POLL_SECONDS`, `EXPORT_WORKER_STALE_SECONDS`, `EXPORT_RENDER_POLL_SECONDS`
  - `EXPORT_MAX_CONCURRENT_PER_USER`, `EXPORT_GLOBAL_QUEUE_CAP`
  - `EXPORT_FREE_TIER_MAX_QUALITY`, `EXPORT_FREE_TIER_MAX_DURATION_SEC`
  - `EXPORT_SHARE_BASE_URL`
- Lambda/S3 mode
  - `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
  - `LAMBDA_FUNCTION_NAME`, `LAMBDA_SERVE_URL`, `LAMBDA_OUTPUT_BUCKET`

Important runtime guards in `app/config.py`:

- `ENVIRONMENT=production` + `DEBUG=true` aborts startup.
- default `SECRET_KEY` is rejected when debug is off.
- production lambda mode expects AWS credentials.

## Local Development

### Manual run

```bash
cd backend
python -m venv .venv
# Windows
.venv\Scripts\activate
# Linux/macOS
source .venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

In a second terminal:

```bash
cd backend
python -m app.workers.export_worker
```

Optional live-tracking worker terminal:

```bash
cd backend
python -m app.workers.live_tracking_worker
```

### Docker run (from repo root)

```bash
docker compose -f docker-compose.dev.yml up --build
```

## Health and Ops

- Liveness: `GET /health`
- Readiness (DB check): `GET /ready`
- Root metadata: `GET /`
- Sentry initializes when `SENTRY_DSN` is present.

Deployment workflow:

- `.github/workflows/deploy-railway.yml` deploys API, worker, and renderer services to Railway (after migrations).

## Testing

Run full backend suite:

```bash
cd backend
pytest -v
```

Targeted suites:

```bash
pytest tests/test_export_endpoints.py tests/test_export_worker.py -v
pytest tests/test_media_endpoints.py tests/test_place_endpoints.py -v
```

CI behavior:

- `backend-ci.yml` runs lint (`ruff`), migration checks (`alembic check`), and pytest with coverage against PostGIS service container.

## Known Doc Conflicts and Source of Truth

- `backend/ARCHITECTURE.md` and `backend/CLAUDE.md` are useful but older (last major update around 2026-02-06).
- For current behavior, prefer:
  - code under `app/` + tests under `tests/`
  - export Phase 6 docs in `flutter/docs/phases/` and `flutter/docs/handoffs/`
  - renderer contract at `video-renderer/docs/renderer-api-contract.md`

## Security Notes

- Renderer endpoints are currently unauthenticated unless you add network/API-key protection (see `docs/security-deferred.md`).
- Do not expose renderer port publicly in production.
- Storage service currently requires JWT-style Supabase service keys; `sb_secret_*` keys are treated as incompatible by current Python client path.

## Live-Tracking

-coming soon
