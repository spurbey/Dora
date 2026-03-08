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

- Letterbox mood supported across ratios
- Lower text density than classic
- Longer scene breath with stronger transition continuity

## 5.2 Beat Plan

1. Opening (title + destination tone)
2. Journey progression (alternating place emphasis and route motion)
3. Closing summary (trip completion beat)

## 5.3 Camera and Transition Rules

- Zoom range per place: `1.02 -> 1.10`
- Cross-dissolve or masked wipe transitions only
- Transition duration: 0.35s-0.75s
- Route fly-over interpolation must remain smooth at 30fps

## 6. Map and Route Strategy

- Do not fetch external map tiles per frame
- Reuse scene-level map background when possible
- Animate camera over route geometry inside composition
- Route ordering comes from snapshot timeline and must not be re-sorted by name

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

