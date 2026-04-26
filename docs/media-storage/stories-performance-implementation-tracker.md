# Stories Performance Implementation Tracker

## Purpose

This document tracks what has actually been implemented for Stories performance, which decisions were locked, and which files changed in each phase.

Use this with:

- `stories-viewing-performance-execution-spec.md` (strategy/spec)
- `stories-publish-backend-client.md` (current product contract)

## Snapshot (as of 2026-04-27)

1. P0 is implemented and validated.
2. P1 is implemented and validated.
3. P2 is not started.

Primary implementation commits:

- `6516f6c` (P0)
- `f2352bd` (P1)

## Decision Log

### P0 locked decisions (implemented)

1. Viewer smoothness in existing screen only:
- Preload current + next media.
- Preview-first rendering for photos (`thumbnail_url` before `media_url`).
- Warm one next video controller.
- Segmented per-story progress.
- Session-level viewed-id dedupe to avoid repeated `markViewed` spam.

2. Story publish compression:
- Reuse existing `ImageCompressor`.
- Compress photo stories before publish.
- Keep video compression out of P0.
- Cleanup temporary compressed files on success/failure paths.

3. Backend view write-load reduction:
- Add `story_views` receipt table with unique `(story_id, viewer_user_id)`.
- Make view counting idempotent per viewer/story.

4. Storage/cache tuning:
- Add optional `cache_control_seconds` to storage upload method.
- Apply stronger cache control from stories publish path only.

### P1 locked decisions (implemented)

1. Feed pagination hard cutover:
- Replace offset cursor with opaque keyset cursor.
- Numeric legacy cursor is rejected with `400 Invalid cursor`.
- No dual-read compatibility window.

2. Feed read-path hardening:
- Keep business filters in SQL.
- SQL ordering with own-first tier + `published_at DESC, id DESC`.
- Geo strategy: SQL bbox prefilter + Python exact haversine filter.
- Batch scan loop: `max(3 * limit, 60)` until `limit + 1` valid rows.

3. API surface stability:
- Keep `/api/v1/stories/feed` response shape unchanged (`stories`, `next_cursor`).
- Do not add new story media fields in P1.
- No Flutter UI pagination changes in P1.

## File Change Map by Phase

### P0 changed files

Backend:

- `backend/app/models/story.py`
- `backend/app/models/__init__.py`
- `backend/alembic/versions/c4d1e7b9a2f5_add_story_views_table.py`
- `backend/app/services/story_service.py`
- `backend/app/services/storage_service.py`
- `backend/tests/test_stories_endpoints.py`

Flutter:

- `flutter/lib/features/stories/presentation/screens/story_viewer_screen.dart`
- `flutter/lib/features/stories/presentation/providers/stories_providers.dart`
- `flutter/test/features/stories/story_publish_controller_test.dart`

### P1 changed files

Backend:

- `backend/app/services/story_service.py`
- `backend/alembic/versions/d8b7c6a5e4f3_add_stories_feed_keyset_index.py`
- `backend/tests/test_stories_endpoints.py`

No Flutter files changed in P1.

## Validation Log

### P0 validation

1. `flutter analyze` on changed Stories files: clean.
2. `flutter test test/features/stories/story_publish_controller_test.dart`: pass.
3. `pytest tests/test_stories_endpoints.py -q`: pass after test environment dependency alignment.

### P1 validation

1. `pytest tests/test_stories_endpoints.py -q`: pass (`11 passed`).
2. Added coverage for:
- opaque keyset cursor emission
- no duplicate/gap across pagination pages
- legacy numeric cursor rejection
- insert-between-pages continuity behavior

3. Migration/index checks:
- feed index migration applied and active
- Alembic heads reconciled to a single head during implementation

4. Performance evidence:
- Synthetic rollback benchmark showed reduced feed-path latency and lower unnecessary scanning work in new path versus old offset path.

## Current Runtime Contract Notes

1. `/api/v1/stories/feed` cursor is now opaque keyset.
2. Clients must treat cursor as opaque.
3. Numeric offset cursor is no longer accepted.
4. P0/P1 do not add new media response fields (`preview/playback/poster` still deferred).

## Next Pending Work (P2)

1. Optional async view-count aggregation if write pressure requires it.
2. Optional video transcode/compression scale-up if metrics show need.
3. Optional Pro-plan CDN optimizations after Free-plan baseline is exhausted.
