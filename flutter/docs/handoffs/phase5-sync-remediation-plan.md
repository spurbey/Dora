# Phase 5 Sync Remediation Plan (Scalable, App-Wide Extension)

Date: 2026-02-23  
Owner: Codex  
Branch: `Media-Integration`  
Status: In Progress (`M1` advanced to v11 with schema-repair safeguards and `M2/M3` route+delete sync coverage implemented; runtime validation pending)

---

## 1. Problem Definition

Current media upload fails because media depends on backend place identity, and place creation depends on backend trip identity.

Dependency chain:

1. Media worker needs backend `trip_place_id` to call upload API.
2. `ensureRemotePlaceId(localPlaceId)` tries to create/find remote place.
3. Remote place create requires backend trip ID.
4. If local trip has no valid backend identity, place create fails (`404 Trip not found`), or fallback trip create fails (`403` free-tier limit).

Result:

- Upload appears stuck or fails even when file pipeline is healthy.
- Offline-first intent is partially implemented, but entity sync prerequisites are missing as a durable system.

---

## 1.1 Why This Is App-Wide (Not Only Media)

Current behavior proves this is a system-level gap:

1. Create domain writes (`trip/place/route`) are local-first, but there is no generic persisted entity sync queue.
2. `core/network/offline_queue.dart` is still a stub, so there is no unified offline replay layer.
3. Media has a real worker and therefore hits backend identity prerequisites first.
4. Trips/feed/profile modules show partial sync behavior, not a single app-wide sync contract.

Conclusion:

- Media failures are a symptom.
- Root cause is missing app-wide entity sync orchestration.

---

## 2. Target Architecture (Scalable)

Implement a durable **Entity Sync Layer** for Trip/Place/Route identities and writes, then let Media queue depend on it.

### Core Principles

1. Persist-first: all user writes local first.
2. Deterministic identity: local IDs map to backend IDs (`serverTripId`, `serverPlaceId`).
3. Dependency-aware queueing: media waits on upstream entity sync readiness.
4. Explicit blocked states: no hidden retry floods.
5. Single orchestrator ownership per queue type.

### Queue Separation

1. `EntitySyncQueue`: Trip/Place/Route create/update/delete sync tasks.
2. `MediaUploadQueue`: Upload tasks only; requires resolved backend place ID.

### App-Wide Feature Matrix (Current -> Target)

1. Create (Trip/Place/Route)
   - Current: local-first writes, identity resolution happens ad hoc.
   - Target: all writes enqueue entity tasks; deterministic server identity mapping.
2. Media
   - Current: robust worker but depends on implicit upstream entity readiness.
   - Target: explicit dependency on entity queue state (`ready|blocked|failed`).
3. Trips (My Trips)
   - Current: mixed local cache + immediate API calls for some actions.
   - Target: mutations routed through entity sync primitives.
4. Feed
   - Current: mostly read-side caching, limited mutation TODOs.
   - Target: keep read cache strategy; mutations adopt sync primitives when enabled.
5. Profile/Settings
   - Current: cache clear and account actions are independent.
   - Target: consume global sync health so destructive actions can warn correctly.

---

## 3. Planned Milestones

## M0: Contract Freeze Refresh

### Scope

- Freeze dependency contract for entity sync and media queue interaction.

### Files

- `flutter/docs/phases/Phase-5-PRD.md`
- `flutter/docs/phases/Phase-5-Execution-Checklist.md`
- `flutter/docs/handoffs/phase5-milestones-handoff.md`

### Exit Gate

- Written contract accepted:
  - media requires backend place ID
  - place requires backend trip ID
  - no blind trip recreation on stale identity failure

---

## M1: Schema v8 -> v9 for Entity Sync Queue

### Scope

- Add persistent sync task table.
- Keep existing trip/place identity columns.

### Files

- `flutter/lib/core/storage/tables/sync_tasks_table.dart` (new)
- `flutter/lib/core/storage/daos/sync_task_dao.dart` (new)
- `flutter/lib/core/storage/drift_database.dart` (schema bump + migration)

### `sync_tasks` table (proposed)

- `id` text PK (uuid)
- `entityType` text (`trip|place|route`)
- `entityId` text (local ID)
- `operation` text (`create|update|delete`)
- `status` text (`queued|in_progress|blocked|failed|completed|canceled`)
- `retryCount` int default 0
- `nextAttemptAt` datetime nullable
- `dependsOnEntityType` text nullable
- `dependsOnEntityId` text nullable
- `errorCode` text nullable
- `errorMessage` text nullable
- `workerSessionId` text nullable
- `createdAt` datetime
- `updatedAt` datetime

### Migration/backfill

1. New installs: create table.
2. Upgrades from v8:
   - create table
   - enqueue `trip:create` for trips missing `serverTripId`
   - enqueue `place:create` for places missing `serverPlaceId`
   - routes optional in first pass (can start with trip/place only)

### Exit Gate

- DB opens on fresh + migrated installs.
- Backfilled tasks exist for unsynced entities.

---

## M2: Entity Sync Repository/Worker (Trip + Place first)

### Scope

- Introduce deterministic sync worker for trip/place identity and create/update.

### Files

- `flutter/lib/core/sync/entity_sync_worker.dart` (new)
- `flutter/lib/core/sync/entity_sync_bootstrap.dart` (new)
- `flutter/lib/features/create/data/trip_repository.dart` (enqueue entity tasks)
- `flutter/lib/features/create/data/place_repository.dart` (enqueue entity tasks, remove hidden fallback loops)
- `flutter/lib/features/create/presentation/providers/editor_provider.dart` (no direct remote assumptions)
- `flutter/lib/features/create/presentation/providers/media_upload_provider.dart` (watch entity readiness)
- `flutter/lib/app.dart` (bootstrap watcher)

### Behavior

1. Trip create/update local write enqueues trip sync task.
2. Place create/update local write enqueues place sync task.
3. Place sync task is `blocked` until trip has valid `serverTripId`.
4. Worker processes queue with lock semantics.
5. Stale remote identity handling:
   - if cached `serverTripId` returns `404`, clear mapping and mark trip task `failed` with explicit code.
   - do not auto-create new trip when policy disallows (quota/permission context).

### Error classification

- Retryable: network timeout, 429, 5xx
- Non-retryable: 400/401/403 validation/auth/quota
- Stale identity: dedicated code (`stale_remote_identity`)

### Exit Gate

- Local-only trip/place eventually receive server IDs when backend allows.
- No retry flood on non-retryable errors.
- Clear blocked/failure reason persisted.

---

## M3: Integrate Media Queue with Entity Readiness

### Scope

- Media worker must consume entity readiness states instead of forcing implicit remote creation.

### Files

- `flutter/lib/core/media/upload_queue_worker.dart`
- `flutter/lib/features/create/data/media_repository.dart`
- `flutter/lib/core/storage/daos/media_dao.dart`

### Behavior

1. Before upload, media worker resolves place readiness through entity state.
2. If place not ready:
   - mark media row `blocked` (new status) or `failed` with code `place_not_synced`.
   - avoid rapid retry loops.
3. If trip quota/permission blocks entity sync:
   - media rows remain actionable with explicit message.
4. Keep existing cancel/remove race protections.

### Exit Gate

- Media no longer fails ambiguously on unsynced trip/place.
- Blocked items display actionable reason and recover when dependency resolves.

---

## M4: UX Transparency for Sync Dependency States

### Scope

- Surface sync/blocked states in editor + media screen.

### Files

- `flutter/lib/features/create/presentation/screens/media_upload_screen.dart`
- `flutter/lib/features/create/presentation/widgets/upload_queue_item.dart`
- `flutter/lib/features/create/presentation/widgets/place_detail_form.dart`
- `flutter/lib/features/create/presentation/screens/editor_screen.dart`

### UX rules

1. Show status labels:
   - `Queued`
   - `Uploading 45%`
   - `Blocked: trip not synced`
   - `Blocked: trip limit reached`
   - `Failed: retry`
2. Retry button behavior:
   - retries only if state is retryable.
3. Remove button always available for terminal failures.

### Exit Gate

- User can understand exactly why upload is waiting/failing.
- No hidden failure state.

---

## M5: Hardening and Test Expansion

### Scope

- Add deterministic tests for dependency chain and failure semantics.

### Tests to add/update

- `flutter/test/features/create/media_upload_integration_test.dart` (extend)
- `flutter/test/features/create/entity_sync_worker_test.dart` (new)
- `flutter/test/features/create/sync_task_dao_test.dart` (new)
- `flutter/test/features/create/media_dependency_state_test.dart` (new)

### Required scenarios

1. Local trip + local place + offline media enqueue -> upload deferred.
2. Reconnect + trip sync success + place sync success -> media auto uploads.
3. Stale `serverTripId` -> clear mapping + explicit failure state (no blind recreate loop).
4. `403` quota on trip create -> terminal blocked state.
5. Cancel/remove during in-flight upload -> no bridge corruption.
6. Editor autosave must not overwrite `serverPlaceId`/`photoUrls`.

### Exit Gate

- All dependency and failure-path tests pass.
- Manual regression on Phase 4 editor/route flows passes.

---

## 4. Implementation Order (Strict)

1. M1 schema + DAO
2. M2 entity sync worker + repository enqueue rules
3. M3 media dependency integration
4. M4 UX state surfacing
5. M5 hardening + regression pack

No out-of-order implementation.

---

## 5. Memory and Recovery Protocol (Critical)

Use this section as canonical handoff memory if a session crashes or branch gets messy.

### Required Per-Milestone Checkpoint Block

For each completed step, append:

1. `Milestone ID`
2. `Commit SHA(s)`
3. `Files changed`
4. `Schema version impact`
5. `Behavioral delta`
6. `Validation evidence` (test/manual log)
7. `Known risk left open`
8. `Next exact command-free action`

### Incident Recovery Runbook

If "something goes south", do this in order:

1. Re-open this doc and `phase5-milestones-handoff.md`.
2. Verify last good schema version and migration boundary.
3. Verify last good queue state machine contract (entity + media).
4. Reproduce with one backend-backed trip and one local-only trip.
5. Classify failure before patching:
   - identity (`trip/place` mapping)
   - queue semantics (claim/retry/cancel)
   - backend contract/auth/quota
   - UI state mismatch only
6. Patch only one class of failure at a time and record checkpoint block.

### Guardrails

1. Never re-introduce blind trip recreation after stale backend identity.
2. Never let editor save clobber system-managed fields (`serverPlaceId`, `photoUrls`, future sync metadata).
3. Never retry-loop non-retryable failures.
4. Never couple media upload worker to direct trip creation logic.

---

## 6. Non-Goals for this pass

1. Full conflict-resolution engine across all entities.
2. Video upload pipeline.
3. Public feed/gallery redesign.

---

## 7. Rollback Strategy

If issues arise:

1. Keep local media queue rows intact.
2. Disable upload execution while preserving queued data.
3. Keep editor functionality unaffected.
4. Re-enable worker after patching failed gate.

---

## 8. Definition of Done

Phase is considered stable when:

1. Uninstall-loss risk is understood and communicated: local unsynced data is local-only by design.
2. Entity sync for trip/place is persistent and dependency-aware.
3. Media queue no longer depends on implicit fallback behavior.
4. Blocked/error states are explicit and actionable.
5. No retry flood loops.
6. Regression suite for editor/media dependency flows is green.
7. App-wide feature modules reference one sync contract (not ad hoc sync logic per feature).

---

## 9. Progress Update 2026-02-25

1. Completed in code (core sync/media):
   - `schemaVersion 10` migration (`sync_tasks.remote_entity_id`, `routes.server_route_id`).
   - `schemaVersion 11` migration repair:
     - idempotent `sync_tasks` and `routes` column reconciliation (`remote_entity_id`, `server_route_id`)
     - safety repair for stale/partial on-device schemas before queue workers run
   - Trip/place/route repositories enqueue create/update/delete sync tasks.
   - Entity worker processes trip/place/route create/update/delete paths.
   - Media worker checks trip/place dependency state and marks media rows `blocked` when upstream entity sync is blocked.
   - Queue UI surfaces blocked states/count and retryability.
   - Route sync now rejects insufficient geometry instead of sending fabricated coordinates.

2. Completed in code (dependency hygiene):
   - Removed app-layer direct `built_collection` imports in create/feed/trips repositories.
   - Added explicit `built_value` app dependency because route payloads require `JsonObject`.
   - Refreshed generated files so new schema/model fields are represented in generated Drift/Freezed/provider outputs.

3. Completed in code (stability patch in this session):
   - Sync task claiming now enforces dependency readiness:
     - downstream tasks are runnable only when dependency task is either absent or `completed`.
     - dependency check is applied in both `getRunnableTasks` and the claim `UPDATE` guard.
   - Editor viewport persistence no longer enqueues trip sync tasks on every pan/zoom event.
     - viewport updates are persisted locally only (backend `TripUpdate` has no viewport fields).
   - Media dependency readiness now defers uploads when dependency sync tasks are still `queued`/`in_progress`/`failed`:
     - upload is marked retryable-failed with backoff instead of attempting place resolution too early.
     - terminal `blocked` dependency states remain explicit and non-retryable.
   - Route sync now enforces unresolved place dependency readiness before remote route creation:
     - if place has no `serverPlaceId` and place sync task is `queued|in_progress|failed`, route sync is deferred (retryable).
     - if place sync task is `blocked`, route sync is blocked with explicit cause.
     - if place already has `serverPlaceId`, route sync proceeds even when a place task exists (prevents false deferral).

4. Tests added/updated:
   - `test/core/storage/sync_task_dao_test.dart`
     - verifies downstream tasks wait for dependency completion.
     - verifies blocked dependency prevents downstream claiming.
   - `test/features/create/trip_repository_viewport_test.dart`
     - verifies `setEditorViewport` persists local viewport without creating sync tasks.
   - `test/features/create/media_upload_integration_test.dart`
     - verifies media upload is deferred (retryable) when trip dependency task is not yet ready.
     - verifies backend-bound place uploads still proceed (no false deferral).
   - `test/features/create/route_repository_dependency_test.dart`
     - verifies route sync defers when place dependency is queued and unresolved.
     - verifies route sync blocks when place dependency is blocked.
     - verifies route sync uses existing `serverPlaceId` directly (no false blocking).
   - `test/core/sync/entity_sync_worker_test.dart`
     - verifies retryable identity failures are persisted as `failed` with backoff.
     - verifies non-retryable identity failures are persisted as `blocked`.
     - verifies success and unsupported entity handling paths.

5. Still pending:
   - manual runtime validation matrix on device/CI for full hardening paths.
   - execution of uninstall/reinstall data-retention expectations against current backend sync policy.
   - optional optimization: dependency-aware prioritization policy (trip-first ordering) beyond current readiness gate.

## 10. Remaining Plan (Ordered)

1. Validation status (latest user run):
   - `flutter analyze`: no errors reported.
    - targeted tests are green in local run, including:
      - `test/core/storage/sync_task_dao_test.dart`
      - `test/core/sync/entity_sync_worker_test.dart`
      - `test/features/create/trip_repository_viewport_test.dart`
      - `test/features/create/route_repository_dependency_test.dart`
      - `test/features/create/media_upload_integration_test.dart` (`5/5`)
      - `test/features/create/phase4b_business_logic_test.dart`

2. Hardening matrix (manual):
   - backend-backed trip: upload success path.
   - local-only trip: explicit blocked reason, no retry flood.
   - dependency chain: trip queued -> place queued -> media queued, then ordered release.
   - blocked dependency recovery: dependency fixed then manual retry succeeds.
   - route dependency chain: queued/blocked place dependency prevents remote route create until ready.

3. Documentation + closure:
   - keep M4 closed and maintain evidence links in handoff.
   - `phase5-rc-report.md` now contains automated evidence; add manual matrix outcomes.
   - move M6 from `In Progress` to `Done` after hardening matrix evidence is attached.

## 11. Read-Path Remediation (2026-02-26)

1. Trips module backend parity work started:
   - removed mock API wiring in `trips_provider`.
   - switched to `OpenApiTripsApi` with tokenized backend calls.
2. Trips deletion integrity improved:
   - backend delete is now enforced for synced rows.
   - local rollback restores trip row on remote delete failure.
3. Feed module moved from mock-first to backend-first list retrieval:
   - `FeedApi.getTrips(...)` introduced using `listTripsApiV1TripsGet`.
   - `FeedRepository.getPublicTrips(...)` now hydrates cache from backend response.
4. Profile module moved to backend-first profile data:
   - wired `usersApiProvider` (`UsersApi`) in `core/network/api_providers.dart`.
   - `ProfileRepository` now uses `getCurrentUserCompleteProfileApiV1UsersMeProfileGet(...)`.
   - local profile/stats fallback retained for offline/degraded backend behavior.

Next validation gate:
1. Confirm backend-created trips are visible in Trips screen after login.
2. Confirm Trips-screen delete triggers backend delete and persists after app restart.
3. Confirm feed list behavior under backend-only data for current user.
4. Confirm profile/settings read backend user+stats payload for authenticated users.
