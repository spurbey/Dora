# Phase 6B Kickoff Procedure

Date: 2026-02-28
Phase: 6B - Remotion MVP Renderer (Local First)
Branch: `phase-6-video-export`

## 1. Objective

Deliver end-to-end local Remotion rendering with real stage progress, cancel handling, and playable export artifacts, while staying within Phase 6 PRD and checklist guardrails.

## 2. Entry Gates (Must Be True Before 6B Build)

- `phase6-contract-freeze.md` exists and is frozen.
- `video-renderer/docs/renderer-api-contract.md` exists and is frozen.
- 6A codebase is merged and green in dependency-ready local environment.
- No unresolved status/cancel contract conflicts in backend API behavior.

## 3. Execution Sequence

### 6B-0: Gate Verification and Tooling Baseline

1. Confirm no contract drift in:
   - `flutter/docs/handoffs/phase6-contract-freeze.md`
   - `video-renderer/docs/renderer-api-contract.md`
2. Record kickoff state in `phase6-rolling-handoff.md`.
3. Ensure local orchestration is usable:
   - `docker-compose.dev.yml`
   - `Procfile.dev`

Exit criteria:
- Contract files unchanged from freeze intent.
- 6B backlog and ownership documented.

### 6B-1: Renderer Service Scaffold (`video-renderer/`)

1. Implement Node/Express service with frozen endpoints:
   - `POST /api/v1/render`
   - `GET /api/v1/render/{render_id}`
   - `DELETE /api/v1/render/{render_id}`
2. Enforce `X-Renderer-Version: 1` request header.
3. Add manifest validation and strict response schema.
4. Render one `classic` composition at:
   - qualities: `480p`, `720p`
   - aspect ratios: `9:16`, `16:9`
   - fps: `30`
5. Output artifacts to `RENDER_OUTPUT_DIR` only.

Exit criteria:
- Renderer API responds per contract.
- Render output is generated and accessible in shared output volume.

### 6B-2: Backend Renderer Integration

1. Implement `LocalRemotionRenderer` in `export_renderer.py` (HTTP via `httpx`).
2. Wire worker `rendering` stage to renderer API poll loop.
3. Preserve cancel semantics:
   - DB status check at each stage boundary
   - on `cancel_requested`, call renderer cancel and settle to `canceled`
   - accept race completion (`cancel_requested -> completed`) per freeze contract
4. Finalize all stage transitions and metadata persistence:
   - `output_url`, `thumbnail_url`, `render_duration_ms`, `completed_at`

Exit criteria:
- One full job runs through all 6 stages and completes.
- Cancel path verified during `rendering` and one additional stage boundary.

### 6B-3: Flutter UX Upgrade

1. Add template-first step in Export Studio (replace hardcoded-only entry flow).
2. Implement 6B state UI for:
   - `queued`, `processing`, `cancel_requested`, `completed`, `failed`, `canceled`, `blocked`
3. Implement polling policy:
   - `queued`: every 10s
   - active states: every 2s
4. Build completion/share surface (`share_preview_screen.dart`) with download/share actions.

Exit criteria:
- User can submit, track progress, cancel, and open completion screen.

### 6B-4: Evidence and Gate Closure

1. Run and capture tests/logs.
2. Save evidence report at `flutter/docs/handoffs/phase6b-remotion-mvp-report.md`.
3. Confirm artifact quality bar:
   - at least 3 trips
   - at least 2 aspect ratios
   - all artifacts playable without corruption
   - logs show all 6 stages complete

Exit criteria:
- 6B checklist criteria met and report signed.

## 4. Mandatory Guardrails During 6B

- No FastAPI `BackgroundTasks` for rendering.
- Claim logic must remain `skip_locked=True`.
- `snapshot_json` max 500KB, URL refs only.
- Export artifacts private by default.
- No direct transport calls from Flutter UI widgets.

## 5. Open Follow-ups (Track During 6B)

- Regenerate `dora_api` exports client and bump package version.
- Reconfirm OpenAPI drift after any export response schema changes.
