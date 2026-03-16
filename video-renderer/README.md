# Dora Video Renderer

Renderer service for Dora exports. This process is the render plane used by the backend export worker.

## Purpose and Boundaries

What this service does:

- exposes the renderer HTTP contract consumed by backend worker
- validates and executes render manifests
- runs local Remotion rendering or Lambda-backed rendering
- returns render status/progress and artifact locations

What this service does not do:

- does not own export job lifecycle persistence (backend owns that)
- does not expose end-user APIs directly
- does not issue app-level auth tokens

## HTTP Contract

Canonical contract doc:

- `docs/renderer-api-contract.md`

Endpoints:

- `POST /api/v1/render`
- `GET /api/v1/render/{render_id}`
- `DELETE /api/v1/render/{render_id}`
- `GET /health` (readiness/liveness for orchestration)

Required version header on render endpoints:

- `X-Renderer-Version: 1`

If header mismatch occurs, service returns:

- `400 {"error":"version_mismatch","expected":"1"}`

## Runtime Modes

Runtime selected by env:

- `RENDER_BACKEND=local`
  - in-process Remotion render via `@remotion/renderer`
  - artifacts written to local filesystem under `RENDER_OUTPUT_DIR`
- `RENDER_BACKEND=lambda`
  - render orchestration via `@remotion/lambda/client`
  - artifacts written to S3 (`s3://<bucket>/<key>`)

Notes:

- renderer supports templates `classic` and `cinematic`
- renderer validates manifest enums and prevents binary/base64 payloads in snapshot
- map styling/token can be injected into `snapshot.renderer_config`

## Project Layout

```text
video-renderer/
  src/
    server.js            express runtime + contract handlers
    lambda-renderer.js   lambda backend adapter
    remotion/            compositions and data helpers
  scripts/
    deploy-function.js   deploy remotion lambda function
    deploy-site.js       deploy remotion site bundle
  docs/
    renderer-api-contract.md
```

## Environment

Copy env template:

```powershell
copy .env.example .env
```

Core variables:

- `PORT` (default `3100`)
- `RENDER_BACKEND` (`local|lambda`)
- `RENDER_OUTPUT_DIR`
- `RENDERER_MAPBOX_TOKEN` (optional but recommended for cinematic map context)
- `RENDERER_MAP_STYLE` (default `mapbox/navigation-night-v1`)
- `REMOTION_CHROME_EXECUTABLE` (optional override for local chrome path)

Lambda variables:

- `AWS_REGION`
- `LAMBDA_FUNCTION_NAME`
- `LAMBDA_SERVE_URL`
- `LAMBDA_OUTPUT_BUCKET`
- `LAMBDA_MEMORY_MB`
- `LAMBDA_TIMEOUT_SECONDS`
- `LAMBDA_DISK_MB`
- `LAMBDA_ARCHITECTURE`
- `LAMBDA_SITE_NAME`
- `LAMBDA_SITE_BUCKET` (optional; falls back to output bucket)
- `LAMBDA_FRAMES_PER_LAMBDA`

## Local Development

```bash
cd video-renderer
npm install
npm run dev
```

On startup, renderer initializes selected backend:

- local mode bundles compositions and prepares render runtime
- lambda mode validates required lambda env immediately

## Integration with Backend Worker

Backend worker config must point here:

- `RENDERER_URL=http://renderer:3100` (docker)
- `RENDERER_URL=http://localhost:3100` (local host setup)

The backend chooses renderer adapter by `RENDER_BACKEND` and still talks HTTP for both local and lambda modes.

## Smoke Test (PowerShell)

### 1) Start renderer

```powershell
cd C:\Users\sumit\Downloads\Dora\video-renderer
npm run dev
```

If browser discovery fails in local mode:

```powershell
$env:REMOTION_CHROME_EXECUTABLE='C:\Program Files\Google\Chrome\Application\chrome.exe'
npm run dev
```

### 2) Submit render

```powershell
$body = @'
{
  "job_id": "smoke-test-1",
  "template": "classic",
  "aspect_ratio": "9:16",
  "quality": "720p",
  "duration_sec": 5,
  "fps": 30,
  "snapshot": {
    "trip": { "title": "Smoke Test Trip" },
    "places": [],
    "media": []
  }
}
'@

curl.exe -s -X POST http://localhost:3100/api/v1/render `
  -H "Content-Type: application/json" `
  -H "x-renderer-version: 1" `
  -d $body
```

### 3) Poll status

```powershell
curl.exe -s http://localhost:3100/api/v1/render/<render_id> `
  -H "x-renderer-version: 1"
```

### 4) Verify artifact (local mode)

```powershell
Get-ChildItem C:\Users\sumit\Downloads\Dora\video-renderer\render_artifacts\*.mp4 |
  Select-Object Name,Length,LastWriteTime
```

### 5) Cancel-path check

```powershell
curl.exe -s -X DELETE http://localhost:3100/api/v1/render/<render_id> `
  -H "x-renderer-version: 1"
```

## Lambda Deploy Flow

Deploy function:

```bash
cd video-renderer
npm run deploy:function
```

Deploy site bundle:

```bash
cd video-renderer
npm run deploy:site
```

`deploy-function.js` emits deployed function name.
`deploy-site.js` emits `serveUrl` to be used as `LAMBDA_SERVE_URL`.

## Operational Behavior Notes

- Lambda cancel semantics:
  - renderer `cancel` is intentionally no-op once lambda render is submitted
  - backend marks job canceled in DB; lambda work may continue billing until completion
- Local artifact paths are normalized by backend worker before persistence/upload.
- Lambda mode stores both output and thumbnail artifact keys in S3 paths.
- Health endpoint returns `503` until backend initialization completes.

## Security Notes

- Render endpoints are version-gated but not user-authenticated by default.
- Keep renderer on private network boundaries; do not expose public ingress without extra auth controls.
- See deferred security backlog in `../docs/security-deferred.md`.

## Troubleshooting

- `version_mismatch`:
  - ensure backend/clients send `X-Renderer-Version: 1`
- `validation_error`:
  - verify manifest enum values and positive `duration_sec`/`fps`
- local render startup failures:
  - set `REMOTION_CHROME_EXECUTABLE`
  - verify Node version (`>=20`)
- lambda config failures:
  - verify all required lambda env variables are set
  - verify IAM policies under `../infra/remotion/`

## Related Docs

- `docs/renderer-api-contract.md`
- `../infra/README.md`
- `../infra/remotion/README.md`
- `../flutter/docs/phases/Phase-6-PRD.md`
- `../flutter/docs/handoffs/phase6c-cloud-scale-report.md`
