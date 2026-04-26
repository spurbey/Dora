# Stories Viewing Performance Execution Spec (Free-Plan First)

## Summary

This document is the implementation source of truth for improving Stories viewing smoothness and reducing backend load, targeting Instagram-like behavior within Supabase Free plan constraints.

This is decision-complete for implementation in phased delivery:

- P0: high-impact UX and load fixes
- P1: canonical media delivery and query-path hardening
- P2: scale-up and Pro-plan optimization path

Contract-level behavior for Stories endpoints and local publish flow remains in:

- `docs/media-storage/stories-publish-backend-client.md`

Performance and scale execution decisions live here.

## Implementation Status Snapshot (as of 2026-04-27)

1. P0: implemented.
2. P1: implemented.
3. P2: not started.

Implementation tracker and file-level change map:

- [`stories-performance-implementation-tracker.md`](./stories-performance-implementation-tracker.md)

Locked implementation notes from delivered P1:

1. Feed cursor is hard-cutover keyset (no dual-read compatibility window).
2. Legacy numeric cursor is rejected with `400 Invalid cursor`.
3. P1 did not add new media response fields; wire shape remained stable.

## Problem Statement

Current behavior introduces visible lag and unnecessary load:

- Viewer initializes media per item without preloading, causing delayed first-frame and transition stutter.
- Photo rendering can fetch heavier media when a lightweight preview-first path is needed.
- Story views are incremented per open without viewer dedupe, inflating counts and adding write pressure.
- Feed query path filters/sorts too much data outside the DB, increasing API latency variance.
- Delivery/cache behavior is not yet formalized around immutable paths and stable cache keys.

## Goals, Non-Goals, and Success Criteria

### Goals

1. Make story playback feel immediate and smooth on real mobile networks.
2. Reduce backend read/write pressure from story feed and view recording.
3. Keep implementation compatible with Supabase Free plan first.
4. Define a clean upgrade path to Pro-only optimizations without redesign.

### Non-Goals

1. Replacing the Stories product contract or lane architecture.
2. Building full ABR/HLS streaming in P0.
3. Migrating all media surfaces (outside Stories) in this effort.

### Measurable Success Criteria

1. Viewer UX latency
- Cold open first frame (story media visible): `<= 800 ms` on good network, `<= 1500 ms` on moderate network.
- Next-story transition to visible frame: `<= 250 ms` median.
- Re-open of recently viewed story in same session: `<= 120 ms` median.

2. Media delivery efficiency
- Story playback image payload target: `<= 350 KB` median.
- Story playback video payload target for short clips: `<= 2.5 MB` median.
- Repeat view cache-hit behavior improves versus current baseline (tracked by response headers and client timing).

3. Backend load
- View write amplification reduced by idempotent view receipts (`1 viewer x 1 story = 1 counted view`).
- Feed endpoint P95 latency improves after DB-side filtering/pagination migration.

4. Correctness
- Mute/hide/report semantics unchanged.
- Expiry/retention behavior unchanged.
- Story count integrity preserved across retries and reopens.

## Final Architecture Decisions

### 1. Viewer Pipeline (Flutter)

1. Preload current + next story media:
- Photo: prefetch preview and playback URL for current and next story.
- Video: initialize current controller immediately, warm next controller in background.

2. Render order:
- Show preview asset first (`thumbnail` or `poster`) for immediate paint.
- Swap to playback asset when ready.

3. Progress UX:
- Replace list-level progress with segmented per-story progress.
- Segment fill is tied to each story's actual play duration.

4. Transition guarantees:
- Next/prev tap should never block on network init if prefetched asset is ready.
- If next asset is not ready, preview must still render instantly and playback must start as soon as initialized.

### 2. Upload Pipeline (Client-Side Compression Before Upload)

1. Photo upload variant:
- Resize long edge to target playback envelope.
- Compress to JPEG/WebP target quality configured per lane.

2. Video upload variant:
- Re-encode to bounded resolution/bitrate and max duration policy.
- Preserve source capture locally; upload optimized variant for stories publish.

3. Local-first invariant remains:
- Capture persists locally first.
- Upload/processing failures do not drop local rows.

### 3. Backend View Path (Idempotent Receipts + Aggregation)

1. Add a dedicated `story_views` receipt table:
- Unique constraint: `(story_id, viewer_user_id)`.
- Records first valid view only.

2. View counting contract:
- `POST /api/v1/stories/{story_id}/view` becomes idempotent per viewer/story.
- Repeated calls return success without incrementing `view_count`.

3. Counter update model:
- P0: synchronous upsert + conditional increment within transaction.
- P1: optional async aggregation worker if write pressure remains high.

### 4. Feed Query and Pagination Contract

1. Replace offset cursor semantics with keyset cursor:
- Stable ordering keys: `published_at DESC, id DESC`.

2. Cursor shape:
- Opaque base64url-encoded payload containing `published_at` and `id`.

3. Query behavior:
- Enforce DB-side ordering and keyset windowing.
- Move filter-heavy logic from in-memory path toward SQL path.

### 5. Delivery and Cache Strategy (Supabase Free-Compatible)

1. Object path policy:
- Immutable, versioned paths for playback assets.
- No overwrite-in-place for active story assets.

2. Cache policy:
- Strong `cacheControl` for immutable story objects.
- Avoid URL churn that creates distinct cache keys without content change.

3. Signed/public URL policy:
- Prefer cache-stable URL usage through story lifetime.
- Avoid minting new signed URL on every single view request.

### 6. Media Metadata Contract

Stories API response must support explicit delivery roles:

1. `preview_image_url` (fast first paint)
2. `playback_media_url` (primary playback asset)
3. `poster_url` (video fallback/preview)
4. Existing fields may be kept temporarily during migration for compatibility.

## Public APIs / Interfaces / Types (Implementation Contract)

### A. Backend Data Model Additions

1. New table: `story_views`
- `id` UUID PK
- `story_id` UUID FK -> `stories.id`
- `viewer_user_id` UUID FK -> `users.id`
- `created_at` timestamp
- Unique: `uq_story_views_story_viewer (story_id, viewer_user_id)`
- Index: `idx_story_views_story_created (story_id, created_at)`

2. `stories` table compatibility updates
- Keep `view_count` as materialized counter.
- Preserve existing retention/lifecycle fields.

### B. Endpoint Contract Adjustments

1. `POST /api/v1/stories/{story_id}/view`
- Request: unchanged.
- Behavior: idempotent per `(story_id, viewer_user_id)`.
- Response: include `view_recorded: bool` (true only when new receipt inserted), plus story payload.

2. `GET /api/v1/stories/feed`
- Cursor migrates from offset string to opaque keyset cursor.
- During transition window, accept legacy offset cursor and emit keyset cursor in response.

### C. Story Response Media Fields

Introduce explicit fields in wire model:

1. `preview_image_url: string | null`
2. `playback_media_url: string | null`
3. `poster_url: string | null`
4. `cache_ttl_hint_seconds: int | null` (optional client hint)

### D. Client Viewer Behavior Contract

1. Preload minimum:
- Preload index `i` and `i+1`.

2. Fallback chain:
- For video: `poster_url` -> `preview_image_url` -> placeholder.
- For photo: `preview_image_url` -> `playback_media_url` -> placeholder.

3. Timing:
- Photo segment duration default remains configurable (baseline 5s).
- Video segment duration uses actual duration when available, else bounded fallback.

## Phase Plan (P0 / P1 / P2)

### P0 (1 week): Immediate UX + Load Wins

Owners:

- Flutter: story viewer preload, segmented progress, preview-first rendering
- Backend: idempotent view receipts (sync upsert path), compatibility response changes
- Infra/App config: cache policy and stable URL usage rules

Tasks:

1. Flutter viewer preload and preview-first render.
2. Segmented progress bar with per-story timing.
3. Client-side photo/video compression on story publish path.
4. Add `story_views` model + migration + idempotent `view` endpoint behavior.
5. Add/align media metadata fields for preview/playback/poster.
6. Enforce stable object path and cache-control conventions in publish path.

P0 acceptance criteria:

1. Next-story transition median `<= 250 ms` on test dataset.
2. Repeated opens by same viewer do not increase `view_count`.
3. No regressions in hide/mute/report/delete/retention behavior.

### P1 (2-3 weeks): Query and Delivery Hardening

Owners:

- Backend: feed keyset pagination and DB-side filtering migration
- Flutter/API: cursor compatibility handling and viewer contract cleanup

Tasks:

1. Implement keyset cursor read path and phased offset deprecation.
2. Move remaining feed sorting/filtering logic to SQL path where feasible.
3. Tighten media field usage in client (prefer explicit preview/playback fields only).
4. Add richer latency/load instrumentation.

P1 acceptance criteria:

1. Feed P95 latency improvement versus P0 baseline.
2. Cursor stability under insertions/deletions between pages.
3. No duplicate/missing rows across pagination windows.

### P2 (Scale-Up / Optional Pro Path)

Owners:

- Backend/infra: background aggregation + optional Pro-tier cache optimizations

Tasks:

1. Optional async counter aggregation if sync path becomes write bottleneck.
2. Optional Pro plan adoption for Smart CDN-centric improvements.
3. Expand media derivative strategy across additional surfaces when needed.

P2 acceptance criteria:

1. Sustained load profile remains stable at target concurrency.
2. Cache hit ratio and egress profile improve measurably after Pro-path rollout.

## Test and Validation Matrix

| Area | Scenario | Pass Criteria |
| --- | --- | --- |
| Viewer latency | Cold story open on good/moderate network | First frame within defined SLOs |
| Viewer transitions | Rapid next/prev across mixed photo/video stories | Transition median `<= 250 ms`, no blank frame flashes |
| Re-open behavior | Open same story set twice in session | Re-open median `<= 120 ms` |
| Delivery efficiency | Compare payload sizes before/after compression | Payload targets met for photos/videos |
| Cache behavior | Repeat requests for same URLs | Higher cache-hit pattern and lower repeated origin fetch latency |
| View dedupe | Call view endpoint repeatedly as same user | Only first call increments count |
| Feed correctness | Paginate while new stories are inserted | No duplicates, no skipped eligible stories |
| Functional regression | hide/mute/report/delete + retention worker | Behavior unchanged from contract |
| Cross-lane regression | camera capture -> story publish -> vault consistency | Local-first persistence preserved |
| Low network | Packet loss/high latency simulation | Preview-first render still immediate, graceful degradation |

## Rollout and Observability

1. Rollout order:
- Backend idempotent view path first (safe), then Flutter viewer improvements, then keyset pagination migration.

2. Instrumentation requirements:
- Client timing: first-frame, transition latency, re-open latency.
- Backend timing: feed P50/P95/P99, view endpoint latency.
- Counters: view receipts inserted, idempotent skips, feed cursor decode errors.

3. Safeguards:
- Keep backward-compatible response fields during migration window.
- Feature-flag keyset cursor enforcement until client support is verified.

## Risks and Mitigations

1. Risk: Migration complexity for cursor contract.
- Mitigation: dual-read cursor handling window and explicit deprecation cutoff.

2. Risk: Device-specific compression artifacts/perf cost.
- Mitigation: bounded presets and QA matrix across low/mid/high-tier devices.

3. Risk: Signed URL churn reducing CDN effectiveness.
- Mitigation: cache-stable URL strategy per story lifetime and explicit policy checks.

4. Risk: Regressions in existing stories moderation/report flows.
- Mitigation: endpoint regression suite gating before rollout.

## Free Plan Now vs Pro Upgrade Later

### Free-Plan Baseline (Required)

1. Use Supabase CDN fundamentals with cache-stable URLs and strong cache-control.
2. Do not assume Smart CDN features.
3. Rely on client preload + compression + backend dedupe for primary gains.

### Pro-Plan Upgrade Path (Optional)

1. Enable Smart CDN-aware strategy improvements after baseline is stable.
2. Reassess signed URL and cache strategy for maximum edge revalidation benefit.
3. Expand derivative and transformation strategy where cost/benefit is positive.

## Implementation Checklist

1. Add schema migration(s) for `story_views` and related indexes/constraints.
2. Update stories API schemas/contracts for media metadata and view response flag.
3. Implement viewer preload + segmented progress + preview-first rendering.
4. Implement client compression path in story publish flow.
5. Implement keyset feed pagination path with compatibility window.
6. Add/extend backend + Flutter tests per matrix above.
7. Add telemetry and dashboards for latency/load verification.
