# Trip Sync Stabilization - Execution Tracker (2026-03-20)

Date: 2026-03-20  
Owner: Codex + Backend + Flutter + QA  
Status: Active (M0-M6 Completed, M7 Not Started)  
Related Docs:
1. `flutter/docs/handoffs/2026-03-19-trip-feed-sync-state-audit.md`
2. `docs/live-tracking/live-tracking-prd.md`
3. `flutter/docs/handoffs/2026-03-20-trip-sync-m0-contract-freeze.md`

## 1. Purpose

Track the full execution of trip-sync stabilization work with explicit completion gates, test evidence, and rollout controls.

This plan is designed so the sync foundation scales to:
1. Live tracking (`tracking sessions`, `points`, `check-in decisions`, `moments`)
2. Future social/feed features (public visibility and projection correctness)

## 2. Update Rules

1. Mark work items from `[ ]` to `[x]` only after implementation and tests pass.
2. Add one line to the progress log for every milestone transition.
3. Do not start next milestone until current milestone gate is fully satisfied.
4. If a gate fails, reopen the milestone and log the failure with root cause.

## 3. Non-Negotiable Invariants

1. No intent loss: edits during `in_progress` must always produce a later sync attempt.
2. No false synced state: UI/domain rows cannot show synced unless backend ack is persisted.
3. Manual-over-auto precedence: manual edits cannot be silently overwritten.
4. Idempotent writes: duplicate retries cannot create duplicate remote entities.
5. Visibility safety: public feed behavior must be backend-contract-driven.
6. Tombstone safety: deleted auto-generated entities cannot reappear immediately.

## 4. Milestone Board

## M0: Baseline + Guardrails

Status: Completed  
Target: 1 day

Work Items:
1. [x] Freeze sync contract and state transitions used by Flutter + backend.
2. [x] Define kill switches and rollback conditions for sync pipeline.
3. [x] Capture baseline metrics before changes (sync success, stale in-progress count, queue lag).
4. [x] Lock acceptance scenarios for regression pack.

Completion Gate:
1. [x] Written contract approved and linked in this doc.
2. [x] Baseline metrics snapshot recorded.
3. [x] Regression scenarios listed and agreed.

## M1: Durable Queue Semantics (No Intent Loss)

Status: Completed  
Target: 2 days

Work Items:
1. [x] Add durable "dirty while in progress" behavior in local queue model.
2. [x] Ensure upsert path never mutates away pending intent.
3. [x] Add stale-lock recovery for abandoned `in_progress` tasks.
4. [x] Preserve retry taxonomy (`retryable`, `non_retryable`, `stale_identity`).

Completion Gate:
1. [x] High-churn edit sequence always converges to latest intent.
2. [x] Crash/restart during `in_progress` recovers and requeues correctly.
3. [x] Queue unit tests pass for all transition edges.

## M2: Ack Propagation to Domain Rows

Status: Completed  
Target: 2 days

Work Items:
1. [x] Persist backend sync success back into entity rows (`trip`, `place`, `route`, `user_trips` projections as needed).
2. [x] Ensure queue completion and entity update are transactionally consistent.
3. [x] Persist sync receipt fields (`server revision`, `synced_at`, `last_error` clear).
4. [x] Prevent "synced" UI state unless receipt write succeeds.

Completion Gate:
1. [x] No entity remains pending after confirmed backend success.
2. [x] No false-success UI states in delayed or partial-write scenarios.
3. [x] Integration tests validate queue + entity atomicity.

## M3: Cross-Worker Identity and Dedup Hardening

Status: Completed  
Target: 1 day

Work Items:
1. [x] Remove multi-instance dedup race for place identity resolution.
2. [x] Use shared lock/dedup strategy across entity and media workers.
3. [x] Verify parallel workers cannot create duplicate remote place identities.

Completion Gate:
1. [x] Parallel upload + edit stress test shows single remote identity creation.
2. [x] No race-induced duplicate create calls under test harness.

## M4: Feed/Public Contract Safety

Status: Completed  
Target: 1 day

Work Items:
1. [x] Add compatibility guard for backend `public_only` support.
2. [x] Ensure fallback behavior is explicit and logged when contract mismatch occurs.
3. [x] Align feed/trips mapping to backend-authoritative metadata where available.

Completion Gate:
1. [x] Mixed-version mobile/backend does not produce ambiguous visibility behavior.
2. [x] Contract mismatch is diagnosable via logs/telemetry.

## M5: UX Sync State Clarity

Status: Completed  
Target: 1 day

Work Items:
1. [x] Replace local-only "saved" semantics with explicit states:
   - local saved
   - syncing
   - synced
   - sync failed/blocked
2. [x] Ensure editor/trips/feed surfaces use consistent status semantics.
3. [x] Add recovery actions where failures are user-actionable.

Completion Gate:
1. [x] User never sees "All changes saved" before backend receipt.
2. [x] Status transitions are deterministic under offline/online churn.

## M6: Live-Tracking Compatibility Layer

Status: Completed  
Target: 2 days

Work Items:
1. [x] Finalize shared sync primitives to support upcoming entities:
   - tracking sessions
   - tracking points (batch lane)
   - check-in decisions
   - moments
2. [x] Define manual-lock + provenance + tombstone rules now for auto-generated entities.
3. [x] Validate that tracking batch lane cannot starve trip/place/route user edits.

Completion Gate:
1. [x] Sync primitives accepted as reusable for live-tracking Phase 1.
2. [x] Provenance and tombstone behavior validated in test cases.

## M7: Test, Canary, Rollout

Status: Not Started  
Target: 2 days

Work Items:
1. [ ] Run full regression pack:
   - offline create/edit/delete
   - rapid edit churn
   - app kill/restart mid-sync
   - media + entity concurrent sync
   - feed visibility scenarios
2. [ ] Run canary with staged rollout and thresholds.
3. [ ] Monitor and close rollback window after stability period.

Completion Gate:
1. [ ] Release criteria met with no P0/P1 regressions.
2. [ ] Canary metrics remain within thresholds through stability window.
3. [ ] Final release note and postmortem checklist completed.

## 5. Regression Pack (Must Pass Before M7 Complete)

1. Offline create trip -> add place -> add route -> reconnect -> all synced with correct remote IDs.
2. Edit same place repeatedly while queue is busy -> latest edit is final remote state.
3. App termination during `in_progress` -> no lost updates after restart.
4. Concurrent media upload + place edit -> no duplicate place identity creation.
5. Feed request with/without `public_only` support -> deterministic behavior and explicit logs.
6. Delete auto-generated entity -> no immediate reappearance without user action.

## 6. Rollback Triggers

1. Sync success rate drops below target threshold.
2. Stale `in_progress` tasks exceed threshold.
3. Feed visibility mismatch incidents are detected.
4. Duplicate remote entity creation incidents increase.

## 7. Progress Log

1. 2026-03-20: Tracker created. Milestones M0-M7 initialized as Not Started.
2. 2026-03-20: M0 started; architecture/rules/design/sync docs reviewed and consolidated.
3. 2026-03-20: Flutter CLI unblock completed (`lockfile` permission issue); recovery runbook applied.
4. 2026-03-20: Baseline tests passed: `sync_task_dao_test.dart`, `entity_sync_worker_test.dart`.
5. 2026-03-20: M0 contract freeze published in `2026-03-20-trip-sync-m0-contract-freeze.md`; M0 marked Completed, M1 set In Progress.
6. 2026-03-20: M1 implemented in queue layer (`pending_requeue` + stale `in_progress` reclaim) and schema bumped to v12.
7. 2026-03-20: Regenerated `.g.dart` via elevated `dart run build_runner build --delete-conflicting-outputs`.
8. 2026-03-20: Sync tests passed after M1 changes: `sync_task_dao_test.dart`, `entity_sync_worker_test.dart`.
9. 2026-03-20: M1 marked Completed, M2 set In Progress.
10. 2026-03-20: Re-ran elevated generation + validation (`dart run build_runner build --delete-conflicting-outputs`; `flutter test test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart`), all green.
11. 2026-03-20: M2 implemented: repositories now return sync receipts, worker applies receipts + completes queue atomically, and pending-requeue paths keep entity status pending to avoid false synced UI.
12. 2026-03-20: M2 validation passed (elevated): `flutter test test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart test/features/create/route_repository_dependency_test.dart --reporter compact`.
13. 2026-03-20: M2 marked Completed, M3 set In Progress.
14. 2026-03-20: M3 implemented shared identity dedup across repository instances and unified media to reuse canonical `placeRepositoryProvider`.
15. 2026-03-20: Added cross-instance dedup regression test (`media_upload_integration_test.dart`) and validated no duplicate place create calls under concurrent ensure requests.
16. 2026-03-20: M3 validation passed (elevated): `flutter test test/features/create/media_upload_integration_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart test/features/create/route_repository_dependency_test.dart --reporter compact`.
17. 2026-03-20: M3 marked Completed, M4 set In Progress.
18. 2026-03-20: M4 guard (part 1/2) implemented in `FeedApi`: retries without `public_only` on explicit compatibility errors and logs fallback path.
19. 2026-03-20: Feed compatibility tests added and passed (elevated): `flutter test test/features/feed/feed_api_test.dart test/features/create/media_upload_integration_test.dart test/core/sync/entity_sync_worker_test.dart --reporter compact`.
20. 2026-03-20: M4 mapping alignment completed: `FeedRepository` and `OpenApiTripsApi` now use backend `place_count` (`TripResponse.placeCount`) where available.
21. 2026-03-20: Added mapping regression tests (`test/features/feed/feed_repository_test.dart`, `test/features/trips/trips_api_test.dart`) and validated with elevated run including sync/media regressions.
22. 2026-03-20: M4 marked Completed, M5 set In Progress.
23. 2026-03-20: M5 implemented sync-aware editor status callout with actionable recovery paths (`Retry now`, blocked media deep-link, blocked entity review) using enriched trip sync snapshot metadata.
24. 2026-03-20: Trips sync semantics unified via shared mapper (`sync_status_ui.dart`) across grid/list badges and My Trips banner (`Saved locally`, `Syncing...`, `Sync failed`, `Sync blocked`, `Synced`).
25. 2026-03-20: M5 validation passed (elevated): `flutter test test/features/create/editor_sync_status_provider_test.dart test/features/trips/sync_status_ui_test.dart test/features/feed/feed_api_test.dart test/features/feed/feed_repository_test.dart test/features/trips/trips_api_test.dart test/features/create/media_upload_integration_test.dart test/core/sync/entity_sync_worker_test.dart --reporter compact`.
26. 2026-03-20: M5 marked Completed; next executable milestone is M6 (Live-Tracking Compatibility Layer).
27. 2026-03-21: M6 started; introduced shared live-tracking sync primitives (SyncEntityTypes, lane mapping, worker support contract) to prevent entity-type drift across upcoming tracking entities.
28. 2026-03-21: DAO claim ordering hardened to prioritize interactive trip/place/route work before `tracking_point_batch`, preventing high-volume batch starvation of user edits.
29. 2026-03-21: M6 validation passed (elevated): `flutter test test/core/sync/live_tracking_sync_primitives_test.dart test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart test/features/create/route_repository_dependency_test.dart test/features/create/media_upload_integration_test.dart --reporter compact`; includes provenance/manual-lock/tombstone policy coverage and DAO lane-priority claim test.
30. 2026-03-21: M6 marked Completed; next executable milestone is M7 (Test, Canary, Rollout).


