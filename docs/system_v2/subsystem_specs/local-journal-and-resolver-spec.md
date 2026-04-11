# Local Journal and Resolver Spec (V2)

Status: Draft for implementation lock
Version: v2.0
Last updated: 2026-04-10
Owner: Flutter data/runtime team

## 1. Purpose

This spec defines the on-device canonical data model and resolver workflow for Live System V2.

It covers:

1. Local journal tables and indexes.
2. Resolver state machine and decision-source semantics.
3. Manual-lock behavior.
4. Shared unresolved inbox contract for Live and Editor.
5. Runtime processing and trigger rules.

This spec is authoritative for local data semantics during active session and local editing.

## 2. References

1. Master blueprint: [Master Blueprint](./master-blueprint.md)
2. Command controls: [Command Lane Spec](./command-lane-spec.md)
3. Subsystem index: [Subsystem Specs Index](./README.md)
4. System index: [System V2 Index](../README.md)

## 3. Depends On

1. Master architecture lane model and canonical truth rules from `master-blueprint.md`.

## 4. Used By

1. `session-commit-worker-spec.md`
2. `local-timeline-compiler-spec.md`
3. `trip-publish-spec.md`
4. `backend-ingest-and-projection-spec.md`

## 5. Design Goals

1. Capture must be instant and local-only.
2. Resolver must be deterministic and side-effect-safe.
3. User manual decisions must be immutable to automation.
4. Both Live and Editor must consume one unresolved queue source.
5. Schema must support crash recovery and eventual commit.

## 6. Data Ownership

1. During active session and local editing, this local journal is canonical.
2. Resolver writes only local state in this phase.
3. No server write is required for normal capture and review decisions.
4. Server persistence happens later in commit/publish subsystems.

## 7. Local Tables

All table names are logical names. Physical Drift naming can vary by conventions.

### 7.1 `session_journal`

One row per local live session.

Columns:

1. `session_id` TEXT PRIMARY KEY
2. `trip_local_id` TEXT NOT NULL
3. `server_trip_id` TEXT NULL
4. `control_state` TEXT NOT NULL
- enum: `planned`, `active`, `paused`, `sealed`
5. `stop_server_pending` INTEGER NOT NULL DEFAULT 0
6. `start_ack_at` DATETIME NULL
7. `stop_ack_at` DATETIME NULL
8. `started_at` DATETIME NULL
9. `ended_at` DATETIME NULL
10. `created_at` DATETIME NOT NULL
11. `updated_at` DATETIME NOT NULL
12. `seal_version` INTEGER NOT NULL DEFAULT 0
13. `start_request_seq` INTEGER NOT NULL DEFAULT 0
14. `session_seq` INTEGER NOT NULL
15. `device_id` TEXT NOT NULL

Indexes:

1. `(trip_local_id, control_state, updated_at)`
2. `(trip_local_id, started_at)`

### 7.1.1 `session_activity_window`

Tracks active/pause windows within session.

Columns:

1. `window_id` TEXT PRIMARY KEY
2. `session_id` TEXT NOT NULL
3. `trip_local_id` TEXT NOT NULL
4. `window_kind` TEXT NOT NULL
- enum: `active`, `paused`
5. `started_at` DATETIME NOT NULL
6. `ended_at` DATETIME NULL
7. `window_seq` INTEGER NOT NULL

Indexes:

1. `(session_id, window_seq)`
2. `(session_id, started_at)`

### 7.2 `route_point_journal`

Local route points recorded during session.

Columns:

1. `point_id` TEXT PRIMARY KEY
2. `session_id` TEXT NOT NULL
3. `trip_local_id` TEXT NOT NULL
4. `captured_at` DATETIME NOT NULL
5. `latitude` REAL NOT NULL
6. `longitude` REAL NOT NULL
7. `accuracy_m` REAL NULL
8. `speed_mps` REAL NULL
9. `bearing_deg` REAL NULL
10. `altitude_m` REAL NULL
11. `source` TEXT NOT NULL DEFAULT `device_gps`
12. `point_seq` INTEGER NOT NULL

Indexes:

1. `(session_id, captured_at)`
2. `(trip_local_id, captured_at)`
3. `(session_id, point_seq)`

### 7.3 `event_journal`

One row per captured event (note/warn/tag/photo/media).

Columns:

1. `event_id` TEXT PRIMARY KEY
2. `session_id` TEXT NOT NULL
3. `trip_local_id` TEXT NOT NULL
4. `event_type` TEXT NOT NULL
- enum: `note`, `warn`, `tag`, `photo`, `media`
5. `captured_at` DATETIME NOT NULL
6. `latitude` REAL NOT NULL
7. `longitude` REAL NOT NULL
8. `anchor_accuracy_m` REAL NULL
9. `payload_json` TEXT NULL
10. `resolver_state` TEXT NOT NULL
- enum: `geotag_unresolved`, `review_required`, `place_bound`, `geotag_final`
11. `decision_source` TEXT NULL
- enum: `auto_high_confidence`, `user_accept_candidate`, `user_manual_place`, `user_keep_geotag`
12. `manual_lock` INTEGER NOT NULL DEFAULT 0
13. `place_bind_kind` TEXT NULL
- enum: `none`, `provider_poi`, `trip_place_local`
14. `place_bind_id` TEXT NULL
15. `place_bind_name` TEXT NULL
16. `geotag_final_reason` TEXT NULL
- enum: `user_keep_geotag`, `no_reliable_candidate`, `manual_add_cancelled`
17. `captured_while_paused` INTEGER NOT NULL DEFAULT 0
18. `candidate_set_version` INTEGER NOT NULL DEFAULT 0
19. `resolved_at` DATETIME NULL
20. `created_at` DATETIME NOT NULL
21. `updated_at` DATETIME NOT NULL
22. `event_seq` INTEGER NOT NULL

Indexes:

1. `(session_id, captured_at)`
2. `(trip_local_id, resolver_state, captured_at)`
3. `(trip_local_id, manual_lock, resolver_state)`
4. `(session_id, event_seq)`

### 7.4 `media_journal`

Media records linked to event rows.

Columns:

1. `media_id` TEXT PRIMARY KEY
2. `event_id` TEXT NOT NULL
3. `session_id` TEXT NOT NULL
4. `trip_local_id` TEXT NOT NULL
5. `media_type` TEXT NOT NULL
- enum: `photo`, `video`, `audio`, `other`
6. `local_uri` TEXT NOT NULL
7. `mime_type` TEXT NULL
8. `bytes_size` INTEGER NULL
9. `duration_ms` INTEGER NULL
10. `captured_at` DATETIME NOT NULL
11. `width_px` INTEGER NULL
12. `height_px` INTEGER NULL
13. `upload_state` TEXT NOT NULL DEFAULT `local_only`
- enum: `local_only`, `staged_for_commit`, `uploaded`, `upload_failed`
14. `upload_ref` TEXT NULL
15. `created_at` DATETIME NOT NULL
16. `updated_at` DATETIME NOT NULL

Indexes:

1. `(event_id)`
2. `(session_id, upload_state)`
3. `(trip_local_id, captured_at)`

### 7.5 `resolver_candidate_journal`

Candidate place list returned by external API per event.

Columns:

1. `candidate_id` TEXT PRIMARY KEY
2. `event_id` TEXT NOT NULL
3. `candidate_version` INTEGER NOT NULL
4. `provider` TEXT NOT NULL
5. `provider_place_id` TEXT NULL
6. `name` TEXT NOT NULL
7. `label` TEXT NULL
8. `latitude` REAL NOT NULL
9. `longitude` REAL NOT NULL
10. `confidence_score` REAL NULL
11. `distance_m` REAL NULL
12. `rank_index` INTEGER NOT NULL
13. `is_top_tied` INTEGER NOT NULL DEFAULT 0
14. `raw_json` TEXT NULL
15. `created_at` DATETIME NOT NULL

Indexes:

1. `(event_id, candidate_version, rank_index)`
2. `(event_id, candidate_version, is_top_tied)`

### 7.6 `resolver_attempt_journal`

Observability and deterministic retry control for resolver runs.

Columns:

1. `attempt_id` TEXT PRIMARY KEY
2. `event_id` TEXT NOT NULL
3. `attempt_no` INTEGER NOT NULL
4. `trigger_reason` TEXT NOT NULL
- enum: `capture_created`, `network_recovered`, `live_open`, `editor_open`
5. `started_at` DATETIME NOT NULL
6. `finished_at` DATETIME NULL
7. `result_kind` TEXT NOT NULL
- enum: `auto_place`, `review_required`, `unresolved`, `skipped_locked`, `provider_error`
8. `error_code` TEXT NULL
9. `error_message` TEXT NULL

Indexes:

1. `(event_id, attempt_no)`
2. `(started_at)`

### 7.7 `unresolved_inbox` (computed provider/query)

`unresolved_inbox` is a computed local projection and is not stored as a
materialized table in this phase.

Source rows:

1. `event_journal`
2. `resolver_candidate_journal`

Computed shape:

1. `event_id`
2. `trip_local_id`
3. `session_id`
4. `event_type`
5. `captured_at`
6. `resolver_state`
7. `manual_lock`
8. `top_candidates` (max 3, derived from latest candidate version)
9. `last_activity_at` (derived from event/resolver timestamps)

## 8. Resolver State Machine

### 8.1 Initial state

On capture create:

1. Insert event row with `resolver_state = geotag_unresolved`.
2. `manual_lock = 0`.
3. `place_bind_* = NULL`.

### 8.2 Automatic transitions

Resolver may apply only when `manual_lock = 0`.

1. Unique top candidate above threshold:
- `resolver_state = place_bound`
- `decision_source = auto_high_confidence`
- set `place_bind_*`

2. Ambiguous top candidates above threshold:
- `resolver_state = review_required`
- clear `place_bind_*`
- persist candidate list in candidate table

  3. No reliable candidate:
  - `resolver_state = geotag_unresolved` until user acts.
  - No automatic retry is triggered after a successful response (even empty).

### 8.2.1 Resolver Attempt Policy (Lock)

  1. Run once at capture if network is available.
  2. If the attempt returns a valid response (including zero candidates), do not retry automatically.
  3. If the attempt fails (network/timeout/5xx/parse), allow exactly one automatic retry on network recovery.
  4. Recovery triggers are explicit only: app resume, live screen open, editor open.
  5. Recovery must run only when connectivity is online (do not spend the retry while still offline).
  6. Recovery scan is bounded (`limit=20`) and deduped (one in-flight runner per trip).
  7. No polling loop and no connectivity package dependency in Phase 3 (use lightweight online check).
  8. No manual retry UI exists in V2; further attempts must not occur.

### 8.3 Manual transitions

User actions from inbox:

1. Accept candidate:
- `resolver_state = place_bound`
- `decision_source = user_accept_candidate`
- `manual_lock = 1`

2. Add place manually:
- `resolver_state = place_bound`
- `decision_source = user_manual_place`
- `manual_lock = 1`

3. Keep geotag:
- `resolver_state = geotag_final`
- `decision_source = user_keep_geotag`
- `geotag_final_reason = user_keep_geotag`
- `manual_lock = 1`

### 8.4 Lock invariant

1. Any row with `manual_lock = 1` is immutable to automatic resolver updates.
2. Resolver workers must short-circuit to `skipped_locked`.

## 9. Resolver Decision Rules (Locked)

Provider contract:

1. Resolver provider is ORS direct from app.
2. For each unresolved event, call reverse + nearby POI in parallel.
3. Per-call timeout is 1500ms.

Decision constants:

1. `CONFIDENCE_MIN = 0.60`
2. `UNIQUE_MARGIN_MIN = 0.05` (`top - second >= 0.05`)
3. `TIE_EPSILON = 0.02` (`abs(top-second) <= 0.02`)
4. `DISTANCE_MAX_M = 100`

Auto bind requires all:

1. top score >= 0.60
2. unique top candidate (`top-second >= 0.05`)
3. top candidate distance <= 100m

Ambiguous review rule:

1. top score >= 0.60
2. top candidates tied (`abs(top-second) <= 0.02`)
3. transition to `review_required`

No reliable candidate rule:

1. if thresholds are not met, keep unresolved
2. user may finalize as geotag (`geotag_final`) later

## 10. Shared Unresolved Inbox Contract

Live and Editor must read from the same computed source (`unresolved_inbox`).

### 10.1 Sorting

1. Newest first by `captured_at`.
2. Secondary by unresolved severity (`review_required` first, then `geotag_unresolved`).

### 10.2 Card actions

Each card supports:

1. Candidate `Accept` actions.
2. `Add place manually`.
3. `Geo-Tag`.

### 10.3 Deep-link behavior

1. `Add place manually` can deep-link to editor place picker/create screen.
2. On return with selected place, event row is updated through manual transition rules.
3. If user dismisses manual add, default action is `Geo-Tag`.

## 11. Trigger Model

Resolver processing is event-driven, not free-running.

Allowed triggers:

1. `capture_created`
2. `network_recovered` (`AppLifecycleState.resumed`)
3. `live_open` (bounded scan)
4. `editor_open` (bounded scan)

Forbidden:

1. Constant polling loops.
2. Unbounded whole-trip rescans per UI frame.
3. Connectivity plugin listeners in Phase 3.

## 12. Performance and Limits

1. Per trigger unresolved scan cap: default 20 events.
2. Candidate list cap per event: top 3 surfaced to UI.
3. Resolver provider timeout budget: fixed 1500 ms per call.
4. Resolver calls should be cancellable if event becomes locked before apply.

## 13. Error Handling

1. Provider errors do not block capture.
2. Provider errors retain event in unresolved state.
3. Error details are stored in `resolver_attempt_journal`.
4. UI shows non-blocking retry affordance.

## 14. Data Integrity Rules

1. Every media row must map to an existing event row.
2. Every event row must map to an existing session row.
3. `manual_lock = 1` requires non-null `decision_source`.
4. `place_bound` requires `place_bind_name` or `place_bind_id`.
5. `geotag_final` requires non-null `geotag_final_reason`.
6. `start_request_seq` is monotonic per session and must not change during retry of the same start attempt.

## 15. Migration Strategy

1. Introduce V2 tables in additive migration.
2. Start writing only new sessions to V2 tables behind feature flag.
3. Keep legacy tables read-only during transition.
4. No destructive drop until V2 commit/publish lanes are fully deployed and soaked.

## 16. Observability

Required local metrics:

1. `resolver_attempt_count` by trigger and result.
2. `resolver_auto_bind_count`.
3. `resolver_review_required_count`.
4. `resolver_locked_skip_count`.
5. `unresolved_inbox_size` by trip.

Required log markers:

1. `resolver_attempt_started`
2. `resolver_attempt_completed`
3. `resolver_state_transition`
4. `resolver_skipped_locked`

## 17. Acceptance Criteria

This subsystem is ready only when:

1. Capture writes are instant and independent of network.
2. Resolver never overwrites manual-locked decisions.
3. Live and Editor show the same unresolved queue for the same trip.
4. Candidate acceptance/manual/geotag actions transition states correctly.
5. No background polling flood exists for unresolved processing.

## 18. Locked Decisions

1. Resolver states are domain truth only:
  1. `geotag_unresolved`
  2. `review_required`
  3. `place_bound`
  4. `geotag_final`
2. Route/on-route is compiler bucket output, not resolver state.
3. ORS direct provider and thresholds in Section 9 are fixed for V2 baseline.

