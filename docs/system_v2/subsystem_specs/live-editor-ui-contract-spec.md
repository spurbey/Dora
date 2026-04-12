# Live and Editor UI Contract Spec (V2)

Status: Draft for implementation lock
Version: v2.2
Last updated: 2026-04-12
Owner: Flutter UI/runtime team

## 1. Purpose

This spec defines V2 UI behavior for Live and Editor.

It covers:

1. shared unresolved review lane,
2. local-first timeline visibility,
3. stop/commit/publish status semantics,
4. publish-only upload success ownership.

## 2. References

1. [Master Blueprint](./master-blueprint.md)
2. [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
3. [Local Timeline Compiler Spec](./local-timeline-compiler-spec.md)
4. [Session Commit Worker Spec](./session-commit-worker-spec.md)
5. [Trip Publish Spec](./trip-publish-spec.md)

## 3. UX Principles

1. local-first visibility,
2. shared unresolved source for live/editor,
3. geotag is valid state, not error,
4. manual decisions are final,
5. stop does not mean uploaded.

## 4. Shared Unresolved Inbox

1. source is computed local provider from `event_journal + resolver_candidate_journal`.
2. not a persisted inbox table.
3. live shows informational panel with `Review in editor` CTA.
4. editor owns actions: `Accept`, `Add place manually`, `Geo-Tag`.
5. manual add cancel/dismiss defaults to `Geo-Tag` with `manual_add_cancelled`.

## 5. Live Screen Contract

### Responsibilities

1. map + local route context,
2. capture actions,
3. unresolved informational panel,
4. local session status feedback.

### Status chips

1. runtime chip: `Active`, `Paused`, `Stopped`.
2. session-staging chip:
   - `Local only`
   - `Saved locally`
   - `Needs local retry` (if staging failed)
3. publish chip (optional compact):
   - `Not published`
   - `Publishing`
   - `Publish failed - retry`
   - `Published`

Rule: do not show upload-success semantics from stop/staging lane.

## 6. Editor Screen Contract

1. timeline and route come from local V2 projection.
2. unresolved review queue is actionable.
3. publish CTA and status come from `trip_publish_job`.
4. publish failure must preserve local timeline/editing state.

### Entry chips

1. `Needs place confirmation`
2. `Bound to <Place>`
3. `Geotag (On Route)`
4. `Saved locally`
5. `Not published`
6. `Publishing`
7. `Publish failed - retry`
8. `Published`

## 7. Navigation Contract

1. live `Review in editor` opens editor scoped to unresolved queue.
2. manual place flow in editor and live deep-link return share one reducer path.
3. duplicate navigation stacking is prevented with event-scoped token.

## 8. Copy Rules

1. avoid legacy `sync blocked` wording for V2 lane.
2. use explicit local/publish wording:
   - `Saved locally. Upload on publish.`
   - `Publish failed. Retry required.`

## 9. Telemetry

1. `ui_unresolved_panel_opened`
2. `ui_review_action_applied`
3. `ui_publish_clicked`
4. `ui_publish_retry_clicked`
5. `ui_publish_completed`
6. `ui_publish_failed`

## 10. Acceptance Criteria

1. live/editor unresolved queues remain consistent,
2. manual decisions are never auto-overwritten,
3. stop/staging never shown as uploaded success,
4. publish state is clear and actionable,
5. local timeline remains visible under all publish outcomes.
