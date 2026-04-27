**Findings (ordered by severity)**

1. **High: Stash is incomplete; required new files are missing, causing immediate dependency break.**  
   The stash modifies imports/providers to use new types, but those files are not present in the stash payload.
   - Imports expecting missing files: [drift_database.dart:10](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/drift_database.dart:10), [drift_database.dart:15](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/drift_database.dart:15), [drift_database.dart:30](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/drift_database.dart:30), [drift_database.dart:35](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/drift_database.dart:35), [database_provider.dart:3](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/database_provider.dart:3), [database_provider.dart:5](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/database_provider.dart:5).
   - Missing files referenced include `media_attachments_dao.dart`, `stories_dao.dart`, `media_attachments_table.dart`, `stories_table.dart`.
   - This will fail at compile time (`URI not found` / undefined classes).

2. **High: Publish path queues trip-event media, but upload worker only accepts place-review attachments.**  
   - Trip publish enqueue path includes `trip_event` attachments: [media_repository.dart:178](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/media_repository.dart:178), [media_repository.dart:192](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/media_repository.dart:192), and is called from publish flow: [trips_repository.dart:424](C:/Users/sumit/Downloads/Dora/flutter/lib/features/trips/data/trips_repository.dart:424).  
   - Worker hard-requires `targetKind == 'place' && role == 'review'`: [upload_queue_worker.dart:344](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart:344), [upload_queue_worker.dart:349](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart:349).  
   - If missing, it blocks media: [upload_queue_worker.dart:208](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart:208), [upload_queue_worker.dart:219](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart:219).  
   - Net effect: live-capture media without resolved place attachment gets pushed into `blocked`.

3. **Medium: Live-capture media type mapping is logically incorrect.**  
   - Mapping uses `wireType == 'video' ? 'video' : 'photo'`: [live_capture_journal_repository.dart:172](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart:172).  
   - But `_eventTypeWireName()` returns `note|warn|tag|photo|media` (never `video`): [live_capture_journal_repository.dart:287](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart:287), [live_capture_journal_repository.dart:297](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart:297).  
   - So `LiveTrackingEventType.media` is persisted as `photo`, which can break downstream behavior/labels.

4. **Medium: Generated DB file was updated for new schema, but source table/dao files are missing.**  
   - `drift_database.g.dart` references `mediaAttachments`/`stories`, but the corresponding source Dart files are absent in stash. This is a direct source-generation dependency mismatch.

**Notes**
- I could not run `flutter analyze` on the stashed state because I couldn’t create an isolated apply workspace (permission errors creating worktree/clone in this environment).  
- The findings above are from static patch review of `stash@{0}` and are enough to block merge.

**Recommended immediate fix order**
1. Recreate/add missing table/DAO files and stash with untracked files (`git stash push -u`) or commit them directly.  
2. Fix enqueue/worker contract: either enqueue only place-review media for this worker, or teach worker to handle `trip_event` media path.  
3. Fix live-capture `mediaType` mapping for `LiveTrackingEventType.media`.





**Findings (logic/dependency mismatches)**

1. **Critical: trip publish can queue media that the worker can never upload, then strand it.**  
   - Publish queue selects `trip`/`trip_event` attachments in `local_only` state ([media_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/media_repository.dart#L165), [media_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/media_repository.dart#L178)).  
   - Live capture always creates `trip_event` + `trip` `capture` attachments ([live_capture_journal_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart#L189), [live_capture_journal_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart#L201)).  
   - Worker requires a **place+review** attachment and blocks if missing ([upload_queue_worker.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart#L344), [upload_queue_worker.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart#L219)).  
   - Once blocked, next publish won’t re-enqueue it because query only picks `local_only` ([media_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/media_repository.dart#L186)).  

2. **Critical: resolver mirrors provider POI IDs into `media_attachments.target_local_id`, but uploader expects local place IDs.**  
   - Auto/accept resolver sets `placeBindKind='provider_poi'` and uses `providerPlaceId` ([v2_resolver_decision_reducer.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/resolver/v2_resolver_decision_reducer.dart#L43), [v2_resolver_orchestrator.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/resolver/v2_resolver_orchestrator.dart#L107)).  
   - That value is mirrored into attachment `target_local_id` ([v2_resolver_orchestrator.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/resolver/v2_resolver_orchestrator.dart#L499)).  
   - Upload path resolves remote place from **local place id**; unknown id throws ([place_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/place_repository.dart#L132), [place_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/place_repository.dart#L386)).  

3. **High: no FK/cascade enforcement for canonical relations; hard delete can leave orphans.**  
   - `media_attachments`/`stories` tables define no FK to `media` ([media_attachments_table.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/tables/media_attachments_table.dart#L12), [stories_table.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/core/storage/tables/stories_table.dart#L16)).  
   - `removeMedia` hard-deletes media row only ([media_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/media_repository.dart#L278)).  

4. **Medium: stale state branch in timeline compiler.**  
   - UI subtitle checks `staged_for_commit` ([v2_local_timeline_compiler.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/compiler/v2_local_timeline_compiler.dart#L919)), but no writer sets this state in canonical flow.

5. **Medium: video metadata path is inconsistent.**  
   - `createMediaCaptureNow` only sets `mediaType='video'` if wire type is `'video'`, but event mapping returns `'media'`/`'photo'` ([live_capture_journal_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart#L172), [live_capture_journal_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart#L287)).  
   - MIME fallback in worker is image-only defaulting to jpeg ([upload_queue_worker.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart#L448)).

---

**What is implemented (confirmed in stash-pop state)**

- Canonical `media` table + new `media_attachments` + `stories` are in code and wired into Drift v23 migration.  
- Old `media_journal` table/DAO/repository are removed from runtime use.  
- Live capture now writes canonical media + attachments.  
- Resolver mirrors place bindings into attachments.  
- Create/export/trips/timeline queries were switched to canonical joins.

---

**Plan sanity check**

- The future phase plan (Nav/FAB/Vault, then camera plugin, then Stories backend) is directionally aligned with your earlier decisions.  
- Before Phase 1 UI, fix Findings #1 and #2 first, otherwise trip-capture media upload behavior will be unreliable even if UI is perfect.





1. **High: Vault captures are stored with transient picker paths, so media can disappear later.**  
   - In `_writeVault`, the code writes `localUri: picked.file.path` directly without copying to app-managed storage ([camera_capture_controller.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/capture/presentation/providers/camera_capture_controller.dart#L242)).  
   - Editor flow already protects against this by copying files before persisting. Vault flow currently does not.

2. **High: Video capture from FAB conflicts with existing live-capture media typing.**  
   - FAB sends video as `LiveTrackingEventType.media` ([camera_capture_controller.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/capture/presentation/providers/camera_capture_controller.dart#L189)).  
   - Live capture repository sets `mediaType` to `video` only when wire type is `'video'`, but `_eventTypeWireName` returns `'media'` for that branch ([live_capture_journal_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart#L172), [live_capture_journal_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/data/live_capture_journal_repository.dart#L287)).  
   - Result: trip-attached videos are persisted as photo-type rows.

3. **Medium: Vault marker cache invalidation is inconsistent and leaks stale entries.**  
   - Cache keys are `id|path` ([vault_marker_provider.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/vault/presentation/providers/vault_marker_provider.dart#L93)).  
   - On media removal, invalidation is called with just `id` ([vault_marker_provider.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/vault/presentation/providers/vault_marker_provider.dart#L75)).  
   - `state.bytesById` is never pruned for removed ids, so stale byte blobs remain in memory ([vault_marker_provider.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/vault/presentation/providers/vault_marker_provider.dart#L73)).

4. **Critical dependency still unresolved (from previous review), and this commit now depends on it.**  
   - Publish queue includes trip/trip_event media ([media_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/media_repository.dart#L188)).  
   - Worker hard-requires a place-review attachment and blocks otherwise ([upload_queue_worker.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart#L344), [upload_queue_worker.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/core/media/upload_queue_worker.dart#L219)).  
   - Resolver writes provider POI ids into place attachments ([v2_resolver_decision_reducer.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/resolver/v2_resolver_decision_reducer.dart#L43), [v2_resolver_orchestrator.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/live_tracking/v2/resolver/v2_resolver_orchestrator.dart#L521)), while upload-side place resolution expects local place ids ([place_repository.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/create/data/place_repository.dart#L132)).  
   - Net effect: FAB/live captures can still hit blocked upload paths later.

5. **Low: `currentUserIdProvider` is non-reactive.**  
   - It reads `Supabase.instance.client.auth.currentUser` directly without subscribing to auth state ([vault_provider.dart](C:/Users/sumit/Downloads/Dora/flutter/lib/features/vault/presentation/providers/vault_provider.dart#L12)).  
   - Vault data refresh on auth transitions may rely on unrelated rebuilds.

Assumptions:
- I reviewed only code/logic in the latest commit and related dependency paths.
- I did not run `flutter analyze` or tests, per your instruction.

Implementation summary:
- NAV/FAB/Vault architecture is wired as intended (center FAB, `/vault` fullscreen route, Profile sub-tab entry, map+filter+carousel composition).  
- Main risk is that media pipeline dependencies underneath this UI remain inconsistent, so user-visible Vault/capture flows can still fail later in upload/sync lifecycle.