# Renderer API Contract v2 (Draft for Phase 6D)

Status: draft
Version Header: `X-Renderer-Version: 2`
Date: 2026-03-08

## 1. Purpose

This draft extends the v1 renderer contract to support 6D hardening requirements:
- export-owned thumbnail artifact generation,
- richer artifact metadata,
- consistent local/lambda output mapping for worker finalization.

v1 remains the active production contract until this draft is implemented and signed off.

## 2. Compatibility Strategy

- Renderer should support both version headers during migration:
  - `X-Renderer-Version: 1` -> v1 response shape
  - `X-Renderer-Version: 2` -> v2 response shape
- Backend worker should be upgraded to v2 only after renderer dual-support is verified.

## 3. Render Manifest Schema (v2)

`POST /api/v1/render`

```json
{
  "job_id": "uuid",
  "template": "classic|cinematic",
  "aspect_ratio": "9:16|1:1|16:9",
  "quality": "480p|720p|1080p",
  "duration_sec": 15,
  "fps": 30,
  "snapshot": {},
  "thumbnail": {
    "enabled": true,
    "capture_frame": "auto"
  }
}
```

Rules:
- `thumbnail.enabled` defaults to `true`.
- `capture_frame=auto` allows renderer to choose best scene frame.

## 4. Endpoints (v2)

## 4.1 Create Render

`POST /api/v1/render`

Response `202`:
```json
{
  "render_id": "uuid",
  "status": "queued"
}
```

## 4.2 Get Render Status

`GET /api/v1/render/{render_id}`

Response `200`:
```json
{
  "render_id": "uuid",
  "status": "queued|rendering|completed|failed|canceled",
  "progress": 0.0,
  "output_path": "s3://.../output.mp4",
  "thumbnail_path": "s3://.../thumbnail.jpg",
  "artifacts": {
    "video": {
      "path": "s3://.../output.mp4",
      "codec": "h264",
      "container": "mp4",
      "size_bytes": 123456
    },
    "thumbnail": {
      "path": "s3://.../thumbnail.jpg",
      "mime_type": "image/jpeg",
      "size_bytes": 12345
    }
  },
  "error": null
}
```

Rules:
- `thumbnail_path` is required when `status=completed`.
- `output_path` and `thumbnail_path` must resolve under private export storage path.
- `artifacts` is optional for intermediate statuses, required for `completed`.

## 4.3 Cancel Render

`DELETE /api/v1/render/{render_id}`

Response `200`:
```json
{
  "canceled": true
}
```

## 5. Error Codes

Validation errors:
- `validation_error`
- `version_mismatch`

Runtime failures:
- `render_crash`
- `asset_all_404`
- `lambda_throttle`
- `lambda_timeout`
- `upload_failed`

## 6. Worker Integration Requirements

Backend worker v2 behavior:
1. read `thumbnail_path` from renderer status on completion
2. persist export-owned thumbnail URL (not source media URL fallback)
3. keep `output_path` + `thumbnail_path` together as completed artifact set

## 7. Sign-Off Checklist

- [ ] renderer supports v1 and v2 headers
- [ ] backend worker consumes v2 status fields
- [ ] completed job always has `output_url` and `thumbnail_url`
- [ ] rollback path to v1 documented

