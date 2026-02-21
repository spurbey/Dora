# FLUTTER PHASE 5 PRD: MEDIA INGESTION, QUEUE, AND PLACE GALLERY

Last Updated: 2026-02-21  
Owner: TBD  
Status: Ready for implementation handoff

---

## 1. Goal

Build a reliable place-media pipeline in Flutter so users can:

- Select or capture photos from editor context.
- See local thumbnails immediately.
- Upload in background with retry/resume behavior.
- Recover cleanly from app restarts, network loss, and API failures.

This phase must preserve all stable Phase 4 editor and route behaviors.

---

## 2. Reality Snapshot (Current Codebase)

This PRD is aligned to current repository state (not generic docs):

- Drift `schemaVersion` is now `8` (v6 -> v7 media/place mapping, v7 -> v8 trip mapping) in `flutter/lib/core/storage/drift_database.dart`.
- `Media` table and `MediaDao` contain queue/upload fields and worker helpers.
- Media upload provider/repository/screen wiring exists in Flutter and is under hardening.
- `mediaApiProvider` exists in `flutter/lib/core/network/api_providers.dart`.
- Media upload navigation route exists in `flutter/lib/core/navigation/routes.dart` and `flutter/lib/core/navigation/app_router.dart`.
- Place detail now supports local-first media previews and queue status overlays.
- Backend upload contract exists via generated OpenAPI client:
  - `MediaApi.uploadMediaApiV1MediaUploadPost(...)`
  - file path: `flutter/packages/dora_api/lib/src/api/media_api.dart`

Important identity constraint:

- Backend media upload requires `trip_place_id` (backend place UUID).
- Current local place IDs are not guaranteed to be backend IDs (e.g., search result IDs).
- This must be solved before queue/upload implementation.

---

## 3. Non-Negotiable Guardrails

1. No direct plugin/API calls from widgets to upload endpoints.
2. Persist first, upload second. Never fire-and-forget uploads.
3. Keep plugin/vendor imports in `core/**` adapters/services.
4. Preserve `Place.photoUrls` compatibility until migration is complete.
5. Do not regress Phase 4C route/map/editor flow.
6. Do not change map abstraction contracts in `features/**`.

---

## 4. Pre-Phase Contract Freeze (Stop-the-Line)

Before coding, freeze these decisions in writing.

### 4.1 Place Identity Contract (Required)

Problem:

- Upload API needs backend `trip_place_id`.
- Local place rows may not have a backend UUID.

Decision for Phase 5:

- Add `serverPlaceId` to local place storage/model.
- Add `serverTripId` to local trip storage/model.
- Add repository method `ensureRemoteTripId(localTripId)`:
  - If `serverTripId` exists, return it.
  - Else create trip via `TripsApi.createTripApiV1TripsPost(...)`.
  - Persist `serverTripId` locally.
  - Return `serverTripId`.
- Add repository method `ensureRemotePlaceId(localPlaceId)`:
  - If `serverPlaceId` exists, return it.
  - Resolve backend trip ID first (`ensureRemoteTripId(localTripId)`).
  - Else create place via `PlacesApi.createPlaceApiV1PlacesPost(...)`.
  - Persist `serverPlaceId` locally.
  - Return `serverPlaceId`.
- Upload queue worker must call `ensureRemotePlaceId` before upload.

### 4.2 Schema Versioning (Required)

- Migration target is `v6 -> v7`; add `v7 -> v8` when enabling trip identity mapping.
- Any doc/spec still saying `v5 -> v6` must be treated as outdated.

### 4.3 Queue Idempotency (Required)

- A queue item may only be uploaded once.
- Worker must claim tasks atomically (single runner semantics).
- Connectivity/lifecycle/background triggers must not create duplicate in-flight uploads.

### 4.4 Background Behavior Contract (Required)

- iOS background execution is best-effort.
- Product promise: "uploads resume automatically" (not guaranteed complete while fully backgrounded).

### 4.5 Phase 4 Baseline Contract (Required)

- Before Phase 5 Step 1, align Phase 4C route-creation expectations with current UX behavior.
- Baseline must explicitly cover:
  - route creation/edit flow
  - editor selection and map interaction flow
  - timeline interactions used by route creation
- If baseline behavior is unclear or failing, fix/lock Phase 4 first and then start Phase 5.

---

## 5. Scope

### In Scope

- Photo ingest from gallery/camera (max 10 per session).
- Compression + thumbnail generation.
- Persistent upload queue in Drift.
- Retry/backoff and resume across restart/network restore.
- Place detail integration for queue states and uploaded media.
- Compatibility bridge for `Place.photoUrls`.

### Out of Scope

- Video upload.
- Full media gallery redesign for public trip detail tabs.
- New sync/conflict engine beyond media and place-identity binding needed for upload.

---

## 6. Architecture Alignment

Source docs to follow:

- `flutter/docs/architecture.md`
- `flutter/docs/rules.md`
- `flutter/docs/screens/screen1-6.md` (Screen 5 editor context)
- `flutter/docs/screens/screen6-12.md` (Screen 9 media upload flow)

Practical implementation rule:

- `features/**` may depend on providers/repositories only.
- `core/media/**` handles plugin + preprocessing + adapter details.

---

## 7. Technical Design

### 7.1 Data Model Changes

#### Place storage/model

Update:

- `flutter/lib/core/storage/tables/places_table.dart`
- `flutter/lib/features/create/domain/place.dart`
- `flutter/lib/features/create/data/place_repository.dart`

Add:

- `serverPlaceId` (nullable text/string UUID)

Purpose:

- Store remote place UUID used by media upload API.

#### Trip storage/model

Update:

- `flutter/lib/core/storage/tables/trips_table.dart`
- `flutter/lib/features/create/domain/trip.dart`
- `flutter/lib/features/create/data/trip_repository.dart`

Add:

- `serverTripId` (nullable text/string UUID)

Purpose:

- Store remote trip UUID used to create backend places for media upload.

#### Media storage/model

Update:

- `flutter/lib/core/storage/tables/media_table.dart`
- `flutter/lib/core/storage/daos/media_dao.dart`
- `flutter/lib/core/storage/drift_database.dart`

Add queue and upload metadata:

- `thumbnailPath` (nullable local path)
- `mimeType` (nullable)
- `fileSizeBytes` (nullable)
- `width`, `height` (nullable)
- `uploadStatus` (`queued | compressing | uploading | uploaded | failed | canceled`)
- `uploadProgress` (`0.0..1.0`)
- `retryCount` (int)
- `errorMessage` (nullable)
- `uploadedAt` (nullable)
- `nextAttemptAt` (nullable; retry scheduling)
- `workerSessionId` (nullable; task claim lock)

Migration:

- Drift `schemaVersion: 6 -> 7` (media/place mapping)
- Drift `schemaVersion: 7 -> 8` (trip mapping, if enabled)
- Backfill:
  - if `url` exists: `uploadStatus=uploaded`, `uploadProgress=1.0`
  - else: `uploadStatus=queued`, `uploadProgress=0.0`

### 7.2 Core Media Layer

Create:

- `flutter/lib/core/media/app_media_uploader.dart`
- `flutter/lib/core/media/adapters/dora_media_uploader.dart`
- `flutter/lib/core/media/image_compressor.dart`
- `flutter/lib/core/media/thumbnail_generator.dart`
- `flutter/lib/core/media/media_permissions.dart`
- `flutter/lib/core/media/upload_queue_worker.dart`
- `flutter/lib/core/media/models/queued_media_task.dart`

Responsibilities:

- Permission checks and settings redirect.
- Compression (target bounds/quality).
- Thumbnail generation for immediate UI preview.
- OpenAPI upload adapter using `MediaApi.uploadMediaApiV1MediaUploadPost`.
- Queue worker orchestration and retries.

### 7.3 Repository + Providers

Create:

- `flutter/lib/features/create/data/media_repository.dart`
- `flutter/lib/features/create/presentation/providers/media_upload_provider.dart`
- `flutter/lib/features/create/presentation/providers/place_media_provider.dart`

Update:

- `flutter/lib/core/network/api_providers.dart` add `mediaApiProvider`
- `flutter/lib/features/create/data/place_repository.dart` add `ensureRemotePlaceId(...)`

Repository contract:

- `enqueueSelectedAssets(...)`
- `watchPlaceMedia(placeId)`
- `startQueue()`
- `retryUpload(mediaId)`
- `cancelUpload(mediaId)`
- `removeMedia(mediaId)`
- On successful upload, update `Place.photoUrls` compatibility list.

### 7.4 UI and Navigation

Create:

- `flutter/lib/features/create/presentation/screens/media_upload_screen.dart`
- `flutter/lib/features/create/presentation/widgets/photo_grid_item.dart`
- `flutter/lib/features/create/presentation/widgets/selected_photo_chip.dart`
- `flutter/lib/features/create/presentation/widgets/upload_queue_item.dart`

Update:

- `flutter/lib/core/navigation/routes.dart`
- `flutter/lib/core/navigation/app_router.dart`
- `flutter/lib/features/create/presentation/widgets/place_detail_form.dart`
- `flutter/lib/features/create/presentation/widgets/floating_tool_panel.dart`
- `flutter/lib/features/create/presentation/widgets/bottom_detail_panel.dart`

Navigation contract (explicit):

- Add media screen path pattern: `/trips/:tripId/places/:placeId/media`.
- Add helper: `Routes.mediaUploadPath(String tripId, String placeId)`.
- Route params are required and non-null:
  - `tripId` (editor trip context)
  - `placeId` (local place row ID used for queue record)
- Media upload screen must receive both params and resolve backend ID via `ensureRemotePlaceId(placeId)` before API upload.

UX rules:

- Enforce max selection `10`.
- Show selected strip, queue status, retry/remove actions.
- Returning to editor must not cancel queue work.

### 7.5 Queue Worker Bootstrap Contract

Add explicit bootstrap wiring:

- Create `flutter/lib/core/media/media_queue_bootstrap.dart` (or equivalent provider module).
- Bootstrap must start once per app process and guard against double-init.
- Hook bootstrap from app root after DB init:
  - update `flutter/lib/app.dart` to watch the bootstrap provider.
- Worker triggers are centralized in bootstrap:
  - app foreground/resume
  - connectivity restore
  - optional periodic/background task hook
- UI screens must never start independent worker loops.

---

## 8. Execution Plan

### Phase A: Contract + Foundations

- Freeze upload API request/response handling.
- Freeze place/trip identity mapping (`serverPlaceId` + `serverTripId` + `ensureRemotePlaceId` + `ensureRemoteTripId`).
- Add route wiring and provider stubs.

Exit gate:

- Clear written decision for identity mapping and queue idempotency.

### Phase B: Storage + Migration + DAO

- Implement `v6 -> v7` migration (media/place).
- Implement `v7 -> v8` migration (trip identity).
- Add media queue columns and DAO query helpers.
- Add `serverPlaceId` to place table/model/repository mapping.
- Add `serverTripId` to trip table/model/repository mapping.

Exit gate:

- Fresh create + migration from v6 verified.

### Phase C: Media Services + Repository

- Implement compression, thumbnail, permissions, adapter.
- Implement `media_repository` with enqueue-first persistence.
- Implement `ensureRemotePlaceId` flow and error handling.

Exit gate:

- Local enqueue works and media rows are created before upload.

### Phase D: Queue Worker + Retry/Resume

- Implement worker claim/lock semantics.
- Add retry/backoff (max 3).
- Trigger worker on app resume + connectivity restore.

Exit gate:

- No duplicate upload for same row under repeated triggers.

### Phase E: UI Integration

- Build media upload screen and widgets.
- Wire from place detail and editor context.
- Add place media provider live updates.

Exit gate:

- User sees local thumbnails immediately and final remote media after upload.

### Phase F: Hardening + Regression

- Validate failure states (permission/network/compression/API).
- Validate Phase 4 route/editor behavior still stable.
- Document deferred risks.

Exit gate:

- No critical defects, no data-loss scenarios.

---

## 9. Test Strategy

### Unit tests

Create:

- `test/core/media/upload_queue_worker_test.dart`
- `test/features/create/media/media_repository_test.dart`
- Compression/thumbnail service tests
- Place identity binding tests (`ensureRemotePlaceId`)

### Provider/widget tests

Create:

- `test/features/create/media/media_upload_provider_test.dart`
- `test/features/create/media/place_media_provider_test.dart`
- `test/features/create/media/media_upload_screen_test.dart`

### Manual scenarios

1. Online happy path (3-5 images).
2. Offline enqueue -> reconnect -> upload resumes.
3. App kill during upload -> restart -> resume.
4. API 4xx failure -> failed state + actionable message.
5. API 5xx/network failure -> retry behavior.
6. Duplicate trigger safety (resume/connectivity/manual start).
7. Max 10 selection enforced.
8. Existing Phase 4 place/route/editor interactions unaffected.

---

## 10. Risks and Mitigations

### Risk: Backend place ID mismatch blocks media upload

Mitigation:

- `ensureRemotePlaceId` pre-upload requirement.
- explicit failed status + user-visible action if mapping fails.

### Risk: Duplicate uploads

Mitigation:

- worker lock (`workerSessionId`) + atomic claim update.

### Risk: Queue stalls silently

Mitigation:

- persisted `errorMessage`, `retryCount`, `nextAttemptAt`.
- provider exposes queue diagnostics to UI.

### Risk: File storage bloat

Mitigation:

- cleanup compressed temp files after success/remove.
- optional cleanup job for stale failed artifacts.

---

## 11. Completion Definition

Phase 5 is complete when all are true:

1. `v6 -> v7` migration is live and safe (and `v7 -> v8` when trip mapping is enabled).
2. Place + trip identity mapping to backend UUIDs is implemented.
3. Camera/gallery ingestion supports max 10 selection.
4. Compression and thumbnail generation are active.
5. Queue persists and resumes after restart/network restore.
6. Retry/remove flows for failed uploads work.
7. Place detail shows local-then-remote media progression.
8. `Place.photoUrls` compatibility is maintained.
9. Added media tests pass and Phase 4 core flows remain stable.

---

## 12. AI Agent Execution Guardrails

1. Implement identity mapping first (`serverPlaceId`, `serverTripId`, `ensureRemotePlaceId`, `ensureRemoteTripId`).
2. Persist queue rows before any upload attempt.
3. Upload worker must be idempotent and lock-safe.
4. Keep plugin/API details in `core/**` only.
5. Preserve existing editor/route contracts.
6. Do not skip migration/backfill validation from current v6 baseline.

---

## 13. Detailed File-Level Contract

This section is intentionally explicit so implementation can be delegated without ambiguity.

### 13.1 Storage and model files

| File | Change | Why |
|---|---|---|
| `flutter/lib/core/storage/tables/places_table.dart` | Add `serverPlaceId` nullable column | Keep stable mapping between local place and backend UUID for upload APIs |
| `flutter/lib/features/create/domain/place.dart` | Add `serverPlaceId` field | Ensure provider/repository domain includes remote identity |
| `flutter/lib/core/storage/tables/trips_table.dart` | Add `serverTripId` nullable column | Keep stable mapping between local trip and backend UUID for place/media APIs |
| `flutter/lib/features/create/domain/trip.dart` | Add `serverTripId` field | Ensure repository can resolve backend trip identity deterministically |
| `flutter/lib/core/storage/tables/media_table.dart` | Add queue metadata columns | Represent persistent upload lifecycle in Drift |
| `flutter/lib/core/storage/daos/media_dao.dart` | Add claim/watch/status update methods | Drive queue worker and UI reactivity |
| `flutter/lib/core/storage/drift_database.dart` | v6 -> v7 (+ optional v7 -> v8) migration + backfill | Keep old data valid and identity-aware |

### 13.2 Core media files

| File | Role |
|---|---|
| `flutter/lib/core/media/app_media_uploader.dart` | Upload abstraction independent of transport |
| `flutter/lib/core/media/adapters/dora_media_uploader.dart` | OpenAPI-backed implementation using `MediaApi` |
| `flutter/lib/core/media/media_permissions.dart` | Camera/gallery permission abstraction |
| `flutter/lib/core/media/image_compressor.dart` | Normalize image size/quality before upload |
| `flutter/lib/core/media/thumbnail_generator.dart` | Generate local preview thumbnail |
| `flutter/lib/core/media/upload_queue_worker.dart` | Claim/process/retry queue tasks safely |
| `flutter/lib/core/media/models/queued_media_task.dart` | Worker-facing DTO for queue row projections |
| `flutter/lib/core/media/media_queue_bootstrap.dart` | Single-entry lifecycle bootstrap and trigger orchestration |

### 13.3 Feature and UI files

| File | Role |
|---|---|
| `flutter/lib/features/create/data/media_repository.dart` | Orchestrate enqueue, upload, retry, remove |
| `flutter/lib/features/create/presentation/providers/media_upload_provider.dart` | Screen-level queue actions |
| `flutter/lib/features/create/presentation/providers/place_media_provider.dart` | Place-level reactive media list |
| `flutter/lib/features/create/presentation/screens/media_upload_screen.dart` | Screen 9 implementation |
| `flutter/lib/features/create/presentation/widgets/photo_grid_item.dart` | Gallery grid item |
| `flutter/lib/features/create/presentation/widgets/selected_photo_chip.dart` | Selected-strip item |
| `flutter/lib/features/create/presentation/widgets/upload_queue_item.dart` | Queue state renderer |
| `flutter/lib/features/create/presentation/widgets/place_detail_form.dart` | Entry point + in-context media state |
| `flutter/lib/core/navigation/routes.dart` | Route constants for media screen |
| `flutter/lib/core/navigation/app_router.dart` | Route registration and params wiring |

---

## 14. Data Contract Details

### 14.1 Place identity contract

`Place` and `PlaceRow` must include:

- `id` (local ID, existing behavior preserved)
- `serverPlaceId` (nullable backend UUID)

Rules:

1. `serverPlaceId != null` means upload can proceed directly.
2. `serverPlaceId == null` requires `ensureRemotePlaceId(localPlaceId)` before upload.
3. `ensureRemotePlaceId` must be idempotent for same local place.

### 14.1b Trip identity contract

`Trip` and `TripRow` should include:

- `id` (local trip ID, existing behavior preserved)
- `serverTripId` (nullable backend UUID)

Rules:

1. `serverTripId != null` means backend place creation can proceed directly.
2. `serverTripId == null` requires `ensureRemoteTripId(localTripId)` before creating backend place.
3. `ensureRemoteTripId` must be idempotent for same local trip.

### 14.2 Media queue contract

`Media` row must include these queue fields:

- `uploadStatus`
- `uploadProgress`
- `retryCount`
- `nextAttemptAt`
- `errorMessage`
- `workerSessionId`
- `thumbnailPath`
- `mimeType`
- `fileSizeBytes`
- `width`
- `height`
- `uploadedAt`

### 14.3 Status transition matrix

| From | To | Trigger |
|---|---|---|
| `queued` | `compressing` | Worker claims task |
| `compressing` | `uploading` | Compression + thumbnail complete |
| `uploading` | `uploaded` | API success |
| `compressing` | `failed` | Compression exception |
| `uploading` | `failed` | API/network error after attempt |
| `failed` | `queued` | User taps Retry OR retry schedule reached |
| `queued` | `canceled` | User cancels pending task |
| `failed` | `canceled` | User removes/cancels failed task |

Forbidden transitions:

- `uploaded -> queued`
- `uploaded -> failed`
- `canceled -> uploading`

---

## 15. Worker Algorithm Contract

### 15.1 High-level loop

```dart
while (workerCanRun) {
  final tasks = dao.claimPendingTasks(
    now: DateTime.now(),
    limit: maxConcurrency,
    workerSessionId: sessionId,
  );
  if (tasks.isEmpty) break;

  await Future.wait(tasks.map(processTask));
}
```

### 15.2 `processTask` contract

```dart
Future<void> processTask(QueuedMediaTask task) async {
  try {
    await dao.markCompressing(task.id);
    final compressed = await compressor.compress(task.localPath);
    final thumb = await thumbnailer.generate(compressed.path);
    await dao.markUploading(task.id, thumbnailPath: thumb.path);

    final placeId = await placeRepository.ensureRemotePlaceId(task.placeId);
    final uploaded = await uploader.uploadPhoto(
      placeId: placeId,
      filePath: compressed.path,
      caption: task.caption,
      takenAt: task.takenAt,
    );

    await dao.markUploaded(task.id, uploaded);
    await repository.updatePlacePhotoUrlsBridge(task.placeId, uploaded.url);
    await cleanupTempArtifacts(task.id);
  } catch (e) {
    await dao.markFailedWithRetryPolicy(task.id, error: e.toString());
  } finally {
    await dao.releaseClaim(task.id, sessionId);
  }
}
```

### 15.3 Idempotency requirements

1. Only claimed rows may be processed.
2. Claim must be atomic at DAO level.
3. Re-triggering worker must not re-process an already claimed row.
4. Successful upload must set `uploadStatus=uploaded` before claim release.

### 15.4 Temp File Lifecycle Policy

Temp artifact policy is mandatory:

1. Store compressed files under an app-controlled temp directory.
2. Store generated thumbnails under an app-controlled cache/support directory.
3. On `uploaded`, `canceled`, or `removeMedia`, delete associated temp artifacts.
4. On `failed`, keep artifacts for retry; cleanup automatically after retention window (for example, 48h) or when user removes item.
5. Run periodic orphan cleanup for stale temp files not linked to active queue rows.

### 15.5 Worker Bootstrap Call Flow

1. App boots and DB init completes.
2. Bootstrap provider starts and registers lifecycle/connectivity listeners.
3. Bootstrap triggers `uploadQueueWorker.startIfIdle()`.
4. Subsequent triggers call `startIfIdle()` only; no parallel independent loops.

---

## 16. API and Error Handling Contract

### 16.1 Upload request contract

Use OpenAPI client only:

- `MediaApi.uploadMediaApiV1MediaUploadPost(...)`
- required:
  - `authorization`
  - `file` (multipart)
  - `tripPlaceId` (backend UUID)
- optional:
  - `caption`
  - `takenAt`

### 16.2 Error mapping

| Error class | Handling |
|---|---|
| 400/422 validation | Mark failed, show actionable message, no auto-retry |
| 401/403 auth/ownership | Mark failed, no auto-retry, surface re-auth/help |
| 404 place not found | Trigger place identity repair path once, then fail |
| 429/5xx/timeouts/network | Retryable with exponential backoff |

Backoff formula:

- `attempt1`: immediate
- `attempt2`: +10s
- `attempt3`: +30s
- `attempt4`: stop and remain `failed` (max retry exceeded)

---

## 17. UI and UX Contract (Screen 9)

### 17.1 Entry points

1. From `place_detail_form.dart` primary media affordance.
2. Optional contextual entry from editor tool panel when place is selected.

### 17.2 Required UI blocks

1. Header: back + selected counter + done.
2. Selected strip with removable chips.
3. Camera action + gallery grid.
4. Queue list with per-item state.
5. Error state actions: Retry/Remove.

### 17.3 UX rules

1. Selection cap hard limit is 10.
2. Done action enqueues and returns immediately.
3. Upload continues when user exits screen.
4. Place detail must show local preview before remote URL completion.

### 17.4 Accessibility and fallback

1. Permission denied state must include \"Open Settings\" action.
2. Failed item must always expose retry and remove controls.
3. Queue status text must be explicit (`Queued`, `Uploading 45%`, `Failed`).

---

## 18. Observability and Debugability

### 18.1 Required logging tags

- `[MEDIA_QUEUE]`
- `[MEDIA_UPLOAD]`
- `[MEDIA_COMPRESS]`
- `[PLACE_ID_BIND]`

### 18.2 Minimum log events

1. Task claimed.
2. Compression started/completed.
3. Upload started/completed.
4. Upload failed with category and retry count.
5. Task released.
6. Place ID mapping success/failure.

### 18.3 Debug artifacts

- Keep last error message per row in `errorMessage`.
- Keep retry counters and next-attempt timestamp.
- Ensure provider can expose a small diagnostics panel in debug builds.

---

## 19. Traceability Matrix

| Requirement | File(s) | Verification |
|---|---|---|
| Persist-first queue | `media_repository.dart`, `media_dao.dart` | Repository unit test |
| Resume on restart | `upload_queue_worker.dart` | Worker integration/unit test |
| Place ID mapping | `place_repository.dart`, place model/table | Identity tests |
| Max 10 selection | `media_upload_screen.dart` | Widget test |
| Retry/remove failed | provider + queue item widget | Provider/widget tests |
| photoUrls compatibility | `media_repository.dart`, `place_repository.dart` | Repository test |
| No Phase 4 regressions | editor providers/widgets | Regression checklist |

---

## 20. Rollout Recommendation

1. Merge schema + identity mapping first.
2. Merge queue worker behind debug toggle.
3. Enable UI flows after worker validation.
4. Keep lightweight telemetry during first rollout window.
5. After stabilization, evaluate deprecation path for direct `Place.photoUrls` dependency.
