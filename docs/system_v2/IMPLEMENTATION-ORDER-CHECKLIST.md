# Implementation Order Checklist (V2)

Status: Execution checklist
Last updated: 2026-04-12
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

- [ ] V1 entity sync lanes disabled for V2 cohorts.
- [ ] V1 projection refresh churn disabled for V2 cohorts.
- [ ] V2 telemetry confirms no flood behavior.

## Phase 9: Legacy Deletion + Hardening

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
