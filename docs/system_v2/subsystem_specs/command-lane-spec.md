# Command Lane Spec (V2)

Status: Locked contract
Version: v2.0
Last updated: 2026-04-10
Owner: Flutter runtime team + backend command API team

## 1. Purpose

This spec locks V2 command-lane behavior.

It defines:

1. Which actions are server-bound vs local-only.
2. Start/stop API expectations.
3. Local pause/resume behavior.
4. Failure and retry semantics.
5. Session stop acknowledgement handling in finalize.

## 2. References

1. Master blueprint: [Master Blueprint](./master-blueprint.md)
2. Local state schema: [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
3. Session finalize flow: [Session Commit Worker Spec](./session-commit-worker-spec.md)
4. Backend ingest/projection: [Backend Ingest and Projection Spec](./backend-ingest-and-projection-spec.md)

## 3. Command Contract (Final)

1. Server-bound commands:
- `start`
- `stop`

2. Local-only control actions:
- `pause`
- `resume`

3. No heartbeat retry loop for commands.

## 4. Start Command

1. Requires network + authenticated session.
2. If start fails, do not create active session state.
3. Explicit user retry only; no background auto-retry loop.
4. Idempotency key required.

Idempotency key format:

1. `start:{trip_local_id}:{session_id}:{start_request_seq}`

## 5. Pause Action (Local-Only)

1. No server call.
2. Update local `control_state = paused`.
3. Stop route point capture while paused.
4. Manual captures remain allowed and must be marked `captured_while_paused = true`.

## 6. Resume Action (Local-Only)

1. No server call.
2. Update local `control_state = active`.
3. Restart route point capture.

## 7. Stop Command

1. Always seal session locally immediately.
2. Attempt server stop call immediately when online.
3. If stop call fails/offline:
- set `stop_server_pending = true`
- keep session sealed locally.
4. Do not block user from exiting live flow.

Idempotency key format:

1. `stop:{trip_local_id}:{session_id}:{seal_version}`

## 8. Stop Ack Completion in Finalize

1. Session finalize must include stop-ack completion phase.
2. If `stop_server_pending = true`, finalize pipeline performs server stop acknowledgement before `done`.
3. On success, set `stop_server_pending = false` and populate `stop_ack_at`.

## 9. Local Session Fields (Required)

`session_journal` requires these fields:

1. `control_state` enum: `planned|active|paused|sealed`
2. `stop_server_pending` boolean
3. `start_ack_at` datetime nullable
4. `stop_ack_at` datetime nullable
5. `seal_version` integer

## 10. Error Model

1. `start` errors are fail-fast and user-visible.
2. `pause/resume` are local and should only fail on local persistence errors.
3. `stop` server failure transitions to local sealed + pending server stop.

## 11. Acceptance Criteria

1. Start never creates active local session when server start fails.
2. Pause/resume never call backend.
3. Stop always seals locally, even offline.
4. Pending stop acknowledgement is completed by finalize path.
5. No command heartbeat retry loop exists.

