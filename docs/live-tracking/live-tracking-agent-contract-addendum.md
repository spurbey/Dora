# Live Tracking Agent Contract Addendum (P2-P3)

Date: 2026-03-31  
Status: Active execution contract  
Applies to: resolver baseline, compiler/projection baseline, media lane activation, advisory in-app pipeline

## 1. Purpose

This addendum closes execution ambiguity for multi-agent implementation of the remaining hard slices.

Use this as the implementation contract for:
1. Deterministic resolver behavior.
2. Idempotent compiler/projection behavior.
3. Media lane activation sequencing.
4. Advisory local-first action and delivery semantics.

## 2. Precedence

When docs conflict, precedence is:
1. This addendum (`live-tracking-agent-contract-addendum.md`) for P2-P3 execution details.
2. `docs/live-tracking-unified-system-architecture-plan.md` for system architecture and phase gates.
3. `flutter/docs/live-capture-screen-implementation-spec.md` for Flutter screen/state behavior.
4. Legacy execution trackers for historical evidence only.

## 3. Non-Negotiable Invariants

1. Session lifecycle commands (`start/pause/resume/stop`) are write-through command-plane operations.
2. Capture data (`tracking_events`, point batches, future media payloads, advisory actions) is local-first data-plane.
3. No destructive rewrite of source capture rows is allowed during compile or sync.
4. Local IDs are canonical on device; remote IDs are mappings.
5. Tracking lifecycle does not drive `trip.status` as runtime truth.
6. Manual user edits always win over automatic inference/projection.

## 4. Resolver Contract (Deterministic)

## 4.1 Required Inputs
1. `trip_id`, `session_id`, `event_type`, `lat`, `lng`, `captured_at`.
2. Optional context: note text, media metadata, last resolved anchors for same trip.

## 4.2 Resolution Order (Must Not Change)
1. Existing trip place within `50m`.
2. Previous resolved anchor for same trip within `80m`.
3. Reverse geocode within `100m`.
4. Nearby POI lookup within `150m`.
5. Fallback: `on_route_unresolved`.

## 4.3 Output Fields (Required)
1. `resolved_place_id` (nullable).
2. `bind_confidence` (`0.0..1.0`).
3. `resolver_reason_code` (machine-readable string).
4. `resolver_version` (for replay/debug).

## 4.4 Decision Thresholds
1. `auto_bind` if `score >= 0.75`.
2. `review_required` if `0.45 <= score < 0.75`.
3. `unresolved` if `score < 0.45`.

## 5. Compiler / Projection Contract

## 5.1 Source of Truth
1. Raw source rows are `tracking_events` and tracking path batches.
2. Compiler writes projection artifacts only.
3. Compiler must never mutate raw source rows except explicit compile metadata fields.

## 5.2 Determinism Rules
1. Projection output for same input snapshot must be byte-equivalent (or semantically equivalent) across reruns.
2. Ordering key is `(captured_at, id)`; never rely on insertion order.
3. Compiler rerun is idempotent: no duplicate projection entries for same source event.
4. Recompile after resolver changes must update projection mapping without data loss.

## 5.3 Override Rules
1. If user manually rebinds/reorders in editor, compiler must preserve override.
2. Auto-recompile cannot overwrite manual override unless explicit user reset.
3. Override provenance must be persisted (`source=manual` / `source=auto`).

## 5.4 Failure Rules
1. Compile failures are retryable and must not block capture writes.
2. Projection drift metric must be emitted when raw/projection counts diverge beyond threshold.

## 6. Media Lane Activation Contract

## 6.1 Activation Gate
Media capture/upload remains gated until all are true:
1. Resolver output fields are persisted and stable.
2. Upload contract for media without mandatory pre-bound place is finalized.
3. Dependency model for `event -> media -> projection` is implemented and tested.

## 6.2 Media Lifecycle FSM
1. `gated_local_only` (current)
2. `pending_upload`
3. `uploaded_remote`
4. `linked_to_event`
5. `failed_retryable`
6. `blocked_validation`

## 6.3 Dependency Rules
1. `tracking_event` can sync without media.
2. Media task depends on event identity mapping.
3. Linking to compiled/editor surface depends on resolver state + upload success.
4. Retryable transport failures must keep local media pointer and user-visible pending state.

## 7. Advisory Pipeline Contract (In-App First)

## 7.1 Local Model Requirements
1. Advisory rows must include `advisory_id`, `trip_id`, `category`, `severity`, `confidence`, `dedupe_key`, window timestamps.
2. In-app inbox is mandatory even when push is suppressed/unavailable.

## 7.2 Dedupe + Cooldown
1. Dedupe key baseline: `(canonical_place_id, normalized_fact, time_bucket)`.
2. Lower-confidence duplicates are collapsed under higher-confidence entry.
3. Cooldown windows prevent repetitive advisory spam in same context.

## 7.3 Action Semantics
Supported actions:
1. `dismiss`
2. `save`
3. `view`
4. `convert_to_event` (future-safe hook)

Rules:
1. Actions are local-first and queued for sync.
2. Action replay must be idempotent.
3. Action sync failure cannot erase local user intent.

## 8. Agent PR Boundaries (Execution Discipline)

1. One PR should own one hard concern: resolver OR compiler OR media lane OR advisory lane.
2. Do not combine schema migration + broad UI refactor + worker rewrites in one PR.
3. Any schema change must include:
   - migration
   - DAO/repository wiring
   - migration test
4. Any sync semantics change must include:
   - worker tests
   - retry/dependency tests
   - blocked vs retryable classification tests

## 9. Mandatory Acceptance Gates

Before marking a hard slice complete:
1. Focused tests for the slice pass.
2. Existing live-tracking regression suite remains green.
3. No new permanent-block loops introduced.
4. Docs updated in same PR:
   - `docs/live-tracking-unified-system-architecture-plan.md`
   - `flutter/docs/live-capture-screen-implementation-spec.md`
   - this addendum (if contract changed)

## 10. Out of Scope in This Addendum

1. External source scraping infrastructure implementation details.
2. Final UI polish/theming decisions beyond contract requirements.
3. Full rollout policy beyond existing phase gates.
