# System V2 Execution Plan

Status: Draft for execution lock
Version: v2.2
Last updated: 2026-04-18
Owner: Tech lead + Flutter lead + Backend lead + QA lead

## 1. Purpose

This document is the executable rollout order for System V2.

It defines:

1. phase sequence,
2. lock-level contracts,
3. gates and rollback policy,
4. deactivation order for legacy paths.

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

## 3. Non-Negotiable Rules

1. No big-bang cutover.
2. V2 is feature-flagged and cohort-based.
3. No dual-write of V1 and V2 for one active session.
4. Manual lock is immutable.
5. No unbounded polling/sync loops.
6. Phase 6 is publish-only backend ingest (no session-finalize ingest lane).

## 4. Feature Flags

1. `enable_live_system_v2`
2. `enable_v2_local_journal`
3. `enable_v2_local_compiler`
4. `enable_v2_session_commit_worker`
5. `enable_v2_trip_publish_worker`
6. `enable_v2_backend_ingest`
7. `enable_v2_live_editor_ui_contract`

## 5. Phase Plan

### Phase 0: Contract Lock + Scaffolding

1. Lock contracts and constants.
2. Add flag plumbing and V2 gate.
3. Add baseline observability.

### Phase 1: Local Journal Foundation

1. Add V2 local tables, DAOs, repositories.
2. Keep flags-off behavior unchanged.

### Phase 2: Local Capture Lane

1. Route V2 capture writes to local journal only.
2. Pause/resume remain local-only.
3. No V1 entity-sync enqueue for V2 sessions.

### Phase 3: Resolver + Shared Inbox

1. ORS resolver + deterministic reducer.
2. Shared unresolved inbox from computed provider.
3. Manual lock short-circuit in all auto paths.

### Phase 4: Local Timeline Compiler

1. Local projection tables and compiler.
2. Live/editor render from local projection for V2 lane.
3. Compile trigger narrowed to sealed transitions.

### Phase 5: Session Commit Worker (Local Staging Only)

1. Keep `session_commit_*` as local staging artifacts.
2. Prepare immutable session snapshot on stop.
3. Upload/finalize network phases are disabled in V2 publish lane.
4. Stop idempotency key remains seal-version scoped.

### Phase 6: Backend Publish Ingest + Server Projection (Publish-Only)

1. Canonical mutating endpoints:
   - `POST /api/v2/trips/{trip_id}/publish:start`
   - `POST /api/v2/trips/{trip_id}/publish:media-complete`
   - `POST /api/v2/trips/{trip_id}/publish:payload-chunk`
   - `POST /api/v2/trips/{trip_id}/publish:commit`
2. Read endpoints:
   - `GET /api/v2/trips/{trip_id}/timeline`
   - `GET /api/v2/trips/{trip_id}/route`
3. Lock rules:
   - one active publish per `trip_id` by `status in {started, failed_retryable}`,
   - snapshot freeze at `publish:start`,
   - mandatory `Idempotency-Key` on mutating endpoints,
   - publish token bound to `user_id + trip_id + publish_job_id + schema_version`,
   - chunk size `128 KiB`, total payload cap `64 MiB`,
   - stop reconciliation required before `committed`,
   - replay after `raw_ingest_completed` skips raw reinsert and reruns projection/finalize.

### Phase 7: Publish Worker Integration (Client)

1. Wire editor publish flow to Phase 6 endpoints.
2. Show publish status and retry UX.
3. Keep local timeline responsive regardless of publish state.

### Phase 8: Legacy Path Deactivation

1. Disable V1 entity sync/projection churn for V2 cohorts.
2. Keep V1 isolated for non-migrated cohorts.

### Phase 9: Legacy Deletion + Hardening

1. Remove obsolete V1 live-sync modules after soak gates.
2. Finalize runbooks and alerts.

## 6. Quality Gates

### Unit

1. migration/readback,
2. resolver reducer + manual-lock,
3. local compiler determinism,
4. publish idempotency/fingerprint,
5. stop reconciliation and manifest transitions.

### Integration

1. offline capture -> stop -> local sealed timeline,
2. explicit publish -> raw ingest -> projection -> cross-device read,
3. replay and conflict paths (`409`, `403`, `413`, `422`, `503`).

### Regression

1. no V1 flood behavior in V2 cohorts,
2. no manual-lock overwrite,
3. no duplicate projection rows on replay.

## 7. Soak Plan

1. 30-minute live sessions with network drops.
2. stop while offline, publish later when online.
3. media-heavy publish with chunked payload.
4. second-device read after publish.

Soak pass requires:

1. near-zero active-session data-plane writes,
2. one active publish manifest per trip,
3. no retry storms,
4. stable local timeline visibility.

## 8. Rollout

1. internal dogfood,
2. 5% cohort,
3. 25% cohort,
4. 100% after soak and incident-free window.

Rollback:

1. disable V2 flags per cohort,
2. preserve local journal data,
3. tech lead is rollback owner (`#live-system-v2-incidents`).

## 9. Locked Decision Log

1. command lane: server-bound `start/stop`, local-only `pause/resume`.
2. resolver: ORS direct + locked thresholds/timeouts.
3. retry constants: 15s/60s/180s, max 3.
4. no cancelled terminal states.
5. app kill/no-stop: no auto-finalize.
6. stop payload contract uses `stop_client_event_id` scoped to `(client_session_id, seal_version)`.
7. Phase 6 ingest is publish-only; session-commit upload lane is disabled.
8. publish contracts:
   - chunk `128 KiB`, payload cap `64 MiB`,
   - mandatory `Idempotency-Key`,
   - token mismatch => `403 token_scope_mismatch`,
   - same key + different fingerprint => `409 idempotency_conflict`.

## 10. Definition of Done

1. local capture and timeline are resilient offline,
2. server writes are milestone-based,
3. published snapshot is reproducible on new devices,
4. no high-frequency sync churn in V2,
5. program soak/quality gates pass.

## 11. Recent Execution Notes (2026-04-18)

1. OpenAPI client cleanup executed against backend-sourced schema:
   - refreshed `flutter/openapi.json` from current backend app OpenAPI,
   - regenerated `flutter/packages/dora_api`,
   - removed stale generated compiled-projection and legacy V1 tracking artifacts.
2. Compatibility patches applied in Flutter runtime to avoid dependency on removed generated V1 DTOs:
   - legacy notification/media calls now use raw Dio payloads in `live_tracking_api.dart`,
   - route/timeline geojson parsing updated for regenerated `JsonObject` shape.
3. Remaining known runtime gap:
   - push-token registration lifecycle currently calls `/api/v1/notifications/device-tokens/register`,
   - backend route is absent, resulting in `404` until route is restored or bootstrap is gated off.
