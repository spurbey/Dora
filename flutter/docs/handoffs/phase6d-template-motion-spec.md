# Phase 6D Template Motion Spec (Classic + Cinematic)

Date: 2026-03-08
Status: draft
Owner: Export Visuals

## 1. Purpose

This spec defines the motion and timing contract for Phase 6D templates.
It prevents visual drift and gives a single source of truth for quality sign-off.

## 2. Global Composition Rules

- FPS: `30`
- Allowed aspect ratios: `9:16`, `1:1`, `16:9`
- Duration sources: manifest `duration_sec`
- Safe text area:
  - horizontal padding >= 6% of frame width
  - bottom padding >= 8% of frame height
- Maximum single transition block: 0.8s
- Minimum per-place visibility: 1.8s

## 3. Motion Primitives

Use these easing curves consistently:

- Fade/opacity: `easeInOutCubic`
- Camera pan/zoom: `easeInOutSine`
- Route draw: `easeOutCubic`
- Title/label slide: `easeOutQuad`

Implementation note:
- Keep primitive helpers centralized and reused by both templates.
- Avoid ad-hoc per-scene easing constants.

## 4. Classic Template Contract

## 4.1 Shot Structure

1. Title card: 1.8-2.2s
2. Place loop:
   - image lead-in 0.3s fade
   - steady scene body with slow Ken Burns
   - label reveal (name then sublabel)
3. End card: 0.8-1.2s

## 4.2 Camera Rules

- Scale range per place: `1.03 -> 1.12`
- Optional horizontal drift magnitude <= 2.5% frame width
- No abrupt direction flips between adjacent places

## 4.3 Route Overlay Rules

- Route progress follows timeline order only
- Draw animation must be continuous (no step jumps)
- Route stroke remains legible on all ratios

## 5. Cinematic Template Contract

## 5.1 Visual Language

- Continuous map journey: one Mapbox static map as the canvas for the full trip.
- Camera follows the vehicle marker along routes — no scene cuts.
- Letterbox framing and vignette across all ratios.
- Photo cards pop at geographic locations (not full-screen backgrounds).
- Lower text density than classic; place name labels at bottom with scrim.

## 5.2 Beat Plan

1. **Intro** (1.5s): trip title + destination over semi-transparent overlay, map visible behind.
2. **Journey** (bulk of duration): alternating arrive/travel segments.
   - Arrive: camera zooms to place (5.0×), photo cards spring in, place name fades in.
   - Travel: camera follows vehicle along route (ground 4.0×, air 2.0×), route draws progressively.
3. **Outro** (1.0s): branded "Story Captured — Dora" closer.

## 5.3 Camera Rules

- Camera focus = vehicle marker position (exact tracking, no drift).
- Only camera scale transitions between segments (20% ease window, `easeInOutSine`).
- Mode-dependent zoom:
  - Ground routes (car/bus/foot/bike/train): `CAMERA_SCALE_GROUND = 4.0`
  - Air routes: `CAMERA_SCALE_AIR = 2.0`
  - Arrive at place: `CAMERA_SCALE_ARRIVE = 5.0`
- Edge clamping prevents map boundaries from becoming visible.

## 5.4 Vehicle Marker Rules

- Rendered in screen-space (fixed 64px, unaffected by camera zoom).
- Route-colored circle background with white transport-mode icon.
- 24×24 top-down SVG icons: plane, car, walking person, bicycle, bus, train.
- Whole marker rotates to face direction of travel.
- Mode-specific animations: plane vertical bob, car/bus rumble, train sway.
- At place: 52px marker with location pin icon.

## 5.5 Route Visual Rules

- Vivid per-mode colors: gold (car), bright green (foot), mint (bike), cyan (air), orange (bus), purple (train).
- Stroke widths: 4–5px in map-pixel space.
- Progressive draw via `pathLength="1"` + `strokeDasharray`.
- Glow layer (opacity 0.2) behind main trail.
- Air routes: full dashed arc at 50% opacity + progressive solid glow.
- Completed segments remain fully drawn.

## 6. Map and Route Strategy

- Single Mapbox Static API fetch per composition (one map for entire trip).
- OVERSIZE factor 2.5 with paddingRatio 0.06 — maximizes auto-fit zoom for city-level detail.
- @2x image provides 2× pixel density at the geographic coordinate dimensions.
- Camera CSS `translate + scale` handles panning/zooming over the static image.
- All coordinate projection uses geographic (pre-@2x) dimensions.
- Route ordering comes from snapshot timeline and must not be re-sorted by name.

## 7. Text and Legibility Rules

- Primary label contrast ratio >= 4.5:1 against background area
- Apply gradient scrim where needed for readability
- Max two text lines in active scene body
- Avoid placing text over dense route intersections

## 8. Quality Acceptance Checklist

- [ ] motion is smooth at 30fps across all target ratios
- [ ] route progression matches trip timeline order
- [ ] no image/video flicker on scene boundaries
- [ ] text remains readable in bright and dark scenes
- [ ] both templates produce trip-specific and non-placeholder output
- [ ] no visual regressions in previously passing classic scenarios

## 9. Required Evidence for Sign-Off

- 3 completed jobs per template (`classic`, `cinematic`)
- each template validated in all target ratios
- side-by-side review clips attached in 6D report
- explicit pass/fail against checklist above

