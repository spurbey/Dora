# Command Lane Spec (V2)

Status: Locked contract
Version: v2.2
Last updated: 2026-04-12
Owner: Flutter runtime team + backend command API team

## 1. Purpose

This spec locks V2 command behavior.

It defines:

1. server-bound vs local-only actions,
2. start/stop payload and idempotency,
3. local pause/resume behavior,
4. stop reconciliation via publish commit.

## 2. Command Split (Final)

1. Server-bound:
   - `start`
   - `stop`
2. Local-only:
   - `pause`
   - `resume`
3. No command heartbeat loop.

## 3. Start Contract

1. Requires network + auth.
2. If start fails, do not create active local session.
3. Explicit user retry only.

Payload:

1. `client_session_id`
2. `started_at`
3. optional `timezone`
4. optional `device_context`

Idempotency key:

1. `start:{trip_local_id}:{session_id}:{start_request_seq}`

## 4. Pause/Resume Contract

1. No server call.
2. Pause sets local `control_state=paused` and stops route point capture.
3. Resume sets local `control_state=active` and resumes point capture.
4. Manual captures while paused are allowed and marked accordingly.

## 5. Stop Contract

1. Always seal locally first.
2. Attempt server stop immediately.
3. If stop call fails/offline, set `stop_server_pending=true` and keep session sealed.

Canonical session identity is path `client_session_id`.

Stop request body:

1. `seal_version`
2. `stop_client_event_id`
3. `stopped_at`
4. `reason` (optional opaque string)
5. optional `client_session_id` echo for audit only (must match path if present)

Idempotency key:

1. `stop:{trip_local_id}:{session_id}:{seal_version}`

## 6. Stop Reconciliation in Publish

1. Pending stop ack is reconciled during `publish:commit`.
2. `publish:commit` cannot return success until pending stop reconciliation succeeds.
3. On successful reconciliation:
   - `stop_server_pending=false`
   - `stop_ack_at` populated

## 7. Required Local Fields

`session_journal` requires:

1. `control_state` (`planned|active|paused|sealed`)
2. `stop_server_pending`
3. `start_ack_at`
4. `stop_ack_at`
5. `seal_version`
6. `start_request_seq`

## 8. Error Model

1. Start failures are fail-fast and user-visible.
2. Pause/resume failures are local persistence failures only.
3. Stop server failure transitions to sealed local state with pending stop flag.

## 9. Acceptance Criteria

1. start never leaves active local session on failed start call,
2. pause/resume never call server,
3. stop always seals locally,
4. pending stop is reconciled before publish commit success,
5. no command retry storm loop.
