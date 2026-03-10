# Phase 6D Quality and Hardening Report (Execution Ledger)

Date Opened: 2026-03-08
Phase: 6D
Branch: `phase-6-video-export`
Status: `in_progress`

## 1. Purpose

This document is the execution ledger for Phase 6D.
It tracks quality work, reliability hardening, regression coverage, and release sign-off evidence.

Every validation run must record:
- exact scenario and scope,
- result (pass/fail),
- evidence (job IDs, logs, screenshots, artifact paths),
- fixes applied.

## 2. Gate Status

| Gate | Description | Status (`todo/in_progress/done`) | Notes |
|---|---|---|---|
| D1 | Visual foundation frozen (classic + cinematic motion contract) | done | Motion contract drafted in `phase6d-template-motion-spec.md` and linked in kickoff |
| D2 | Template implementation complete (classic polish + cinematic) | in_progress | Cinematic rewritten as continuous map journey with camera-follows-marker; validation artifacts pending |
| D3 | Hardening complete (thumbnail pipeline, share revoke, pinned retention) | todo | Includes cancel and stale-reaper validation |
| D4 | Regression and release readiness complete | todo | Includes runbook and final go/no-go |

## 3. Visual Quality Validation Matrix

| Scenario | Template | Ratio | Quality | Result | Evidence |
|---|---|---|---|---|---|
| Trip A baseline | classic | 9:16 | 720p | todo | |
| Trip A social landscape | classic | 16:9 | 1080p | todo | |
| Trip B square | classic | 1:1 | 720p | todo | |
| Trip A cinematic mobile | cinematic | 9:16 | 720p | todo | |
| Trip B cinematic landscape | cinematic | 16:9 | 1080p | todo | |
| Trip C cinematic square | cinematic | 1:1 | 720p | todo | |

Acceptance checks per scenario:
- route order matches snapshot timeline order,
- transitions are smooth at 30fps with no visible jumps,
- labels are readable on bright and dark footage,
- artifact is playable and non-corrupt.

## 4. Hardening Validation Matrix

| Area | Validation | Result | Evidence |
|---|---|---|---|
| Thumbnail pipeline | `thumbnail.jpg` exported and persisted under export-owned path | todo | |
| Share token persistence | token record created and linked to export | todo | |
| Share revoke | revoked token returns forbidden and no new redirect URL | todo | |
| Trip privacy revoke | private trip cannot be shared from old link | todo | |
| Pinned retention | pinned export excluded from lifecycle deletion policy | todo | |
| Cancel at stage boundary | snapshotting | todo | |
| Cancel at stage boundary | asset_fetch | todo | |
| Cancel at stage boundary | rendering | todo | |
| Cancel at stage boundary | uploading | todo | |
| Stale reaper | stuck processing/cancel_requested settles correctly | todo | |

## 5. Regression Matrix

| Flow | Scope | Result | Notes |
|---|---|---|---|
| Create trip | add/edit/delete trip metadata | todo | |
| Place flow | add/edit/reorder places | todo | |
| Route flow | route generation + timeline order | todo | |
| Media queue | upload + retry + failure handling | todo | |
| Entity sync | queued, retry, recovery behavior | todo | |
| Export flow | submit, poll, cancel, download, share | todo | |

## 6. Incident Ledger

| Timestamp (UTC) | Incident | Root Cause | Action Taken | Verification |
|---|---|---|---|---|
| 2026-03-08 | Local smoke capture blocked on expected port | Existing long-running renderer process already bound to port | Continued implementation and documented pending smoke-evidence capture as next task | pending |

## 7. Evidence Log

### 7.0 Implementation Snapshot (2026-03-08)

Completed in this window:
- Added cinematic composition:
  - `video-renderer/src/remotion/Cinematic.jsx`
- Added shared render-data helpers to avoid template logic drift:
  - `video-renderer/src/remotion/render-data.js`
- Wired cinematic composition registration:
  - `video-renderer/src/remotion/Root.jsx`
- Switched template map so `template=cinematic` resolves to composition `Cinematic`:
  - `video-renderer/src/server.js`
- Refactored classic composition to reuse shared data helpers:
  - `video-renderer/src/remotion/Classic.jsx`

Validation currently pending:
- end-to-end renderer smoke artifacts for cinematic template across target ratios.

### 7.1 Map Context Upgrade Snapshot (2026-03-09)

Planned in this window:
- replace cinematic dark fallback route scenes with map-backed context,
- keep one map fetch per scene (not per frame),
- maintain local/lambda parity through shared renderer input props.

Completed:
- `video-renderer/src/remotion/render-data.js`
  - added viewport fitting and Mercator projection helpers,
  - added scene map URL builder (Mapbox Static API),
  - added reusable route path/progress helpers.
- `video-renderer/src/remotion/Cinematic.jsx`
  - map-backed cinematic scene rendering,
  - projected route animation and progress marker,
  - safe fallback behavior for missing token/data.
- `video-renderer/src/server.js` + `video-renderer/src/lambda-renderer.js`
  - inject `renderer_config.mapbox_token` + `renderer_config.map_style` into render `inputProps`.
- `video-renderer/.env.example`
  - added `RENDERER_MAPBOX_TOKEN` and `RENDERER_MAP_STYLE`.

Validation pending:
- collect 3 cinematic artifacts and confirm map visibility/readability on 9:16, 1:1, 16:9.

### 7.2 Cinematic Motion Enhancement Snapshot (2026-03-09)

Planned:
- raise cinematic quality bar on static-map mode before any WebGL migration,
- add smoother route geometry and camera-keyframe fly-over motion.

Completed:
- `video-renderer/src/remotion/render-data.js`
  - added bounded polyline smoothing (`smoothPolyline`) for route overlays.
- `video-renderer/src/remotion/Cinematic.jsx`
  - added scene camera-keyframe planning (focus/target/scale tracks),
  - added eased multi-stage camera transform,
  - upgraded route overlay with glow/trail and animated route-head pulse,
  - tuned label and vignette transitions for continuity.

Validation pending:
- export 3 cinematic artifacts and verify that route progression remains synchronized with timeline order after smoothing.

### 7.3 Continuous Map Journey Rewrite (2026-03-10)

Architecture change: replaced isolated scene-per-place cinematic slideshow with a
continuous map journey composition where a single Mapbox static map serves as the
canvas for the entire trip.

Completed — `video-renderer/src/remotion/render-data.js`:
- `buildGlobalMapContext`: collects all coordinates, fits one viewport, projects
  all places and routes into a single map-pixel coordinate space.
  - Fixed critical Mapbox @2x projection mismatch (geographic vs pixel dimensions)
    that caused all coordinates to render in the Indian Ocean.
  - OVERSIZE factor raised to 2.5 (from 1.7) and paddingRatio lowered to 0.06 for
    higher auto-fit Mapbox zoom — more city-level detail.
- `buildJourneyTimeline`: allocates arrive/travel segments proportionally across
  the available journey frames.
- `pointOnArc`: quadratic bezier interpolation for air route arcs — marker and
  camera follow the actual arc curve, not a straight line.
- `ROUTE_STYLES`: vivid per-mode colors (gold car, green foot, cyan air, orange
  bus, purple train) and thicker widths (4–5px).
- `TRAVEL_MODE_ICONS`: 24×24 top-down SVG paths for plane, car, walking person,
  bicycle, bus, and train — oriented facing right for heading rotation.
- `getPlaceImageUrls`, `cardScreenPosition`, `airArcPath`, `getHeadingAtProgress`:
  supporting helpers for photo cards, arc paths, and heading computation.

Completed — `video-renderer/src/remotion/Cinematic.jsx` (full rewrite):
- **MapJourney** (continuous composition spanning full duration):
  - Single static map `<Img>` rendered at geographic dimensions (CSS) with @2x
    pixel density.
  - Camera focus = marker position directly (zero drift). Only the camera scale
    transitions between segments.
  - Mode-dependent camera zoom: ground 4.0×, air 2.0×, arrive 5.0× (with smooth
    cross-ease at segment boundaries).
  - `RouteTrail`: SVG progressive route drawing via `pathLength="1"` +
    `strokeDasharray`. Air routes show full dashed arc with progressive glow.
  - `PlaceDots`: small white dots at visited places.
- **TravelMarker** (screen-space, fixed 64px):
  - Route-colored circle with white transport-mode icon inside.
  - Whole marker rotates to face direction of travel.
  - Mode-specific micro-animations: plane vertical bob, car/bus rumble, train sway.
- **PlacePhotoCards** (screen-space):
  - Up to 3 photo cards per place with spring-enter and fade-exit.
  - Cards positioned at geographic location with edge avoidance.
  - Fan rotation for multi-card layout.
- **CinematicIntro / CinematicOutro**: semi-transparent overlays with trip title
  and branded closer.
- **Vignette + Letterbox**: consistent across all aspect ratios.

Bugs fixed in this window:
- @2x projection mismatch: `fitViewportToCoordinates` was called with pixel
  dimensions (geoWidth×2) instead of geographic dimensions — all coordinates
  projected 2× too far from center, placing everything in the Indian Ocean.
- Camera drift: camera independently interpolated along the route with different
  easing than the marker, causing desynchronization. Fixed by making camera focus
  track the marker position directly.
- Route dashed-style masking: dark-colored SVG path overlay was visible against
  the map background. Removed in favor of clean progressive draw for all routes.

Validation pending:
- export 3 cinematic artifacts across 9:16, 1:1, 16:9 and confirm that camera
  follows the route, vehicle markers are visible, and photo cards appear at
  correct geographic positions.

### 7.4 Artifact Table

| Job ID | Template | Ratio | Quality | Final Status | Output URL | Thumbnail URL | Playable |
|---|---|---|---|---|---|---|---|
| | | | | | | | |

### 7.5 Logs and Screens

- Worker log excerpt:
- Renderer log excerpt:
- Flutter status UI screenshot(s):
- Share/revoke validation screenshots:

## 8. Open Risks and Carry-Forward

Use this section only for explicit 6D scope decisions. Do not silently defer required 6D work.

| Item | Decision | Owner | Target |
|---|---|---|---|
| Cinematic artifact evidence not yet captured | keep D2 open until 3+ trip-specific outputs are recorded | Codex | D2 closure |

## 9. Sign-Off Block

Status: `not_ready`

Go/No-Go: `NO-GO`

Required for `GO`:
- D1-D4 all `done`,
- no critical defects in export quality/security/reliability,
- regression matrix signed off,
- runbook complete and reviewed.
