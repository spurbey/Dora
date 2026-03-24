# Cinematic GL Export - Execution Tracker (2026-03-24)

Date: 2026-03-24  
Owner: Video Renderer + Backend Worker + Flutter + QA  
Status: Active (P1 In Progress)  
Related Docs:
1. `video-renderer/docs/prd-cinematic-gl-remotion-lambda.md`
2. `video-renderer/docs/implementation-spec-cinematic-gl-quality.md`
3. `video-renderer/docs/renderer-api-contract-v2-draft.md`
4. `video-renderer/docs/cinematic-gl-runtime-architecture.md` (canonical runtime flow)

## 1. Purpose

Track cinematic GL delivery in **progressive phases**, where each phase solves a specific problem and creates the base for the next phase.

This tracker is the session-memory anchor for future work.

## 2. Session Continuity Block (Update Every Session)

1. Branch: `[fill]`
2. Latest commit: `b1bed52` (`Tighten GL style pin rules and runtime planning behavior`)
3. Last known good test command: `node --test video-renderer/tests/gl-planner.test.mjs video-renderer/tests/thumbnail-frame.test.mjs` (pass: 9/9 on 2026-03-24)
4. Current active phase: `P1` (deterministic planning core, hardening pass)
5. Next 3 executable steps:
   - Implement `map-init.js` runtime gate (`delayRender` + style-load/idle synchronization) for P2.
   - Implement `map-runtime.js` per-frame apply path (`jumpTo`, route/marker layer updates) for P2.
   - Wire renderer v2 style pin/fallback metadata plumbing in backend worker status persistence for P5.
6. Open blockers + owner:
   - Backend style pin population/source-of-truth still pending in export snapshot builder (owner: backend worker/data-model).
   - Real GL runtime path not yet enabled; current P1 uses projected static compatibility rendering (owner: video-renderer runtime).

## 3. Update Rules

1. Move `[ ]` -> `[x]` only after code + tests + evidence.
2. Add one progress-log line for each phase transition.
3. Keep one primary active phase, but allow explicitly tagged `[parallel-safe]` tasks from later phases if they do not depend on unfinished gate decisions.
4. `P0` contract freeze is mandatory before merging `P2+` runtime behavior into the default cinematic path.
5. If a gate fails, reopen phase and log failure + root cause.

## 4. Non-Negotiable Invariants

1. `template=cinematic` must map to GL implementation (no profile split).
2. Frame state is deterministic and single-source-of-truth.
3. No map time-driven camera transitions (`easeTo`/`flyTo`) in export path.
4. Output includes both video and thumbnail artifacts.
5. Worker attempt count remains source-of-truth for retries.
6. Chunk seams must pass continuity thresholds.
7. Full-frame video validation is metric-based (SSIM/seam), not byte-identical hash equality.

## 5. Problem Ladder (Incremental)

1. Problem A: architecture ambiguity and context loss across sessions.
   - Countered by P0 contract freeze + tracker discipline.
2. Problem B: static cinematic look and unsynced motion quality.
   - Countered by P1/P2 deterministic planner + GL runtime integration.
3. Problem C: cinematic motion quality inconsistency.
   - Countered by P3 camera/easing/overlay algorithm hardening.
4. Problem D: cloud render instability/cost drift.
   - Countered by P4 Lambda tuning + observability.
5. Problem E: integration mismatch between backend/renderer/flutter.
   - Countered by P5 contract/schema/client alignment.
6. Problem F: regressions and seam artifacts.
   - Countered by P6 quality gates + visual regression suite.
7. Problem G: rollout risk.
   - Countered by P7 canary + rollback triggers.

## 6. Phase Board

Phase DRI Map (single accountable owner):
1. `P0`: Backend API/contract owner.
2. `P1`: Video-renderer planning owner.
3. `P2`: Video-renderer runtime owner.
4. `P3`: Video-renderer motion/visual owner.
5. `P4`: Video-renderer infra/ops owner.
6. `P5`: Backend worker/data-model owner.
7. `P6`: QA automation owner.
8. `P7`: Release/operations owner.

## P0: Baseline and Contract Freeze

Status: Not Started  
Target: 1 day  
Problem Countered: A  
Owner: Backend API/contract owner

Work Items:
1. [ ] Freeze scope: `classic` unchanged, `cinematic` => GL replacement.
2. [ ] Freeze internal renderer v2 contract and error envelope.
3. [ ] Freeze deterministic quality gates: `SSIM >= 0.985`, overlay hash consistency `>= 99.9%`, seam camera jump `<= 0.0005 deg`, seam marker jump `<= 3 px @1080p`, staging completion `>= 99%` across `>= 500` jobs.
4. [ ] Capture baseline metrics from current renderer (success rate, duration, failure modes).

Completion Gate:
1. [ ] Approved and linked contract docs.
2. [ ] Baseline metric snapshot recorded (`duration_p95_sec`, `memory_p95_mb`, `cost_p95_usd`, `completion_rate_500`, classic fixture baseline SSIM).
3. [ ] Tracker continuity block fully populated.

## P1: Deterministic Planning Core

Status: In Progress  
Target: 2 days  
Problem Countered: B  
Owner: Video-renderer planning owner

Work Items:
1. [x] Implement snapshot normalization module.
2. [x] Implement timeline compiler (contiguous segments, deterministic frame allocation).
3. [x] Implement route animator (`pointAtS`, heading continuity, air arc mode).
4. [x] Implement camera planner and unified progress pipeline.
5. [x] Build single `frameState(frame)` API consumed by all systems.

Completion Gate:
1. [x] Planner unit tests pass.
2. [ ] No NaN/invalid frame state in fuzz/property tests.
3. [x] Same input -> same planned frame state hash.

## P2: Cinematic GL Runtime Integration

Status: Not Started  
Target: 2 days  
Problem Countered: B  
Owner: Video-renderer runtime owner

Work Items:
1. [ ] Replace cinematic composition internals with GL runtime.
2. [ ] Implement map init gate using `delayRender()/continueRender()`.
3. [ ] Apply per-frame camera via `jumpTo`.
4. [ ] Implement style pin verification (`style_revision`/`style_hash`).
5. [ ] Implement deterministic route/marker layer updates from frame state.

Completion Gate:
1. [ ] Local render smoke passes for cinematic GL.
2. [ ] Style mismatch correctly fails with explicit error code.
3. [ ] No use of time-driven map camera transitions in export path.

## P3: Motion and Visual Quality Hardening

Status: In Progress (parallel-safe)  
Target: 2 days  
Problem Countered: C  
Owner: Video-renderer motion/visual owner

Work Items:
1. [ ] Apply exact easing equation mapping per subsystem.
2. [ ] Finalize camera interpolation and bearing shortest-path handling.
3. [ ] Implement overlay card placement scoring algorithm.
4. [ ] Tune typography safe zones and legibility overlays.
5. [x] Add content-aware thumbnail frame selection for cinematic. `[parallel-safe]`

Completion Gate:
1. [ ] Fixture clips meet visual review baseline.
2. [ ] Label readability and placement pass all aspect ratios.
3. [ ] Camera/route/marker sync validated on fixture routes.

## P4: Lambda Stability and Cost Controls

Status: Not Started  
Target: 2 days  
Problem Countered: D  
Owner: Video-renderer infra/ops owner

Work Items:
1. [ ] Add cinematic GL render options (png, explicit crf/preset/colorspace).
2. [ ] Set Lambda chunking defaults (`framesPerLambda`, `concurrencyPerLambda`).
3. [ ] Add CloudWatch dashboard and alert thresholds (`error_rate > 1% for 15m`, `throttles > 0 for 5m`, `duration_p95 > 1.20x baseline for 30m`).
4. [ ] Validate runtime memory/duration envelope.
5. [ ] Capture cost telemetry model per completed render.

Completion Gate:
1. [ ] Lambda smoke renders pass without manual retries.
2. [ ] p95 duration `<= 1.20 x P0 duration_p95_sec`, p95 memory `<= 3840 MB`, and timeout-breach count `= 0` in smoke run.
3. [ ] Dashboard and alerts verified in target environment.

## P5: Backend, Worker, and Client Contract Alignment

Status: Not Started  
Target: 2 days  
Problem Countered: E  
Owner: Backend worker/data-model owner

Work Items:
1. [ ] Implement renderer v2 integration in worker adapter.
2. [ ] Add/align schema fields needed for style pinning and dedup fingerprint.
3. [ ] Implement dedup collision strategy and DB index.
4. [ ] Update public API docs and response envelope alignment.
5. [ ] Regenerate Flutter OpenAPI client and update usage paths.
6. [ ] Add and verify migration rollback path (upgrade + downgrade rehearsal for new columns/indexes).

Completion Gate:
1. [ ] Worker->renderer contract tests pass (create/status/cancel + error envelope).
2. [ ] Dedup conflict returns deterministic `409 existing_job_id`.
3. [ ] Flutter builds/tests pass with regenerated client.
4. [ ] Migration rehearsal proves upgrade + downgrade success and preserves pre-existing data.

## P6: Quality Gate Test Suite

Status: Not Started  
Target: 2 days  
Problem Countered: F  
Owner: QA automation owner

Work Items:
1. [ ] Add fixture-based visual regression suite.
2. [ ] Add seam continuity checks at chunk boundaries.
3. [ ] Add deterministic hash checks for planner/frame-state and overlay paths; validate full-frame output with SSIM/seam metrics (not full-frame hash equality).
4. [ ] Add stress tests for long routes and mixed transport modes.
5. [ ] Add classic-template non-regression suite (fixtures + API/status shape checks).

Completion Gate:
1. [ ] SSIM and hash thresholds pass.
2. [ ] Seam thresholds pass.
3. [ ] Stability threshold meets target in staging run.
4. [ ] Classic non-regression passes (`SSIM >= 0.995` on classic fixtures and completion-rate delta `>= -0.5 pp` vs `P0` baseline).

## P7: Canary and Rollout

Status: Not Started  
Target: 2 days  
Problem Countered: G  
Owner: Release/operations owner

Work Items:
1. [ ] Enable cinematic GL in controlled environment/canary cohort.
2. [ ] Monitor errors, retries, duration, and cost during canary window.
3. [ ] Close rollback window after stability period.
4. [ ] Publish release notes and operational runbook updates.

Completion Gate:
1. [ ] No P0/P1 regressions during canary.
2. [ ] Canary metrics hold: completion `>= 99%` over `>= 500` jobs, `SSIM >= 0.985`, seam limits pass, and `cost_p95 <= 1.20 x P0 cost_p95_usd`.
3. [ ] Rollout sign-off completed.

## 7. Utility Export to Execution Map (Canonical Checklist)

Source of truth alignment:
1. Utility exports are canonical in `video-renderer/docs/cinematic-gl-runtime-architecture.md` section `14`.
2. This section maps each utility file to phase ownership, dependencies, and test evidence.
3. `[x]` allowed only after code + tests + evidence links are added in section `10`.

### 7.1 File-Level Ownership and Phase Mapping

| Utility file | Phase | Primary owner | Depends on | Required evidence |
| --- | --- | --- | --- | --- |
| `src/remotion/gl/types.js` | P1 | Video-renderer planning owner | none | `types.test.js` pass |
| `src/remotion/gl/quality-constants.js` | P1 | Video-renderer planning owner | none | constants snapshot test pass |
| `src/remotion/gl/normalize-snapshot.js` | P1 | Video-renderer planning owner | `types.js` | normalization fixtures pass |
| `src/remotion/gl/timeline-compiler.js` | P1 | Video-renderer planning owner | `normalize-snapshot.js` | segment allocation tests pass |
| `src/remotion/gl/geometry-math.js` | P1 | Video-renderer planning owner | none | numeric property tests pass |
| `src/remotion/gl/route-animator.js` | P1 | Video-renderer planning owner | `timeline-compiler.js`, `geometry-math.js` | route continuity tests pass |
| `src/remotion/gl/camera-planner.js` | P1/P3 | Video-renderer planning owner (P1), motion/visual owner (P3) | `route-animator.js`, `geometry-math.js`, `quality-constants.js` | camera seam + interpolation tests pass |
| `src/remotion/gl/overlay-planner.js` | P1/P3 | Video-renderer planning owner (P1), motion/visual owner (P3) | `timeline-compiler.js`, `quality-constants.js` | overlay placement scoring tests pass |
| `src/remotion/gl/render-plan-builder.js` | P1 | Video-renderer planning owner | all planner utilities | determinism hash tests pass |
| `src/remotion/gl/map-init.js` | P2 | Video-renderer runtime owner | `render-plan-builder.js` | style gate + pin mismatch tests pass |
| `src/remotion/gl/map-runtime.js` | P2 | Video-renderer runtime owner | `map-init.js`, `render-plan-builder.js` | per-frame map apply tests pass |
| `src/remotion/gl/retry-policy.js` | P4/P5 | Infra/ops owner (P4), backend worker owner (P5) | error code list freeze from P0 + shared retry matrix | renderer retry classification tests + Python worker parity tests pass |
| `src/remotion/CinematicGL.jsx` | P2/P3 | Runtime owner (P2), motion/visual owner (P3) | full GL utility stack | cinematic fixture render and sync tests pass |
| `src/remotion/Cinematic.jsx` | P2 | Runtime owner (P2) | `CinematicGL.jsx`, `CinematicLegacy.jsx` | wrapper/export contract tests pass |
| `src/remotion/CinematicLegacy.jsx` | P2 | Runtime owner (P2) | legacy renderer path | rollback fixture render parity tests pass |

### 7.2 Exact Export Completion Checklist

`src/remotion/gl/types.js`
1. [ ] `isLngLat(value)`
2. [ ] `isFrameIndex(value)`
3. [ ] `isNormalized(value)`

`src/remotion/gl/quality-constants.js`
1. [ ] `CAMERA_LIMITS`
2. [ ] `EASING`
3. [ ] `SEAM_THRESHOLDS`
4. [ ] `OVERLAY_SAFE_AREA`
5. [ ] `ROUTE_STYLE_DEFAULTS`

`src/remotion/gl/normalize-snapshot.js`
1. [ ] `normalizeSnapshot(snapshot)`
2. [ ] `extractRendererConfig(snapshot)`
3. [ ] `validateSnapshotForCinematic(snapshot)`

`src/remotion/gl/timeline-compiler.js`
1. [ ] `compileTimelineSegments(input)`
2. [ ] `allocateSegmentFrames(input)`
3. [ ] `findActiveSegment(segments, frame)`

`src/remotion/gl/geometry-math.js`
1. [ ] `clamp(value, min, max)`
2. [ ] `lerp(a, b, t)`
3. [ ] `lerpAngleDegShortest(aDeg, bDeg, t)`
4. [ ] `lerpLngShortest(aLng, bLng, t)`
5. [ ] `haversineMeters(a, b)`
6. [ ] `cumulativePolylineMeters(points)`

`src/remotion/gl/route-animator.js`
1. [ ] `buildRouteCurves(input)`
2. [ ] `pointAtS(curve, sNorm)`
3. [ ] `headingAtS(curve, sNorm, eps?)`
4. [ ] `buildAirArc(start, end, curvature?)`
5. [ ] `pointOnAirArc(arc, sNorm)`

`src/remotion/gl/camera-planner.js`
1. [ ] `buildCameraKeyframes(input)`
2. [ ] `interpolateCamera(frame, keyframes)`
3. [ ] `cameraStateAtFrame(frame, keyframes)`
4. [ ] `clampCameraState(camera)`

`src/remotion/gl/overlay-planner.js`
1. [ ] `buildOverlayTracks(input)`
2. [ ] `overlayStateAtFrame(tracks, frame)`
3. [ ] `resolveCardPlacement(input)`
4. [ ] `scoreCardCandidate(input)`

`src/remotion/gl/render-plan-builder.js`
1. [ ] `buildRenderPlan(input)`
2. [ ] `getFrameState(plan, frame)`
3. [ ] `hashRenderPlan(plan)`
4. [ ] `assertPlanDeterminism(plan)`

`src/remotion/gl/map-init.js`
1. [ ] `initMapWithGate(input)`
2. [ ] `verifyStylePin(input)`
3. [ ] `destroyMap(map)`

`src/remotion/gl/map-runtime.js`
1. [ ] `applyFrameToMap(map, frameState)`
2. [ ] `upsertRouteLayerState(map, routeState)`
3. [ ] `upsertMarkerLayerState(map, markerState)`
4. [ ] `applyCameraState(map, camera)`

`src/remotion/gl/retry-policy.js`
1. [ ] `classifyRendererError(code)`
2. [ ] `nextBackoffMs(code, attempt)`
3. [ ] `isTerminalRendererError(code)`

`src/remotion/CinematicGL.jsx`
1. [ ] `CinematicGL(props)`
2. [ ] `useCinematicPlan(input)`
3. [ ] `useCinematicFrameState(plan, frame)`

`src/remotion/Cinematic.jsx`
1. [ ] `Cinematic` re-export alias to `CinematicGL`
2. [ ] `CinematicLegacy` re-export

`src/remotion/CinematicLegacy.jsx`
1. [ ] `CinematicLegacy(props)`

### 7.3 Export-to-Test Pack Mapping

1. [ ] U-PLAN-01: deterministic planner snapshot test pack covers `normalize-snapshot`, `timeline-compiler`, `render-plan-builder`.
2. [ ] U-GEOM-01: numeric and property tests cover `geometry-math`, `route-animator`, `camera-planner`.
3. [ ] U-OVERLAY-01: visual fixture tests cover `overlay-planner` placement and readability constraints.
4. [ ] U-RUNTIME-01: local headless map runtime tests cover `map-init`, `map-runtime`, `CinematicGL.jsx` frame application + `Cinematic.jsx` wrapper contract.
5. [ ] U-RETRY-01: backend worker integration tests cover worker-attempt source-of-truth, and parity checks validate Python worker retry mapping against renderer retry classification matrix.
6. [ ] U-SEAM-01: chunk-boundary seam tests validate camera jump and marker jump thresholds.
7. [ ] U-CLASSIC-01: classic template non-regression suite stays green while cinematic internals are replaced.

## 8. Regression Pack (Must Pass Before P7 Complete)

1. Deterministic rerender of same manifest matches thresholds.
2. Long route cinematic render completes with stable marker/camera sync.
3. Chunk seam continuity checks pass on all cinematic fixtures.
4. Style pin mismatch fails with explicit error code.
5. Dedup race scenario returns one active job and deterministic conflict for duplicates.
6. Cancel and retry paths preserve worker state invariants.
7. Classic non-regression: fixture SSIM `>= 0.995` and completion-rate delta `>= -0.5 pp` vs `P0` baseline.
8. Migration safety: upgrade + downgrade rehearsal succeeds with dedup behavior intact.

## 9. Rollback Triggers

1. Rolling 500-job completion rate drops below `99%`.
2. (`gl_chunk_unstable` + `gl_timeout_delay_render`) exceeds `2%` of cinematic jobs in a rolling 200-job window.
3. 7-day `cost_p95_usd` exceeds `1.20 x P0 cost_p95_usd`.
4. Any quality gate breach in regression pack (`SSIM < 0.985`, seam camera jump `> 0.0005 deg`, seam marker jump `> 3 px @1080p`).

## 10. Evidence Checklist Template (Per Phase)

1. Code diff references: `[fill]`
2. Commands run: `[fill]`
3. Test outputs summary: `[fill]`
4. Visual evidence links: `[fill]`
5. Decision changes (if any): `[fill]`

## 11. Progress Log

1. 2026-03-24: Tracker created. All phases initialized as Not Started.
2. 2026-03-24: Added utility export to execution map and export-level completion checklist aligned to canonical architecture doc.
3. 2026-03-24: P1 implementation started in codebase. Added deterministic planner utilities (`gl/*`) and wired `CinematicGL.jsx` route/marker progression to shared `frameState`.
4. 2026-03-24: Composition split for migration safety: legacy cinematic preserved in `CinematicLegacy.jsx`, new work moved to `CinematicGL.jsx`, and `Cinematic.jsx` now acts as compatibility wrapper exporting GL as canonical cinematic.
5. 2026-03-24: Added `normalize-snapshot.js`, `camera-planner.js`, and `overlay-planner.js`; integrated camera/overlay outputs into `render-plan-builder` and consumed planned camera/label state in `CinematicGL.jsx`.
6. 2026-03-24: Addressed reviewer criticals: robust short-duration segment allocation, travel-camera fallback away from `{0,0}`, style pin enforcement via normalized pin, stronger determinism assertions with rebuild checks, and added automated planner tests.
7. 2026-03-24: Tightened hardening pass: style pin is strict-by-default with explicit compatibility flag only, determinism assertion moved to opt-in diagnostics mode, route-aware overlay scoring wired at runtime, and camera easing/bearing-delta limits enforced; planner test suite green (5/5).
8. 2026-03-24: Replaced fixed thumbnail frame (`45%`) with deterministic content-aware selection for cinematic in both local and Lambda renderer paths, keeping classic template behavior unchanged.
