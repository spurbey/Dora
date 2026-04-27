# Canonical Data Model

## Scope

This document defines the canonical storage contract in Flutter for media and story drafts.

- Schema owner: Drift database (`schemaVersion = 24`)
- Canonical migration boundary: `from < 23` and `from < 24` in `flutter/lib/core/storage/drift_database.dart`

## Canonical tables

## `media` (single media identity table)

File: `flutter/lib/core/storage/tables/media_table.dart`

Key columns:

- Identity: `id`, `serverId`, `ownerUserId`
- Classification: `mediaType` (`photo|video`), `originScope` (`editor|live_capture|vault`)
- Local artifacts: `localUri`, `thumbnailLocalPath`, `mimeType`, `bytesSize`, `durationMs`, `contentHash`
- Remote artifacts: `remoteUrl`, `remoteThumbnailUrl`, `uploadedAt`
- Geo/time: `capturedAt`, `latitude`, `longitude`, `accuracyM`
- Upload lifecycle: `uploadState`, `uploadProgress`, `retryCount`, `nextAttemptAt`, `workerSessionId`, `errorMessage`
- Sync markers: `syncStatus`, `localUpdatedAt`, `serverUpdatedAt`, `deletedAt`

Indexes:

- `(owner_user_id, captured_at)` for Vault listing
- `(upload_state, next_attempt_at)` for worker claims
- `(origin_scope, captured_at)` for lane-scoped queries
- `(latitude, longitude)` for map/filter support

## `media_attachments` (polymorphic links)

File: `flutter/lib/core/storage/tables/media_attachments_table.dart`

Purpose: One media row can attach to multiple targets and roles.

Key columns:

- Link: `mediaId`, `targetKind`, `targetLocalId`, `targetServerId`
- Semantics: `role` (`review|capture|...`), `source` (`user|place_resolution|...`)
- Lifecycle: `attachedAt`, `detachedAt`

Current target kinds used in production code:

- `place` (editor reviews, resolver-local place mirror)
- `trip_event` (live capture event binding)
- `trip` (trip context marker for live capture)

Uniqueness:

- Partial unique index created in migration (`media_id,target_kind,target_local_id,role` where `detached_at IS NULL`)

## `stories` (local story draft + publish status)

File: `flutter/lib/core/storage/tables/stories_table.dart`

Purpose: Local publishing state for camera story intent and Vault story management.

Key columns:

- Identity: `id` (local/client id), `serverId`, `mediaId`, `authorUserId`
- Geo/time: `centerLat`, `centerLng`, `publishedAt`, `expiresAt`
- Visibility/status: `visibility`
- Publish metadata (`v24`): `publishAttemptCount`, `lastErrorCode`, `lastErrorMessage`, `publishRequestedAt`, `lastPublishAttemptAt`, `serverDeletedAt`

Local status values in use:

- `draft`, `publishing`, `published`, `failed`, `expired`, `deleted`, `moderation_hidden`

## Storage lanes and attachments

## Lane A: Editor place review

- Creates canonical `media` row (`originScope = editor`)
- Adds `media_attachments`:
  - `place/review`
  - `trip/review`
- Publish enqueue selects place-review attachments only

Code:

- `flutter/lib/features/create/data/media_repository.dart`

## Lane B: Live tracking capture

- Creates `event_journal` row
- Creates canonical `media` row (`originScope = live_capture`)
- Adds `media_attachments`:
  - `trip_event/capture`
  - `trip/capture`
- Resolver can add `place/review` mirror only when bound to `trip_place_local`

Code:

- `flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart`
- `flutter/lib/features/live_tracking/v2/resolver/v2_resolver_orchestrator.dart`

## Lane C: Camera FAB without active session

- Creates canonical `media` row (`originScope = vault`)
- No attachment required
- Optional local story draft row references the same `mediaId`

Code:

- `flutter/lib/features/capture/domain/capture_orchestrator.dart`

## Upload state contract

Implemented in `media_dao.dart` and `upload_queue_worker.dart`.

Observed states:

- `local_only`
- `queued`
- `compressing`
- `uploading`
- `uploaded`
- `deferred`
- `failed`
- `blocked`
- `canceled`

Critical rule:

- Queue worker requires a `place + review` attachment. Any other attachment set is invalid for this worker and gets blocked.

Code:

- `flutter/lib/core/media/upload_queue_worker.dart` (`_requirePlaceAttachment`)

## Migration history

## Drift v23

`from < 23`:

- Drops legacy `media` and `media_journal`
- Creates canonical `media`, `media_attachments`, local `stories`
- Recreates indexes

## Drift v24

`from < 24`:

- Adds stories publish metadata columns:
  - `publish_attempt_count`
  - `last_error_code`
  - `last_error_message`
  - `publish_requested_at`
  - `last_publish_attempt_at`
  - `server_deleted_at`

## Known constraints

1. Drift tables do not enforce FK cascades between `media` and `media_attachments`/`stories`. Cleanup is handled by repository/DAO logic.
2. Any change to status strings must be applied consistently across:
   - Drift table defaults and DAO writes
   - Backend model/service enums (for server-facing story status)
   - UI label mapping and filter logic

