# Phase 6D Kickoff Procedure (Visual Scope + Hardening Blueprint)

Date: 2026-03-08
Phase: 6D - Quality, Templates, and Hardening
Branch: `phase-6-video-export`
Status: Active kickoff document

## 1. Objective

Convert the 6C cloud-stable export pipeline into product-grade trip videos with polished visuals, reliable hardening, and release-ready evidence.

## 2. Scope

In scope for 6D:
- Visual quality upgrade for `classic` template.
- New `cinematic` template with route-led storytelling.
- Export-owned thumbnail generation (`thumbnail.jpg` artifact path).
- Share-token revocation + `pinned_at` retention wiring.
- Final regression pass and operations runbook.

Out of scope for 6D:
- Non-template AI edits.
- Multi-language subtitle generation.
- Web studio parity beyond existing mobile export flow.

## 3. Visual Scope (Implementation Contract)

### 3.1 Classic Template (Polish Target)

- Route animation: smooth interpolation (no step-jumps).
- Camera motion: ease-in/out over place transitions.
- Place card sequence: cleaner enter/exit timing and label fade.
- Map context: route and place markers remain readable at all aspect ratios.

### 3.2 Cinematic Template (New Template Target)

- Letterbox framing support across export ratios.
- Photo motion language: controlled Ken Burns pan/zoom.
- Route fly-over segments between key places.
- Beat structure:
  - opening title scene
  - journey progression scenes
  - closing summary scene

### 3.3 Visual Acceptance Bar

- Video must be trip-specific, not placeholder-like.
- Scene transitions must look continuous at 30fps.
- Route progression must match timeline order from snapshot.
- Text overlays must remain legible on 9:16, 16:9, and 1:1.

## 4. Map and Route Rendering Strategy (Cost + Scale Safe)

- Do not fetch map tiles per frame from external APIs.
- Use scene-level map background generation and reuse across frames.
- Animate route path and camera transforms in composition over cached map context.
- Keep manifest payload compact (URL references only, no binary blobs).
- Maintain Lambda-compatible rendering profile from 6C (exact Remotion version pinning, output to private S3 path).

## 5. Execution Gates

### Gate D1 - Visual Foundation

Tasks:
- Finalize scene/timing spec for classic and cinematic.
- Lock shared motion primitives (easing curves, fade durations, camera bounds).
- Validate required snapshot fields already emitted by backend.

Exit:
- Visual spec frozen and linked in this document.
- No unresolved data contract gaps.

Reference:
- `flutter/docs/handoffs/phase6d-template-motion-spec.md`

### Gate D2 - Template Implementation

Tasks:
- Implement classic polish in `video-renderer/src/remotion/Classic.jsx`.
- Implement cinematic composition and register it in Root/index.
- Add thumbnail generation path and persist export-owned thumbnail URL.

Exit:
- 3+ playable trip-specific outputs per template.
- Thumbnail artifact present at export-owned private path.

### Gate D3 - Hardening and Security

Tasks:
- Implement share-token persistence and revocation enforcement.
- Wire `pinned_at` to retention policy behavior.
- Finalize error taxonomy + user copy mapping.

Exit:
- Share revoke behavior verified by test and manual run.
- Retention behavior documented and validated.

### Gate D4 - Evidence and Release Readiness

Tasks:
- Regression matrix across create/media/sync/export.
- Cloud validation rerun for both templates.
- Update runbook and final handoff docs.

Exit:
- `phase6d-quality-hardening-report.md` complete.
- Final go/no-go checklist signed.

## 6. Required Evidence Artifacts

- `flutter/docs/handoffs/phase6d-quality-hardening-report.md`
- `flutter/docs/handoffs/phase6d-template-motion-spec.md`
- `video-renderer/docs/renderer-api-contract-v2-draft.md` (until v2 is finalized and merged into the canonical contract)
- `flutter/docs/ops/export-runbook.md`
- Template validation set (classic + cinematic, at least 3 trips each)
- Thumbnail artifact verification notes
- Share-token revoke verification notes
- Regression matrix and defect summary

## 7. Stop-The-Line Conditions

- Any regression in 6C stability (stuck jobs, duplicate artifacts, private artifact leak).
- Route/map visuals desynchronized from timeline order.
- Share revocation bypass or raw long-lived public artifact exposure.
- Thumbnail pipeline falls back silently to trip-media shortcut.

## 8. Runtime Procedure (During 6D Execution)

Use the same three-process local flow for iterative validation:

```bash
cd video-renderer && npm run dev
cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
cd backend && python -m app.workers.export_worker
```

For cloud validation, keep `RENDER_BACKEND=lambda` and collect job IDs/artifact paths in the 6D evidence report.

## 9. Handoff Discipline

After each 6D gate:
1. update this kickoff doc if scope/gates change,
2. update `phase6-rolling-handoff.md` with current gate status,
3. append concrete evidence in `phase6d-quality-hardening-report.md`,
4. record carry-forward only if explicitly out of 6D scope.

## 10. Execution Memory (2026-03-09)

### 10.1 Planned in this execution window

- Implement scene-level map context generation for cinematic scenes using a single static map URL per scene.
- Project route geometry into frame coordinates and animate route draw over map context.
- Keep cloud-safe behavior by avoiding per-frame tile fetching.
- Preserve renderer contract by injecting renderer config (`mapbox_token`, `map_style`) through `inputProps`, not backend snapshot schema changes.
- Record plan and completion evidence in this kickoff doc and `phase6d-quality-hardening-report.md`.

### 10.2 Completed in this execution window

- Added map/projection helpers in `video-renderer/src/remotion/render-data.js`:
  - viewport fitting from route/place coordinates,
  - map URL generation for Mapbox Static API,
  - projected route path helpers for animation.
- Upgraded `video-renderer/src/remotion/Cinematic.jsx` to:
  - render map-backed scenes,
  - animate route draw and marker over projected coordinates,
  - keep robust image/dark fallbacks when map context is unavailable.
- Updated renderer runtime input-prop wiring in:
  - `video-renderer/src/server.js` (local backend),
  - `video-renderer/src/lambda-renderer.js` (lambda backend),
  so both backends pass `renderer_config.mapbox_token` and `renderer_config.map_style`.
- Added env template entries in `video-renderer/.env.example`:
  - `RENDERER_MAPBOX_TOKEN`,
  - `RENDERER_MAP_STYLE`.

### 10.3 Planned in current enhancement window

- Improve cinematic quality without WebGL:
  - keyframed map camera motion (focus and target tracks),
  - smoother route geometry and route-head marker pulse,
  - stronger transition continuity and legibility overlays.

### 10.4 Completed in current enhancement window

- Added route smoothing helper in `video-renderer/src/remotion/render-data.js` (`smoothPolyline` with bounded point count).
- Upgraded cinematic map camera in `video-renderer/src/remotion/Cinematic.jsx`:
  - multi-keyframe focus/target camera plan per scene,
  - eased zoom/translation tracks for fly-over feel.
- Upgraded route visual treatment in `video-renderer/src/remotion/Cinematic.jsx`:
  - layered trail + glow path,
  - animated head pulse marker,
  - improved vignette/text transition continuity.

### 10.5 Continuous map journey rewrite (2026-03-10)

Replaced the per-scene cinematic model with a single continuous map journey:

- **Architecture**: one Mapbox static map for the entire trip; camera pans and
  zooms over it following the vehicle marker along routes.
- **Camera follows marker**: camera focus = marker position directly (no separate
  interpolation). Only zoom level transitions between segments.
- **Mode-dependent zoom**: ground routes 4.0× (city-visible), air 2.0× (arc
  visible), arrive at place 5.0× (zoomed close).
- **Bigger map**: OVERSIZE raised to 2.5, paddingRatio lowered to 0.06 — gives
  higher auto-fit Mapbox zoom for more geographic detail.
- **Fixed @2x projection bug**: viewport fitting and coordinate projection now
  use geographic dimensions (pre-@2x), not pixel dimensions.
- **Vehicle markers**: 64px screen-space markers with route-colored background,
  24×24 top-down transport icons (plane/car/foot/bike/bus/train), heading
  rotation, and mode-specific animations (plane bob, car rumble, train sway).
- **Route visuals**: vivid per-mode colors, progressive SVG drawing, air arcs
  with dashed flight path + progressive glow.
- **Photo cards**: spring-animated cards at geographic location with edge avoidance.

Files changed:
- `video-renderer/src/remotion/render-data.js` (added ~230 lines of helpers)
- `video-renderer/src/remotion/Cinematic.jsx` (full rewrite, ~840 lines)
