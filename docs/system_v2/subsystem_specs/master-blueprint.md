# Dora Live System V2 Master Blueprint

Status: Draft for implementation lock
Version: v2.2
Last updated: 2026-04-12
Audience: Product, Flutter, backend, QA, SRE

## 1. Intent

System V2 is a clean reset for live tracking:

1. local-first runtime,
2. bounded server writes,
3. deterministic resolver and timeline behavior,
4. strong replay/idempotency.

## 2. Core Problem Being Solved

V1-style continuous sync caused:

1. request floods,
2. state mismatches between live/editor/server,
3. sticky retry loops,
4. fragile coupling between capture and server availability.

## 3. Product Principles

1. Capture first, sync later.
2. Manual user decisions are final.
3. Server writes are milestone-based.
4. Local timeline must be visible immediately.
5. Cross-device view comes from published server projection.

## 4. Architecture Lanes

### 4.1 Command lane

1. server-bound: `start`, `stop`
2. local-only: `pause`, `resume`
3. no command heartbeat loops

### 4.2 Local journal lane

1. points/events/media/resolver states are local during active editing/live
2. local compiler renders timeline and route for current device

### 4.3 Publish lane

1. explicit publish is the only V2 data-plane ingest trigger
2. session-stop commit artifacts are local staging only
3. backend ingest + projection happen at publish milestones

## 5. Canonical Truth by Lifecycle

1. During live/edit: local journal is canonical.
2. After publish: server raw rows are canonical.
3. Server projection is derived read model for cross-device.

## 6. Runtime Flow (High Level)

### 6.1 Live capture

1. capture writes locally immediately,
2. resolver runs locally,
3. unresolved items go to shared review queue,
4. manual action locks decision.

### 6.2 Session stop

1. session seals locally immediately,
2. stop command attempts server ack,
3. on failure, mark `stop_server_pending`,
4. create/update local session staging artifacts.

### 6.3 Editor publish

1. user explicitly taps save/upload,
2. client freezes snapshot and starts publish job,
3. backend ingests raw payload and compiles projection synchronously,
4. second device reads timeline/route from projection endpoints.

## 7. Locked Behavioral Contracts

1. no automatic publish on background/close,
2. stop does not imply upload success,
3. one active publish per trip,
4. immutable snapshot per publish job,
5. replay-safe idempotency and fingerprint validation,
6. manual-lock never overwritten by automation.

## 8. Performance and Load Targets

1. near-zero active-session data-plane writes,
2. bounded publish ingest with chunking,
3. bounded read APIs (cursor timeline and capped route response),
4. no unbounded polling loops.

## 9. Security Baseline

1. V2 mutating endpoints require `Idempotency-Key`,
2. publish token bound to user/trip/job/schema context,
3. media references verified for existence and ownership,
4. provider-specific storage URLs are not canonical identity.

## 10. Rollout Direction

1. feature-flagged cohorts,
2. publish lane behind `enable_v2_backend_ingest` until all Phase 6 gates pass,
3. legacy V1 sync/projection deactivated only after soak success.

## 11. Acceptance Criteria

1. local capture is responsive under network loss,
2. publish is idempotent and replay-safe,
3. no V1 flood behavior in V2 cohorts,
4. second-device reads match published snapshot,
5. no manual-lock overwrite incidents.

## 12. Related Specs

1. [Command Lane Spec](./command-lane-spec.md)
2. [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
3. [Session Commit Worker Spec](./session-commit-worker-spec.md)
4. [Trip Publish Spec](./trip-publish-spec.md)
5. [Local Timeline Compiler Spec](./local-timeline-compiler-spec.md)
6. [Backend Ingest and Projection Spec](./backend-ingest-and-projection-spec.md)
7. [Live and Editor UI Contract Spec](./live-editor-ui-contract-spec.md)
