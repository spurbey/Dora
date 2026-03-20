# Trip Sync M0 Contract Freeze (2026-03-20)

Date: 2026-03-20  
Owner: Codex  
Status: Accepted Baseline (M0)

## 1) Source Documents Reviewed

1. `flutter/docs/architecture.md`
2. `flutter/docs/design_system.md`
3. `flutter/docs/rules.md`
4. `flutter/docs/phases/Phase-5-PRD.md`
5. `flutter/docs/handoffs/phase5-sync-remediation-plan.md`
6. `flutter/docs/handoffs/2026-03-19-trip-feed-sync-state-audit.md`
7. `docs/live-tracking/live-tracking-prd.md`
8. `docs/architecture.md`

## 2) Contract Scope

This freeze applies to trip/place/route entity sync behavior in Flutter and its backend interaction contract.  
It is the baseline required before M1-M7 implementation in `2026-03-20-trip-sync-execution-tracker.md`.

## 3) Contract-First Rules (Mandatory)

1. Backend OpenAPI is source of truth; Flutter consumes generated DTOs only.
2. Generated code is never hand-edited:
   - `flutter/packages/dora_api/**`
   - `*.g.dart`
   - `*.freezed.dart`
   - Drift generated DAO/database parts
3. DTO-to-domain mapping remains explicit in repositories; UI never binds directly to OpenAPI DTO types.
4. Persist-first offline behavior remains mandatory: local write first, sync queue second.

## 4) Current Sync Task State Contract (Frozen)

## 4.1 Entity + Operation

1. Entity types: `trip`, `place`, `route`
2. Operations: `create`, `update`, `delete`

## 4.2 Status Vocabulary

1. Active states used by runtime: `queued`, `in_progress`, `failed`, `blocked`, `completed`
2. Compatibility/read states (must remain readable): `pending`

## 4.3 Allowed Transitions (Current Baseline)

1. `queued|failed|pending -> in_progress` (DAO claim)
2. `in_progress -> completed` (worker success)
3. `in_progress -> failed` (retryable failure with backoff)
4. `in_progress -> blocked` (terminal/non-retryable failure)
5. `failed -> queued` (requeue by changed operation)
6. `completed|blocked -> queued` (new operation via upsert)

## 4.4 Dependency Contract

1. Task may declare dependency (`dependsOnEntityType`, `dependsOnEntityId`).
2. Dependent task is claimable only when dependency task is `completed`.
3. If dependency is `blocked`, downstream does not run.

## 4.5 Retry/Error Contract

1. Retryable: timeouts, network/socket failures, HTTP `408/429/5xx`, retryable identity exceptions.
2. Non-retryable: unsupported entity/operation and non-retryable identity errors.
3. Backoff baseline in worker:
   - retry #1: +15s
   - retry #2+: +60s
   - max attempts: 3 (then block)

## 5) Safety Guardrails (Do Not Violate)

1. No blind trip recreation loop after stale remote identity failures.
2. No retry floods for non-retryable failures.
3. Media queue must remain dependency-aware of entity readiness.
4. UI "saved" semantics must stay separate from backend "synced" semantics.
5. Feed visibility behavior must remain backend-contract-driven (`public_only` compatibility aware).

## 6) Kill Switch and Rollback Contract (M0 Definition)

## 6.1 Required Kill Switches

1. `entity_sync_enabled` (global)
2. `entity_sync_delete_enabled`
3. `feed_public_only_guard_enabled`

Note: these flags are defined here as rollout contract; implementation lands in later milestones.

## 6.2 Rollback Triggers

1. Spike in stale `in_progress` tasks.
2. Sync success-rate drop below agreed threshold.
3. Feed visibility mismatch incidents.
4. Duplicate remote identity creation incidents.

## 7) Baseline Evidence Snapshot (Before M1 Changes)

Date captured: 2026-03-20

## 7.1 Flutter CLI unblock evidence

1. Confirmed root cause:
   - `Flutter failed to open a file at "C:\flutter\flutter\bin\cache\lockfile"...`
2. Recovery actions:
   - terminated stale `dart/flutter` processes
   - removed only `C:\flutter\flutter\bin\cache\lockfile` and `C:\flutter\flutter\bin\cache\flutter.bat.lock`
   - re-ran Flutter commands elevated (environment policy)
3. Verification:
   - `flutter --version` succeeded (`Flutter 3.38.9`, `Dart 3.10.8`)

## 7.2 Baseline test evidence

Command:
`flutter test test/core/storage/sync_task_dao_test.dart test/core/sync/entity_sync_worker_test.dart --reporter compact`

Result:
1. Passed: `sync_task_dao_test.dart`
2. Passed: `entity_sync_worker_test.dart`
3. Aggregate output: `All tests passed!`

## 7.3 Baseline metric fields for rollout dashboard

1. `sync_success_rate_24h`
2. `stale_in_progress_count`
3. `queue_lag_p95_seconds`
4. `feed_visibility_mismatch_count`
5. `duplicate_remote_identity_count`

Note: Production values require runtime telemetry export in rollout environment; this file defines canonical keys.

## 8) Locked Regression Scenarios

1. Offline create trip/place/route then reconnect: deterministic convergence.
2. High-churn edits while task is in progress: latest intent persists.
3. App restart mid-sync: no lost updates.
4. Concurrent media + place sync: no duplicate remote place identity.
5. Feed behavior with/without backend `public_only` support: deterministic and diagnosable.
6. Deleted auto-generated entity does not reappear without explicit user action.

## 9) Code Generation Commands (When Needed)

1. Flutter generated code (Freezed/Drift/Riverpod/json):
`dart run build_runner build --delete-conflicting-outputs`
2. OpenAPI package regeneration:
   - backend serves latest `/openapi.json`
   - regenerate `flutter/packages/dora_api` via project OpenAPI generation flow
3. Never hand-edit generated outputs; regenerate and commit deterministic artifacts.

