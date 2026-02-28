# Video Renderer Service (Phase 6B)

This folder hosts the local renderer service used by the backend export worker.

## Contract

Renderer HTTP contract:
- `video-renderer/docs/renderer-api-contract.md`

Implemented endpoints:
- `POST /api/v1/render`
- `GET /api/v1/render/{render_id}`
- `DELETE /api/v1/render/{render_id}`

All requests must include:
- `X-Renderer-Version: 1`

## Runtime

- Node + Express service (`src/server.js`)
- In-memory render lifecycle (`queued -> rendering -> completed|failed`)
- Artifacts written to `RENDER_OUTPUT_DIR`

## Local Run

```bash
cd video-renderer
npm install
npm run dev
```

Required env vars:
- `PORT` (default `3100`)
- `RENDER_OUTPUT_DIR` (must be shared with backend worker in Docker)

Backend worker must use:
- `RENDER_BACKEND=local`
- `RENDERER_URL=http://renderer:3100` (or local host URL outside Docker)

Or use root orchestration:
- `docker-compose.dev.yml`
- `Procfile.dev`
