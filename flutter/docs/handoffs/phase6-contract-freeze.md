# Phase 6 Contract Freeze (6A Gate)

Date: 2026-02-28  
Phase: 6A - Control Plane and Product Wiring  
Status: Frozen for 6A implementation

## 1. Export Status Enum and Transition Rules

Status enum:

- `queued`
- `processing`
- `cancel_requested`
- `completed` (terminal)
- `failed`
- `blocked` (terminal, worker-set only)
- `canceled` (terminal)

Authoritative transitions:

- `queued -> processing` (worker claim)
- `queued -> canceled` (user cancel before claim)
- `processing -> completed`
- `processing -> failed` (retryable)
- `processing -> blocked` (non-retryable terminal)
- `processing -> cancel_requested` (async cancel signal)
- `processing -> canceled` (confirmed cancel)
- `cancel_requested -> canceled`
- `cancel_requested -> completed` (race: render completed before cancel took effect)
- `failed -> queued` (automatic retry with backoff)

Invalid transitions must return `409` with `invalid_transition`.

## 2. Export Stage Enum

Stage enum:

- `snapshotting`
- `asset_fetch`
- `rendering`
- `encoding`
- `uploading`
- `finalizing`

6B implementation note:
- `uploading` guarantees MP4 artifact upload to private export storage.
- `thumbnail_url` may be populated from an existing snapshot media URL in 6B.
- Renderer-produced export thumbnail artifact upload is deferred to 6D hardening.

## 3. API Contract (Frozen)

### 3.1 Create Export

`POST /api/v1/trips/{trip_id}/export`

Request:

```json
{
  "template": "classic",
  "aspect_ratio": "9:16",
  "duration_sec": 15,
  "quality": "720p",
  "fps": 30
}
```

Response `202`:

```json
{
  "job_id": "uuid",
  "status": "queued",
  "stage": null,
  "progress": 0.0
}
```

Response `409` (duplicate):

```json
{
  "error": "duplicate_job",
  "existing_job_id": "uuid",
  "detail": "An identical export is already queued or processing."
}
```

Response `422` (precondition failed):

```json
{
  "error": "export_precondition_failed",
  "reason": "trip_not_synced|pending_media|pending_sync",
  "detail": "Human-readable explanation."
}
```

### 3.2 Get Export Status

`GET /api/v1/exports/{job_id}`

Response `200`:

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
  "render_duration_ms": null,
  "created_at": "2026-02-27T10:00:00Z",
  "started_at": "2026-02-27T10:00:05Z",
  "completed_at": null
}
```

### 3.3 Cancel Export

`POST /api/v1/exports/{job_id}/cancel`

Response rules:

- `200` when current status is `queued`, body: `{"status":"canceled"}`
- `202` when current status is `processing`, body: `{"status":"cancel_requested"}`
- `202` when current status is already `cancel_requested`, body: `{"status":"cancel_requested"}`
- `409` when current status is `completed|blocked|canceled|failed`, body includes:

```json
{
  "error": "invalid_transition",
  "current_status": "..."
}
```

### 3.4 Get Download URL

`GET /api/v1/exports/{job_id}/download-url`

Response `200`:

```json
{
  "download_url": "https://storage.example.com/exports/private/.../output.mp4?token=...",
  "expires_at": "2026-02-27T11:00:00Z",
  "ttl_seconds": 3600
}
```

Only valid for `status == completed`; otherwise `409`.

### 3.5 Get Share URL

`GET /api/v1/exports/{job_id}/share`

Response `200`:

```json
{
  "share_url": "https://api.dora.app/api/v1/shares/abc123",
  "expires_at": "2026-03-06T10:00:00Z",
  "ttl_seconds": 604800
}
```

`share_url` is a backend revocable token URL, not a raw 7-day S3 presigned URL.

## 4. URL and Token TTL Freeze

- Download presigned URL TTL: `3600s` (1 hour)
- Share token lifetime: `604800s` (7 days)
- Share redirect presigned URL TTL: `60s`

## 5. Storage Privacy Model Freeze

- Export artifacts are private by default.
- Download uses short-lived presigned URLs.
- Sharing uses revocable backend token flow.
- Public export path is explicit action only (not implicit on completion).

## 6. Quality and Tier Caps Freeze

- Free tier: max `720p`, max `15s`
- Paid tier: max `1080p`, max `60s`

## 7. Concurrency Caps Freeze

- Per-user active export cap: `2`
- Global active queue cap: `50`

## 8. Pre-Submit Guard Freeze (All Required)

- `trip.serverTripId != null`
- No pending/failed media queue items for this trip
- No blocking sync tasks for this trip

## 9. Blocked Semantics Freeze

- `blocked` is server-side and worker-set only.
- `blocked` is never set during job creation.
- Client-side pre-submit guard failures return `422` and do not create `blocked` jobs.

## 10. Renderer Contract Reference

Renderer API contract freeze reference:

- `video-renderer/docs/renderer-api-contract.md`

Frozen requirements include:

- `POST /api/v1/render`
- `GET /api/v1/render/{render_id}`
- `DELETE /api/v1/render/{render_id}`
- `X-Renderer-Version: 1` header requirement

## 11. 6C Addendum Freeze (Lambda Mode)

These clarifications are frozen before 6C execution:

- Backend worker remains HTTP-only toward renderer (`LambdaRemotionRenderer` is an HTTP adapter).
- Node renderer service owns `@remotion/lambda` SDK calls.
- Remotion version policy: exact same patch version across `remotion` and all `@remotion/*` packages; no range specifiers.
- Lambda output destination uses `outName: {bucketName, key}`.
- `getRenderProgress` polling uses the `bucketName` returned by `renderMediaOnLambda`.
- Cancel semantics follow current worker model:
  - `cancel_requested -> completed` when render already completed (race accepted)
  - otherwise worker settles `canceled` immediately after cancel path
- IAM principal split:
  - renderer runtime principal for Lambda invoke path
  - backend runtime principal for presigned download path
- Scope boundary:
  - 6C includes download presigned URL path
  - share-token revocation hardening and `pinned_at` lifecycle protection remain 6D work
- Runtime timeout split:
  - Lambda function timeout remains `900s` (deploy-time setting)
  - renderer call watchdog remains `timeoutInMilliseconds=240000` for delayRender resolution

Decision log (2026-03-02):

- Branch execution explicitly accepts the 6C scope boundary above.
- 6C completion gate for this branch is implementation + evidence for cloud rendering, not 6D hardening items.

## 12. Sign-Off

Contract freeze completed for 6A gate on 2026-02-28.  
6C addendum freeze recorded on 2026-03-01.
