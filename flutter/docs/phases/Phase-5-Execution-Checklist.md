# FLUTTER PHASE 5 EXECUTION CHECKLIST

Phase: Media Ingestion, Queue, and Place Gallery  
Duration Target: 2 weeks  
Owner: TBD  
Last Updated: 2026-02-20

---

## How To Use This Checklist

- Execute steps in order.
- Do not proceed until all exit criteria for the current step are met.
- Attach evidence notes for each step.
- If a stop-the-line condition appears, pause and resolve before continuing.

---

## Step 0: Contract Freeze and Readiness Gate (Day 1)

### Tasks
- [ ] Confirm Phase 4 editor baseline is stable (open/edit/save/close).
- [ ] Confirm map abstraction compliance in `lib/features/**`.
- [ ] Align/lock Phase 4C route-creation baseline expectations with current implemented UX.
- [ ] Freeze media API usage from `dora_api` (`MediaApi.uploadMediaApiV1MediaUploadPost`).
- [ ] Freeze upload state machine:
  - [ ] `queued -> compressing -> uploading -> uploaded`
  - [ ] failures -> `failed` with retry metadata
  - [ ] user action -> `canceled`
- [ ] Freeze place identity strategy for media uploads:
  - [ ] Add and use `serverPlaceId` mapping
  - [ ] Define `ensureRemotePlaceId(localPlaceId)` behavior
- [ ] Confirm migration target is `schemaVersion 6 -> 7`.

### Exit Criteria
- [ ] Written contract for API + state machine + place identity mapping exists.
- [ ] Phase 4C baseline behavior is documented and accepted as regression reference.
- [ ] No unresolved blockers for schema work.

### Evidence
- [ ] `phase5-step0-contract-freeze.md`

---

## Step 1: Schema and DAO Migration (Day 1-2)

### Tasks
- [ ] Update `flutter/lib/core/storage/tables/places_table.dart`:
  - [ ] add `serverPlaceId` (nullable)
- [ ] Update `flutter/lib/core/storage/tables/media_table.dart` with queue columns.
- [ ] Update `flutter/lib/core/storage/drift_database.dart`:
  - [ ] bump to schema version 7
  - [ ] implement v6 -> v7 migration and backfill rules
- [ ] Update `flutter/lib/core/storage/daos/media_dao.dart`:
  - [ ] pending query
  - [ ] failed query
  - [ ] watch by place
  - [ ] claim/release task helpers for worker lock
- [ ] Regenerate Drift code (`*.g.dart`) after schema change.

### Exit Criteria
- [ ] Fresh DB create works at v7.
- [ ] Upgrade from v6 data works without corruption.
- [ ] DAO queries return correct queued/failed/uploaded sets.

### Evidence
- [ ] Migration notes and sample before/after rows.

---

## Step 2: Place Identity Binding for Upload (Day 2-3)

### Tasks
- [ ] Update `flutter/lib/features/create/domain/place.dart` with `serverPlaceId`.
- [ ] Update place row mapping in `place_repository.dart`.
- [ ] Add method `ensureRemotePlaceId(localPlaceId)` in `place_repository.dart`.
- [ ] Ensure place creation flow stores local UUID safely for unsynced places.
- [ ] Ensure upload path uses backend place UUID (never raw external search ID).

### Exit Criteria
- [ ] For any place selected in editor, upload path can resolve a backend `trip_place_id`.
- [ ] Failure mode is explicit and user-recoverable if remote place creation fails.

### Evidence
- [ ] `phase5-step2-place-identity.md` with call flow and sample logs.

---

## Step 3: Core Media Pipeline and Repository (Day 3-5)

### Tasks
- [ ] Add dependencies in `flutter/pubspec.yaml`.
- [ ] Create core media services:
  - [ ] `media_permissions.dart`
  - [ ] `image_compressor.dart`
  - [ ] `thumbnail_generator.dart`
  - [ ] `app_media_uploader.dart`
  - [ ] `adapters/dora_media_uploader.dart`
- [ ] Add `mediaApiProvider` in `flutter/lib/core/network/api_providers.dart`.
- [ ] Create `flutter/lib/features/create/data/media_repository.dart`.
- [ ] Ensure enqueue-first behavior (persist row before upload attempt).

### Exit Criteria
- [ ] Selected assets are persisted immediately with queue metadata.
- [ ] Compression/thumbnail failures produce `failed` rows (no crash).
- [ ] Repository keeps `Place.photoUrls` bridge updated after successful upload.

### Evidence
- [ ] `phase5-step3-repository-contract.md`

---

## Step 4: Persistent Queue Worker and Retry Policy (Day 5-6)

### Tasks
- [ ] Implement `flutter/lib/core/media/upload_queue_worker.dart`.
- [ ] Implement bounded concurrency (recommended max 2).
- [ ] Implement retry policy (max 3, exponential backoff).
- [ ] Implement task-claim lock semantics (idempotency).
- [ ] Add explicit bootstrap module for worker lifecycle orchestration:
  - [ ] `flutter/lib/core/media/media_queue_bootstrap.dart` (or equivalent)
- [ ] Wire worker triggers:
  - [ ] app foreground/resume
  - [ ] connectivity restored
  - [ ] optional background hook
- [ ] Wire bootstrap in app root:
  - [ ] `flutter/lib/app.dart` watches bootstrap provider after DB init

### Exit Criteria
- [ ] Queue resumes after restart.
- [ ] Queue resumes after network recovery.
- [ ] Duplicate upload for one queue row does not occur under repeated triggers.

### Evidence
- [ ] Worker lifecycle logs for success/failure and retry paths.

---

## Step 5: Media Upload UX and Editor Integration (Day 7-9)

### Tasks
- [ ] Create screen/widgets:
  - [ ] `media_upload_screen.dart`
  - [ ] `photo_grid_item.dart`
  - [ ] `selected_photo_chip.dart`
  - [ ] `upload_queue_item.dart`
- [ ] Add navigation route wiring in:
  - [ ] `routes.dart`
  - [ ] `app_router.dart`
- [ ] Create providers:
  - [ ] `media_upload_provider.dart`
  - [ ] `place_media_provider.dart`
- [ ] Update editor widgets:
  - [ ] `place_detail_form.dart` launch media flow
  - [ ] `floating_tool_panel.dart` media entry affordance
  - [ ] `bottom_detail_panel.dart` queue status context
- [ ] Enforce max selection of 10.

### Exit Criteria
- [ ] User can select/capture, enqueue, and monitor upload states.
- [ ] Place detail shows immediate local preview and eventual remote media.
- [ ] Existing place edit flows remain functional.

### Evidence
- [ ] UI validation notes mapped to Screen 9 contract.

---

## Step 6: Hardening and Regression Pack (Day 10)

### Tasks
- [ ] Run failure-path pass:
  - [ ] permission denied
  - [ ] no network at enqueue
  - [ ] compression failure
  - [ ] API 4xx
  - [ ] API 5xx/timeout
- [ ] Verify app kill/restart while uploading.
- [ ] Verify queue cleanup and stale temp file behavior.
- [ ] Validate Phase 4 regression pack:
  - [ ] add place/city
  - [ ] route creation/edit
  - [ ] timeline reorder
  - [ ] editor autosave

### Exit Criteria
- [ ] No critical defects open.
- [ ] No data-loss scenario remains.
- [ ] No major Phase 4 flow regression.

### Evidence
- [ ] `phase5-rc-report.md` with go/no-go.

---

## Test Gates

### Unit Tests
- [ ] `test/core/media/upload_queue_worker_test.dart`
- [ ] `test/features/create/media/media_repository_test.dart`
- [ ] compression/thumbnail service tests
- [ ] place identity binding tests (`ensureRemotePlaceId`)

### Provider/Widget Tests
- [ ] `test/features/create/media/media_upload_provider_test.dart`
- [ ] `test/features/create/media/place_media_provider_test.dart`
- [ ] `test/features/create/media/media_upload_screen_test.dart`

### Manual Scenarios
- [ ] Online upload happy path
- [ ] Offline enqueue -> reconnect -> auto-upload
- [ ] App kill during upload -> restart -> resume
- [ ] Failed upload -> retry success
- [ ] Remove/cancel pending upload
- [ ] Max 10 selection enforcement
- [ ] No duplicate upload after repeated worker triggers

---

## Stop-the-Line Conditions

- [ ] User-selected media is lost.
- [ ] Duplicate upload records for same queue item.
- [ ] Migration corrupts existing place/media data.
- [ ] Upload attempts made with invalid/unmapped backend place ID.
- [ ] Phase 4 editor/route flows regress critically.

If any occurs:

- [ ] Pause progression.
- [ ] Open blocker issue with repro and expected/actual.
- [ ] Fix and re-run current step gate.

---

## Final Sign-Off

### Delivery
- [ ] All step exit criteria complete.
- [ ] All required tests complete and green.
- [ ] PRD/checklist/handoff docs updated.
- [ ] Residual risks explicitly listed.

### Approval
- [ ] Engineering sign-off
- [ ] Product/PRD sign-off
- [ ] Ready for next-phase handoff

---

## Implementation Sequence Map (File-by-File)

This section is used to prevent out-of-order implementation drift.

### Sequence A: Identity + Schema Foundations
- [ ] `flutter/lib/core/storage/tables/places_table.dart` (`serverPlaceId`)
- [ ] `flutter/lib/features/create/domain/place.dart` (`serverPlaceId`)
- [ ] `flutter/lib/features/create/data/place_repository.dart` mapping for `serverPlaceId`
- [ ] `flutter/lib/core/storage/tables/media_table.dart` queue metadata columns
- [ ] `flutter/lib/core/storage/daos/media_dao.dart` queue query/update helpers
- [ ] `flutter/lib/core/storage/drift_database.dart` migration `6 -> 7`
- [ ] Drift generated files updated and reviewed

### Sequence B: Core Services
- [ ] `flutter/lib/core/media/media_permissions.dart`
- [ ] `flutter/lib/core/media/image_compressor.dart`
- [ ] `flutter/lib/core/media/thumbnail_generator.dart`
- [ ] `flutter/lib/core/media/app_media_uploader.dart`
- [ ] `flutter/lib/core/media/adapters/dora_media_uploader.dart`
- [ ] `flutter/lib/core/network/api_providers.dart` adds `mediaApiProvider`

### Sequence C: Repository + Worker
- [ ] `flutter/lib/features/create/data/media_repository.dart`
- [ ] `flutter/lib/core/media/upload_queue_worker.dart`
- [ ] `flutter/lib/core/media/media_queue_bootstrap.dart`
- [ ] place identity binding path (`ensureRemotePlaceId`) integrated before upload
- [ ] idempotent claim/release flow verified in DAO + worker

### Sequence D: UI + Navigation
- [ ] `flutter/lib/core/navigation/routes.dart`
- [ ] `flutter/lib/core/navigation/app_router.dart`
- [ ] `flutter/lib/features/create/presentation/screens/media_upload_screen.dart`
- [ ] `flutter/lib/features/create/presentation/widgets/photo_grid_item.dart`
- [ ] `flutter/lib/features/create/presentation/widgets/selected_photo_chip.dart`
- [ ] `flutter/lib/features/create/presentation/widgets/upload_queue_item.dart`
- [ ] `flutter/lib/features/create/presentation/providers/media_upload_provider.dart`
- [ ] `flutter/lib/features/create/presentation/providers/place_media_provider.dart`
- [ ] `flutter/lib/features/create/presentation/widgets/place_detail_form.dart`
- [ ] `flutter/lib/features/create/presentation/widgets/floating_tool_panel.dart`
- [ ] `flutter/lib/features/create/presentation/widgets/bottom_detail_panel.dart`

---

## Acceptance Matrix (Hard Gates)

### Gate G1: Identity Integrity
- [ ] Upload path never sends non-backend IDs as `trip_place_id`.
- [ ] For unsynced places, `ensureRemotePlaceId` creates and persists mapping once.
- [ ] Repeat upload attempts for same place do not create duplicate backend places.

### Gate G2: Queue Reliability
- [ ] Worker can be triggered repeatedly without double-uploading same row.
- [ ] Claimed rows are not re-claimed by parallel worker runs.
- [ ] Failed rows retain actionable `errorMessage` and `retryCount`.
- [ ] Rows transition only through allowed states.
- [ ] Worker bootstrap starts once and does not create parallel loops.

### Gate G3: UX Contract
- [ ] Selection cap blocks 11th item.
- [ ] Done action enqueues and returns to editor quickly.
- [ ] Local preview appears before network success.
- [ ] Failed items show retry/remove actions.
- [ ] Permission denied state offers settings path.

### Gate G4: Regression Safety
- [ ] Editor screen opens and closes normally.
- [ ] Place add/edit flow unaffected.
- [ ] Route draw/edit flow unaffected.
- [ ] Timeline interactions unaffected.

---

## Migration Validation Script Checklist

Use this as a manual script while validating DB upgrades.

### Pre-upgrade fixture setup
- [ ] Prepare v6 DB snapshot with:
  - [ ] media rows with URL
  - [ ] media rows without URL
  - [ ] places with and without photos
  - [ ] route and editor data

### Post-upgrade expectations
- [ ] DB opens with schema version 7.
- [ ] Existing rows retained.
- [ ] Backfill expectations:
  - [ ] rows with URL => `uploaded`, progress `1.0`
  - [ ] rows without URL => `queued`, progress `0.0`
- [ ] New columns are non-crashing with defaults.

### Integrity verification
- [ ] No orphan place/media relation due to identity mapping fields.
- [ ] DAO reads/watches return expected row counts.
- [ ] No crash in editor after migration.

---

## Worker State Machine Verification

### Transition checks
- [ ] `queued -> compressing` when worker claims item.
- [ ] `compressing -> uploading` after preprocessing.
- [ ] `uploading -> uploaded` on success.
- [ ] `compressing -> failed` on preprocessing exception.
- [ ] `uploading -> failed` on API/network exception.
- [ ] `failed -> queued` on user retry.
- [ ] `queued -> canceled` on user cancel.

### Forbidden transition checks
- [ ] `uploaded -> queued` never occurs.
- [ ] `uploaded -> failed` never occurs.
- [ ] `canceled -> uploading` never occurs.

---

## Error Taxonomy Checklist

### API/client errors
- [ ] 400/422 treated as non-retryable validation failures.
- [ ] 401/403 treated as auth/ownership failures (no blind retries).
- [ ] 404 place-not-found triggers identity repair once, then fails clearly.
- [ ] 429/5xx/timeouts treated as retryable.

### Local failures
- [ ] Missing file path handled as failed row, no crash.
- [ ] Compression failure handled as failed row, no crash.
- [ ] Thumbnail generation failure handled with fallback (or failed state) deterministically.
- [ ] Temp file cleanup failures logged but non-fatal.

---

## Evidence Template (Per Step)

Use this structure for each step evidence artifact.

### Header
- [ ] Step ID
- [ ] Date/time
- [ ] Branch/commit range
- [ ] Owner

### What changed
- [ ] Files touched
- [ ] APIs touched
- [ ] Migrations/codegen updates

### Validation
- [ ] Test list executed
- [ ] Manual flows executed
- [ ] Known limitations

### Decision
- [ ] Gate PASS
- [ ] Gate FAIL with blocker links

---

## Rollback and Recovery Checklist

If release candidate fails:

- [ ] Disable media entry route/affordance via controlled guard.
- [ ] Preserve queued rows (no destructive wipe).
- [ ] Keep editor core features available.
- [ ] Capture failure logs and sample rows.
- [ ] Patch and re-run only blocked gate + affected regressions.

---

## Daily Progress Tracking

### Day 1
- [ ] Step 0 complete
- [ ] Risks logged

### Day 2
- [ ] Step 1 complete
- [ ] Migration verified

### Day 3
- [ ] Step 2 complete
- [ ] Identity mapping verified

### Day 4-5
- [ ] Step 3 complete
- [ ] Repository + core pipeline verified

### Day 6
- [ ] Step 4 complete
- [ ] Queue reliability verified
- [ ] Bootstrap lifecycle verified in app root

### Day 7-9
- [ ] Step 5 complete
- [ ] UX integration verified

### Day 10
- [ ] Step 6 complete
- [ ] RC report complete

---

## Final Release Readiness Summary

Before closure, all must be checked:

- [ ] Schema migration validated on real v6 data snapshot.
- [ ] Place identity mapping prevents invalid `trip_place_id` uploads.
- [ ] Queue is idempotent and restart-safe.
- [ ] UI handles happy path and failure path equally.
- [ ] Phase 4 regression checklist has no critical failures.
- [ ] Documentation artifacts are complete and linked.
