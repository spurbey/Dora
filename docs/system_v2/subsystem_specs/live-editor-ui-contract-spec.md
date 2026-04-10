# Live and Editor UI Contract Spec (V2)

Status: Draft for implementation lock
Version: v2.0
Last updated: 2026-04-10
Owner: Flutter UI/runtime team

## 1. Purpose

This spec defines the UI behavior contract for Live and Editor in System V2.

It covers:

1. Shared unresolved review experience.
2. Live screen interaction model.
3. Editor screen interaction model.
4. State chips and messaging semantics.
5. Navigation contracts between live/editor/manual place flows.

## 2. References

1. Master blueprint: [Master Blueprint](./master-blueprint.md)
2. Local source of truth: [Local Journal and Resolver Spec](./local-journal-and-resolver-spec.md)
3. Local timeline rendering: [Local Timeline Compiler Spec](./local-timeline-compiler-spec.md)
4. Commit state source: [Session Commit Worker Spec](./session-commit-worker-spec.md)
5. Publish state source: [Trip Publish Spec](./trip-publish-spec.md)
6. Subsystem index: [Subsystem Specs Index](./README.md)
7. System index: [System V2 Index](../README.md)

## 3. Depends On

1. Shared unresolved inbox data contract.
2. Resolver state and manual-lock semantics.
3. Local timeline projection output.
4. Session commit state transitions.

## 4. Used By

1. Live capture screen runtime UX.
2. Editor timeline and place review UX.
3. QA acceptance scripts and regression suites.

## 5. UX Principles

1. Local-first visibility: captured items appear immediately.
2. Single-source review: unresolved items come from one inbox source in both screens.
3. No false error language: `on-route`/geotag outcomes are valid, not failures.
4. Manual intent is respected and persistent.
5. Progress feedback is explicit and actionable.

## 6. Shared Unresolved Inbox UI Contract

### 6.1 Source

1. Both Live and Editor consume unresolved items from the same computed local source (`unresolved_inbox` provider/query).
2. `unresolved_inbox` is derived from `event_journal + resolver_candidate_journal` and is not a persisted table.

### 6.2 Placement

1. Live: top-right unresolved panel (compact stack/list).
2. Editor: top section panel or sticky section above timeline list.

### 6.3 Item format

Each unresolved card includes:

1. Event type icon and label.
2. Captured timestamp.
3. Candidate list (max 3 surfaced) with `Accept` per candidate.
4. `Add place manually` button.
5. `Geo-Tag` button.

### 6.4 Actions

1. `Accept` -> sets place-bound state + manual lock.
2. `Add place manually` -> deep-links to place picker/create flow.
3. `Geo-Tag` -> sets geotag resolved route state + manual lock.
4. If manual add is dismissed/cancelled -> default to `Geo-Tag`.

### 6.5 Priority order

1. `review_required` first.
2. `geotag_unresolved` second.
3. Newest first inside priority group.

## 7. Live Screen Contract

### 7.1 Core responsibilities

1. Show map and real-time local route context.
2. Provide capture actions (photo/media/note/warn/tag).
3. Show unresolved review panel.
4. Show session commit status.

### 7.2 Capture behavior

1. Capture success updates recent strip immediately from local projection.
2. No server dependency for capture success feedback.
3. Missing location for location-required capture shows clear local fail-fast message.

### 7.3 Live status chips

1. Session runtime chip: `Active`, `Paused`, `Stopped`.
2. Commit chip from session commit job:
- `Local only`
- `Commit pending`
- `Uploading`
- `Upload failed - retry`
- `Committed`

### 7.4 Review panel behavior

1. Panel must be non-blocking.
2. User can continue capturing while unresolved items exist.
3. Panel count indicator should reflect unresolved queue size.

## 8. Editor Screen Contract

### 8.1 Core responsibilities

1. Render timeline from local timeline projection.
2. Render unresolved review panel from shared inbox.
3. Allow manual place add and timeline-focused review operations.
4. Allow explicit trip publish/save action.

### 8.2 Timeline sections

1. Place-bound section.
2. On-route section.
3. Needs review section.

### 8.3 Entry chips

Each entry can surface:

1. `Needs place confirmation`
2. `Bound to <Place>`
3. `Geotag (On Route)`
4. `Commit pending`
5. `Committed`
6. `Upload failed - retry`

### 8.4 Publish UX

1. Publish button state from `trip_publish_job`.
2. Publish errors do not remove local timeline visibility.
3. Retry affordance is explicit and non-destructive.

## 9. Navigation Contracts

### 9.1 Live -> Editor manual add

1. Trigger: user taps `Add place manually` in live unresolved card.
2. App opens editor place picker/create flow scoped to target event.
3. On selection, returns selection and applies manual place decision with lock.
4. On cancel/dismiss, applies `Geo-Tag` default behavior.

### 9.2 Editor internal manual add

1. Same action semantics as live deep-link return path.
2. One shared reducer/action handler for manual decisions.

### 9.3 Duplication prevention

1. Repeated navigation taps must not stack duplicate screens.
2. Use event-scoped navigation token to ensure idempotent action handling.

## 10. Copy and Severity Rules

1. `review_required` => warning/informational action needed.
2. `geotag_final` => neutral valid state, not error.
3. Commit retryable failure => actionable warning with retry CTA.
4. Do not use broad “sync blocked” wording from legacy model.

## 11. Interaction State Matrix

### 11.1 Resolver states to UI

1. `geotag_unresolved` -> unresolved card + needs review badge.
2. `review_required` -> unresolved card with candidate options.
3. `place_bound` -> bound badge and place bucket.
4. `geotag_final` -> on-route badge and route bucket.

### 11.2 Commit states to UI

1. `commit_pending` -> pending badge.
2. `committing` -> progress badge + optional progress details.
3. `commit_failed_retryable` -> retry badge and action.
4. `committed` -> synced badge.

## 12. Performance Contract

1. Unresolved panel open/close should not block map interactions.
2. Candidate action response should update UI state within one frame after DB commit cycle.
3. Timeline scroll and map pan must remain smooth while compile updates occur.

## 13. Accessibility Contract

1. All action buttons must have semantic labels and role hints.
2. State chips must not depend on color alone.
3. Time and place labels must support large text modes.
4. Critical retry actions must be keyboard/switch accessible.

## 14. Telemetry

Required UI metrics:

1. `ui_unresolved_panel_opened`
2. `ui_candidate_accept_clicked`
3. `ui_manual_place_clicked`
4. `ui_geotag_clicked`
5. `ui_commit_retry_clicked`
6. `ui_publish_clicked`
7. `ui_publish_retry_clicked`

Required UI logs:

1. `ui_review_action_applied`
2. `ui_review_action_failed`
3. `ui_navigation_manual_place_opened`
4. `ui_navigation_manual_place_returned`

## 15. Migration and Rollout

1. Enable V2 UI contract only for V2 sessions/trips via feature flag.
2. Keep legacy UI paths isolated for V1 sessions until cutover completes.
3. Remove legacy sync wording and widgets only after V2 full rollout.

## 16. Acceptance Criteria

This UI contract is complete only when:

1. Live and editor show consistent unresolved items and decisions.
2. Manual decisions are reflected instantly and never reverted.
3. Geotag outcomes are shown as valid non-error states.
4. Commit and publish states are clear, bounded, and actionable.
5. Navigation between live unresolved action and editor manual place flow is deterministic.

## 17. Open Decisions

1. Final visual style and density for top-right live unresolved panel.
2. Maximum unresolved cards shown before collapsing into “See all”.
3. Whether candidate actions should include optional “Undo” window.
4. Exact copy style guide for status chips across locales.


