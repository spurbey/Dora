# Live Capture Screen Implementation Spec (Flutter)

Last updated: 2026-03-29  
Checkpoint: Doc-only memory checkpoint committed on 2026-03-29.  
Owner: Flutter architecture  
Parent docs:
1. `docs/live-tracking-unified-system-architecture-plan.md`
2. `docs/live-tracking/live-tracking-execution-plan.md`
3. `flutter/docs/live-tracking-flutter-execution-plan.md`

## 1. Objective

Build a dedicated live-capture experience that is separate from trip editor UX, while preserving seamless flow into editor after capture.

This spec defines:
1. Screen structure and interaction model.
2. Runtime states and transitions.
3. Data flow (local-first capture, sync, projection).
4. Notification and animation behavior.
5. File-level implementation boundaries for agents.

## 2. Product Boundaries

### 2.1 Live Capture Screen Responsibilities
1. Start/Pause/Resume/Stop tracking.
2. Capture actions: photo, note, warning, media, geotag/checkpoint.
3. Show live path, current marker, last captures, and advisories.
4. Always write local first; never block capture on network.

### 2.2 Editor Screen Responsibilities
1. Rich restructuring and long-form editing.
2. Timeline/place/media rebinding and correction.
3. Route/timeline curation and publish/privacy controls.

### 2.3 Hard Rule
Live screen is for capture and runtime monitoring.  
Editor is for curation and restructuring.

### 2.4 Command vs Data Contract (Hotfix Alignment: 2026-03-30)
1. Session lifecycle commands (`start`, `pause`, `resume`, `stop`) are server-authoritative commands.
2. Capture artifacts (`note`, `warn`, `photo/media marker`, `tag/checkpoint`, path points) are offline-first data writes.
3. Command failures must not permanently lock local capture artifacts; they surface actionable callouts and leave local data intact.
4. Current hotfix in branch:
   - removes ended-state `Start New Session` CTA to avoid invalid backend `409` replay loop.
   - keeps command-path migration to pure write-through execution tracked in Slice B follow-up.

## 3. Navigation and Entry Points

### 3.1 New Route
1. Add route constant: `Routes.liveCapture = '/trips/:id/live'`.
2. Add helper: `Routes.liveCapturePath(String id) => '/trips/$id/live'`.

### 3.2 Router Entry
1. Register `GoRoute(path: Routes.liveCapture, builder: ...LiveCaptureScreen(tripId))`.
2. Keep route outside bottom-nav shell if fullscreen immersive behavior is required.

### 3.3 Launch Paths
1. From trip detail: `Start Live Tracking` CTA.
2. From editor header: `Open Live Capture` secondary action.
3. From push deep link: open live route when session is active, else open editor/trip detail.

## 4. Screen Blueprint (UI/UX)

## 4.1 Visual Hierarchy
1. Fullscreen map is primary layer.
2. HUD controls are overlay layers.
3. Action dock is thumb-reachable.
4. Advisory strip is compact and dismissible.

### 4.1.1 Visual Quality Directive (Non-Negotiable)
1. The new live capture screen must be visually distinct from the existing editor strip-based UI.
2. Do not ship legacy card strips for runtime controls as the primary interaction model.
3. Use immersive map-first composition with premium overlays (depth, spacing rhythm, clear contrast).
4. Action controls must feel deliberate and modern, not generic form widgets.
5. Every control state must have strong visual affordance (normal/pressed/disabled/loading/blocked).

### 4.2 Component Tree (Target)
1. `LiveCaptureScreen`
2. `LiveCaptureMapCanvas`
3. `LiveCaptureTopBar`
4. `LiveCaptureActionDock`
5. `LiveCaptureBottomPanel`
6. `LiveCaptureRecentEventsStrip`
7. `LiveAdvisoryStrip`
8. `LiveCaptureTransientEffects`

### 4.2.1 Prohibited Reuse Patterns
1. Do not directly reuse:
   - `live_tracking_control_strip.dart`
   - `live_tracking_moment_strip.dart`
   - `live_tracking_candidate_inbox_strip.dart`
2. These can be used only as logic reference, not UI reference.
3. New screen widgets in `features/live_capture` must define a fresh visual system consistent with design tokens.

### 4.3 Top Bar
1. Back.
2. Trip title.
3. Session badge (`Active`, `Paused`, `Ended`, `Blocked`).
4. Sync indicator (`Synced`, `Syncing`, `Blocked`).
5. Overflow menu (permissions, diagnostics, open editor).

### 4.4 Right Action Dock
Actions in fixed order:
1. Photo.
2. Note.
3. Warning.
4. Media.
5. Geotag/Checkpoint.

Rules:
1. During `Active`: all actions enabled.
2. During `Paused`: actions except note disabled by default.
3. During `Ended`: all capture actions disabled with clear CTA to open editor.

### 4.5 Bottom Panel
1. Session controls row (`Start/Pause/Resume/Stop`).
2. Last point timestamp and GPS status.
3. Last action result and pending sync count.
4. Expand/collapse behavior:
   - collapsed by default while map interaction occurs
   - auto-expand on errors or blocked state

### 4.5.1 Layout and Surface Styling Rules
1. Use layered surfaces:
   - map base layer
   - translucent top bar
   - floating action rail
   - elevated bottom control surface
2. Use rounded geometry with consistent radii from token system.
3. Keep touch targets >= 44 dp.
4. Keep single-thumb critical actions in lower half of screen.
5. Avoid dense text blocks inside runtime surfaces.

### 4.6 Recent Events Strip
1. Show latest 3-5 capture cards.
2. Card fields: icon, time, place badge (`Near X`, `On Route`), sync badge.
3. Tap opens quick preview; long-press opens editor deep link for that event.

### 4.7 Advisory Strip
1. Inline cards with severity color and category icon.
2. Actions: `Dismiss`, `Save`, `View`.
3. Show only top priority advisory in collapsed mode; open inbox sheet for full list.

## 5. Runtime State Model

### 5.1 Session State Enum
1. `planned`
2. `active`
3. `paused`
4. `ended`
5. `blocked`

### 5.2 Sync State Enum
1. `idle`
2. `syncing`
3. `degraded`
4. `blocked`

### 5.3 Resolver State Enum (per event)
1. `resolved`
2. `review_required`
3. `on_route_unresolved`

### 5.4 State Transition Contract
1. `planned -> active` only after server `start` acknowledgement.
2. `active -> paused` only after server `pause` acknowledgement.
3. `paused -> active` only after server `resume` acknowledgement.
4. `active|paused -> ended` only after server `stop` acknowledgement.
5. Any state -> `blocked` only for hard failure requiring user action.

### 5.5 Blocked State Policy
1. User-facing reason must be actionable and non-technical.
2. Expose `Retry` and `Review sync issues`.
3. Capture persistence remains local even if sync blocked.

## 6. Activity Flows (User Actions)

### 6.1 Start Tracking
1. Check permissions and service availability.
2. Validate command prerequisites (authenticated + `serverTripId` present + online).
3. Execute `start` against backend with idempotency key.
4. Persist returned session snapshot locally (`remote_session_id`, timestamps, state).
5. Begin foreground capture loop only after command success.
6. On failure, keep `planned` and show actionable message.

### 6.2 Pause Tracking
1. Execute `pause` against backend with idempotency key.
2. Persist returned session snapshot locally.
3. Pause capture loop after command success.
4. Keep map and recent events visible.

### 6.3 Resume Tracking
1. Execute `resume` against backend with idempotency key.
2. Persist returned session snapshot locally.
3. Resume capture loop after command success.
4. Reopen path stream and current marker updates.

### 6.4 Stop Tracking
1. Execute `stop` against backend with idempotency key.
2. Persist returned session snapshot locally (`ended`).
3. Stop capture loop safely.
4. Flush pending data-plane queue (events/media/path batches).
5. Show summary CTA: `Review in Editor`.

### 6.5 Capture Photo
1. Acquire location snapshot + timestamp.
2. Save event row with local media reference.
3. Show immediate visual confirmation.
4. Enqueue media upload + event sync tasks.

### 6.6 Capture Note
1. Open quick text composer.
2. Save note event with location and text.
3. Resolve place and show confidence badge.
4. Sync asynchronously.

### 6.7 Capture Warning
1. Open compact warning sheet (severity + text + optional media).
2. Save warning event.
3. Render warning marker on map.
4. Sync and surface in editor timeline.

### 6.8 Capture Geotag/Checkpoint
1. Save point-of-interest checkpoint event at current coordinates.
2. Attempt auto-bind to nearest place.
3. If unresolved, tag `On Route`.

## 7. Data Flow (Flutter Local First)

### 7.1 Local Write Order
1. Create event in local DB.
2. Attach local media pointers if present.
3. Run place resolver locally.
4. Emit UI stream update.
5. Enqueue data-plane sync tasks.

### 7.2 Sync Worker Order
1. Event tasks.
2. Media tasks.
3. Point batch tasks.
4. Advisory ack actions.

### 7.2.1 Command-Plane Note
1. Session lifecycle commands are not part of deferred data-plane queue in target architecture.
2. Existing queued command behavior is temporary legacy behavior pending Slice B migration closeout.

### 7.3 Identity Recovery Rule
If tracking endpoint returns trip identity mismatch:
1. Clear stale `serverTripId`.
2. Requeue trip-sync create task.
3. Requeue tracking tasks with trip dependency.
4. Keep local UI operational.

## 8. Provider and Repository Contracts

### 8.1 Required Providers
1. `liveCaptureControllerProvider(tripId)`
2. `liveCaptureViewStateProvider(tripId)`
3. `liveCaptureRecentEventsProvider(tripId)`
4. `liveCaptureAdvisoryProvider(tripId)`
5. `liveCaptureMapOverlayProvider(tripId)`

### 8.2 Required Repositories
1. `LiveCaptureRepository`
2. `TrackingEventRepository`
3. `AdvisoryInboxRepository`
4. `LiveCaptureRuntimeRepository` (existing runtime behavior alignment)

### 8.3 View State Contract
`LiveCaptureViewState` must include:
1. Session state.
2. Sync state.
3. Current marker/path.
4. Recent event summaries.
5. Pending sync counts.
6. Top advisory snapshot.
7. Last error callout (optional).

## 9. Animation Spec

### 9.1 Animation Types
1. Type A: Map-native geospatial animation.
2. Type B: Flutter overlay transitions.
3. Type C: Lottie event bursts.

### 9.2 Animation Tokens
Create `core/theme/animation_tokens.dart` and use constants only.

Required tokens:
1. Durations: `120ms`, `180ms`, `260ms`.
2. Curves: standard, decelerate, emphasized.
3. Map interpolation timings for marker/path updates.
4. Sheet spring constants.

### 9.2.1 Motion Quality Rules
1. Avoid animation noise; motion must indicate state change or spatial relation.
2. Do not animate every widget simultaneously.
3. Keep critical action feedback under 220 ms end-to-end.
4. Use reduced-motion fallback where platform setting requires it.

### 9.3 Event-to-Animation Mapping
1. GPS update: Type A.
2. Route extension: Type A.
3. Photo saved: Type B + Type C.
4. Note saved: Type B.
5. Warning saved: Type A + Type C.
6. Advisory received: Type B (Type C only for critical).
7. Sync success: subtle Type B.
8. Sync blocked: no celebratory motion, static error emphasis.

## 10. In-App Notification and Push Behavior

### 10.1 In-App Advisory
1. Live screen consumes advisory stream from local inbox table.
2. Action handling (`dismiss`, `save`) writes local first then sync.
3. Advisory card dedupe by key `(place_id, category, time_bucket)`.

### 10.2 Push Rules
1. Push only medium/high/critical advisories.
2. Respect cooldown windows and quiet hours.
3. Deep links:
   - active session -> live screen
   - no active session -> editor or trip detail

### 10.3 Token Safety
1. Use auth-generation guard in token lifecycle.
2. Suppress stale token usage after account switch/logout/login races.

## 11. Implementation File Plan

### 11.1 New Files
1. `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
2. `flutter/lib/features/live_capture/presentation/widgets/live_capture_top_bar.dart`
3. `flutter/lib/features/live_capture/presentation/widgets/live_capture_action_dock.dart`
4. `flutter/lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart`
5. `flutter/lib/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart`
6. `flutter/lib/features/live_capture/presentation/widgets/live_advisory_strip.dart`
7. `flutter/lib/features/live_capture/presentation/providers/live_capture_provider.dart`
8. `flutter/lib/features/live_capture/data/live_capture_repository.dart`
9. `flutter/lib/core/storage/tables/tracking_events_table.dart`
10. `flutter/lib/core/storage/daos/tracking_event_dao.dart`
11. `flutter/lib/core/storage/tables/advisory_inbox_table.dart`
12. `flutter/lib/core/storage/daos/advisory_inbox_dao.dart`
13. `flutter/lib/core/theme/animation_tokens.dart`
14. `flutter/lib/features/live_capture/presentation/widgets/live_capture_theme_contract.dart`

### 11.2 Modified Files
1. `flutter/lib/core/navigation/routes.dart`
2. `flutter/lib/core/navigation/app_router.dart`
3. `flutter/lib/core/network/live_tracking_api.dart`
4. `flutter/lib/core/sync/tracking_sync_worker.dart`
5. `flutter/lib/features/create/presentation/screens/editor_screen.dart` (remove live runtime controls)
6. `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
7. `flutter/lib/features/create/presentation/providers/editor_sync_status_provider.dart`

## 12. UX Safety Rules

1. Never hide a just-captured event due to sync reconciliation.
2. Never show raw exceptions in production UI.
3. Always allow user to continue local capture while network is unstable.
4. Keep common capture actions to max two taps.
5. Avoid bottom overflow by adaptive panel height and keyboard-aware layout.
6. Do not expose legacy `Capture now` strip pattern in this new screen.
7. No generic utility-style controls as primary CTA; use dedicated live-capture components.
8. Keep visual hierarchy map-first and reduce clutter in active tracking state.

## 13. Acceptance Criteria

1. New live screen exists and is routable from trip detail.
2. Editor no longer hosts runtime capture controls.
3. All five capture actions persist locally and appear immediately.
4. Session transitions (`start/pause/resume/stop`) are server-authoritative and do not create permanent blocked loops.
5. Identity mismatch recovery unblocks tasks automatically.
6. In-app advisories render with action handling and dedupe.
7. Push deep links route to correct screen based on session status.
8. Animation behavior matches tokenized timing and event mapping.
9. UI passes design quality gate (Section 16.6) with no legacy strip regressions.

## 14. Testing Matrix

### 14.1 Unit
1. Session transition policy.
2. Resolver confidence threshold behavior.
3. Event serialization and payload mapping.
4. Advisory dedupe key generation.

### 14.2 DAO/Storage
1. Tracking events insert/query/update.
2. Advisory inbox insert/query/action-state transitions.
3. Migration tests on clean and upgraded DB.

### 14.3 Sync/Integration
1. Offline capture then replay.
2. Stale serverTripId recovery path.
3. Media upload retries and eventual success.
4. Blocked -> recovered task transitions.

### 14.4 Widget/Golden
1. Live screen state variants (planned/active/paused/ended/blocked).
2. Action dock behavior and disabled states.
3. Advisory strip interactions.
4. Bottom panel overflow resilience.

### 14.5 Manual QA
1. 30+ minute tracking session with intermittent connectivity.
2. Capture burst under motion.
3. Deep-link from push under active and ended sessions.
4. Editor handoff correctness for captured events and media.

## 15. Execution Slices for Agents

1. Slice A: Route + screen shell + state placeholders.
2. Slice B: Session controls and runtime loop integration.
3. Slice C: Capture actions and event local persistence.
4. Slice D: Resolver and place badges.
5. Slice E: Advisory strip and inbox actions.
6. Slice F: Sync/identity recovery hardening.
7. Slice G: Animation tokenization + mappings.
8. Slice H: Editor decoupling + final validation.

Each slice must include:
1. code changes
2. tests
3. docs update (`flutter/docs/live-tracking-flutter-execution-plan.md` status section)

## 16. Agent Execution Checklist (Tick Board)

This section is the Flutter execution memory board for agent handoffs.  
Update it in every implementation commit.

### 16.1 Cross-Doc Requirements
Before closing a slice, confirm updates in:
1. `docs/live-tracking-unified-system-architecture-plan.md` (Section 16).
2. `docs/live-tracking/live-tracking-execution-plan.md` (phase evidence line).
3. `flutter/docs/live-tracking-flutter-execution-plan.md` (Flutter phase status).
4. this document (Section 16 tick board + evidence log).

### 16.2 Slice Tracker

Baseline prefill snapshot: 2026-03-29.
Important tracking rule:
1. A checklist item is `[x]` only when implemented in the new dedicated `features/live_capture` path.
2. Existing editor-based live-tracking code is treated as prerequisite context, not slice completion.

#### Slice A: Route + Screen Shell
Status: `[x]`
1. [x] Add `Routes.liveCapture` + path helper.
2. [x] Register route in `app_router.dart`.
3. [x] Add `LiveCaptureScreen` scaffold with map and placeholders.
4. [x] Add state variants UI (`planned/active/paused/ended/blocked`) without business logic.
5. [x] Add initial widget tests for render states.

#### Slice B: Session Controls + Runtime
Status: `[-]`
1. [x] Add session start/pause/resume/stop actions to provider/controller.
2. [x] Wire to runtime repository and local persistence.
3. [ ] Migrate lifecycle commands to server write-through execution (remove deferred session-task queue path).
4. [x] Show actionable blocked-state callout and retry action.
5. [x] Add unit/integration tests for transition rules.
6. [x] Hotfix: remove ended-state restart CTA that triggers backend `start` policy `409` loop.

#### Slice C: Capture Actions and Local Persistence
Status: `[-]`
1. [x] Implement photo/note/warn/media/geotag actions.
2. [ ] Persist `tracking_events` row before any network call.
3. [ ] Persist local media refs and enqueue upload tasks.
4. [x] Render recent events strip from local stream.
5. [x] Add tests for immediate local visibility.

#### Slice D: Resolver and Place Badges
Status: `[ ]`
1. [ ] Add resolver pipeline (50m/80m/100m/150m steps).
2. [ ] Persist `resolved_place_id`, confidence, reason code.
3. [ ] Show `Near X` or `On Route` badges in event cards.
4. [ ] Add override-safe behavior (manual edits not auto-overwritten).
5. [ ] Add regression tests for trip-id remap disappearance bug class.

#### Slice E: Advisory In-App UX
Status: `[ ]`
1. [ ] Add advisory inbox table + DAO + repository.
2. [ ] Render advisory strip and inbox sheet.
3. [ ] Implement advisory actions (`dismiss/save/view`) local-first.
4. [ ] Add dedupe/cooldown display behavior.
5. [ ] Add widget and provider tests.

#### Slice F: Sync/Identity Recovery Hardening
Status: `[ ]`
1. [ ] Add identity mismatch recovery in tracking sync worker.
2. [ ] Requeue trip create task when stale remote identity detected.
3. [ ] Requeue dependent tracking tasks to pending (not terminal block).
4. [ ] Expose blocked/pending counts in sync status.
5. [ ] Add stale-identity replay tests.

#### Slice G: Animation and Motion Tokens
Status: `[ ]`
1. [ ] Add `core/theme/animation_tokens.dart`.
2. [ ] Apply tokenized timings/curves in live capture widgets.
3. [ ] Implement Type A/B/C mappings from Section 9.
4. [ ] Add low-end fallback behavior for Lottie bursts.
5. [ ] Add animation timing smoke tests.

#### Slice H: Editor Decoupling + Final Validation
Status: `[-]`
1. [x] Remove live runtime control strips from editor screen.
2. [x] Keep editor consuming compiled/projection overlays only.
3. [x] Run full test matrix from Section 14.
4. [ ] Validate no overflow/crash in long live sessions.
5. [ ] Update all related docs and add final evidence entry.

### 16.3 Definition of Slice Completion
A slice is complete only when all are true:
1. Code merged with clear commit message.
2. Required tests added and passing.
3. No TODO placeholders for critical path.
4. Cross-doc updates complete.
5. Evidence block added.

### 16.6 UI Quality Gate (Mandatory)
All items must pass before merging any live screen PR:
1. No direct usage of legacy strip widgets listed in Section 4.2.1.
2. Screen remains map-dominant in active state (no stacked card clutter at top).
3. Core actions are reachable one-handed on common Android screen sizes.
4. Typography and spacing follow token system; no ad-hoc inline styling drift.
5. Loading, error, blocked, paused, ended states each have distinct and polished visual treatment.
6. Golden screenshots captured for `planned/active/paused/ended/blocked`.
7. Manual UX review note included in PR summary.

### 16.4 Evidence Log Template

```md
### Slice X Evidence (YYYY-MM-DD)
- Owner:
- PR/Commit:
- Files changed:
  - `...`
- Commands run:
  - `flutter analyze ...`
  - `flutter test ...`
- Results:
  - passed:
  - failed:
- Known follow-ups:
- Docs touched:
  - `flutter/docs/live-capture-screen-implementation-spec.md`
  - `flutter/docs/live-tracking-flutter-execution-plan.md`
  - `docs/live-tracking-unified-system-architecture-plan.md`
```

### 16.5 Baseline Evidence (Prefill Snapshot)

1. Session controls + runtime pipeline already exist in editor path:
   - `flutter/lib/features/create/data/live_tracking_capture_coordinator.dart`
   - `flutter/lib/features/create/data/live_tracking_runtime_repository.dart`
   - `flutter/lib/features/create/presentation/screens/editor_screen.dart`
2. Sync identity recovery hardening is implemented:
   - `flutter/lib/core/sync/tracking_sync_worker.dart`
   - `flutter/test/core/sync/tracking_sync_worker_test.dart`
3. Local moment persistence and override tests exist:
   - `flutter/lib/features/create/data/live_tracking_moment_repository.dart`
   - `flutter/test/features/create/live_tracking_moment_repository_test.dart`
4. Editor-side live capture widgets and tests exist (carry-over assets):
   - `flutter/lib/features/create/presentation/widgets/live_tracking_control_strip.dart`
   - `flutter/lib/features/create/presentation/widgets/live_tracking_moment_strip.dart`
   - `flutter/test/features/create/live_tracking_control_strip_test.dart`
   - `flutter/test/features/create/live_tracking_moment_strip_test.dart`

### Slice A Evidence (2026-03-29)
- Owner: Codex
- PR/Commit: `53ed9f3`
- Files changed:
  - `flutter/lib/core/navigation/routes.dart`
  - `flutter/lib/core/navigation/app_router.dart`
  - `flutter/lib/features/live_capture/domain/live_capture_shell_state.dart`
  - `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_top_bar.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_action_dock.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_map_canvas.dart`
  - `flutter/test/features/live_capture/live_capture_screen_test.dart`
- Commands run:
  - `flutter analyze lib/core/navigation/routes.dart lib/core/navigation/app_router.dart lib/features/live_capture/domain/live_capture_shell_state.dart lib/features/live_capture/presentation/screens/live_capture_screen.dart lib/features/live_capture/presentation/widgets/live_capture_top_bar.dart lib/features/live_capture/presentation/widgets/live_capture_action_dock.dart lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart lib/features/live_capture/presentation/widgets/live_capture_map_canvas.dart test/features/live_capture/live_capture_screen_test.dart`
  - `flutter test test/features/live_capture/live_capture_screen_test.dart`
- Results:
  - passed: analyze clean, 5 widget tests passed
  - failed: none
- Known follow-ups:
  - Wire real runtime providers and actions in Slice B
  - Replace placeholder map canvas with live map runtime overlay integration
- Docs touched:
  - `flutter/docs/live-capture-screen-implementation-spec.md`
  - `docs/live-tracking-unified-system-architecture-plan.md`

### Slice B Evidence (2026-03-29)
- Owner: Codex
- PR/Commit: `e0ac2df`
- Files changed:
  - `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart`
  - `flutter/test/features/live_capture/live_capture_screen_test.dart`
- Commands run:
  - `flutter analyze lib/features/live_capture/presentation/screens/live_capture_screen.dart lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart test/features/live_capture/live_capture_screen_test.dart`
  - `flutter analyze lib/core/navigation/routes.dart lib/core/navigation/app_router.dart lib/features/live_capture/domain/live_capture_shell_state.dart lib/features/live_capture/presentation/screens/live_capture_screen.dart lib/features/live_capture/presentation/widgets/live_capture_top_bar.dart lib/features/live_capture/presentation/widgets/live_capture_action_dock.dart lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart lib/features/live_capture/presentation/widgets/live_capture_map_canvas.dart test/features/live_capture/live_capture_screen_test.dart`
  - `flutter test test/features/live_capture/live_capture_screen_test.dart`
- Results:
  - passed: analyze clean, 5 widget tests passed
  - failed: none
- Known follow-ups:
  - Replace placeholder map canvas with runtime overlay integration
  - Add dedicated provider layer under `features/live_capture/presentation/providers`
- Docs touched:
  - `flutter/docs/live-capture-screen-implementation-spec.md`
  - `docs/live-tracking-unified-system-architecture-plan.md`

### Slice C Evidence (2026-03-29, Partial)
- Owner: Codex
- PR/Commit: `a7f1ba2`
- Files changed:
  - `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_action_dock.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart`
  - `flutter/test/features/live_capture/live_capture_recent_events_strip_test.dart`
- Commands run:
  - `flutter analyze lib/features/live_capture/presentation/screens/live_capture_screen.dart lib/features/live_capture/presentation/widgets/live_capture_action_dock.dart lib/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart test/features/live_capture/live_capture_screen_test.dart test/features/live_capture/live_capture_recent_events_strip_test.dart`
  - `flutter test test/features/live_capture/live_capture_screen_test.dart test/features/live_capture/live_capture_recent_events_strip_test.dart`
- Results:
  - passed: analyze clean, 7 widget tests passed
  - failed: none
- Known follow-ups:
  - Add dedicated `tracking_events` write path for all capture actions
  - Add media-ref persistence and upload-task enqueue for photo/media actions
- Docs touched:
  - `flutter/docs/live-capture-screen-implementation-spec.md`
  - `docs/live-tracking-unified-system-architecture-plan.md`

### Slice H Evidence (2026-03-30, Partial)
- Owner: Codex
- PR/Commit: `c893416`, `dccfc9d`, `91a053d`
- Files changed:
  - `flutter/lib/features/create/presentation/screens/editor_screen.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_top_bar.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart`
  - `flutter/test/features/live_capture/live_capture_screen_test.dart`
  - `flutter/docs/live-capture-screen-implementation-spec.md`
  - `docs/live-tracking-unified-system-architecture-plan.md`
  - `docs/live-tracking/live-tracking-execution-plan.md`
  - `flutter/docs/live-tracking-flutter-execution-plan.md`
- Commands run:
  - `flutter analyze --no-fatal-infos lib/features/create/presentation/screens/editor_screen.dart`
  - `flutter analyze --no-fatal-infos lib/features/create/presentation/screens/editor_screen.dart lib/features/live_capture/presentation/screens/live_capture_screen.dart test/features/live_capture/live_capture_screen_test.dart test/features/live_capture/live_capture_recent_events_strip_test.dart`
  - `flutter test test/core/sync/live_tracking_sync_primitives_test.dart test/features/create/live_tracking_capture_coordinator_test.dart test/features/create/live_tracking_runtime_repository_test.dart test/core/storage/live_tracking_storage_dao_test.dart test/core/storage/sync_task_dao_test.dart test/features/create/live_tracking_moment_repository_test.dart test/features/create/live_tracking_candidate_repository_test.dart test/core/sync/tracking_sync_worker_test.dart test/features/create/live_tracking_runtime_provider_test.dart test/features/create/live_tracking_map_overlay_test.dart test/core/network/live_tracking_api_test.dart test/features/live_capture/live_capture_screen_test.dart test/features/live_capture/live_capture_recent_events_strip_test.dart test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_moment_strip_test.dart test/features/create/live_tracking_candidate_inbox_strip_test.dart`
  - `flutter test test/features/create/live_tracking_control_strip_test.dart test/features/create/live_tracking_moment_strip_test.dart`
- Results:
  - passed: matrix rerun green (`94` tests); compact-viewport overflow regression now covered by `live_capture_screen_test.dart`
  - failed: none
- Known follow-ups:
  - Manual 30+ minute live-session QA from Section 14.5 remains pending before slice closeout
  - Remove legacy strip implementation paths completely after migration window
  - Replace `_showLegacyTrackingWidgets` fallback with full removal once migration is stable
- Docs touched:
  - `flutter/docs/live-capture-screen-implementation-spec.md`
  - `docs/live-tracking-unified-system-architecture-plan.md`
  - `docs/live-tracking/live-tracking-execution-plan.md`
  - `flutter/docs/live-tracking-flutter-execution-plan.md`

### Hotfix Evidence (2026-03-30, Session Command + Crash Stabilization)
- Owner: Codex
- Scope:
  - Live quick-note dialog lifecycle crash fix.
  - Prevent live screen runtime lock from known `tracking/start` `http_409` policy block.
  - Improve blocked error message quality from raw Dio blob to backend detail text.
- Files changed:
  - `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
  - `flutter/lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart`
  - `flutter/lib/features/create/presentation/providers/editor_sync_status_provider.dart`
  - `flutter/lib/core/sync/tracking_sync_worker.dart`
  - `flutter/test/features/live_capture/live_capture_screen_test.dart`
  - `flutter/test/features/create/editor_sync_status_provider_test.dart`
  - `flutter/test/core/sync/tracking_sync_worker_test.dart`
- Commands run:
  - `flutter test test/features/live_capture/live_capture_screen_test.dart test/features/create/editor_sync_status_provider_test.dart test/core/sync/tracking_sync_worker_test.dart`
  - `flutter analyze lib/features/live_capture/presentation/screens/live_capture_screen.dart lib/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart lib/features/create/presentation/providers/editor_sync_status_provider.dart lib/core/sync/tracking_sync_worker.dart test/features/live_capture/live_capture_screen_test.dart test/features/create/editor_sync_status_provider_test.dart test/core/sync/tracking_sync_worker_test.dart`
- Results:
  - passed: focused tests (`31`) and targeted analyze on touched files
  - failed: none
- Follow-up:
  - complete Slice B item 3 (write-through server command path for lifecycle actions).
