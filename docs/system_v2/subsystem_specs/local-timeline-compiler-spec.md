# Local Timeline Compiler Spec (V2)

Status: Draft for implementation lock
Version: v2.0
Last updated: 2026-04-10
Owner: Flutter timeline/editor team

## 1. Purpose

This spec defines the on-device timeline compiler for Live System V2.

It covers:

1. Compiler input contracts from local journal.
2. Deterministic compile rules.
3. Local projection output tables consumed by Live and Editor UI.
4. Incremental invalidation and recompute behavior.
5. Consistency guarantees between resolver decisions and timeline rendering.

## 2. References

1. Master blueprint: [Master Blueprint](./master-blueprint.md)
2. Input source contracts: [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
3. Commit state semantics: [Session Commit Worker Spec](./session-commit-worker-spec.md)
4. Subsystem index: [Subsystem Specs Index](./README.md)
5. System index: [System V2 Index](../README.md)

## 3. Depends On

1. Event/media/route/resolver tables and lock semantics from local-journal spec.
2. Commit status states for UI chips from commit-worker spec.

## 4. Used By

1. Live screen timeline strip/recent captures.
2. Editor storyline timeline.
3. Local map overlays for route and event/media pins.
4. Trip publish payload composer.

## 5. Design Goals

1. Timeline generation must be local, deterministic, and fast.
2. Compile must not require server data while editing.
3. Manual decisions must be reflected immediately and never regressed by automation.
4. Incremental recompute should avoid full-trip recompilation on small changes.
5. Output schema should be UI-ready with minimal transform logic in widgets.

## 6. Compiler Inputs

Compiler reads from local canonical journal tables.

Required inputs:

1. `session_journal`
2. `event_journal`
3. `media_journal`
4. `route_point_journal`
5. `resolver_candidate_journal` (for optional UI hint context)
6. commit status from `session_commit_job` and related media states

## 7. Compiler Output Tables

### 7.1 `timeline_projection_local`

One row per timeline entry rendered in Live/Editor storyline.

Columns:

1. `entry_id` TEXT PRIMARY KEY
2. `trip_local_id` TEXT NOT NULL
3. `session_id` TEXT NOT NULL
4. `source_kind` TEXT NOT NULL
- enum: `event`, `media`
5. `source_id` TEXT NOT NULL
6. `event_type` TEXT NOT NULL
7. `captured_at` DATETIME NOT NULL
8. `bucket_type` TEXT NOT NULL
- enum: `place`, `on_route`, `needs_review`
9. `place_bind_name` TEXT NULL
10. `place_bind_id` TEXT NULL
11. `decision_source` TEXT NULL
12. `manual_lock` INTEGER NOT NULL
13. `title` TEXT NOT NULL
14. `subtitle` TEXT NULL
15. `anchor_latitude` REAL NOT NULL
16. `anchor_longitude` REAL NOT NULL
17. `route_segment_key` TEXT NULL
18. `route_distance_m` REAL NULL
19. `sync_chip_state` TEXT NOT NULL
- enum: `local_only`, `commit_pending`, `committing`, `committed`, `commit_failed_retryable`
20. `render_payload_json` TEXT NULL
21. `compiled_at` DATETIME NOT NULL
22. `compiler_version` INTEGER NOT NULL

Indexes:

1. `(trip_local_id, captured_at DESC)`
2. `(trip_local_id, bucket_type, captured_at DESC)`
3. `(trip_local_id, source_kind, source_id)` UNIQUE

### 7.2 `route_projection_local`

Local route geometry segments for map and route context.

Columns:

1. `segment_key` TEXT PRIMARY KEY
2. `trip_local_id` TEXT NOT NULL
3. `session_id` TEXT NOT NULL
4. `started_at` DATETIME NOT NULL
5. `ended_at` DATETIME NOT NULL
6. `points_count` INTEGER NOT NULL
7. `distance_m` REAL NOT NULL
8. `geometry_polyline` TEXT NOT NULL
9. `compiled_at` DATETIME NOT NULL
10. `compiler_version` INTEGER NOT NULL

Indexes:

1. `(trip_local_id, started_at)`
2. `(session_id, started_at)`

### 7.3 `timeline_compile_cursor`

Tracks incremental compile position and dirty windows.

Columns:

1. `trip_local_id` TEXT PRIMARY KEY
2. `last_compiled_at` DATETIME NOT NULL
3. `last_event_seq` INTEGER NOT NULL
4. `last_point_seq` INTEGER NOT NULL
5. `dirty_from_ts` DATETIME NULL
6. `dirty_reason` TEXT NULL
7. `compiler_version` INTEGER NOT NULL

## 8. Deterministic Compile Rules

### 8.1 Ordering

1. Primary sort: `captured_at` ascending for compilation, descending for top-of-feed UI.
2. Tie-breaker: stable source sequence (`event_seq`, then `media_id` deterministic order).
3. Compiler must be stable across runs with identical input.

### 8.2 Bucket mapping

Bucket is derived from `event_journal.resolver_state` and lock state.

1. `place_bound` -> `bucket_type = place`
2. `geotag_final` -> `bucket_type = on_route`
3. `review_required` -> `bucket_type = needs_review`
4. `geotag_unresolved` -> `bucket_type = needs_review`
5. `geotag_final_reason` is propagated into `render_payload_json` for UI copy.

### 8.3 Decision precedence

1. Manual-locked rows are always applied as final truth.
2. Non-locked rows use latest resolver state.
3. Compiler does not mutate source rows.

### 8.4 Media binding

1. Media entry inherits event resolution state and place binding unless explicit media override exists.
2. Missing media file does not remove timeline row; row remains with warning payload.

### 8.5 Sync chip mapping

Derived from session commit job state:

1. no job and local session active -> `local_only`
2. sealed with pending job -> `commit_pending`
3. job running -> `committing`
4. job success -> `committed`
5. job retryable failure -> `commit_failed_retryable`

## 9. Route Association Rules

Route association is for display context, not source mutation.

1. Build route segments from `route_point_journal` grouped by session continuity.
2. For `on_route` entries, compute nearest segment and store:
- `route_segment_key`
- `route_distance_m`
3. If no segment within threshold, keep null route association and still render as on-route.

## 10. Compile Triggers

Allowed triggers:

1. Event inserted/updated.
2. Media inserted/updated.
3. Resolver state transition.
4. Manual review decision action.
5. Route point append or route window seal.
6. Session commit state change.
7. App start recovery and explicit rebuild action.

Forbidden:

1. Continuous polling loops for timeline rebuild.
2. Full-trip recompute on every small state change when incremental path is possible.

## 11. Incremental Invalidation Strategy

1. Any write to source tables marks `timeline_compile_cursor.dirty_from_ts`.
2. Compiler recomputes only affected window from `dirty_from_ts` forward.
3. Full recompute is allowed only when:
- compiler version changes,
- cursor corruption detected,
- user/developer explicit rebuild action.

## 12. UI Consumption Contract

### 12.1 Live screen

1. Uses recent entries from `timeline_projection_local` limited by recency count.
2. Uses `needs_review` bucket count for unresolved indicator.
3. Must not call remote compiled projection for runtime timeline.

### 12.2 Editor screen

1. Uses grouped timeline from `timeline_projection_local` by day/session.
2. Uses unresolved inbox for action widgets.
3. Uses `route_projection_local` for map route overlay.

## 13. Performance Targets

1. Incremental compile under 100 ms for single event state change on mid-range device.
2. Full session compile under 1.5 s for typical day session dataset.
3. No dropped frame in primary interactions due to compile execution on UI thread.

Implementation notes:

1. Run compile work on background isolate where needed.
2. Batch DB writes in transactions.

## 14. Integrity Rules

1. Projection rows are derived artifacts and can be rebuilt at any time.
2. Projection row must map to existing source row (`source_kind`, `source_id`).
3. Manual-lock decisions must be reflected with no downgrade in bucket state.
4. Compiler must be idempotent: repeated run with unchanged input produces identical semantic output.

## 15. Observability

Required counters:

1. `timeline_compile_runs_total`
2. `timeline_compile_incremental_runs`
3. `timeline_compile_full_runs`
4. `timeline_compile_duration_ms`
5. `timeline_projection_row_count`
6. `timeline_compile_errors_total`

Required logs:

1. `timeline_compile_started`
2. `timeline_compile_completed`
3. `timeline_compile_incremental_window`
4. `timeline_compile_full_rebuild`

## 16. Migration and Cutover

1. Introduce projection tables in additive migration.
2. Enable local compiler for V2 sessions first.
3. Keep legacy projection paths off for V2 sessions to avoid dual source ambiguity.
4. After soak, remove V1 dependency paths from live/editor timeline rendering.

## 17. Acceptance Criteria

This subsystem is complete only when:

1. Live and editor timelines render from local projection without server dependency.
2. Manual decision changes appear in timeline immediately.
3. Incremental compile works without full rebuild storms.
4. Commit state chips reflect session commit worker state correctly.
5. Route association metadata is stable and non-destructive.

## 18. Open Decisions

1. Final route segment association threshold by movement mode.
2. UI grouping policy for multi-session same-day merges.
3. Maximum recent strip entry count for live screen.
4. Compiler versioning and rollback policy.

