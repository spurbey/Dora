# Renderer API Contract (Phase 6A Freeze)

Version: `1`  
Last Updated: 2026-02-27

## 1. Overview

This document defines the frozen HTTP contract between:

- Backend export worker (`backend/app/workers/export_worker.py`)
- Renderer service (`video-renderer/` in 6B)

Transport protocol: **HTTP REST only**.

All requests from backend to renderer must include:

- `X-Renderer-Version: 1`
- `Content-Type: application/json` (where request body exists)

If `X-Renderer-Version` is missing or unsupported, renderer returns:

- `400 Bad Request`
- Body: `{"error":"version_mismatch","expected":"1"}`

## 2. Render Manifest Schema

`POST /api/v1/render` accepts:

```json
{
  "job_id": "uuid",
  "template": "classic|cinematic",
  "aspect_ratio": "9:16|1:1|16:9",
  "quality": "480p|720p|1080p",
  "duration_sec": 15,
  "fps": 30,
  "snapshot": {
    "trip": {},
    "timeline": [],
    "routes": [],
    "places": [],
    "media": [],
    "config": {}
  }
}
```

Validation rules:

- `snapshot` must be JSON object (no binary/base64 payloads).
- `duration_sec > 0`
- `fps > 0`
- `template`, `aspect_ratio`, `quality` must be supported enum values.

## 3. Endpoints

### 3.1 Create Render

`POST /api/v1/render`

Success:

- `202 Accepted`
- Body:

```json
{
  "render_id": "uuid",
  "status": "queued"
}
```

Validation error:

- `422 Unprocessable Entity`
- Body:

```json
{
  "error": "validation_error",
  "detail": "Human-readable validation message"
}
```

### 3.2 Get Render Status

`GET /api/v1/render/{render_id}`

Success:

- `200 OK`
- Body:

```json
{
  "render_id": "uuid",
  "status": "queued|rendering|completed|failed",
  "progress": 0.0,
  "output_path": "/render_artifacts/{render_id}.mp4",
  "error": null
}
```

Rules:

- `progress` is in `0.0..1.0`.
- `output_path` is `null` unless `status == completed`.
- `output_path` must resolve inside renderer `RENDER_OUTPUT_DIR`.

Not found:

- `404 Not Found`
- Body:

```json
{
  "error": "not_found"
}
```

### 3.3 Cancel Render

`DELETE /api/v1/render/{render_id}`

Success:

- `200 OK`
- Body:

```json
{
  "canceled": true
}
```

Not found:

- `404 Not Found`
- Body:

```json
{
  "error": "not_found"
}
```

## 4. Containerized Local Development Requirement

When running in Docker, `api`, `worker`, and `renderer` are separate containers.
If renderer returns an `output_path`, the worker must be able to read it.

Required setup:

- Shared named volume mounted at the same path (example: `/render_artifacts`) in both `worker` and `renderer`.
- `RENDER_OUTPUT_DIR` env var must be identical in both services.

## 5. Backward Compatibility Rules

- Any response/body field change requires version bump (`X-Renderer-Version`) and PRD/checklist update.
- 6B implementation must conform to this file before feature work proceeds.
