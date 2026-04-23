# Stories Publish: Backend and Client Contract

## Scope

This document defines Dora's Stories MVP contract across backend and Flutter client.

Core backend files:

- `backend/app/models/story.py`
- `backend/app/services/story_service.py`
- `backend/app/api/v1/stories.py`
- `backend/app/workers/story_retention_worker.py`
- Migration: `backend/alembic/versions/e3c5a8d1b9f0_add_stories_tables_and_moderation_support.py`

Core Flutter files:

- API wrapper: `flutter/lib/features/stories/data/stories_api.dart`
- Models: `flutter/lib/features/stories/data/models/story_models.dart`
- Controllers/providers: `flutter/lib/features/stories/presentation/providers/stories_providers.dart`
- Feed strip/viewer:
  - `flutter/lib/features/stories/presentation/widgets/stories_strip.dart`
  - `flutter/lib/features/stories/presentation/screens/story_viewer_screen.dart`
- Feed integration: `flutter/lib/features/feed/presentation/screens/feed_screen.dart`

## Backend model contract

`stories` status values:

- `draft`
- `publishing`
- `published`
- `failed`
- `expired`
- `deleted`
- `moderation_hidden`

Associated moderation/safety tables:

- `story_author_mutes`
- `story_reports`

Key backend policy:

- `client_story_id` is a forever idempotency key per author.
- `moderation_hidden` is excluded from normal feed/list visibility.

## Backend endpoints

Base: `/api/v1/stories`

1. `POST /publish`
2. `GET /feed`
3. `GET /{story_id}`
4. `DELETE /{story_id}`
5. `POST /{story_id}/report`
6. `POST /authors/{author_id}/mute`
7. `POST /{story_id}/view`
8. `POST /{story_id}/moderation-hide` (moderator allow-list only)

## Publish validation and limits

From `story_service.py`:

- Media type: `photo|video` only
- MIME allow-lists:
  - photos: `image/jpeg|image/png|image/webp|image/heic`
  - videos: `video/mp4|video/quicktime|video/x-m4v`
- Size caps:
  - photo <= `10MB`
  - video <= `100MB`
- Video max duration: `<= 60s`
- Location is required and validated in API layer (`lat/lng` range checks)

Storage path policy:

- Bucket: `stories`
- Object key: `{user_id}/{story_id}.{ext}`
- Thumb object key: `{user_id}/{story_id}_thumb.jpg` (metadata/path tracked)

## Feed semantics

Filtering:

- Base feed includes active `published` rows (`expires_at > now`, not deleted)
- Mute table removes muted authors
- Client default radius is `all` (stories strip starts unbounded for testing/always-on behavior)
- Radius filter:
  - `1|5|25` uses viewer lat/lng distance filtering
  - `all` disables geo filtering

Ordering:

1. Own stories first
2. Then latest `published_at` (time-only ordering)

Pagination:

- Cursor is offset string

## Viewer behavior (Flutter)

Defaults in `story_viewer_screen.dart`:

- Photo auto-advance: 5 seconds
- Video autoplay muted
- Tap middle toggles mute for video
- Long-press pauses
- Tap left/right navigates previous/next

Actions:

- Hide story: local suppression (`SharedPreferences` store)
- Mute author: server call + immediate feed removal
- Report story: server call

## Local publish lifecycle (Flutter)

`StoryPublishController` flow:

1. Load local draft row and linked media row
2. Validate local media path exists
3. `markPublishing()`
4. Call stories publish API
5. On success: `markPublished(serverId, publishedAt, expiresAt)`
6. On failure: `markFailed(errorCode, errorMessage)`

Delete behavior:

- Remote-backed rows (`published|expired|moderation_hidden|deleted` with `serverId`) call server `DELETE`, then local `markDeleted`.
- Pure local rows are deleted locally.

## Camera and Vault integration

Capture runtime integration:

- Destination `storyDraft` creates local draft row in orchestrator.
- Runtime triggers best-effort publish asynchronously after local persist.
- Publish failure does not roll back local media or live event attachment.

Vault integration:

- Vault story cards show status + error.
- Users can retry failed/draft stories and delete published/expired stories.

## Retention policy

From `StoryService.run_retention_cleanup()`:

- TTL: 24h (`STORY_TTL_HOURS`)
- Purge grace: 24h after expiry (`STORY_PURGE_GRACE_HOURS`)
- Minimum DB retention: 30 days (`STORY_ROW_RETENTION_DAYS`)

Worker:

- `backend/app/workers/story_retention_worker.py` polls every 300s
- Performs:
  - mark `published -> expired`
  - purge storage objects for eligible expired rows
  - hard-delete old rows after retention window (expired/deleted/moderation_hidden and media already purged)

## Availability

- Stories publish and feed are treated as core product surfaces (no runtime UI gating by story feature flags).
- Camera destination chooser always includes `Share as Story`.
- Feed always renders the stories strip.
