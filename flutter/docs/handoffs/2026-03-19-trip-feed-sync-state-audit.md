# Trip Feed + Sync State Audit (2026-03-19)

## Context
- Production app is published.
- Reported symptoms:
1. Major gap in trip feed behavior.
2. Offline/online sync flow feels unstable.
3. Trips/edits appear to change unexpectedly or complete after delay.
4. Concern that some trips become public unexpectedly.

## Scope Reviewed
- Flutter docs:
1. `flutter/docs/handoffs/phase5-sync-remediation-plan.md`
2. `flutter/docs/handoffs/phase5-rc-report.md`
3. `flutter/docs/handoffs/2026-03-17-editor-city-place-sync-audit.md`
4. `flutter/docs/rules.md`
- Backend docs:
1. `docs/auth-and-user-provisioning-reliability-runbook.md`
2. `docs/architecture.md`
- Flutter code (sync/feed/trips/editor/media paths).
- Backend code (`/api/v1/trips`, auth dependency path, trip service).
- Git commit history and diffs of relevant files.

## Executive Summary
The app has meaningful sync improvements compared to early Phase 5, but there are still structural gaps that explain the production symptoms:

1. Entity-level sync completion is not consistently reflected back to domain rows (`trip/place/route/user_trips`), so UI can remain in `pending/failed` semantics even after queue progress.
2. Queue upsert behavior while a task is `in_progress` can drop intent changes (operation mutation without guaranteed follow-up requeue), producing stale or delayed server convergence.
3. Feed behavior is version-sensitive across backend/mobile rollout:
   - backend `public_only` support must exist before mobile feed expects it.
   - mixed versions can look like wrong feed visibility behavior.
4. Media and entity workers use different `PlaceRepository` provider instances; in-flight dedup for remote place identity is in-memory and instance-local, so cross-worker dedup can fail.
5. Editor header text ("All changes saved") is local-write state, not end-to-end sync state; this can mislead users during delayed queue completion.

## Confirmed Findings

### P0: Sync completion is not propagated to entity rows
Current write paths mark entities as `pending`, but queue completion finalizes only `sync_tasks` rows.

Evidence:
1. `flutter/lib/features/create/data/trip_repository.dart`
2. `flutter/lib/features/create/data/place_repository.dart`
3. `flutter/lib/features/create/data/route_repository.dart`
4. `flutter/lib/core/sync/entity_sync_worker.dart`
5. `flutter/lib/features/trips/data/trips_repository.dart`

Impact:
1. Perceived "sync stuck" or inconsistent state.
2. Local UI can continue showing pending/failed semantics after backend success.
3. Subsequent merge logic in Trips can prefer unsynced local rows longer than intended.

### P0: Potential lost intent when task is in progress
`SyncTaskDao.upsertQueuedTask(...)` preserves lock semantics in `in_progress`, but changed operation can be written without forced next run scheduling.

Evidence:
1. `flutter/lib/core/storage/daos/sync_task_dao.dart`
2. `flutter/test/core/storage/sync_task_dao_test.dart` (lock-preservation cases)

Impact:
1. High-churn edits can converge to stale remote state.
2. Users perceive delayed/random updates after background cycles.

### P1: Cross-worker dedup gap for place identity
`ensureRemotePlaceId` dedup map is per `PlaceRepository` instance. Media worker and entity worker use separate providers/instances.

Evidence:
1. `flutter/lib/features/create/presentation/providers/media_upload_provider.dart`
2. `flutter/lib/features/create/presentation/providers/entity_sync_provider.dart`
3. `flutter/lib/features/create/data/place_repository.dart`

Impact:
1. Concurrent identity creation attempts can race.
2. Additional backend load and non-deterministic timing.

### P1: Feed/public behavior depends on synchronized backend/mobile rollout
Feed moved from mock to backend path; backend gained `public_only`; mobile then started sending it.

Evidence:
1. `backend/app/api/v1/trips.py`
2. `backend/app/services/trip_service.py`
3. `flutter/lib/features/feed/data/feed_api.dart`
4. `flutter/lib/features/feed/data/feed_repository.dart`

Impact:
1. If backend is older than `public_only` support while mobile expects it, feed results can look incorrect.
2. Users may interpret owner-trip visibility in feed as accidental public exposure.

### P1: Feed/trips mapping still flattens backend richness
Trip cards/trips mapping defaults to weak metadata in several paths.

Evidence:
1. `flutter/lib/features/feed/data/feed_repository.dart` (`placeCount` fallback logic)
2. `flutter/lib/features/trips/data/trips_api.dart` (`placeCount: 0`, status derivation)

Impact:
1. Feed/trips quality mismatch.
2. Confusing perception of backend sync completeness.

### P2: UX mismatch between local save and true sync
Header text is based on local `saving` flag, not queue + backend ack state.

Evidence:
1. `flutter/lib/features/create/presentation/widgets/editor_header.dart`
2. `flutter/lib/features/create/presentation/providers/editor_provider.dart`
3. `flutter/lib/core/sync/entity_sync_bootstrap.dart`
4. `flutter/lib/core/media/media_queue_bootstrap.dart`

Impact:
1. Users see "All changes saved" before remote completion.
2. Delayed background completion appears random.

## Commit Timeline (Key)

### Sync and editor behavior
1. `2e6f655` (2026-02-09): Phase-4 editor baseline introduced autosave + bulk save behavior that later caused queue noise.
2. `e6f1761` (2026-02-25): Entity sync foundation (`sync_tasks`, worker/bootstrap) introduced.
3. `b16d3d4` (2026-03-17): Autosave requeue flood fix and failed-backoff preservation.

### Place/media retry and identity handling
1. `17e1f01` (2026-03-16): Place API retry flood hardening and storage misconfig classification.
2. `c8bda24` (2026-03-16): Prevented blind inline trip recreation on stale mapping retry.

### Feed/trips runtime shift
1. `ae0dd30` (2026-02-27): Feed/Trips switched to backend runtime paths.
2. `a150a4a` (2026-03-07): Trips backend-authoritative merge behavior introduced.
3. `b6c7b4d` (2026-03-18): Backend `/trips` gained `public_only`.
4. `e88b4f0` (2026-03-18): Flutter OpenAPI regenerated and `publicOnly` query wired in feed client.

### Backend auth reliability
1. `a316f01` (2026-03-17): race-safe user bootstrap in auth dependency (`users_pkey` incident class).
2. `03ac94d` (2026-03-18): Google sign-in dependency update retained race-safe provisioning loop model.

## What Was Already Fixed (Important)
1. Autosave bulk requeue flood was addressed in `b16d3d4`.
2. Stale trip mapping no longer triggers blind inline trip recreation in place sync (`c8bda24`).
3. Backend/public feed filtering path was added (`b6c7b4d`) and mobile client updated (`e88b4f0`).
4. Auth bootstrap race condition was hardened (`a316f01`, then refined in `03ac94d`).

## What Is Still Open (Next Iteration Priority)
1. Add durable "dirty while in progress" handling in `sync_tasks` so intent changes are never dropped.
2. Propagate successful entity sync completion back into entity/domain rows and `user_trips`.
3. Unify `PlaceRepository` instance usage (or move in-flight dedup to shared storage/lock abstraction).
4. Replace editor "saved" messaging with queue-aware status surface:
   - local saved
   - syncing
   - sync blocked/failed
   - synced
5. Add explicit compatibility guard/diagnostic when feed `public_only` contract is not supported by backend.
6. Improve feed/trips mapping so place counts and status semantics come from backend where available.

## Validation Notes From This Audit Session
1. Static code + git-history analysis completed.
2. Backend tests were not runnable in this shell due missing local dependency (`sqlalchemy`) in current environment.
3. `deploy_logs.txt` in workspace was empty at audit time, so historical incident references rely on docs and prior captured evidence.

## Guardrails for Follow-Up
1. Do not reintroduce bulk autosave requeue behavior.
2. Do not perform inline trip recreation from place/media identity retry path.
3. Keep non-retryable server misconfiguration errors terminal and explicit.
4. Keep feed visibility behavior strictly backend-contract-driven (`public_only`) with explicit fallback handling.
5. Treat UI "saved" as separate from "synced" everywhere.

## Related Documents
1. `flutter/docs/handoffs/phase5-sync-remediation-plan.md`
2. `flutter/docs/handoffs/phase5-rc-report.md`
3. `flutter/docs/handoffs/2026-03-17-editor-city-place-sync-audit.md`
4. `docs/auth-and-user-provisioning-reliability-runbook.md`
