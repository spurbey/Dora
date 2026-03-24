# Renderer API Contract v2 (Internal: Backend -> Renderer)

Status: Draft  
Version header: `X-Renderer-Version: 2`  
Date: 2026-03-23

Canonical runtime architecture reference:
1. `video-renderer/docs/cinematic-gl-runtime-architecture.md`

## 1. Boundary

This document is for **internal renderer service** calls only.

It does not define public mobile/web API payloads.

Actors:

1. backend export worker
2. renderer service

---

## 2. Required headers

1. `X-Renderer-Version: 2`
2. `X-Renderer-Secret: <shared_secret>`
3. `Content-Type: application/json`

Version mismatch response:

```json
{
  "error": {
    "code": "version_mismatch",
    "message": "Unsupported renderer version",
    "retryable": false,
    "layer": "renderer",
    "details": {
      "expected": "2"
    }
  }
}
```

---

## 3. Endpoints

1. `POST /api/v1/render`
2. `GET /api/v1/render/{render_id}`
3. `DELETE /api/v1/render/{render_id}`
4. `GET /health` (no auth headers required)

---

## 4. `POST /api/v1/render`

## 4.1 Request schema

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
    "config": {},
    "renderer_config": {
      "map_style": "mapbox/standard",
      "style_revision": "rev_2026_03_20",
      "style_hash": "sha256_hex_optional",
      "mapbox_token": "optional_override"
    }
  }
}
```

## 4.2 Validation rules

1. all enum fields must be supported values.
2. `duration_sec > 0`, `fps > 0`.
3. `snapshot` must be JSON object without binary/base64 payloads.
4. for `template=cinematic`:
   - `renderer_config.map_style` required
   - one of `style_revision` or `style_hash` required
5. request must satisfy renderer limits for duration/fps/payload size.

Phase-scope simplification:

1. `renderer_preferences` is intentionally omitted from v2 phase-1 schema.
2. Any optional execution tuning keys must be added only after explicit contract update.

## 4.3 Success response

`202 Accepted`

```json
{
  "render_id": "uuid",
  "status": "queued"
}
```

---

## 5. `GET /api/v1/render/{render_id}`

## 5.1 Success response

`200 OK`

```json
{
  "render_id": "uuid",
  "status": "queued|rendering|completed|failed|canceled",
  "progress": 0.0,
  "output_path": null,
  "thumbnail_path": null,
  "engine_used": "cinematic_gl|cinematic_static_fallback|classic",
  "fallback_executed": false,
  "fallback_reason": null,
  "error": null
}
```

Completion rules:

1. when `status=completed`, both `output_path` and `thumbnail_path` are required.
2. when `status=failed`, `error` must be non-null.
3. `engine_used` is always required.
4. if `fallback_executed=true`, `engine_used` must be `cinematic_static_fallback`.

Fallback rules:

1. for `template=cinematic`, renderer attempts GL first.
2. on retry-eligible GL init/runtime errors, renderer performs one static compatibility retry.
3. fallback is internal reliability behavior and does not change client API shape.

---

## 6. `DELETE /api/v1/render/{render_id}`

Success `200`:

```json
{
  "canceled": true
}
```

Note:

1. Lambda backend may continue compute after cancellation request.
2. Worker state remains authoritative for final user-visible job state.

---

## 7. Error envelope

All non-2xx renderer responses must follow:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Human-readable message",
    "retryable": false,
    "layer": "renderer",
    "details": {}
  }
}
```

Fields:

1. `code`: stable machine code
2. `message`: human-readable
3. `retryable`: renderer-layer retry hint
4. `layer`: `renderer`
5. `details`: optional object

---

## 8. Error codes

Validation/auth:

1. `version_mismatch`
2. `unauthorized`
3. `renderer_auth_not_configured`
4. `validation_error`

Runtime:

1. `renderer_not_ready`
2. `queue_full`
3. `submit_failed`
4. `status_failed`
5. `cancel_failed`
6. `render_crash`

Status metadata markers (not error-envelope codes):

1. `fallback_executed=true`

Map/style:

1. `map_token_invalid`
2. `map_style_unreachable`
3. `map_style_revision_mismatch`
4. `gl_timeout_delay_render`
5. `gl_chunk_unstable`

---

## 9. Determinism and style pinning

For `template=cinematic`:

1. backend passes style pin metadata.
2. renderer verifies style metadata at render initialization.
3. mismatch fails with `map_style_revision_mismatch`.
4. frame planning must be deterministic and chunk-independent.

---

## 10. Migration strategy

1. phase A: renderer accepts version `1` and `2`
2. phase B: backend worker sends `2` only
3. phase C: remove version `1` support

Backward mapping for temporary dual support:

1. version `1` payloads are accepted with existing v1 behavior.

Rollback note:

1. During GL rollback windows, renderer may force `template=cinematic` to static compatibility engine while preserving v2 envelope/status shapes.

---

## 11. Contract test matrix

1. valid create render for `classic`
2. valid create render for `cinematic` with style pin fields
3. validation error for missing cinematic style pin fields
4. status completion includes output + thumbnail paths
5. cinematic GL failure path triggers exactly one static compatibility fallback retry
6. fallback status metadata correctness (`engine_used`, `fallback_executed`, `fallback_reason`)
7. error envelope shape for all non-2xx responses
8. dual-version compatibility test until v1 removal
