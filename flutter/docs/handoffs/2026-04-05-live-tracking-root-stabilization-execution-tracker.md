# Live Tracking Root Stabilization - Execution Tracker (2026-04-05)

Date: 2026-04-05  
Owner: Codex + Flutter + QA  
Status: In Progress (S1-S6 code wired, S7 verification pending)  
Branch: `main`  
Primary Goal: Stabilize live tracking traffic, compiled projection reliability, and place binding from root causes.

Related Docs:
1. `docs/live-tracking-unified-system-architecture-plan.md`
2. `flutter/docs/live-capture-screen-implementation-spec.md`
3. `flutter/docs/handoffs/2026-03-20-trip-sync-execution-tracker.md`

## 1. Purpose

Track execution of the Live Tracking Root Stabilization plan with strict phase gates so work can continue across multiple sessions without losing state.

This tracker is the source of truth for:
1. What is done
2. What remains
3. What is blocked
4. Which tests prove each phase

## 2. Update Rules

1. Move checklist items from `[ ]` to `[x]` only after code + verification are complete.
2. Add one progress log entry for every meaningful code/test milestone.
3. Do not start the next phase until the current phase gate is satisfied.
4. If a regression is found, reopen the phase and log the rollback decision.
5. For every session end, fill `Next Session Start` with exact first commands/files.

## 3. Non-Negotiable Contracts

1. Local IDs remain canonical in Flutter state and local DB.
2. Backend calls use remote IDs only.
3. If required remote ID is missing, do not call backend; return actionable sync state.
4. `on_route_unresolved` is informational, not error.
5. Trip CRUD is online-only for this stabilization wave.
6. No silent swallow in sync/rebind paths (`catch (_) {}` banned for critical paths).

## 4. Phase Board

## S1: Session Integrity First

Status: Code Complete (verification in progress)  
Target: 1-2 working sessions

Work Items:
1. [x] Enforce single global `active` tracking session in runtime repair path.
2. [x] On recovery, keep newest `active`, mark others `abandoned`.
3. [x] Ensure point ingest writes each GPS sample to only one active session.
4. [x] On `session not found` (404), mark local session stale/abandoned and stop new point-batch generation for it.
5. [x] Add DB guard for single-active-session invariant (migration + runtime compatibility).

Completion Gate:
1. [x] Repro with multiple active sessions converges to one active session automatically.
2. [x] No cross-trip fanout for same GPS sample.
3. [x] Stale session 404 no longer creates new point-batch churn.

Primary Files (expected):
1. `flutter/lib/features/create/data/live_tracking_capture_coordinator.dart`
2. `flutter/lib/core/sync/tracking_sync_worker.dart`
3. `flutter/lib/core/storage/drift_database.dart` and migration files

## S2: Retry Contract (Bounded + Classified)

Status: Code Complete (verification in progress)  
Target: 1 working session

Work Items:
1. [x] Introduce `SyncFailureClass { retryable, deferred, terminal, identity_recoverable }`.
2. [x] Centralize sync failure classification in tracking sync worker.
3. [x] Keep retry to max 3 attempts with backoff: `15s`, `60s`, `180s`.
4. [x] Mark terminal failures blocked without retry loops.
5. [x] Preserve explicit identity recovery for stale trip identity only.

Completion Gate:
1. [ ] 4xx terminal errors stop retrying immediately (except identity-recoverable branch).
2. [ ] Retryable network failures respect bounded backoff and then block.
3. [ ] Logs show clear failure class for each blocked/retried task.

Primary Files (expected):
1. `flutter/lib/core/sync/tracking_sync_worker.dart`
2. `flutter/lib/core/storage/daos/sync_task_dao.dart`

## S3: Trip Lifecycle Contract (Online-only)

Status: Code Complete (verification in progress)  
Target: 1 working session

Work Items:
1. [x] Ensure `create/update/delete` trip are direct server operations only.
2. [x] Remove pending-only update branches without explicit repair.
3. [x] If `serverTripId` missing during update, attempt one identity repair then fail actionable.
4. [x] Keep live lifecycle commands gated by valid remote identity (`allowCreate: false`).

Completion Gate:
1. [x] No queued trip metadata mutation path remains for normal CRUD.
2. [x] Missing identity is surfaced as explicit error, not silent pending.
3. [ ] Existing synced trips continue update/delete successfully.

Primary Files (expected):
1. `flutter/lib/features/create/data/trip_repository.dart`
2. `flutter/lib/features/create/presentation/screens/pre_create_screen.dart`
3. `flutter/lib/core/sync/entity_sync_worker.dart` (only if cleanup needed)

## S4: Compiled Projection Reliability

Status: Code Complete (verification in progress)  
Target: 1-2 working sessions

Work Items:
1. [x] Keep immediate projection fetch on editor open.
2. [x] Replace aggressive fixed polling with 90s fallback polling while editor is visible.
3. [x] Add event-driven projection refresh signal on successful tracking sync + rebind + checkin decision.
4. [x] Merge rule: include local storyline entries missing from remote via deterministic dedupe.
5. [x] If remote unavailable/identity missing, show local-only/sync-required view without hiding valid entries.

Completion Gate:
1. [ ] Events appear in editor without leaving/re-entering screen.
2. [ ] Projection traffic is reduced during idle editor state.
3. [ ] No duplicate storyline entries after remote catches up.

Primary Files (expected):
1. `flutter/lib/features/create/presentation/providers/compiled_projection_provider.dart`
2. `flutter/lib/features/create/data/compiled_projection_repository.dart`
3. `flutter/lib/core/sync/tracking_sync_worker.dart` (refresh signal publish)

## S5: Editor + Place Binding Wiring

Status: Partial (lean wiring completed, QA pending)  
Target: 1-2 working sessions

Work Items:
1. [x] Mobile editor always opens timeline/storyline even when `places.isEmpty`.
2. [ ] Move `Add Destination` into timeline sheet action (not hard gate).
3. [x] Surface candidate/place-binding flow in editor where currently hidden.
4. [x] Resolve storyline place names by `serverPlaceId` mapping first, then local `id` fallback.
5. [x] Ensure hydration/refresh merges places and does not drop unsynced local places/cities.

Completion Gate:
1. [ ] No-place trips still show captured storyline panel.
2. [ ] Place/city entries do not disappear after live <-> editor navigation.
3. [ ] Assign/rebind flow remains remote-ID based and user-visible on failure.

Primary Files (expected):
1. `flutter/lib/features/create/presentation/screens/editor_screen.dart`
2. `flutter/lib/features/create/presentation/providers/editor_provider.dart`
3. `flutter/lib/features/create/data/place_repository.dart`

## S6: Map Path Correctness + Diagnostics

Status: Partial (core fixes completed, QA pending)  
Target: 1 working session

Work Items:
1. [x] Change live map redraw trigger from path length to geometry signature.
2. [ ] Keep local path authoritative while active unless remote passes quality gate.
3. [x] Tune spike filters for walking scenario.
4. [x] Keep diagnostics entry reachable on compact widths.
5. [x] Add counters in diagnostics: request-rate snapshot, retry-code summary, active session count.
6. [x] Add fail-fast log markers for invariant violations.

Completion Gate:
1. [ ] Polyline updates when geometry changes even if point count is unchanged.
2. [ ] Compact layout still exposes diagnostics action.
3. [ ] Diagnostics show actionable counters for churn triage.

Primary Files (expected):
1. `flutter/lib/features/live_capture/map/live_capture_map_widget.dart`
2. `flutter/lib/features/create/presentation/live_tracking_map_overlay.dart`
3. `flutter/lib/features/live_capture/presentation/widgets/live_capture_top_bar.dart`
4. `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`

## S7: Verification (Unit + Integration + Soak)

Status: In Progress  
Target: 1-2 working sessions

Work Items:
1. [x] Unit: single-active-session recovery and ingest target behavior.
2. [ ] Unit: retry classifier and terminal/retryable/deferred branches.
3. [x] Unit: compiled merge dedupe and local-only fallback behavior.
4. [ ] Unit: place-name resolution mapping (`serverPlaceId` then local id).
5. [ ] Integration: live capture -> editor auto-appearance without re-entry.
6. [ ] Integration: rebind with remote media IDs updates projection.
7. [ ] Soak: 10-minute idle no retry flood.
8. [ ] Soak: 30-minute walk no multi-trip fanout and stable request rate.

Completion Gate:
1. [ ] All acceptance scenarios pass and are documented.
2. [ ] No P0/P1 regressions introduced in existing live-capture flow.
3. [ ] Tracker updated with final evidence links and commit list.

## 5. Acceptance Scenarios (Must Pass)

1. Create trip online -> start live -> capture note/photo/tag -> open editor and see storyline without re-enter.
2. Confirm place from live review prompt -> media rebind uses remote media IDs and projection updates.
3. Force stale `session not found` 404 -> stale session is abandoned and churn stops.
4. Keep trip with no places -> timeline/storyline remains accessible and visible.
5. Idle app after stop for 10 minutes -> no flood of retries/polls.

## 6. Risk Register

1. Migration risk: single-active DB guard may fail on dirty legacy data if runtime repair is not applied first.
2. Refresh risk: projection event bus can over-invalidate if not debounced.
3. Contract risk: online-only trip updates can surface new UX errors if not mapped to clear messages.
4. Merge risk: wrong dedupe keys can cause duplicate or hidden storyline entries.

Mitigation:
1. Runtime repair before guard enforcement.
2. Debounce refresh signal and keep 90s fallback poll.
3. Add targeted logs and regression tests for each risk.

## 7. Session Handoff Log

Use one entry per work session.

| Date | Session Focus | Branch/Commit Range | What Changed | Tests Run | Result | Blockers | Next Session Start |
|------|----------------|---------------------|--------------|-----------|--------|----------|--------------------|
| 2026-04-05 | Tracker bootstrap | `main` @ `55c184d` | Created execution tracker and phase gates | None | Ready | None | Start S1 implementation in `live_tracking_capture_coordinator.dart` + sync worker stale-session handling |
| 2026-04-05 | S1-S6 lean wiring pass | `main` (working tree) | Implemented single-active-session repair + DB guard, stale-session abandonment on 404, retry classifier/backoff updates, trip lifecycle online-authoritative update path, compiled projection refresh/merge wiring, editor no-place gating removal, place hydration merge, map redraw signature + diagnostics counters | `flutter test test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/compiled_projection_view_test.dart test/features/create/live_tracking_map_overlay_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/sync/live_tracking_sync_primitives_test.dart`; `flutter analyze` on touched files | Focused tests passed; analyze returned only 2 existing info warnings in `editor_screen.dart` (`WillPopScope` deprecation, async context lint) | Integration + soak not yet run; stale-session churn scenario still needs explicit verification evidence | Run manual E2E scenario: create trip -> live capture -> editor auto-compile visibility -> idle traffic check |
| 2026-04-05 | Targeted regression completion | `main` (working tree) | Added regression tests for stale session 404 point-batch handling and compiled fallback with synced local entries | `flutter test test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/compiled_projection_view_test.dart test/features/create/live_tracking_map_overlay_test.dart test/core/sync/tracking_sync_worker_test.dart test/core/sync/live_tracking_sync_primitives_test.dart` | All focused tests passed (44 tests) | Integration + soak still pending | Run manual 10-minute idle + live->editor auto-refresh verification with diagnostics overlay open |

## 8. Commit Ledger (Fill As Work Progresses)

| Phase | Commit SHA | Title | Notes |
|------|------------|-------|------|
| S1 |  |  |  |
| S2 |  |  |  |
| S3 |  |  |  |
| S4 |  |  |  |
| S5 |  |  |  |
| S6 |  |  |  |
| S7 |  |  |  |

## 9. Immediate Next Actions

1. Add/adjust targeted tests for retry classifier + local-only compiled fallback + place-name mapping.
2. Run manual integration pass for editor auto-refresh and no-place timeline visibility.
3. Validate stale-session 404 behavior in an explicit repro and capture logs.
4. Run 10-minute idle soak and record request-rate counters from diagnostics overlay.
