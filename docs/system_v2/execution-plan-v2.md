# System V2 Execution Plan

Status: Draft for execution lock
Version: v2.1
Last updated: 2026-04-12
Owner: Tech lead + Flutter lead + Backend lead + QA lead

## 1. Purpose

This document defines the implementation order for System V2.

It is the operational plan that turns V2 architecture/spec docs into code delivery with controlled risk.

It includes:

1. Phase-by-phase commit plan.
2. Kill-list for legacy modules.
3. Test/soak/rollout gates.
4. Rollback and contingency rules.

## 2. Inputs (Authoritative Specs)

1. [Master Blueprint](./subsystem_specs/master-blueprint.md)
2. [Local Journal and Resolver Spec](./subsystem_specs/local-journal-and-resolver-spec.md)
3. [Session Commit Worker Spec](./subsystem_specs/session-commit-worker-spec.md)
4. [Local Timeline Compiler Spec](./subsystem_specs/local-timeline-compiler-spec.md)
5. [Backend Ingest and Projection Spec](./subsystem_specs/backend-ingest-and-projection-spec.md)
6. [Trip Publish Spec](./subsystem_specs/trip-publish-spec.md)
7. [Live and Editor UI Contract Spec](./subsystem_specs/live-editor-ui-contract-spec.md)
8. [Command Lane Spec](./subsystem_specs/command-lane-spec.md)
9. [Contract Freeze V2](./contract-freeze-v2.md)

## 3. Non-Negotiable Delivery Rules

1. No big-bang cutover.
2. V2 is feature-flagged and trip/session scoped.
3. No deletion of V1 paths before V2 soak gates pass.
4. Manual decision lock invariants must be true before any public rollout.
5. No unbounded polling/sync loops in V2 paths.

## 4. Feature Flags

Define these flags before implementation starts:

1. `enable_live_system_v2`
2. `enable_v2_local_journal`
3. `enable_v2_local_compiler`
4. `enable_v2_session_commit_worker`
5. `enable_v2_trip_publish_worker`
6. `enable_v2_backend_ingest`
7. `enable_v2_live_editor_ui_contract`

Flag policy:

1. Flags can be enabled per user/trip/session cohort.
2. V1 and V2 must not both write to same logical entities for a single active session.

## 5. Phased Commit Plan

Each phase can contain multiple commits. Phase gate must pass before next phase.

### 5.1 Commit-Level Implementation Plan (Concrete)

This is the executable, file-level plan that replaces ambiguity with exact steps.
Resolver provider is locked to **ORS direct** (per Contract Freeze).
V2 code namespace is locked to **`flutter/lib/features/live_tracking/v2/`** (new subtree).

Commit naming below is illustrative; actual messages can vary.

#### Commit 0 — Phase 0 Scaffolding (DONE)

Status: already committed in `1e3aa07`.

Includes:
1. Feature flags for V2.
2. `LiveSystemV2Gate` + baseline observability markers.
3. Contract-lock doc updates.

No behavior changes.

---

#### Commit 1 — Phase 1: V2 Local Schema + Migration

Goal: add V2 journal tables without touching V1 tables.

Files (new):
1. `flutter/lib/core/storage/tables/v2/session_journal_table.dart`
2. `flutter/lib/core/storage/tables/v2/session_activity_window_table.dart`
3. `flutter/lib/core/storage/tables/v2/route_point_journal_table.dart`
4. `flutter/lib/core/storage/tables/v2/event_journal_table.dart`
5. `flutter/lib/core/storage/tables/v2/media_journal_table.dart`
6. `flutter/lib/core/storage/tables/v2/resolver_candidate_journal_table.dart`
7. `flutter/lib/core/storage/tables/v2/resolver_attempt_journal_table.dart`

Files (edit):
1. `flutter/lib/core/storage/drift_database.dart`
   - bump `schemaVersion` (current 17 -> 18)
   - import and register v2 tables
   - `onUpgrade`: `if (from < 18) createTable(...)` for each v2 table

No UI wiring yet.

---

#### Commit 2 — Phase 1: V2 DAOs + Repositories

Goal: local access layer for v2 tables, still not wired to UI.

Files (new):
1. `flutter/lib/core/storage/daos/v2/session_journal_dao.dart`
2. `flutter/lib/core/storage/daos/v2/event_journal_dao.dart`
3. `flutter/lib/core/storage/daos/v2/media_journal_dao.dart`
4. `flutter/lib/core/storage/daos/v2/route_point_journal_dao.dart`
5. `flutter/lib/core/storage/daos/v2/resolver_candidate_journal_dao.dart`
6. `flutter/lib/core/storage/daos/v2/resolver_attempt_journal_dao.dart`
7. `flutter/lib/features/live_tracking/v2/data/v2_session_repository.dart`
8. `flutter/lib/features/live_tracking/v2/data/v2_event_repository.dart`
9. `flutter/lib/features/live_tracking/v2/data/v2_media_repository.dart`
10. `flutter/lib/features/live_tracking/v2/data/v2_route_point_repository.dart`
11. `flutter/lib/features/live_tracking/v2/data/v2_resolver_repository.dart`

Files (edit):
1. `flutter/lib/core/storage/daos/daos.dart` (or equivalent export barrel)
2. `flutter/lib/features/live_tracking/v2/v2_providers.dart` (new provider barrel)

---

#### Commit 3 — Phase 2: Capture Lane Switch (Live)

Goal: when `enable_live_system_v2` is on, live capture writes to v2 only.

Files (edit):
1. `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
   - choose v2 providers when gate enabled
2. `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
   - route capture coordinator to v2 for gated sessions
3. `flutter/lib/features/live_tracking/v2/capture/v2_capture_coordinator.dart` (new)

Files (new):
1. `flutter/lib/features/live_tracking/v2/capture/v2_capture_coordinator.dart`
2. `flutter/lib/features/live_tracking/v2/capture/v2_capture_types.dart`

Behavior:
1. route points -> `route_point_journal`
2. events/media -> `event_journal` / `media_journal`
3. no V1 sync task enqueues for v2 sessions

---

#### Commit 4 — Phase 3: Resolver + Unresolved Inbox

Goal: deterministic resolver with manual lock + shared inbox.

Files (new):
1. `flutter/lib/features/live_tracking/v2/resolver/ors_resolver_client.dart`
2. `flutter/lib/features/live_tracking/v2/resolver/v2_resolver_service.dart`
3. `flutter/lib/features/live_tracking/v2/inbox/unresolved_inbox_provider.dart`
4. `flutter/lib/features/live_tracking/v2/inbox/unresolved_inbox_widget.dart`

Files (edit):
1. `flutter/lib/core/location/app_geocoding_service.dart` (only if adapting to ORS)
2. `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`
3. `flutter/lib/features/create/presentation/screens/editor_screen.dart`

Behavior:
1. immediate local resolve pass, network fallback async
2. manual lock enforced on all reconcile paths
3. inbox renders top 2–3 candidates
4. recovery trigger is explicit only: app resume, live open, editor open (no polling loop)
5. live shows informational review CTA; editor owns review actions

---

#### Commit 5 — Phase 4: Local Timeline Compiler

Goal: replace compiled projection for v2 with local compiler.

Files (new):
1. `flutter/lib/features/live_tracking/v2/compiler/local_timeline_compiler.dart`
2. `flutter/lib/features/live_tracking/v2/compiler/local_projection_tables.dart`
3. `flutter/lib/features/live_tracking/v2/compiler/local_projection_provider.dart`

Files (edit):
1. `flutter/lib/features/create/presentation/screens/editor_screen.dart`
2. `flutter/lib/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart`

Behavior:
1. editor + live use local projection if v2 gate enabled
2. no server dependency for timeline visibility

---

#### Commit 6 — Phase 5: Session Commit Worker (Client)

Goal: finalize session via bounded commit job.

Files (new):
1. `flutter/lib/features/live_tracking/v2/commit/session_commit_job_table.dart`
2. `flutter/lib/features/live_tracking/v2/commit/session_commit_worker.dart`
3. `flutter/lib/features/live_tracking/v2/commit/session_commit_repository.dart`

Files (edit):
1. `flutter/lib/features/live_tracking/v2/capture/v2_capture_coordinator.dart`
   - enqueue commit job on stop
2. `flutter/lib/features/create/presentation/providers/live_tracking_runtime_provider.dart`
   - show commit status in UI when v2

Behavior:
1. phases: prepare → media_upload → payload_upload → finalize_ack → done
2. retry bounded (15/60/180s, max 3)

---

#### Commit 7 — Phase 6: Backend Ingest + Projection (Server)

Goal: accept v2 finalize payloads and materialize server projection.

Backend files (new or edit, exact paths TBD under `backend/`):
1. `backend/app/api/v2/trip_finalize.py` (new endpoints)
2. `backend/app/models/v2/*` (raw journal tables + idempotency manifest)
3. `backend/app/services/v2_projection_compiler.py`
4. migrations for v2 tables

Behavior:
1. idempotent finalize API set
2. raw journal storage
3. server projection read endpoints for cross-device

---

#### Commit 8 — Phase 7: Trip Publish Worker + Endpoint Integration

Goal: explicit publish/save from editor.

Files (new):
1. `flutter/lib/features/live_tracking/v2/publish/trip_publish_worker.dart`
2. `flutter/lib/features/live_tracking/v2/publish/trip_publish_job_table.dart`

Files (edit):
1. `flutter/lib/features/create/presentation/screens/editor_screen.dart`
   - publish CTA wired to v2 publish worker when gate enabled

Backend:
1. `backend/app/api/v2/trip_publish.py`
2. `backend/app/services/v2_publish_service.py`

---

### Phase 0: Contract Lock and Scaffolding

Goal:

1. Freeze V2 contracts and set up guardrails.

Changes:

1. Finalize doc set and open decisions.
2. Add feature flag plumbing.
3. Add baseline observability events for V2 paths.

Exit criteria:

1. All V2 contract fields and enums locked.
2. Flag system supports safe per-trip/session rollouts.

---

### Phase 1: Local Journal Foundation

Goal:

1. Introduce V2 local schema and base repositories.

Changes:

1. Add local V2 tables and indexes.
2. Add repository layer for session/event/media/route and resolver candidates/attempts.
3. Add migrations with backward-compatible rollout.

Exit criteria:

1. V2 tables created successfully on upgrade paths.
2. Existing app runs with flags off unchanged.

---

### Phase 2: Local Capture Lane Switch

Goal:

1. Route live capture writes to V2 local journal only.

Changes:

1. Live capture actions (note/warn/tag/photo/media) write to `event_journal`/`media_journal`.
2. Route points write to `route_point_journal`.
3. Disable V1 per-entity sync enqueue for V2 sessions.
4. Command bridge payload lock (until backend `/api/v2/.../sessions:start|stop` exists):
- `start`: `client_session_id`, `started_at`, optional `timezone`, `device_context`
- `stop`: `client_event_id`, `session_id`, `stopped_at`, optional `reason`

Exit criteria:

1. Capture is instant and local with network off.
2. No V1 live entity sync tasks created for V2 sessions.

---

### Phase 3: Resolver and Shared Unresolved Inbox

Goal:

1. Implement deterministic local resolver and shared Live/Editor review queue.

Changes:

1. Resolver worker and candidate normalization.
2. State transitions and manual lock enforcement.
3. Shared unresolved inbox provider and action handlers.
   - Use a single batch candidate lookup per trip to avoid N+1 local DB queries.
4. Live/editor unresolved widgets/actions wired to same reducer.
5. Retry contract lock: exactly one recovery attempt after provider error; sources = resumed/live_open/editor_open.

Exit criteria:

1. Manual decisions are never overwritten by resolver.
2. Live/editor unresolved queues show same data for same trip.

---

### Phase 4: Local Timeline Compiler Cutover

Goal:

1. Render timeline/map overlays from local projection tables.

Changes:

1. Add local projection tables.
2. Implement incremental compiler and invalidation cursor.
3. Switch live recent strip/editor storyline readers to local projection.

Exit criteria:

1. No server dependency for timeline visibility during live/edit.
2. Compiler deterministic and performant under target loads.
3. Post-lock hotfixes applied:
   - null dirty-window safety guard (no `dirtyFrom` null dereference),
   - compile trigger narrowed to session-sealed transitions for this phase.
4. Deferred guardrail logged for next phase:
   - route association cost growth (`events x points`) is tracked as a performance hardening item, not a Phase 4 correctness blocker.

---

### Phase 5: Session Commit Worker (Client)

Goal:

1. Replace live continuous sync with bounded session finalize jobs.

Changes:

1. Add `session_commit_job` state machine and media/chunk tracking tables.
2. Implement commit phase executor and resume logic.
3. Add commit status UI chips and retry CTA.

Exit criteria:

1. One commit job per sealed session.
2. Retry behavior bounded and user-actionable.

---

### Phase 6: Backend Ingest and Server Projection

Goal:

1. Accept V2 raw canonical payloads and materialize server projection.

Changes:

1. Add finalize start/media chunk/commit endpoints.
2. Add idempotency manifest table and conflict handling.
3. Add raw storage tables and projection compiler.
4. Add timeline/route read endpoints for cross-device view.

Exit criteria:

1. Finalize replay-safe with idempotency.
2. New device can fetch server projection for committed trips.

---

### Phase 7: Trip Publish Worker and Endpoint Integration

Goal:

1. Enable explicit publish/save from editor with idempotent behavior.

Changes:

1. Add `trip_publish_job` client state machine.
2. Implement publish payload assembly from canonical local journal + editor metadata.
3. Integrate publish endpoint and response handling.

Exit criteria:

1. Publish succeeds without affecting local timeline responsiveness.
2. Publish retry works with clear UX.

---

### Phase 8: Legacy Path Deactivation

Goal:

1. Turn off V1 live data sync/projection coupling for V2 cohorts.

Changes:

1. Disable legacy entity sync lanes for V2 trips.
2. Disable legacy projection refresh churn triggers for V2 trips.
3. Keep V1 paths isolated for non-migrated cohorts only.

Exit criteria:

1. No V1 flood pattern appears in V2 telemetry.
2. V2 cohorts stable under soak.

---

### Phase 9: Legacy Deletion and Hardening

Goal:

1. Remove obsolete V1 modules after full rollout confidence.

Changes:

1. Delete dead code paths and unused workers.
2. Finalize docs/runbooks and support playbooks.
3. Lock long-term SLO dashboards and alarms.

Exit criteria:

1. V2 full rollout complete.
2. V1 live-sync modules removed without regression.

## 6. Legacy Kill-List (After Gates)

This is a retirement target list, not immediate delete list.

Primary retire candidates for V2 scope:

1. Legacy live entity sync orchestration:
- `flutter/lib/core/sync/tracking_sync_worker.dart`
- `flutter/lib/core/sync/entity_sync_worker.dart`
- `flutter/lib/core/media/upload_queue_worker.dart` (for live lane usage; keep if reused for commit lane only)

2. Legacy continuous point batching to server:
- V1 logic in `flutter/lib/features/create/data/live_tracking_runtime_repository.dart` related to periodic remote point flush

3. Legacy projection refresh churn logic for editor:
- `flutter/lib/features/create/presentation/providers/compiled_projection_provider.dart` refresh-by-sync-task patterns for V2 trips

4. Any resolver reconcile path that can overwrite manual decisions.

Deletion conditions:

1. V2 full rollout stable for agreed soak window.
2. No active cohorts depend on V1 path.
3. Backfill/migration scripts complete.

## 7. Test and Quality Gates

### 7.1 Unit Gates

Must pass before each phase promotion:

1. Schema migration/readback tests.
2. Resolver state transition + lock tests.
3. Compiler deterministic output tests.
4. Commit worker idempotent retry tests.
5. Publish payload hash/idempotency tests.

### 7.2 Integration Gates

1. Offline capture -> stop -> finalize -> committed.
2. Ambiguous candidate -> manual decision -> lock persists.
3. Editor local timeline works before any server commit.
4. Cross-device fetch shows server projection after finalize/publish.

### 7.3 Regression Gates

1. No old “sync blocked flood” behavior in V2 cohorts.
2. No disappearing entries after app restart.
3. No duplicate projection entries across retries.

## 8. Soak Plan

### 8.1 Soak scenarios

1. 30-minute live session with mixed captures and network drops.
2. Stop session on weak network; verify bounded retries and eventual commit.
3. Reinstall/login on second device; verify projection visibility.
4. Long media-heavy session finalize under chunked upload.

### 8.2 Soak pass criteria

1. Active session data-plane server calls stay near zero.
2. Exactly one active finalize job per sealed session.
3. No infinite retry loops.
4. Timeline remains visible locally through failures.

## 9. Rollout Strategy

1. Internal dogfood with staff accounts.
2. 5% staged beta cohort.
3. 25% broader cohort with continuous monitoring.
4. 100% rollout after success metrics and incident-free soak window.

Rollback policy:

1. Disable V2 flags for affected cohort.
2. Preserve local journal data.
3. Keep V1 untouched for fallback cohorts until final deletion phase.

## 10. SLO and Monitoring Targets

1. Session finalize success rate >= 99% within retry window.
2. Median finalize latency within agreed threshold (to be locked).
3. Publish success rate >= 99% within retry window.
4. Projection read p95 latency target (backend to lock).
5. Zero known manual-lock overwrite incidents.

## 11. Risks and Mitigations

1. Risk: provider/API confidence inconsistency.
- Mitigation: provider adapter normalization tests and fallback behavior.

2. Risk: large finalize payloads fail.
- Mitigation: chunking + resumable phase tracking + idempotency.

3. Risk: key/token exposure in client-side resolver.
- Mitigation: scoped tokens and provider key policy.

4. Risk: dual-path complexity during migration.
- Mitigation: strict feature-flag scoping and no dual writes per session.

5. Risk: hidden dependency on V1 modules.
- Mitigation: explicit kill-list audits and staged deactivation.

## 12. Locked Decision Log

Locked:

1. Command lane split:
  1. server-bound: `start`, `stop`
  2. local-only: `pause`, `resume`
2. Resolver provider contract:
  1. ORS direct
  2. threshold rules from resolver spec (0.60, margin 0.05, tie epsilon 0.02, distance <= 100m)
3. Directions provider contract:
  1. Mapbox Directions API direct from app
3. Retry constants:
  1. max auto attempts = 3
  2. delays = 15s, 60s, 180s
4. Publish retries use snapshot-locked payload per job.
5. Commit and publish state enums are strict minimal sets (no cancelled state).
6. App kill/no-stop behavior:
  1. No auto-finalize.
  2. Session remains recoverable locally until user explicitly stops.
7. Rollback ownership and incident routing:
  1. Rollback trigger authority: tech lead.
  2. Mobile and backend responders execute rollback/support actions under tech-lead coordination.
  3. Incident channel: `#live-system-v2-incidents`.

Remaining to track separately (if not already locked by product):

1. Final rollout and rollback staffing roster by week.

## 13. Definition of Done (Program Level)

V2 program is done only when:

1. All subsystem acceptance criteria pass.
2. Soak tests pass under agreed load and network conditions.
3. V1 live sync/projection paths are retired for production cohorts.
4. Runbooks, dashboards, and alerting are active.
5. Post-rollout incident window closes without Sev-1/Sev-2 regressions.

