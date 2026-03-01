# Video Renderer Service (Phase 6B/6C)

This folder hosts the renderer service used by the backend export worker in both local and Lambda modes.

## Contract

Renderer HTTP contract:
- `video-renderer/docs/renderer-api-contract.md`

Implemented endpoints:
- `POST /api/v1/render`
- `GET /api/v1/render/{render_id}`
- `DELETE /api/v1/render/{render_id}`

Required request header on all renderer routes:
- `X-Renderer-Version: 1`

## Runtime

- Node + Express service (`src/server.js`)
- Frozen HTTP contract (`renderer-api-contract.md`) for both modes
- `RENDER_BACKEND=local`: in-process Remotion rendering, artifacts written to `RENDER_OUTPUT_DIR`
- `RENDER_BACKEND=lambda`: `@remotion/lambda` orchestration, artifacts written to S3 (`s3://...`)

## Local Run

```bash
cd video-renderer
npm install
npm run dev
```

Required env vars:
- `PORT` (default `3100`)
- `RENDER_BACKEND` (`local` or `lambda`, default `local`)
- `RENDER_OUTPUT_DIR` (must be shared with backend worker in Docker)

Additional env vars for Lambda mode:
- `AWS_REGION`
- `LAMBDA_FUNCTION_NAME`
- `LAMBDA_SERVE_URL`
- `LAMBDA_OUTPUT_BUCKET`

Backend worker must use:
- `RENDER_BACKEND=local`
- `RENDERER_URL=http://renderer:3100` (or localhost URL outside Docker)

Lambda deploy helpers:

```bash
cd video-renderer
npm run deploy:function
npm run deploy:site
```

Or use root orchestration:
- `docker-compose.dev.yml`
- `Procfile.dev`

## Smoke Test (Windows PowerShell)

Run these in order. Keep terminal A running for server logs.

### 1. Start server (terminal A)

```powershell
cd C:\Users\sumit\Downloads\Dora\video-renderer
npm run dev
```

Wait for:

`[renderer] bundle ready — 1 composition(s): Classic`

If bundle init fails due browser discovery, set Chrome path and restart:

```powershell
$env:REMOTION_CHROME_EXECUTABLE='C:\Program Files\Google\Chrome\Application\chrome.exe'
npm run dev
```

### 2. Submit render (terminal B)

Use `curl.exe` (not PowerShell `curl` alias):

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

$resp = curl.exe -s -X POST http://localhost:3100/api/v1/render `
  -H "Content-Type: application/json" `
  -H "x-renderer-version: 1" `
  -d $body

$resp
```

Expected: JSON with `render_id` and `status: "queued"`.

### 3. Poll status to completion

Replace `<render_id>` with value from step 2.

```powershell
curl.exe -s http://localhost:3100/api/v1/render/<render_id> `
  -H "x-renderer-version: 1"
```

Repeat until status is `completed` or `failed`.

### 4. Verify output file

```powershell
Get-ChildItem C:\Users\sumit\Downloads\Dora\video-renderer\render_artifacts\*.mp4 |
  Select-Object Name,Length,LastWriteTime
```

Pass criteria:
- API status is `completed`
- output `.mp4` exists
- output size is non-zero
- video opens in a player

### 5. Cancel-path smoke (recommended)

Submit a longer render (e.g., `duration_sec: 30`), then cancel while `rendering`:

```powershell
curl.exe -s -X DELETE http://localhost:3100/api/v1/render/<render_id> `
  -H "x-renderer-version: 1"
```

Then poll again (with version header) and verify final canceled/failed-with-cancel state.

### 6. Negative contract checks (recommended)

- Missing version header should return `400 version_mismatch`
- Invalid payload should return `422 validation_error`
