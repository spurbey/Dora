# Implementation Order Checklist (V2)

Status: Execution checklist
Last updated: 2026-04-18
Reference: [Execution Plan V2](./execution-plan-v2.md)

## Phase 0: Contract Lock and Scaffolding

- [x] Open decisions resolved or deferred with owner/date.
- [x] App kill/no-stop policy locked (no auto-finalize).
- [x] Rollback owner locked (tech lead).
- [ ] Command lane implemented exactly (`start/stop` server, `pause/resume` local).
- [ ] Retry constants globally fixed (15s/60s/180s, max 3).
- [ ] V2 feature flags created and validated.
- [ ] Baseline V2 telemetry added.

## Phase 1: Local Journal Foundation

- [ ] V2 tables/indexes added via migration.
- [ ] Upgrade test passes on existing DBs.
- [ ] V2 repositories added.
- [ ] Flags-off behavior unchanged.

## Phase 2: Local Capture Lane

- [ ] Live capture writes only to V2 local journal for V2 sessions.
- [ ] Paused sessions stop point capture; manual captures mark paused context.
- [ ] No V1 sync task enqueue for V2 sessions.
- [ ] Offline capture scenario passes.

## Phase 3: Resolver + Shared Inbox

- [ ] Resolver transitions deterministic.
- [ ] Manual-lock short-circuit enforced everywhere.
- [ ] Shared unresolved inbox used by live + editor.
- [ ] Editor actions (`Accept`, `Add place`, `Geo-Tag`) work end-to-end.

## Phase 4: Local Timeline Compiler

- [ ] Projection tables + cursor added.
- [ ] Compiler deterministic with sealed-trigger policy.
- [ ] Live recent strip from local projection.
- [ ] Editor storyline/map from local projection.

## Phase 5: Session Commit Worker (Local Staging)

- [x] `session_commit_job`, media/chunk tables implemented.
- [x] Prepare snapshot path implemented.
- [x] Stop idempotency per seal-version implemented.
- [x] Lease takeover/recovery implemented.
- [x] Network upload/finalize phases disabled for V2 publish lane.
- [x] UI copy reflects local staging only (no false upload success on stop).

## Phase 6: Backend Publish Ingest + Server Projection

- [x] Publish mutating APIs implemented:
  - [x] `publish:start`
  - [x] `publish:media-complete`
  - [x] `publish:payload-chunk`
  - [x] `publish:commit`
- [x] Read APIs implemented:
  - [x] `GET /timeline` (cursor, stable ordering)
  - [x] `GET /route` (bounded segments/points)
- [x] Active publish uniqueness enforced by `status in {started, failed_retryable}`.
- [x] Snapshot frozen at `publish:start` and reused on replay.
- [x] Mandatory `Idempotency-Key` on all mutating V2 endpoints.
- [x] Publish token bound to user+trip+job+schema (`403 token_scope_mismatch` on mismatch).
- [x] Chunk contract enforced (`128 KiB`, total `64 MiB`, strict index bounds).
- [x] Server recomputes chunk hash and verifies media existence/ownership.
- [x] Stop reconciliation completed before manifest `committed`.
- [x] Replay from `raw_ingest_completed` skips raw reinsert.
- [x] Projection timeout guard and non-O(SxP) point grouping implemented.

## Phase 7: Trip Publish Worker Integration

- [ ] `trip_publish_job` worker wired to Phase 6 endpoints.
- [ ] Publish status chips + retry CTA wired.
- [ ] Publish failure preserves local timeline/editing state.

## Phase 8: Legacy Path Deactivation

- [x] V1 entity sync lanes disabled for V2 cohorts.
- [ ] V1 projection refresh churn disabled for V2 cohorts.
- [ ] V2 telemetry confirms no flood behavior.

## Phase 9: Legacy Deletion + Hardening

**Status: Partially complete (2026-04-17)**

### Completed (commits `7eb383d`, `fcf1022`, `fba465a`, `e20d805`)

Backend deletions:
- [x] `backend/app/api/v1/live_tracking.py` — V1 tracking endpoints removed
- [x] `backend/app/services/live_tracking_service.py` — V1 service removed
- [x] `backend/app/workers/live_tracking_worker.py` — V1 worker removed
- [x] `backend/app/schemas/live_tracking.py` — V1 schemas removed
- [x] V1 models removed: `trip_tracking_session.py`, `trip_tracking_notification.py`, `trip_tracking_notification_event.py`, `trip_moment.py`, `trip_checkin_candidate.py`, `trip_auto_entity_tombstone.py`
- [x] V1 backend tests removed: `test_live_tracking_endpoints.py`, `test_live_tracking_worker.py`

Flutter deletions:
- [x] V1 Drift tables removed: `tracking_sessions`, `tracking_point_batches`, `tracking_events`, `tracking_event_media`, `tracking_moments`, `tracking_candidates`
- [x] V1 DAOs removed: `sync_task_dao.dart`, `tracking_session_dao.dart`, `tracking_point_batch_dao.dart`, `tracking_event_dao.dart`, `tracking_event_media_dao.dart`, `tracking_moment_dao.dart`, `tracking_candidate_dao.dart`
- [x] V1 sync workers removed: `tracking_sync_worker.dart`, `entity_sync_worker.dart`, `tracking_sync_bootstrap.dart`, `entity_sync_bootstrap.dart`
- [x] V1 providers removed: `live_tracking_runtime_provider.dart`, `tracking_sync_provider.dart`, `entity_sync_provider.dart`, `live_tracking_candidate_provider.dart`, `live_tracking_moment_provider.dart`
- [x] V1 repositories removed: `live_tracking_runtime_repository.dart`, `live_tracking_candidate_repository.dart`, `live_tracking_moment_repository.dart`, `live_tracking_capture_coordinator.dart`, `live_tracking_event_repository.dart`, `live_tracking_event_resolver.dart`
- [x] V1 widgets removed: `live_tracking_map_overlay.dart`, `live_tracking_candidate_inbox_strip.dart`, `live_tracking_moment_strip.dart`
- [x] V1 tests removed: All `live_tracking_*_test.dart` files in `test/features/create/` and `test/features/live_capture/`
- [x] Drift database regenerated without V1 tables

### Completed (2026-04-17)

1. **`editor_sync_status_provider.dart`** — Rewritten with V2-aware model (session_journal, trip_publish_state queries).

2. **`sync_tasks` table** — Removed from Drift schema, migration drops table in v22, export guards rewritten.

3. **`lib/core/live_tracking/`** — Tracked in commit 9687160.

4. **`live_tracking_api.dart`** — V1 API methods removed (startTracking, pauseTracking, resumeTracking, stopTracking, uploadPointsBatch, uploadEventsBatch, checkin/moment methods).

### Completed (2026-04-18)

1. **OpenAPI source alignment** — `flutter/openapi.json` regenerated from current backend app OpenAPI to avoid stale running-server schema.

2. **Generated client cleanup (`dora_api`)** — stale compiled-projection and legacy V1 tracking generated artifacts removed; serializers/models regenerated.

3. **Flutter compatibility bridge after client cleanup**:
   - `lib/core/network/live_tracking_api.dart` moved legacy notification/media endpoints to raw Dio payloads (no deleted generated V1 DTO dependency).
   - `lib/features/create/data/route_repository.dart` and `lib/features/feed/data/feed_api.dart` updated for current `JsonObject` structure in regenerated client.

4. **Known gap** — push-token lifecycle currently logs `POST /api/v1/notifications/device-tokens/register 404` because backend route is absent; either reintroduce backend notification routes or disable bootstrap on Flutter side.

### NOT YET DONE (deferred or Track B)

5. **V1/V2 gate logic** — `liveSystemV2RolloutGateProvider` still evaluates in editor. Keep for subsystem-specific flags until unified timeline replaces V1.

6. **Backend V1 compiled_projection** — Endpoint at `/api/v1/compiled/projection` still served — Flutter still uses it until Track B (unified timeline).

7. **Backend tests** — `test_advisory_lifecycle_hooks.py` and `test_compiled_projection_endpoints.py` may reference deleted V1 modules.

- [ ] Legacy modules removed after soak/pass gates.
- [ ] Docs/runbooks/alerts finalized.
- [ ] Post-rollout stability window completed.

## Mandatory Gates Before Public Rollout

- [ ] Unit suite pass (resolver/compiler/publish/idempotency/state machine).
- [ ] Integration pass (capture->stop local, publish->cross-device read).
- [ ] Soak pass complete (mixed-network + media-heavy publish).
- [ ] No manual-lock overwrite incidents.
- [ ] No high-frequency backend write flood in V2 cohorts.

## Quick Exit Criteria

- [ ] V2 capture and editor are local-first and resilient offline.
- [ ] Server writes happen only on explicit publish in Phase 6 lane.
- [ ] Published projection is reproducible on second device.
- [ ] Retry model is bounded and user-actionable.
