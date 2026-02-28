# Video Renderer Service (Phase 6)

This folder hosts the local Remotion render service used by the backend export worker.

## Contract First

The API contract is frozen in:
- `video-renderer/docs/renderer-api-contract.md`

Phase 6B implementation must conform to that contract.

## Planned Runtime

- Node + Express server
- Remotion composition render pipeline
- Output directory from `RENDER_OUTPUT_DIR`

## Local Orchestration

Use either:
- `docker-compose.dev.yml` (api + worker + renderer + db), or
- `Procfile.dev` for multi-process local runs.

Required env vars for renderer:
- `PORT` (default `3100`)
- `RENDER_OUTPUT_DIR` (shared with worker)

## Current State

Scaffold docs only. Service implementation begins in Phase 6B.
