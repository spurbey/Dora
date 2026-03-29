# Live Tracking + Editor Unified System Architecture Plan

Date: 2026-03-29
Checkpoint: Doc-only memory checkpoint committed on 2026-03-29.
Scope: End-to-end technical blueprint for a seamless live-capture-to-editor system that integrates in-app events with external travel signals.

## 1. Product Boundary and Core Principles

### 1.1 Two Bounded Contexts
1. Live Capture Runtime (`capture-first`, low-friction, real-time, offline-safe).
2. Travelogue Editor (`curation-first`, rich editing, restructuring, publish controls).

### 1.2 Core Rules
1. Local capture is append-only and never blocked by network.
2. Local IDs are canonical on device; remote IDs are mappings, not replacements.
3. Live screen does not expose full editor complexity.
4. Editor consumes compiled projections and allows manual overrides.
5. External signals are advisory, never authoritative over user-captured truth.

### 1.3 Non-Goals (for this plan)
1. No hard dependency on external signal providers for core trip capture.
2. No destructive data rewrites during sync or compile.
3. No hidden auto-edits that cannot be manually corrected in editor.

## 2. Target User Experience

### 2.1 Live Capture Screen
1. Full-screen map.
2. Start/Pause/Resume/Stop tracking.
3. Quick actions: Photo, Note, Warning, Media, Geotag.
4. Live route/path + current marker + recent capture chips.
5. Lightweight in-app advisories ("nearby caution", "quiet spot", "detour").

### 2.1.1 UX Quality Contract
1. The new live capture screen must not reuse the existing strip-centric editor runtime UI as-is.
2. Legacy `Capture now`/`moment strip` patterns are considered transitional and not acceptable as final live screen UX.
3. New live capture UI must be immersive and map-dominant with dedicated runtime surfaces and polished states.
4. Visual quality is a release gate, not a post-release enhancement.

### 2.2 Editor Screen
1. Full timeline of places, moments, media, path segments.
2. Rebinding of events to places.
3. Content editing (title, note, warning text, media captions, place association).
4. Route/timeline restructuring and visibility controls (public/private).

### 2.3 Seamless Transition
1. Every capture appears immediately in live screen local stream.
2. Compiler projection makes items appear in editor without manual refresh.
3. If auto-binding is wrong, user can relink in editor; relink is persisted and protected.

## 3. System Architecture

## 3.1 High-Level Services
1. Flutter App:
   - Capture runtime
   - Local database + sync outbox
   - In-app advisory rendering
2. Backend API:
   - Tracking lifecycle and capture ingest
   - Moment/candidate operations
   - Projection and advisory retrieval
3. Background Workers:
   - Inference and compilation
   - External signal ingestion/normalization
   - Advisory scoring and delivery
4. Notification Delivery:
   - In-app stream feed
   - Push notification worker

### 3.2 Data Planes
1. Operational plane: tracking sessions, points, moments, candidates, sync tasks.
2. Knowledge plane: external signals, place graph, dedupe index, advisory features.
3. Presentation plane: compiled trip projection for editor and live overlays.

### 3.3 Worker Topology
1. `live_tracking_worker` (existing): session lifecycle inference, candidate progression, auto-end checks.
2. `trip_compiler_worker` (new): builds editor projections from raw tracking events and points.
3. `external_signal_ingestion_worker` (new): connector orchestration for Google/Reddit/Tripadvisor fetch jobs.
4. `external_signal_normalization_worker` (new): parsing, language normalization, place mention extraction, dedupe key generation.
5. `advisory_scoring_worker` (new): trip-context scoring, thresholding, and delivery readiness.
6. `advisory_delivery_worker` (new): in-app inbox writes + push dispatch with cooldown and dedupe windows.

## 4. Canonical Data Model and Identity

### 4.1 Identity Strategy
1. `local_trip_id` (Flutter DB) is immutable on device.
2. `server_trip_id` is nullable and can be re-resolved.
3. Tracking entities carry both local trip key and optional remote references.
4. Recovery path for stale identity:
   - Clear stale `server_trip_id`
   - Requeue trip create/sync
   - Requeue blocked tracking tasks with trip dependency

### 4.2 Local (Flutter) Tables
Existing:
1. `tracking_sessions`
2. `tracking_point_batches`
3. `tracking_moments`
4. `tracking_candidates`
5. `sync_tasks`

New:
1. `tracking_events`
   - `id`, `trip_id`, `session_id`, `event_type`, `lat`, `lng`, `accuracy_m`, `captured_at`, `payload_json`, `resolved_place_id`, `bind_confidence`, `sync_status`
2. `tracking_event_media`
   - `id`, `event_id`, `local_file_uri`, `mime_type`, `size_bytes`, `upload_status`, `remote_media_id`
3. `advisory_inbox`
   - `id`, `trip_id`, `session_id`, `source`, `category`, `severity`, `title`, `body`, `lat`, `lng`, `place_id`, `score`, `status`, `created_at`, `expires_at`
4. `place_bind_overrides`
   - `id`, `trip_id`, `event_id`, `from_place_id`, `to_place_id`, `reason`, `updated_at`

### 4.3 Backend Tables
Existing:
1. `trip_tracking_sessions`
2. `trip_location_points`
3. `trip_moments`
4. `trip_checkin_candidates`
5. existing idempotency and notification tables

New:
1. `trip_tracking_events`
2. `trip_tracking_event_media`
3. `external_signal_runs`
4. `external_signals_raw`
5. `external_signals_normalized`
6. `trip_advisories`
7. `advisory_deliveries` (in-app/push dedupe and audit)
8. `place_resolution_links` (provider place id -> canonical place id)

## 5. Data Lifecycle (Capture to Editor)

### 5.1 Live Capture
1. User action creates a `tracking_event` row immediately.
2. Optional media gets local URI attachment.
3. Place resolver attempts auto-binding.
4. Event is rendered in live strip from local stream.

### 5.1.1 Entity Resolver Specification
Resolver input:
1. `trip_id`, `session_id`, `event_type`, `lat/lng`, `captured_at`, optional text/media metadata.

Resolver steps (deterministic order):
1. Exact match to existing trip place within `50m`.
2. Match against previous resolved anchors for same trip within `80m`.
3. Reverse geocode fallback within `100m`.
4. Nearby POI lookup within `150m`.
5. Fallback status `on_route_unresolved`.

Confidence score:
1. `score = distance_score + source_quality + temporal_consistency + user_override_bonus`
2. `auto_bind` only if `score >= 0.75`.
3. `review_required` if `0.45 <= score < 0.75`.
4. `unresolved` if `score < 0.45`.

Resolver outputs:
1. `resolved_place_id` nullable.
2. `bind_confidence` (0.0-1.0).
3. `resolver_version` for replay/debug.
4. `resolver_reason_code` for explainability in editor.

### 5.2 Sync
1. Sync worker claims pending tasks by priority and dependency.
2. Tasks upload session/events/batches/media.
3. Idempotency keys are mandatory on mutating endpoints.
4. Failures:
   - transport: retry with backoff
   - `404 trip not found`: identity recovery flow
   - validation: mark blocked + actionable reason

### 5.3 Compilation
1. Compiler builds projection incrementally:
   - points -> route segments
   - events -> moments/timeline entries
   - place bindings -> grouped sections
2. Projection update events are emitted for in-app refresh.
3. Editor reads projection and raw entities for correction paths.

## 6. API Design (New and Modified Endpoints)

### 6.1 Keep Existing Live Tracking Endpoints
1. `POST /trips/{trip_id}/tracking/start`
2. `POST /trips/{trip_id}/tracking/pause`
3. `POST /trips/{trip_id}/tracking/resume`
4. `POST /trips/{trip_id}/tracking/stop`
5. `POST /trips/{trip_id}/tracking/points:batch`
6. existing moment/candidate endpoints

### 6.2 New Runtime Endpoints
1. `POST /trips/{trip_id}/tracking/events:batch`
   - payload: `events[]` with event type and metadata
   - returns: accepted IDs + rejected reasons
2. `POST /trips/{trip_id}/tracking/media:batch`
   - payload: media metadata + upload references
   - returns: upload mapping and status
3. `GET /trips/{trip_id}/tracking/runtime`
   - returns: active session, current marker, last N events, advisory summary
4. `GET /trips/{trip_id}/tracking/advisories`
   - query: cursor, severity, category
5. `POST /trips/{trip_id}/tracking/advisories/{id}/actions`
   - actions: `ack`, `dismiss`, `save_to_timeline`

### 6.3 New Editor Projection Endpoints
1. `GET /trips/{trip_id}/compiled/projection`
   - returns normalized editor-ready graph
2. `POST /trips/{trip_id}/compiled/rebind`
   - rebind event/moment/media to a place
3. `POST /trips/{trip_id}/compiled/reorder`
   - timeline/order updates

### 6.4 Internal Ingestion Endpoints (worker-only)
1. `POST /internal/signals/runs`
2. `POST /internal/signals/normalize`
3. `POST /internal/advisories/score`

### 6.5 Endpoint Contracts
1. Mutating routes require `X-Idempotency-Key`.
2. All capture payloads carry `client_created_at`, `client_event_id`.
3. Versioned response envelopes include `contract_version`.
4. Clear intent fields (for patch semantics) remain additive and backward-compatible.

## 7. External Signals Integration (Google/Reddit/Tripadvisor + In-App)

### 7.1 Ingestion Pipeline
1. Source connector fetches raw items into `external_signals_raw`.
2. Normalizer extracts:
   - title/text/rating/date/source-url
   - place hints (name, coordinates when available)
   - language and quality score
3. Canonicalizer maps to place graph:
   - coordinate proximity
   - name + city fuzzy matching
   - map provider reconciliation
4. Scorer computes advisory relevance per trip/session.
5. Delivery planner emits in-app and optional push notifications.

### 7.2 Unified Advisory Object
1. `advisory_id`, `trip_id`, `source`, `category`, `severity`, `confidence`
2. `title`, `summary`, `evidence_snippets`, `place_id`, `lat/lng`, `window_start`, `window_end`
3. `dedupe_key` for cross-source duplicates

### 7.3 Dedupe Strategy
1. Cross-source hash on `(canonical_place_id, normalized_fact, time_bucket)`.
2. Replace lower-confidence advisory with higher-confidence equivalent.
3. Enforce per-trip rate limit windows.

## 8. Flutter Architecture and File-Level Plan

### 8.1 New Flutter Modules
1. `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
2. `flutter/lib/features/live_capture/presentation/providers/live_capture_provider.dart`
3. `flutter/lib/features/live_capture/presentation/widgets/live_capture_hud.dart`
4. `flutter/lib/features/live_capture/presentation/widgets/live_capture_action_dock.dart`
5. `flutter/lib/features/live_capture/presentation/widgets/live_advisory_strip.dart`
6. `flutter/lib/features/live_capture/data/live_capture_repository.dart`
7. `flutter/lib/core/storage/tables/tracking_events_table.dart`
8. `flutter/lib/core/storage/daos/tracking_event_dao.dart`
9. `flutter/lib/core/storage/tables/advisory_inbox_table.dart`
10. `flutter/lib/core/storage/daos/advisory_inbox_dao.dart`

### 8.2 Flutter Modules to Modify
1. `flutter/lib/features/create/presentation/screens/editor_screen.dart`
   - remove live runtime controls; consume compiled data only
2. `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
   - runtime data gateway used by new live screen
3. `flutter/lib/core/sync/tracking_sync_worker.dart`
   - add event/media sync lanes and identity recovery gating
4. `flutter/lib/core/network/live_tracking_api.dart`
   - add event batch, runtime, advisories endpoints
5. `flutter/lib/features/create/presentation/providers/editor_sync_status_provider.dart`
   - include advisory and event sync states
6. `flutter/lib/core/notifications/push_token_lifecycle_provider.dart`
   - keep auth generation guard, add advisory channel settings

### 8.3 Flutter Runtime Behavior
1. Foreground loop captures location/events and writes local DB.
2. UI listens to local streams, not direct network responses.
3. Sync worker runs independently and reconciles remote state.
4. Provider exposes single `LiveCaptureViewState` object for rendering.

### 8.4 Flutter UI Composition Standard
Decision:
1. Use modular widget architecture, not one giant screen file.

Pattern:
1. Screen file orchestrates providers, navigation, and high-level layout.
2. Feature widgets render isolated UI parts (control strip, action dock, overlay, inbox, moment list).
3. State mutations live in repositories/controllers/providers, not in leaf widgets.

Target limits:
1. Screen files: target <= 350 logical lines.
2. Reusable widgets: target <= 220 logical lines.
3. Keep animation behavior encapsulated in dedicated components/mixins.

### 8.5 UI Implementation Guardrails (Live Capture)
1. Do not import old editor strip widgets into `features/live_capture`.
2. Build new `features/live_capture/presentation/widgets/*` components for:
   - top runtime bar
   - action dock
   - bottom control panel
   - advisory strip/inbox
   - transient feedback layer
3. Keep old widgets only for temporary editor fallback paths until decoupling milestone completes.

## 9. Notification Architecture

### 9.1 In-App Notifications
1. Surface location-aware advisories in live HUD.
2. Store all advisories in `advisory_inbox`.
3. Support actions: dismiss, save, convert to moment/warning.

### 9.2 Push Notifications
1. Trigger only high-confidence/high-severity advisories.
2. Apply dedupe window and quiet hours.
3. Send with deep link:
   - live capture context when tracking active
   - editor context when session ended
4. Delivery audit stored in `advisory_deliveries`.

### 9.3 Push Token Lifecycle
1. Register token on auth session bootstrap.
2. Invalidate token on logout/auth generation mismatch.
3. Retry registration with exponential backoff.

## 10. Animation Architecture (Three Types)

### 10.1 Animation Type A: Map-Native Geospatial Animation
Used for:
1. Current location marker interpolation.
2. Live route draw and segment extension.
3. Place pin settle and pulse radius.

Implementation:
1. Driven by map SDK layer/source updates.
2. Keep high-frequency updates on map thread path.
3. Avoid widget rebuild coupling.

### 10.2 Animation Type B: Flutter Overlay Motion
Used for:
1. Quick action feedback chips.
2. Advisory cards/snack banners.
3. Session control state transitions (start/pause/resume/stop).

Implementation:
1. AnimatedPositioned/AnimatedOpacity/ImplicitlyAnimatedWidgets.
2. 120-220 ms transitions for state changes.
3. Spring for bottom sheets and inbox cards.

### 10.3 Animation Type C: Lottie/Event Burst
Used for:
1. Photo capture confirmation burst.
2. Warning created alert pulse.
3. Milestone/achievement style moments.

Implementation:
1. Short-lived visual bursts only (not continuous loops).
2. Triggered by domain events from provider state.
3. Degrade gracefully on low-performance devices.

### 10.3.1 Animation Design Tokens (Required)
1. Create `flutter/lib/core/theme/animation_tokens.dart`.
2. Define:
   - durations (`fast=120ms`, `normal=180ms`, `slow=260ms`)
   - easing curves (`standard`, `decelerate`, `emphasized`)
   - spring specs (`mass`, `stiffness`, `damping`) for sheets/cards
   - map transition constants (`marker_lerp_ms`, `path_segment_ms`)
3. All animation code must import tokens; avoid hardcoded per-widget timings.
4. Add golden/timing smoke tests to prevent accidental token drift.

### 10.4 Event-to-Animation Matrix
1. GPS point accepted: Type A only.
2. Route segment extended: Type A only.
3. Photo captured: Type B + Type C.
4. Note saved: Type B.
5. Warning added: Type A + Type C.
6. Advisory arrives: Type B (card) and optional Type C for critical only.
7. Sync success: subtle Type B.
8. Sync blocked/error: static high-contrast state (no celebratory animation).

## 11. Scalability and Performance Plan

### 11.1 Capacity Baseline
Assumption example:
1. 20k active trackers/day.
2. Avg 2h tracking/user/day.
3. 5s sample interval.
Result:
1. ~28.8M points/day.
2. with batch size 25 -> ~1.15M batch writes/day.

### 11.2 Scale Design
1. Partition writes by `trip_id`/`session_id`.
2. Use async workers with row-lock claims (`FOR UPDATE SKIP LOCKED`) for compile and advisory jobs.
3. Compress/segment route storage for editor rendering.
4. Keep hot raw data retention window, then downsample.
5. Queue backpressure controls and retry budgets.

### 11.3 Performance Budgets
1. Points ingest API p95 < 500 ms.
2. Runtime overlay refresh p95 < 300 ms from local write.
3. Projection refresh p95 < 2 s after sync ack.
4. Live screen map frame budget > 45 FPS at p95.

## 12. Reliability, Recovery, and Observability

### 12.1 Recovery Paths
1. Identity mismatch (`404 trip not found`) -> clear mapping + requeue trip sync + requeue dependent tracking tasks.
2. Media upload failure -> retry lane; keep local pointer and user-visible pending state.
3. Advisory source outage -> degrade silently; capture/editor core unaffected.

### 12.2 Monitoring
1. Metrics:
   - task states (`pending/running/failed/blocked`)
   - ingest latency, compile latency
   - advisory precision feedback
2. Logs:
   - structured with `trip_id`, `session_id`, `task_id`, `request_id`
3. Tracing:
   - capture -> sync -> compile -> notify path

### 12.3 Alert Gates
1. Blocked-task rate > threshold.
2. Advisory spam rate spike.
3. Push delivery failure spike.
4. Projection drift (raw count vs compiled count mismatch).

## 13. Security and Privacy

1. Explicit tracking consent and revocation controls.
2. Fine-grained retention and deletion for location history.
3. Data minimization for push payloads.
4. Source attribution for external advisories.
5. Signed internal worker endpoints.

## 14. Rollout Plan and Milestones

### Milestone A: Boundary Split
1. Ship dedicated live capture screen.
2. Remove runtime controls from editor.
3. Keep existing live tracking behavior stable.
4. DB change policy: no new tables yet; only compatibility columns if required.

### Milestone B: Event Pipeline
1. Add tracking events + media tables.
2. Add event batch sync endpoint and worker path.
3. Build projection join to editor.
4. Migrate in additive mode only (nullable + backfill + constraint tighten later).

### Milestone C: Advisory MVP
1. Ingest one external source end-to-end.
2. Normalize and map to canonical place.
3. Deliver in-app advisory cards only.
4. Add external signal worker chain (ingest + normalize + score).

### Milestone D: Push + Multi-Source
1. Add push planner and dedupe window.
2. Add additional source connectors.
3. Tune scoring and thresholds.
4. Add advisory delivery worker for push fanout and retry handling.

### Milestone E: Hardening and Scale
1. Soak tests with replayed trips.
2. Battery/FPS tuning.
3. SLO gate review and staged rollout.
4. Finalize indexes/constraints after data shape is validated in staging.

### 14.1 Incremental Table Rollout Policy
1. Each milestone ships only the minimal new tables required for that milestone.
2. Every schema expansion follows `expand -> backfill -> validate -> enforce`.
3. No cross-domain mega-migration in one release.
4. Add per-migration replay tests on both clean DB and upgraded DB paths.

## 15. Definition of Done

1. User can run live capture end-to-end without losing moments/media/events.
2. Editor always reflects compiled live capture artifacts with manual override support.
3. Identity sync failures auto-recover without permanent block.
4. Advisory delivery is useful, deduplicated, and rate-limited.
5. Core SLOs (capture latency, sync reliability, crash-free, FPS) are met in staging and pilot rollout.
6. Live capture UI passes quality gate defined in `flutter/docs/live-capture-screen-implementation-spec.md` Section 16.6.

## 16. Execution Tracker (Persistent Memory for Agents)

This section is the canonical execution board for cross-team progress.  
Every implementation agent must update this section in the same commit as code changes.

### 16.1 Usage Rules
1. Prefer one phase as actively owned; baseline prefill may show partial carry-over in later phases from already-merged work.
2. Use status markers:
   - `[ ]` not started
   - `[-]` in progress
   - `[x]` completed
3. A task is `completed` only when code + tests + docs are all updated.
4. Each completed item must include evidence:
   - commit hash
   - test command(s)
   - result summary
5. If scope changes, update this doc and `flutter/docs/live-capture-screen-implementation-spec.md` together.

### 16.2 Cross-Reference Map (Must Stay in Sync)

| Area | Root Doc Section | Flutter Spec Section | Existing Program Memory |
|---|---|---|---|
| Live/Editor boundary | Section 1, 2, 14 | Section 2, 3, 4 | `docs/live-tracking/live-tracking-execution-plan.md` |
| Data model + identity | Section 4, 5 | Section 7, 8 | `flutter/docs/live-tracking-flutter-execution-plan.md` |
| APIs + workers | Section 6, 7 | Section 11, 15 | `docs/live-tracking/live-tracking-execution-plan.md` |
| Notification + push | Section 9 | Section 10 | `flutter/docs/live-tracking-flutter-execution-plan.md` |
| Animation contract | Section 10 | Section 9 | `flutter/docs/design_system.md` |
| Validation + rollout | Section 11-15 | Section 13-15 | both execution plans above |

### 16.3 Master Phase Plan (Tick and Move)

Baseline prefill snapshot: 2026-03-29 (derived from current merged backend + Flutter live-tracking stack).

#### Phase P0: Contract Alignment
Status: `[-]`
1. [x] Reconfirm route/state/identity contracts against:
   - `docs/live-tracking/live-tracking-execution-plan.md`
   - `flutter/docs/live-tracking-flutter-execution-plan.md`
2. [ ] Freeze endpoint additions for Milestone A/B only (no advisory multi-source yet).
3. [ ] Add task owners and PR boundaries per phase.
4. [x] Log decision record in both docs.

#### Phase P1: Live/Editor Boundary Split
Status: `[-]`
1. [x] Add dedicated live capture route and screen shell.
2. [x] Move runtime controls out of editor.
3. [ ] Keep editor map overlays functional for compiled artifacts only.
4. [x] Add focused widget tests for screen states.
5. [x] Update docs status in both execution docs.

#### Phase P2: Event and Session Pipeline
Status: `[-]`
1. [ ] Add local tables/DAOs for tracking events and advisory inbox.
2. [ ] Add sync lanes for event/media tasks.
3. [ ] Add backend `events:batch` ingest API contract.
4. [x] Add identity recovery for stale remote trip mapping.
5. [ ] Validate offline-first replay on upgraded DB path.

#### Phase P3: Resolver + Compiler
Status: `[-]`
1. [ ] Implement resolver thresholds and reason codes.
2. [ ] Add compiler worker projection updates for editor.
3. [x] Add manual override persistence path for place rebinding.
4. [ ] Add projection consistency checks (raw vs compiled counts).
5. [x] Add regression tests for "captured item disappears" class bugs.

#### Phase P4: Advisory MVP (Single Source)
Status: `[ ]`
1. [ ] Implement ingestion worker chain for one source.
2. [ ] Normalize and canonicalize signal payloads into unified advisory schema.
3. [ ] Show in-app advisory strip + inbox actions.
4. [ ] Add advisory dedupe and cooldown policy.
5. [ ] Validate no capture path regression when source pipeline is down.

#### Phase P5: Push + Multi-Source
Status: `[-]`
1. [ ] Add advisory delivery worker for push fanout.
2. [x] Add auth-generation-safe token lifecycle guards.
3. [ ] Add deep-link routing for active vs ended sessions.
4. [ ] Add source adapters incrementally (one source per PR).
5. [ ] Add push delivery observability dashboards and alerts.

#### Phase P6: Animation and UX Hardening
Status: `[ ]`
1. [ ] Introduce `animation_tokens.dart` and remove hardcoded timings.
2. [ ] Apply event-to-animation mapping matrix in live capture surface.
3. [ ] Validate low-end device FPS and motion fallback behavior.
4. [ ] Add golden/timing smoke tests for critical transitions.
5. [ ] Sign off UX safety rules.

#### Phase P7: Scale, Reliability, Rollout
Status: `[ ]`
1. [ ] Run soak tests (long sessions + flaky network + replay).
2. [ ] Pass SLO gates from Section 11/15.
3. [ ] Stage rollout 5% -> 20% -> 50% -> 100%.
4. [ ] Keep rollback hooks and feature flags ready.
5. [ ] Publish final go-live report with evidence.

### 16.4 Evidence Log Template

Use this block for each completed phase:

```md
### Phase PX Evidence (YYYY-MM-DD)
- Owner:
- PR/Commit:
- Commands run:
  - `...`
- Results:
  - tests passed:
  - tests failed:
- Risks left:
- Docs updated:
  - `docs/live-tracking-unified-system-architecture-plan.md`
  - `flutter/docs/live-capture-screen-implementation-spec.md`
```

### 16.5 Baseline Evidence (Prefill Snapshot)

1. Identity recovery for stale trip mapping:
   - `flutter/lib/core/sync/tracking_sync_worker.dart`
   - `flutter/test/core/sync/tracking_sync_worker_test.dart` (`recovers stale trip identity on 404 trip-not-found`)
2. Manual override + non-destructive moment sync behavior:
   - `flutter/lib/features/create/data/live_tracking_moment_repository.dart`
   - `flutter/test/features/create/live_tracking_moment_repository_test.dart`
   - `flutter/test/core/sync/tracking_sync_worker_test.dart` (stale fallback and trip-id safety assertions)
3. Auth-generation-safe push token lifecycle guard:
   - `flutter/lib/core/notifications/push_token_lifecycle_bootstrap.dart`

### Phase P1 Evidence (2026-03-29, Partial)

1. Dedicated live capture route and shell landed with widget-state coverage.
2. Evidence files:
   - `flutter/lib/core/navigation/routes.dart`
   - `flutter/lib/core/navigation/app_router.dart`
   - `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
   - `flutter/test/features/live_capture/live_capture_screen_test.dart`
3. Validation commands and outcomes are logged in:
   - `flutter/docs/live-capture-screen-implementation-spec.md` (`Slice A Evidence`)
4. Remaining P1 scope:
   - remove runtime strips from editor
   - ensure editor overlay remains projection-only
5. Additional P1 progress:
   - runtime controls now wired to live-tracking coordinator on the new live screen
   - blocked sync callout + retry trigger wired to tracking sync worker
   - action dock now triggers local quick-capture writes (photo/note/warn/media/tag) on the new live screen
   - recent-captures overlay strip now renders from local moments stream in live capture
   - editor header stack now surfaces a dedicated "Live Capture" entry card and hides legacy live runtime strips by default
