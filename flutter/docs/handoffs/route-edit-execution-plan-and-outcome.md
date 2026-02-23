# Route Editing Autonomous Execution Runbook

## Document Control
1. Status: Approved for implementation
2. Decision mode: Fix-forward (no reset)
3. Scope owner: Flutter route editor stack
4. Last updated: 2026-02-23

## Objective
Deliver reliable, scalable route editing with bikerouter-like interaction quality while preserving architecture boundaries.

## Final Decision
1. Keep commit `681f3d1` and correct on top.
2. Do not reset to `a8944e0` unless a hard platform/API incompatibility is proven.
3. Execute in three phases:
Phase 1: correctness hardening (required),
Phase 2: interaction parity upgrade (required),
Phase 3: scalability foundation (recommended after stability).

## Why This Decision
1. Existing integration is already useful (line tap wiring, draggable waypoints, toolbar actions).
2. Current issues are logic/concurrency defects, not a failed architecture.
3. Resetting increases regression risk and discards working code.

## Non-Negotiable Boundaries
1. Keep map abstraction intact:
`MapboxMap` must remain inside map abstractions (`MapboxAdapter`/`AppMapView`).
2. Do not use full-screen gesture interception over `MapWidget` as primary interaction path.
3. Do not make air routes editable with waypoints.
4. Keep route creation flow functional during all phases.
5. Leave unrelated generated plugin files untouched.

## Environment Constraint
1. Avoid long/sticky `flutter`/`dart` commands in this workspace session.
2. Validation in this session is static review plus targeted manual device checks.

## Current State Baseline
### Working now
1. Route-line tap callback reaches editor controller.
2. Waypoint markers are draggable and invoke move logic.
3. Route edit toolbar supports edit/flip/delete/close.

### Defects to fix first
1. Generic map tap still inserts waypoint in edit mode.
2. Async route recalculation can commit stale responses.
3. Waypoint insertion snap uses logical straight segments instead of displayed route geometry.
4. Tap-position capture can be stale in edge event ordering.

## Defect Register
1. DEF-01 (Critical): stale async recalc race
Impact: older API responses can override newer edits.
Primary location: `flutter/lib/features/create/presentation/providers/editor_provider.dart:509`

2. DEF-02 (Medium): map tap insertion in edit mode
Impact: accidental off-route waypoint insertion.
Primary location: `flutter/lib/features/create/presentation/providers/editor_provider.dart:661`

3. DEF-03 (High): logical snap instead of geometry snap
Impact: inserted waypoints can appear off the user-tapped road shape.
Primary location: `flutter/lib/features/create/presentation/providers/editor_provider.dart:434`

4. DEF-04 (Medium): tap position freshness risk
Impact: wrong insertion position on some gesture ordering paths.
Primary location: `flutter/lib/core/map/adapters/mapbox_adapter.dart:269`

## Architecture Guardrails (Scalability)
1. Adapter emits map/annotation events only.
2. Controller orchestrates edits and persistence.
3. Geometry math remains pure and testable.
4. Repository handles API/database writes only.
5. Async updates use deterministic `latest-wins` policy.

## Execution Strategy
## Phase 0: Baseline Lock
Goal: freeze reference behavior before edits.

Tasks:
1. Record baseline references and target files.
2. Confirm no reset path.
3. Confirm current route edit event chain.

Exit criteria:
1. Baseline references documented.
2. Execution boundaries acknowledged.

## Phase 1: Correctness Hardening (Required)
Goal: make current edit behavior deterministic and safe.

### Task 1.1: Enforce line-only insertion
1. In `handleMapTap`, remove route-edit insertion behavior.
2. Keep route-edit insertion exclusively behind `handleRouteLineTap`.
3. Preserve non-edit map tap behavior (`deselectAll`) as appropriate.

Files:
1. `flutter/lib/features/create/presentation/providers/editor_provider.dart`

Acceptance:
1. In edit mode, tapping empty map does not add waypoint.
2. Tapping route line still inserts/selects correctly.

### Task 1.2: Add per-route recalc version guard
1. Add route-scoped version counter map in controller:
`Map<String, int> _routeRecalcVersion`.
2. Increment version before each async recalc for that route.
3. Drop async result if version changed before response arrives.

Files:
1. `flutter/lib/features/create/presentation/providers/editor_provider.dart`

Acceptance:
1. Rapid drag/insert actions never roll back to older geometry.
2. Final geometry equals latest user action.

### Task 1.3: Geometry-based snapping
1. Snap tap against `route.coordinates` segments, not logical node chain.
2. Compute snapped point from nearest displayed polyline segment.
3. Derive waypoint insertion index using nearest logical segment to the snapped point.

Files:
1. `flutter/lib/features/create/presentation/providers/editor_provider.dart`

Acceptance:
1. On curved roads, inserted waypoint lies on/near displayed route line.
2. Waypoint order remains stable across multiple insertions.

### Task 1.4: Event freshness hardening
1. Guard line-tap callback path against stale tap-position assumptions.
2. Prefer direct event position when available; otherwise handle fallback safely.

Files:
1. `flutter/lib/core/map/adapters/mapbox_adapter.dart`

Acceptance:
1. Line taps do not insert using visibly stale prior tap positions.

## Phase 2: Interaction Parity Upgrade (Required)
Goal: improve edit fluidity without breaking map gesture stability.

### Task 2.1: Provisional waypoint workflow
1. On route-line interaction, create provisional waypoint state.
2. Allow immediate reposition flow through existing marker drag events.
3. Commit final recalc on drag end.

### Task 2.2: Lightweight live preview
1. Render temporary preview geometry while dragging.
2. Keep preview state transient and non-persistent.
3. Replace preview with API result on commit.

### Task 2.3: Reduce mode friction
1. Keep `editRoute` semantics explicit.
2. Optionally allow route-selected editing shortcuts without mode confusion.

Files:
1. `flutter/lib/features/create/presentation/providers/editor_provider.dart`
2. `flutter/lib/features/create/presentation/providers/map_provider.dart`
3. `flutter/lib/features/create/presentation/widgets/route_edit_toolbar.dart`

Acceptance:
1. Insert+move flow feels continuous.
2. No pan/zoom regression on normal map interactions.

## Phase 3: Scalability Foundation (Recommended)
Goal: prepare for undo/alternatives/no-go/segment controls.

### Task 3.1: Edit command model
1. Normalize route edits into explicit operations:
`insertWaypoint`, `moveWaypoint`, `removeWaypoint`, `flipRoute`.
2. Keep operation handlers side-effect minimal and testable.

### Task 3.2: State separation
1. Keep transient edit-preview state separate from persisted route state.
2. Maintain single write path to repository update.

### Task 3.3: Extension points
1. Add hook points for future alternatives/undo/no-go tools.

Acceptance:
1. New edit tools can be added without changing map adapter contracts.
2. Core edit logic remains unit-testable.

## Autonomous Execution Rules
This section enables execution with minimal intervention.

1. If blocked by uncertainty, choose the least invasive option that preserves correctness and boundaries.
2. Never bypass abstraction boundaries to ship faster.
3. Prefer fix-forward in small commits:
Commit A: correctness,
Commit B: interaction parity,
Commit C: scalability refactor.
4. If a change requires boundary break, pause and request decision.
5. Do not revert or modify unrelated changed files.

## Quality Gates
## Gate 1 (after Phase 1)
1. No stale recalc rollback in rapid edit scenarios.
2. Empty-map tap in edit mode does not insert waypoint.
3. Curved-line insertions snap to displayed route.

## Gate 2 (after Phase 2)
1. One-flow insert-and-adjust interaction is usable and predictable.
2. Map pan/zoom behavior remains intact outside edit interaction path.
3. Air route edit restrictions remain enforced.

## Gate 3 (after Phase 3)
1. Edit operations are modular and composable.
2. Future tooling hooks are explicit and documented.

## Manual Verification Matrix
1. VM-01: Tap route line in edit mode
Expected: one waypoint inserted.

2. VM-02: Tap non-route map area in edit mode
Expected: no waypoint insertion.

3. VM-03: Rapidly drag waypoint multiple times
Expected: final geometry matches last drag endpoint only.

4. VM-04: Insert on curved segment
Expected: inserted waypoint lies on visible curved polyline.

5. VM-05: Tap synthetic connector line
Expected: no edit insertion/select side effects.

6. VM-06: Air route in edit context
Expected: waypoint editing is blocked.

7. VM-07: Reopen trip after edits
Expected: latest waypoints and geometry persist.

## Risks and Mitigations
1. Risk: gesture conflicts with map movement.
Mitigation: keep map-native event path; avoid top overlay interception.

2. Risk: heavy geometry operations on long polylines.
Mitigation: bounded nearest-segment scan and optional simplification for preview only.

3. Risk: stale async overwrite.
Mitigation: per-route version tokens and latest-wins commit checks.

4. Risk: ordering errors on repeated insertions.
Mitigation: deterministic insertion index strategy plus regression checks.

## Rollback Strategy
1. Rollback granularity is commit-level (A/B/C).
2. If Phase 2 introduces gesture instability, keep Phase 1 fixes and disable preview/provisional behavior behind a flag.
3. Never roll back by resetting branch history unless explicitly approved.

## Deliverables
1. Updated editor/controller/map files implementing all Phase 1 items.
2. Phase 2 interaction improvements with no boundary violations.
3. Optional Phase 3 refactor with clear extension hooks.
4. Updated handoff notes with final verification evidence.

## Success Definition
1. Route editing is deterministic under rapid user interaction.
2. Interaction quality is significantly closer to bikerouter behavior.
3. Implementation remains modular and scalable for future route-edit tools.

## References
## Commit references
1. `REF-COMMIT-01`: `681f3d1` - draggable waypoints + tap-on-route-line insertion.
2. `REF-COMMIT-02`: `48c5f8a` - route edit mode and waypoint tooling.
3. `REF-COMMIT-03`: `a8944e0` - directions token fallback.

## Code references
1. `REF-CODE-01`: route line tap handler - `flutter/lib/features/create/presentation/providers/editor_provider.dart:416`
2. `REF-CODE-02`: insertion logic - `flutter/lib/features/create/presentation/providers/editor_provider.dart:434`
3. `REF-CODE-03`: recalc path - `flutter/lib/features/create/presentation/providers/editor_provider.dart:509`
4. `REF-CODE-04`: map tap behavior - `flutter/lib/features/create/presentation/providers/editor_provider.dart:661`
5. `REF-CODE-05`: line tap adapter behavior - `flutter/lib/core/map/adapters/mapbox_adapter.dart:315`
6. `REF-CODE-06`: draggable waypoint markers - `flutter/lib/features/create/presentation/providers/map_provider.dart:101`
7. `REF-CODE-07`: route toolbar - `flutter/lib/features/create/presentation/widgets/route_edit_toolbar.dart:11`

## External behavior references
1. `REF-EXT-01`: BRouter-Web - `https://bikerouter.de`
2. `REF-EXT-02`: BRouter docs - `https://docs.bikerouter.de/en/getting-started/`
3. `REF-EXT-03`: usage walkthrough - `https://www.marcusjaschen.com/faq/bikerouter-brouter-web-anleitung-tipps-und-tricks/`
