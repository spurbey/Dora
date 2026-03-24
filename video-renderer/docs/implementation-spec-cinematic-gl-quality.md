# Implementation Spec: Cinematic (GL) Quality

Status: Draft for execution  
Owner: Rendering Team  
Last updated: 2026-03-23  
Related PRD: `video-renderer/docs/prd-cinematic-gl-remotion-lambda.md`

Canonical runtime architecture:
1. `video-renderer/docs/cinematic-gl-runtime-architecture.md` (this overrides conflicting runtime-flow text)

## 1. Core decision

No profile split.

Execution model:

1. `template=classic` -> Classic composition.
2. `template=cinematic` -> GL cinematic composition.

Old static cinematic is removed from active path.

---

## 2. Engineering principles

1. Deterministic frame state is mandatory.
2. One source of truth for all per-frame subsystems.
3. Math modules are pure functions.
4. No time-based map animation (`easeTo`, `flyTo`) in export runtime.

---

## 3. Module layout

Under `video-renderer/src/remotion/gl/`:

1. `types.js`
2. `normalize-snapshot.js`
3. `timeline-compiler.js`
4. `geometry-math.js`
5. `route-animator.js`
6. `camera-planner.js`
7. `overlay-planner.js`
8. `render-plan-builder.js`
9. `map-init.js`
10. `map-runtime.js`
11. `retry-policy.js`
12. `quality-constants.js`

Composition files:

13. `video-renderer/src/remotion/CinematicGL.jsx` (new cinematic runtime implementation)
14. `video-renderer/src/remotion/Cinematic.jsx` (compatibility wrapper exporting `CinematicGL` as `Cinematic`)
15. `video-renderer/src/remotion/CinematicLegacy.jsx` (frozen rollback-safe legacy implementation)

---

## 4. Contract split

## 4.1 Public API (`client -> backend`)

No profile fields.

Input includes:

1. template
2. aspect_ratio
3. quality
4. duration_sec
5. fps

## 4.2 Internal manifest (`backend -> renderer`)

Uses `X-Renderer-Version: 2` and `X-Renderer-Secret: <shared_secret>`.

For `template=cinematic`, require:

1. `snapshot.renderer_config.map_style`
2. `snapshot.renderer_config.style_revision` or `style_hash`

## 4.3 Backend plumbing requirements

Required backend control-plane updates for style pinning and fallback visibility:

1. `export_service` snapshot builder must populate `renderer_config.map_style` and style pin metadata for cinematic jobs.
2. Worker -> renderer manifest serialization must preserve pin fields exactly (no normalization drift).
3. Worker status persistence must keep renderer fallback metadata:
   - `engine_used`
   - `fallback_executed`
   - `fallback_reason` (nullable)

---

## 5. Frame state contract

For each frame:

```js
{
  frame: 120,
  segment_id: "seg_3",
  segment_progress_norm: 0.42,
  camera: { center_lng, center_lat, zoom, bearing, pitch },
  route: { active_route_id, draw_progress_norm },
  marker: { lng, lat, heading_deg, mode, at_place },
  overlays: { place_label_opacity, photo_cards_opacity, card_x, card_y }
}
```

Rules:

1. Exactly one `frameState` per frame.
2. All numeric outputs clamped.
3. `frameState(frame)` depends only on immutable render plan + frame index.

---

## 6. Timeline compiler

Input:

1. normalized places/routes
2. fps
3. duration frames

Output:

1. contiguous segment list (`intro`, `arrive`, `travel`, `outro`)
2. per-segment metadata

Deterministic rounding:

1. use cumulative remainder carry, not independent per-segment rounding.

---

## 7. Route animator

1. Convert route geometry to cumulative-length curve.
2. `pointAtS(s)` via segment search + linear interpolation.
3. Heading from tangent using `s-eps` and `s+eps`.
4. For air routes, use deterministic quadratic arc.

---

## 8. Camera planner

## 8.1 Segment grammar

1. intro: wide establish
2. ground travel: tighter zoom + heading-follow
3. air travel: wider zoom + smoother bearing
4. arrive: hold + micro dolly
5. outro: stable close

## 8.2 Interpolation algorithm (exact)

Between keyframes `K0` and `K1`:

1. `u = clamp((f - K0.frame)/(K1.frame - K0.frame), 0, 1)`
2. `e = easeInOutSine(u)`

Center:

1. `d_lon = ((lon1 - lon0 + 540) % 360) - 180`
2. `lon = lon0 + d_lon * e`
3. `lat = lat0 + (lat1 - lat0) * e`

Bearing:

1. `d_bear = ((b1 - b0 + 540) % 360) - 180`
2. `bearing = b0 + d_bear * e`

Zoom/pitch:

1. linear over `e`.

---

## 9. Progress and easing

## 9.1 Unified progress

`p = progressForFrame(frame, seg.start, seg.end)`

Then:

1. route draw -> `routeCurve(p)`
2. marker pos -> `markerCurve(p)`
3. camera -> `cameraCurve(p)`
4. overlays -> `overlayCurve(p)`

## 9.2 Easing equations

1. `linear(p) = p`
2. `easeInOutSine(p) = 0.5 * (1 - cos(pi * p))`
3. `easeOutCubic(p) = 1 - (1 - p)^3`
4. `easeOutQuad(p) = 1 - (1 - p)^2`

Mapping:

1. camera: `easeInOutSine`
2. route: `easeOutCubic`
3. marker: `easeInOutSine`
4. label/card entry: `easeOutQuad`
5. opacity fade: `easeInOutSine`

---

## 10. GL runtime

## 10.1 Init gate

1. create map instance once.
2. `delayRender()` until:
   - style loaded
   - map stable idle
   - style pin verified
3. `continueRender()` on ready.

## 10.2 Per-frame apply

1. read `frameState`.
2. apply camera with `jumpTo`.
3. update route/marker layers from frame state.

No time-driven map transitions.

## 10.3 Style hash derivation

1. fetch style JSON
2. remove volatile fields (`created`, `modified`) if present
3. canonicalize (sorted keys, compact JSON)
4. `style_hash = SHA256(UTF8(canonical_json))`
5. compare against pinned metadata
6. mismatch -> `map_style_revision_mismatch`

## 10.4 Cinematic fallback reliability policy

1. For `template=cinematic`, renderer attempts GL first.
2. On retry-eligible GL init/runtime errors, renderer performs one static cinematic compatibility retry.
3. Fallback is an operational safety mechanism, not a user-selectable rendering mode.
4. Renderer status payload must include:
   - `engine_used`
   - `fallback_executed`
   - `fallback_reason` (nullable)
5. If fallback attempt also fails, job fails with terminal renderer error code.

---

## 11. Overlay card layout

## 11.1 Candidate positions

From anchor `(ax, ay)` with offsets `(dx, dy)`:

1. NE
2. NW
3. SE
4. SW

## 11.2 Scoring

`score = overflow_penalty + route_overlap_penalty + edge_penalty + travel_penalty`

Where:

1. `overflow_penalty = overflow_px * 1000`
2. `route_overlap_penalty = overlap_px * 300`
3. `edge_penalty = 100 if too close to safe edge else 0`
4. `travel_penalty = distance(anchor, card_center)`

Pick minimum score.

Tie-break order:

1. NE > NW > SE > SW

---

## 12. Queue and retry ownership

1. Queue fairness/scheduling is backend worker responsibility.
2. Renderer only has local admission cap.
3. Source-of-truth attempts: `export_jobs.retry_count`.
4. Lambda `maxRetries` is chunk-local and does not increment job attempts.

Initial defaults:

1. worker `max_retries=3`
2. lambda `maxRetries=1`

---

## 13. Error classes

1. `validation_error`
2. `map_token_invalid`
3. `map_style_unreachable`
4. `map_style_revision_mismatch`
5. `gl_timeout_delay_render`
6. `gl_chunk_unstable`
7. `render_crash`

Retry matrix:

1. retry: `map_style_unreachable`, `gl_timeout_delay_render`, `gl_chunk_unstable`
2. terminal: `map_token_invalid`, `map_style_revision_mismatch`, validation errors

---

## 14. Test plan

## 14.1 Unit

1. timeline compiler determinism.
2. camera interpolation bounds and continuity.
3. route animator monotonicity + heading continuity.
4. overlay placement scoring determinism.

## 14.2 Integration

1. local cinematic GL render smoke.
2. lambda cinematic GL render smoke.
3. style mismatch failure path.

## 14.3 Visual regression

1. fixture golden frames for 5 route patterns.
2. SSIM and deterministic-hash threshold checks (planner/frame-state + overlays; no full-frame hash gate).
3. chunk seam continuity checks:
   - camera jump threshold
   - marker jump threshold
4. full-frame comparison policy uses SSIM/seam metrics, not full-frame hash equality.

---

## 15. Numeric go/no-go thresholds

1. SSIM >= 0.985
2. overlay hash consistency >= 99.9%
3. planner/frame-state hash consistency = 100% for same manifest
4. seam: camera jump <= 0.0005 deg
5. seam: marker jump <= 3 px @1080p normalized
6. staging completion rate >= 99% across 500 jobs

---

## 16. Implementation sequence

1. build pure planners (`normalize`, `timeline`, `route`, `camera`, `overlay`)
2. build render-plan builder
3. implement GL cinematic composition under existing `Cinematic` entry
4. add style hash pinning verification
5. implement cinematic GL->static fallback reliability path and metadata propagation
6. wire backend style pin plumbing (`export_service`, manifest serializer, worker status persistence)
7. apply lambda cinematic defaults (`png`, chunk size, concurrency)
8. add tests (unit/integration/visual)
9. rollout by environment with quality gates

---

## 17. Flutter API client regeneration commands

Only run this if public backend OpenAPI schema changed.

```bash
curl http://localhost:8000/openapi.json -o flutter/openapi.json
cd flutter
npx @openapitools/openapi-generator-cli generate -c openapi-generator-config.yaml
```

After generation:

1. review `flutter/packages/dora_api/**` diff
2. bump generated package version if needed
3. run Flutter tests
4. never hand-edit generated outputs
