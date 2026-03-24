# PRD: Cinematic GL Export (Remotion + Mapbox + Lambda)

Status: Draft for sign-off  
Owner: Rendering Team  
Last updated: 2026-03-23

Canonical runtime architecture:
1. `video-renderer/docs/cinematic-gl-runtime-architecture.md` (this overrides conflicting runtime-flow text)

## 1. Final Product Decision

We are removing profile/premium split complexity.

New template model:

1. `classic` = existing slideshow-style template.
2. `cinematic` = **new GL cinematic engine** (Mapbox GL + deterministic frame plan).

This means:

1. Old static-map cinematic implementation is obsolete.
2. No `standard` vs `cinematic_plus` profile axis.
3. No profile-based billing or queue partitioning.

---

## 2. Why this simplification

1. One cinematic path is easier to operate and reason about.
2. Lower API/model complexity.
3. Faster implementation and rollout.
4. Fewer contract and migration risks.

---

## 3. Scope

## 3.1 In scope

1. Replace `Cinematic` composition internals with GL cinematic runtime.
2. Keep template key as `cinematic` (no new template enum needed).
3. Deterministic frame planner for camera/route/marker/overlay sync.
4. Lambda tuning for GL stability and quality.
5. Contract updates for style pinning and renderer error envelope.
6. Reliability fallback path for cinematic:
   - attempt GL first
   - one automatic retry on static cinematic compatibility engine on eligible failures
   - persist fallback metadata for support/debug visibility.

## 3.2 Out of scope

1. Profile-based pricing/tier routing.
2. Profile-specific queues and dedup keys.
3. User-selectable static cinematic mode as a product option.
4. Permanent dual-engine cinematic product split after stabilization.

---

## 4. Current to Target Mapping

Current:

1. `cinematic` template exists but uses static map image approach.

Target:

1. `cinematic` template uses GL runtime.
2. Template enum remains unchanged:
   - `classic`
   - `cinematic`

Migration semantics:

1. Existing API consumers keep sending `template=cinematic`.
2. They automatically get the new GL cinematic renderer once deployed.

---

## 5. Architecture

## 5.1 Rendering stack

1. Backend creates export job and snapshot.
2. Worker calls renderer service.
3. Renderer maps template to composition:
   - `classic -> Classic`
   - `cinematic -> Cinematic` (GL implementation)
4. Remotion renders via local or Lambda backend.
5. Worker persists artifact URLs and status.

## 5.2 Deterministic frame contract

For frame `f`, every visual output must come from one shared `frameState(f)`:

1. camera transform
2. marker position + heading
3. route draw progress
4. overlays opacity/layout states

No subsystem may use independent frame timing math.

## 5.3 Reliability fallback semantics

For `template=cinematic`:

1. Primary execution path is GL.
2. If GL fails with retry-eligible init/runtime map errors, renderer performs one static cinematic compatibility retry.
3. Fallback is operational safety, not a separate user-facing template choice.
4. Renderer status must expose:
   - `engine_used`
   - `fallback_executed`
   - `fallback_reason` (nullable)

---

## 6. API Contracts

## 6.1 Public API (`client -> backend`)

Public endpoint family (unchanged):

1. `POST /api/v1/trips/{trip_id}/export`
2. `GET /api/v1/exports/{job_id}`
3. `POST /api/v1/exports/{job_id}/cancel`
4. `GET /api/v1/exports`
5. `GET /api/v1/exports/{job_id}/download-url`
6. `GET /api/v1/exports/{job_id}/share`

Request:

```json
{
  "template": "classic|cinematic",
  "aspect_ratio": "9:16|1:1|16:9",
  "duration_sec": 15,
  "quality": "480p|720p|1080p",
  "fps": 30
}
```

No profile fields.

`GET /api/v1/exports/{job_id}` success (`200`) shape:

```json
{
  "job_id": "uuid",
  "status": "queued|processing|cancel_requested|completed|failed|canceled|blocked",
  "stage": "snapshotting|asset_fetch|rendering|encoding|uploading|finalizing|null",
  "progress": 0.0,
  "output_url": null,
  "thumbnail_url": null,
  "error_code": null,
  "error_message": null,
  "created_at": "iso8601"
}
```

`POST /api/v1/exports/{job_id}/cancel` success (`200`) shape:

```json
{
  "status": "cancel_requested|canceled|completed"
}
```

List/download/share endpoints remain unchanged and out of scope for schema change in this PRD.

## 6.2 Internal API (`backend -> renderer`)

Use `X-Renderer-Version: 2` and `X-Renderer-Secret: <shared_secret>` with the schema in:

1. [renderer-api-contract-v2-draft.md](c:/Users/sumit/Downloads/Dora/video-renderer/docs/renderer-api-contract-v2-draft.md)

Key additions vs v1:

1. style pinning metadata (`style_revision` / `style_hash`) for cinematic.
2. standardized renderer error envelope.
3. cinematic engine metadata in status (`engine_used`, `fallback_executed`, `fallback_reason`).

v2 scope is intentionally minimal for this phase:

1. do not add profile/premium routing fields.
2. keep optional extension fields limited to explicitly implemented keys.

## 6.3 Error format (public export domain)

```json
{
  "error": {
    "code": "export_precondition_failed",
    "message": "Upload all media before exporting.",
    "retryable": false,
    "details": {
      "reason": "pending_media"
    }
  }
}
```

---

## 7. Map and Motion Logic

## 7.1 Map mode by template

1. `classic`: unchanged.
2. `cinematic`: GL map runtime.

## 7.2 Camera runtime rule

1. Use `jumpTo` per frame (no `easeTo`/`flyTo` in export path).
2. Gate render start with `delayRender()` until style ready.

## 7.3 Style pinning requirement

For `template=cinematic`:

1. Snapshot includes `renderer_config.map_style`.
2. Renderer verifies `renderer_config.style_revision` or `style_hash`.
3. Mismatch fails with `map_style_revision_mismatch`.

---

## 8. Infra and AWS

## 8.1 Lambda baseline settings (cinematic)

1. memory: `4096 MB`
2. disk: `4096 MB`
3. timeout: `900s`
4. `framesPerLambda`: `20-40` initial
5. `concurrencyPerLambda`: `1`
6. image format: `png`

## 8.2 Naming convention (exact)

1. function: `dora-render-{env}-fn-main`
2. site bucket: `dora-render-{env}-site`
3. output bucket: `dora-render-{env}-output`
4. dashboard: `dora-render-{env}-dashboard`

## 8.3 CloudWatch dashboard minimum JSON

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "Invocations Errors Throttles",
        "metrics": [
          ["AWS/Lambda", "Invocations", "FunctionName", "dora-render-prod-fn-main"],
          [".", "Errors", ".", "."],
          [".", "Throttles", ".", "."]
        ],
        "stat": "Sum",
        "period": 60
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "Duration p50/p95",
        "metrics": [
          ["AWS/Lambda", "Duration", "FunctionName", "dora-render-prod-fn-main", {"stat":"p50"}],
          [".", "Duration", ".", ".", {"stat":"p95"}]
        ],
        "period": 60
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "Concurrency",
        "metrics": [
          ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", "dora-render-prod-fn-main"],
          [".", "ClaimedAccountConcurrency", ".", "."]
        ],
        "period": 60
      }
    }
  ]
}
```

---

## 9. Queue, Retry, and Dedup

## 9.1 Queue policy

Single queue, FIFO by `created_at`.

Ownership:

1. backend worker claim path is authoritative.
2. renderer only enforces local active render cap.

## 9.2 Layered retry policy

Retry accounting source-of-truth:

1. `export_jobs.retry_count`.

Layer rules:

1. worker retry increments `retry_count`.
2. lambda chunk retries (`maxRetries`) do not increment `retry_count`.
3. renderer internal retries are part of one worker attempt.
4. GL -> static fallback retry is internal to one worker attempt and does not increment `retry_count` when successful.

Initial defaults:

1. worker `max_retries = 3`
2. lambda `maxRetries = 1`

## 9.3 Dedup strategy

Fingerprint:

1. `dedup_fingerprint = sha256(snapshot_hash + template + aspect_ratio + quality + duration_sec + fps)`

Collision handling:

1. transactional duplicate check under lock
2. active-status partial unique index on `(user_id, trip_id, dedup_fingerprint)` where status in `queued|processing|cancel_requested`
3. duplicate returns `409 existing_job_id`
4. suspected hash collision logs audit event and allows new job

Rollout scope:

1. dedup DB hardening is recommended for launch readiness but can be executed as a parallel hardening stream if GL rollout timing is critical.

---

## 10. Cost model

Drivers:

1. Lambda compute (invocations x duration x memory)
2. S3 storage/requests
3. Mapbox GL map/session usage

Chunk relation:

1. `chunks = ceil(total_frames / framesPerLambda)`
2. lower `framesPerLambda` improves stability but raises cost

---

## 11. Rollout plan

1. Phase A: local cinematic GL prototype.
2. Phase B: Lambda cinematic GL stabilization.
3. Phase C: replace cinematic implementation in production.
4. Phase D: cohort rollout with monitoring.
5. Phase E: full rollout after gates pass.

## 11.1 Rollback runbook (explicit)

Rollback triggers (any one):

1. staging or prod completion rate drops below gate threshold.
2. sustained `map_style_revision_mismatch` or `gl_timeout_delay_render` spike.
3. quality gate regression on golden fixtures.

Rollback steps:

1. set renderer feature flag to map `template=cinematic` to static cinematic compatibility engine.
2. keep accepting internal renderer contract v1/v2 during rollback window.
3. drain in-flight GL jobs; new cinematic jobs use static compatibility engine.
4. keep artifacts/status APIs unchanged for clients.
5. after stabilization, re-enable GL behind controlled cohort.

---

## 12. Quality gates (go/no-go)

1. visual:
   - SSIM >= 0.985 on fixture suite
2. determinism:
   - planner/frame-state hash consistency = 100% for same manifest
   - static overlays hash match >= 99.9%
   - full-frame validation uses SSIM + seam metrics (not full-frame hash equality)
3. seam continuity:
   - no chunk seam camera jump > 0.0005 deg
   - no seam marker jump > 3 px @1080p normalized
4. stability:
   - >= 99% completion over 500 staging jobs
5. cost:
   - p95 cost/export within approved envelope for 7 days

---

## 13. File-by-file changes

1. `video-renderer/src/remotion/Cinematic.jsx`
   - replace static cinematic internals with GL runtime.
2. `video-renderer/src/remotion/Root.jsx`
   - keep composition id `Cinematic`; points to GL implementation.
3. `video-renderer/src/server.js`
   - no profile handling; keep template-based routing.
   - add cinematic GL->static fallback policy wiring and fallback metadata in status.
4. `video-renderer/src/lambda-renderer.js`
   - cinematic-specific GL-friendly render options.
   - expose fallback metadata fields on terminal status payloads.
5. `video-renderer/package.json`
   - add `mapbox-gl`.
6. `backend/app/services/export_service.py`
   - ensure snapshot renderer_config includes style pin metadata for cinematic manifests.
7. `backend/app/services/export_renderer.py`
   - internal manifest/status schema updates for v2 fields (`engine_used`, fallback metadata).
8. `backend/app/workers/export_worker.py`
   - preserve renderer fallback metadata in export job terminal status/logging.
9. `video-renderer/docs/renderer-api-contract-v2-draft.md`
   - internal v2 contract (style pinning + error envelope).

---

## 14. Open decisions

1. final `crf` value for cinematic default
2. final style family default (`navigation-night-v1` vs `mapbox/standard`)
3. final `framesPerLambda` value after telemetry

---

## Appendix A: Flutter API client regeneration

Only required if public backend OpenAPI schema changed.

```bash
curl http://localhost:8000/openapi.json -o flutter/openapi.json
cd flutter
npx @openapitools/openapi-generator-cli generate -c openapi-generator-config.yaml
```

Post-steps:

1. review `flutter/packages/dora_api/**` diff
2. bump generated package version if needed
3. run Flutter tests
4. do not hand-edit generated files

---

## Appendix B: DB migration / rollback SQL (dedup hardening)

Upgrade:

```sql
ALTER TABLE export_jobs
  ADD COLUMN dedup_fingerprint TEXT NULL;

CREATE UNIQUE INDEX idx_export_jobs_dedup_active_unique
  ON export_jobs (user_id, trip_id, dedup_fingerprint)
  WHERE dedup_fingerprint IS NOT NULL
    AND status IN ('queued', 'processing', 'cancel_requested');
```

Rollback:

```sql
DROP INDEX IF EXISTS idx_export_jobs_dedup_active_unique;

ALTER TABLE export_jobs
  DROP COLUMN IF EXISTS dedup_fingerprint;
```
