# Implementation Order Checklist (V2)

Status: Execution checklist
Last updated: 2026-04-10
Reference plan: [Execution Plan V2](./execution-plan-v2.md)

Use this file as the day-to-day gate checklist. Do not advance phase until all boxes are checked.

## Phase 0: Contract Lock and Scaffolding

- [ ] All open decisions from subsystem specs are resolved or marked deferred with owner/date.
- [ ] Command lane contract is implemented exactly:
  - [ ] start/stop server-bound
  - [ ] pause/resume local-only
- [ ] Retry constants are fixed globally: max 3, delays 15s/60s/180s.
- [ ] Feature flags created and validated:
  - [ ] `enable_live_system_v2`
  - [ ] `enable_v2_local_journal`
  - [ ] `enable_v2_local_compiler`
  - [ ] `enable_v2_session_commit_worker`
  - [ ] `enable_v2_trip_publish_worker`
  - [ ] `enable_v2_backend_ingest`
  - [ ] `enable_v2_live_editor_ui_contract`
- [ ] Baseline telemetry events added for V2 paths.
- [ ] Rollback owner and incident channel defined.

## Phase 1: Local Journal Foundation

- [ ] V2 local tables and indexes added via migration.
- [ ] Upgrade test passes for existing user DBs.
- [ ] Repositories added for session/event/media/route/resolver.
- [ ] Flags OFF path verified unchanged.

## Phase 2: Local Capture Lane Switch

- [ ] Live capture writes to V2 local tables only (for V2 sessions).
- [ ] `pause` stops point capture locally.
- [ ] manual captures while paused are marked `captured_while_paused=true`.
- [ ] Route points write to `route_point_journal`.
- [ ] No V1 live entity sync task enqueue for V2 sessions.
- [ ] Offline capture verification passed.

## Phase 3: Resolver + Shared Inbox

- [ ] Resolver worker implemented with deterministic transitions.
- [ ] Manual lock short-circuit enforced in all resolver paths.
- [ ] Shared unresolved inbox provider wired for both Live + Editor.
- [ ] `Accept / Add place manually / Geo-Tag` actions work end-to-end.
- [ ] Manual-add cancel defaults to `Geo-Tag`.

## Phase 4: Local Timeline Compiler Cutover

- [ ] Projection tables added.
- [ ] Incremental compiler + dirty cursor implemented.
- [ ] Live recent strip consumes local projection.
- [ ] Editor storyline consumes local projection.
- [ ] No server dependency for timeline rendering in V2 sessions.

## Phase 5: Session Commit Worker

- [ ] `session_commit_job` + media/chunk tables implemented.
- [ ] Commit phases implemented:
  - [ ] prepare
  - [ ] media_upload
  - [ ] payload_upload
  - [ ] finalize_ack
  - [ ] done
- [ ] Idempotency key persisted and reused across retries.
- [ ] Bounded retry + retry CTA implemented.
- [ ] Crash-recovery resume verified.

## Phase 6: Backend Ingest + Server Projection

- [ ] Finalize APIs implemented (`start`, `media-complete`, `payload-chunk`, `commit`).
- [ ] Raw canonical tables implemented.
- [ ] Idempotency manifest + conflict handling implemented.
- [ ] Server projection compiler implemented.
- [ ] Timeline/route read APIs implemented.

## Phase 7: Trip Publish Worker

- [ ] `trip_publish_job` implemented.
- [ ] Deterministic payload assembly implemented.
- [ ] Publish idempotency + hash conflict handling implemented.
- [ ] Editor publish status chips + retry UX implemented.
- [ ] Publish failure preserves local timeline/editor state.

## Phase 8: Legacy Path Deactivation (V2 cohorts)

- [ ] V1 entity sync lanes disabled for V2 sessions.
- [ ] V1 projection refresh churn paths disabled for V2 sessions.
- [ ] V2 telemetry confirms no flood behavior.

## Phase 9: Legacy Deletion + Hardening

- [ ] Legacy modules removed after soak/pass gates.
- [ ] Docs/runbooks/alerts finalized.
- [ ] Post-rollout stability window completed.

## Mandatory Gates Before Public Rollout

- [ ] Unit suite pass for resolver, compiler, commit/publish workers.
- [ ] Integration suite pass for offline->online finalize and cross-device visibility.
- [ ] Soak pass (30 min mixed-network sessions) complete.
- [ ] No manual-lock overwrite incidents.
- [ ] No high-frequency write flood in backend metrics.

## Quick Exit Criteria

Release-ready when all are true:

- [ ] V2 captures are local-first and resilient offline.
- [ ] Server writes are milestone-based only.
- [ ] Timeline is stable locally and reproducible remotely after finalize/publish.
- [ ] Retry model is bounded and user-actionable.

