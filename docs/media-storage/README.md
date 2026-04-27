# Media Storage System

This folder is the source of truth for Dora's unified media stack:

- Canonical media storage (`media`, `media_attachments`, local `stories`)
- Camera runtime and capture orchestration
- Vault product surface (map, carousel, story drafts)
- Stories publish/feed backend and Flutter client behavior

Use this docs set before changing any media, camera, vault, or stories code.

## Why this exists

The app has three media lanes that must stay compatible:

1. Editor place reviews
2. Live tracking captures
3. Camera FAB captures (Vault + Story intent)

The canonical model lets all lanes share one media identity while preserving different publish paths.

## Current lane map

| Lane | Local write path | Publish path | Core files |
| --- | --- | --- | --- |
| Editor place review | Canonical `media` + `media_attachments` (`place/review`) | Media queue worker to `/api/v1/media/upload` | `flutter/lib/features/create/data/media_repository.dart`, `flutter/lib/core/media/upload_queue_worker.dart` |
| Live tracking capture | `event_journal` + canonical `media` + `media_attachments` (`trip_event/capture`, `trip/capture`) | V2 session commit lane (not media queue) | `flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart`, `flutter/lib/features/live_tracking/v2/commit/*` |
| Camera FAB capture | `CaptureOrchestrator` writes to live lane if active session, otherwise canonical vault row | Story intent publishes directly to stories API, Vault stays local | `flutter/lib/features/capture/domain/capture_orchestrator.dart`, `flutter/lib/features/stories/presentation/providers/stories_providers.dart` |

## Read order

1. [canonical-data-model.md](./canonical-data-model.md)
2. [camera-runtime-and-orchestration.md](./camera-runtime-and-orchestration.md)
3. [custom-gallery-picker-architecture.md](./custom-gallery-picker-architecture.md)
4. [vault-product-surface.md](./vault-product-surface.md)
5. [stories-publish-backend-client.md](./stories-publish-backend-client.md)
6. [stories-viewing-performance-execution-spec.md](./stories-viewing-performance-execution-spec.md)
7. [stories-performance-implementation-tracker.md](./stories-performance-implementation-tracker.md)
8. [contributor-playbook.md](./contributor-playbook.md)

## Non-negotiable invariants

1. Canonical `media` is the only media identity table in Flutter.
2. Upload queue worker is place-review specific. Do not enqueue live-capture media into it.
3. Story publish is a direct stories API call, not the media upload queue.
4. Active-session capture must persist live event/media first; story publish is additive and must not roll back live persistence.
5. Generated artifacts are never hand-edited (`flutter/packages/dora_api/**`, Drift `.g.dart`).

## Fast navigation map

- Drift schema/migrations: `flutter/lib/core/storage/drift_database.dart`
- Canonical tables: `flutter/lib/core/storage/tables/media_table.dart`, `flutter/lib/core/storage/tables/media_attachments_table.dart`, `flutter/lib/core/storage/tables/stories_table.dart`
- Core DAOs: `flutter/lib/core/storage/daos/media_dao.dart`, `flutter/lib/core/storage/daos/media_attachments_dao.dart`, `flutter/lib/core/storage/daos/stories_dao.dart`
- Camera runtime: `flutter/lib/features/capture/presentation/screens/camera_runtime_screen.dart`
- Capture orchestrator: `flutter/lib/features/capture/domain/capture_orchestrator.dart`
- Vault UI: `flutter/lib/features/vault/presentation/screens/vault_screen.dart`
- Stories backend: `backend/app/api/v1/stories.py`, `backend/app/services/story_service.py`, `backend/app/models/story.py`
- Stories retention worker: `backend/app/workers/story_retention_worker.py`
