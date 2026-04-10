# Dora Live System V2 Master Blueprint

Status: Draft for implementation lock
Version: v2.0
Last updated: 2026-04-10
Audience: Product, Flutter, backend, QA, SRE, new agents

## 1. Intent

This document defines the new Live System V2 as a clean architecture reset.

It is not an additive patch on prior sync-heavy behavior. It is a new operating model designed to be:

1. Local-first for runtime responsiveness.
2. Bounded-write for server scalability.
3. Deterministic for resolver and timeline behavior.
4. Recoverable for cross-device and reinstall use cases.

This blueprint is the authoritative high-level contract. Subsystem docs must conform to it.

## 2. Problem Statement

The previous model accumulated complexity through always-on data sync and read-refresh coupling.

Observed failure patterns:

1. High server request volume from continuous background syncing and refresh triggers.
2. User confusion from state mismatches between local capture, sync status, and timeline visibility.
3. Fragile behavior when identity mapping or retry loops entered inconsistent states.
4. Slow iteration due to many interdependent workers and side effects.

Root issue: too much behavior attempted in real time, across too many lanes, for data that does not need immediate server persistence.

## 3. Product-Level Principles

V2 follows these principles:

1. Capture first, sync later: capture latency is always prioritized.
2. Manual user decision is final: automation cannot overwrite user intent.
3. Server writes are milestone-based, not heartbeat-based.
4. Timeline editing is local and instant; publish is explicit.
5. Server stores canonical history suitable for recompile and cross-device restore.

## 4. Scope

Included:

1. Live session runtime model.
2. Local journal schema and state contracts.
3. Local resolver workflow with review queue.
4. Session-end commit flow.
5. Trip publish flow.
6. Server canonical storage + server compiled projection for remote devices.

Not included in this wave:

1. Advisory lane redesign and recommendation engine expansion.
2. High-frequency server telemetry streaming.
3. Real-time cross-device co-editing while a session is active.
4. New social collaboration features.

## 5. Architecture Overview

V2 has three lanes only.

1. Command Lane
- Purpose: session control.
- Operations:
  1. server-bound: `start`, `stop`
  2. local-only: `pause`, `resume`
- Characteristics:
  1. no command heartbeat retry loop
  2. stop seals locally immediately and completes server ack in finalize path if needed

2. Local Journal Lane
- Purpose: runtime truth on device.
- Data: route points, events, media, resolver candidates, resolver decisions, manual locks.
- Characteristics: local-only during active session and local editing.

3. Commit Lane
- Purpose: bounded server persistence.
- Milestones:
  1. Session finalize commit.
  2. Trip publish/save commit.
- Characteristics: idempotent, chunked, bounded retry, explicit user feedback.

## 6. Canonical Truth Model

Canonical truth differs by phase.

1. During active session and local editing:
- Local journal is canonical for the current device.

2. After session finalize or trip publish:
- Server raw journal is canonical for account-level history.
- Server compiled projection is a derived read model.

Rule:

1. Raw journal remains canonical on server.
2. Compiled timeline is derived/cache materialization.

Reason:

1. Recompile safety after resolver/compiler rule changes.
2. Better diagnostics and audit of user decisions.
3. Reliable cross-device restoration.

## 7. Runtime Flow (High Level)

### 7.1 Command behavior flow

1. `start` requires network/auth and is fail-fast if server call fails.
2. `pause` and `resume` are local-only control state transitions.
3. `stop` always seals locally first.
4. If server stop fails/offline, `stop_server_pending = true` and finalize job completes stop acknowledgement later.

### 7.2 Live capture flow

1. User captures note/tag/warn/photo/media.
2. App writes event/media locally immediately.
3. Event enters `geotag_unresolved` state.
4. Resolver runs locally using external place API.
5. Outcome:
- unique confident candidate -> auto bind.
- ambiguous high candidates -> review required with candidate list.
- no reliable candidate -> unresolved until user action.

### 7.3 User review flow

1. Shared unresolved inbox appears in Live and Editor.
2. Per event actions:
- Accept candidate.
- Add place manually.
- Keep geotag.
3. Decision is persisted locally with decision source and manual lock.
4. Manual lock prevents any future auto override.

### 7.4 Session finalize flow

1. User stops session.
2. App seals session locally.
3. App creates one `session_finalize_job`.
4. Commit lane uploads media and journal payload in idempotent chunks.
5. On success, local rows become committed.
6. On failure, job remains retryable with explicit UI state.

### 7.5 Trip publish flow

1. User taps save/upload in editor.
2. App creates one `trip_publish_job` from local canonical journal and editor state.
3. Server persists canonical raw payload and compiles published projection.

### 7.6 Cross-device restore

1. New device fetches server compiled projection for immediate viewing.
2. Server raw journal remains available for future recompile consistency.

## 8. State Contracts (Top-Level)

### 8.1 Resolution states

1. `geotag_unresolved`
2. `review_required`
3. `place_bound`
4. `geotag_final`

### 8.1.1 Geotag final reason

1. `user_keep_geotag`
2. `no_reliable_candidate`
3. `manual_add_cancelled`

### 8.2 Decision source values

1. `auto_high_confidence`
2. `user_accept_candidate`
3. `user_manual_place`
4. `user_keep_geotag`

### 8.3 Manual lock

1. `manual_lock = true` for any user decision.
2. Resolver and reconcile logic must short-circuit for locked rows.

### 8.4 Commit states

1. `commit_pending`
2. `committing`
3. `commit_failed_retryable`
4. `committed`

## 9. API Boundary Policy

1. Device -> external place API:
- Used for resolver candidate discovery.
- Provider contract locked to ORS direct for V2.
- Must use secure key strategy and strict limits.

2. Device -> Dora backend:
- Control APIs for session lifecycle.
- Session finalize ingest.
- Trip publish ingest.
- Read APIs for remote compiled timeline.

3. Forbidden patterns:
- Continuous event/media/point flush during active session.
- Sync heartbeat loops for live entities.
- Poll-driven projection flood behavior.

## 10. Scalability Policy

Target behavior:

1. Active session should generate near-zero data-plane server writes.
2. Data-plane writes should happen only at explicit milestone commits.
3. No generalized worker storms from per-entity retries.

Key controls:

1. One finalize job per stopped session.
2. One publish job per explicit user publish.
3. Bounded retries with backoff and user-visible retry action.
4. Chunked ingest for large media/session payloads.
5. Idempotency keys for finalize and publish operations.

## 11. Security and Compliance Baseline

1. External resolver provider keys must be protected.
2. Prefer short-lived scoped tokens or backend-minted session tokens.
3. Avoid shipping unrestricted long-lived provider secrets.
4. Track provider quota and abuse controls.

## 12. V1 Decommission Direction

V2 explicitly retires these patterns from live critical path:

1. Generic entity sync pipeline for live entities.
2. Continuous tracking point batch server sync.
3. Projection refresh mechanisms coupled to sync-task churn.
4. Reconcile paths that can overwrite manual decisions.

## 13. Delivery Strategy

Phase 1: Contracts and schema lock

1. Freeze state machine and payload contracts.
2. Introduce v2 local journal schema.
3. Add unresolved inbox and lock semantics.

Phase 2: Local-first runtime migration

1. Route all live capture and local compile to v2 journal.
2. Disable legacy continuous data flush for v2 sessions.

Phase 3: Commit lane

1. Implement finalize/publish jobs with idempotent ingest.
2. Add explicit retry UI and observability.

Phase 4: Server canonical + projection

1. Persist raw canonical journal on server.
2. Materialize compiled projection read model.
3. Validate cross-device restore.

Phase 5: Deletion and hardening

1. Remove legacy live sync paths.
2. Soak test long sessions, offline/online transitions, reinstall restore.

## 14. Acceptance Criteria

V2 is considered successful only if all hold:

1. Live capture remains responsive under network loss.
2. No continuous server write loop during active session.
3. User manual resolution choices are never auto-overwritten.
4. Session finalize and trip publish are reliable and idempotent.
5. Timeline is visible immediately locally and reproducible on new devices.
6. Server request profile remains bounded under prolonged live usage.

## 15. Locked Decisions

1. Lane contract:
  1. command lane server-bound: `start`, `stop`
  2. local-only controls: `pause`, `resume`
2. Resolver provider and rules:
  1. ORS direct from app
  2. reverse + nearby POI in parallel
  3. 1500ms timeout per call
  4. auto bind requires:
    1. score >= 0.60
    2. unique top candidate
    3. `top - second >= 0.05`
    4. distance <= 100m
  5. ambiguous tie rule: `abs(top-second) <= 0.02` => `review_required`
3. Retry constants:
  1. max auto attempts = 3
  2. backoff schedule = 15s, 60s, 180s
4. Commit states (strict):
  1. `commit_pending`
  2. `committing`
  3. `commit_failed_retryable`
  4. `committed`
5. Publish states (strict):
  1. `publish_pending`
  2. `publishing`
  3. `publish_failed_retryable`
  4. `published`
6. Publish retry semantics: snapshot-lock payload per publish job.

## 16. Glossary

1. Local journal: on-device canonical runtime records.
2. Resolve state: current place/geotag status for an event.
3. Manual lock: immutable marker after user decision.
4. Finalize job: session-end upload transaction.
5. Publish job: explicit editor save/upload transaction.
6. Compiled projection: derived timeline/read model.

## 17. Related Specs

This blueprint is the entry contract. Detailed design and implementation rules are split into subsystem specs.

Primary references:

1. Subsystem index: [Subsystem Specs Index](./README.md)
2. System index: [System V2 Index](../README.md)

Key specs:

1. `local-journal-and-resolver-spec.md`
2. `session-commit-worker-spec.md`
3. `trip-publish-spec.md`
4. `local-timeline-compiler-spec.md`
5. `backend-ingest-and-projection-spec.md`
6. `live-editor-ui-contract-spec.md`
7. `command-lane-spec.md`

