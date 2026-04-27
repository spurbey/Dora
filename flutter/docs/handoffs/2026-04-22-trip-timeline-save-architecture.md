# Trip Timeline, Save/Publish, and Map Correspondence Architecture (2026-04-22)

Owner: `codex`  
Status: `current reference`

## 1) Why This Document Exists
This is the single handoff for:
1. The original timeline and map-correspondence failures.
2. The exact fixes implemented in Phase A and Phase B.
3. The current architecture contract for timeline compile, resolver, save, and publish.
4. Operational failures seen during rollout and how to diagnose them quickly.

## 2) Original Problems and Root Causes
### 2.1 Split timeline model (manual vs live)
1. Manual editor entities and V2 live entities were rendered through different lanes.
2. On editor re-entry, manual places looked "missing" because they were not in one canonical merged lane.
3. Root cause was not data loss. Root cause was fragmented rendering and ordering logic.

### 2.2 Weak map correspondence
1. Selection behavior differed by entity type.
2. Detail surfaces were inconsistent.
3. Map focus was not uniformly tied to timeline selection.

### 2.3 Resolver identity mismatch
1. Live `place_bound` outcomes could still carry provider identity semantics.
2. Manual route/editor flows are built around local `trip_place_local` identity.
3. This created mismatches between resolver outcomes and editor entities.

### 2.4 Route visibility mismatch
1. Manual routes existed on map.
2. In mixed manual+live neighborhoods, route rows were not consistently represented in timeline.

### 2.5 Save/publish confusion
1. Team expectation was local-first draft behavior and server compile only at save/publish time.
2. It was unclear where server-compiled timeline/route projections are mirrored back to local after commit.

### 2.6 Operational failures during stabilization
1. `POST /api/v1/trips/{id}/routes` hit backend 500 due to unresolved FK target table during ORM flush.
2. Save failed with "bucket not found" because backend V2 storage path used a fixed bucket that did not match provisioned env.
3. Save failed with storage 403 RLS when Supabase policies did not permit upload for that bucket/path.
4. `409 active publish` appeared when a previous publish job already existed and client retried save.
5. "No route to host" app-open failures were network reachability issues to backend host, not timeline logic.

## 3) What Was Implemented
### 3.1 Phase A data/behavior hardening (`5281a78`)
1. Added deterministic projection ordering with `timeline_projection_local.display_order`.
2. Local compiler preserves existing `display_order` across recompiles and server mirrors.
3. Added reorder safety via midpoint insertion and periodic normalization.
4. Expanded compile triggers to near-real-time local sources with debounce and single in-flight guard.
5. Canonicalized resolver place identity to local place entities (`trip_place_local`) for editor compatibility.
6. Added explicit route claim lane (`route_segment_claim_local`) for deterministic manual-route ownership of projected segments.
7. Hardened save pipeline to mirror server timeline and route projection after commit.
8. Added save conflict handling for resumable publish jobs and clearer 409/idempotency messaging.
9. Fixed backend route create crash by ensuring `TripTrackingSession` model is imported/registered.

### 3.2 Storage path hardening (`7694d51`)
1. Added backend setting `V2_STORAGE_BUCKET` (default `photos`).
2. V2 upload target generation now resolves bucket from config instead of hardcoded `tracking-v2`.
3. Backend now documents the env variable in `backend/.env.example`.
4. Result: save no longer depends on one hardcoded bucket name.

### 3.3 Phase B editor UX unification (`68bf6fa`)
1. Implemented unified timeline entries for place/live/route.
2. Replaced split sidebar with one merged lane.
3. Applied corrected reorder policy: only manual place/city rows are draggable.
4. Added compact live entry action in header and bounded top-right resolver dock.
5. Added hard-focus mode and unified bottom detail sheet for place/live/route.
6. Resolver "Add place manually" now opens the same editor search/create flow.
7. Place/city insertion ordering now appends by max order index for stable mixed ordering.

## 4) Current Architecture Contract
### 4.1 Canonical data source policy
1. Draft/edit mode canonical source is local state plus local projection.
2. Save compiles and commits to backend, then mirrors server projection back to local.
3. Published timeline semantics are server-authored at commit; editor still reads from mirrored local projection for fast UI.

### 4.2 Local compile and projection pipeline
1. Sources watched: event/session/media/route-point/resolver journals.
2. Refresh signal is merged and debounced (trailing) for near-real-time compile.
3. Compiler writes to `timeline_projection_local`, `route_projection_local`, and `route_segment_claim_local`.
4. Projection ordering uses `display_order` first and timestamp fallback.

### 4.3 Unified editor timeline assembly
1. Live projection entries are loaded from local projection and sorted by `displayOrder`.
2. Manual places are inserted by `orderIndex` into global slots.
3. Manual routes are inserted as explicit rows by endpoint-relative placement.
4. Timeline row types are place row, live row, and route row.
5. Live rows carry media summary indicators from render payload.

### 4.4 Selection and focus behavior
1. Selecting any row or map entity enters focus mode.
2. Non-essential overlays collapse or dim.
3. Map flies to selected entity anchor.
4. Unified bottom detail sheet peeks and expands for place/live/route details.

### 4.5 Resolver contract
1. Resolver inbox is shown in a compact top-right dock.
2. Live events remain visible in main timeline even when unresolved.
3. Resolver actions update place binding and are reflected immediately in timeline and map context.
4. "Add place manually" uses editor place search/create path, not a separate mini flow.

### 4.6 Route correspondence contract
1. Manual route rows are always visible in unified timeline.
2. Segment suppression/ownership should use explicit claims from `route_segment_claim_local`, not pure time overlap heuristics.
3. Heuristic local claims are provisional until publish mirror confirms server projection.

## 5) Save and Publish Sequence
### 5.1 Save flow (`TripsRepository.saveTrip`)
1. Validate trip and ensure no active/paused live session.
2. Build local snapshot from journals (sessions/events/media/route points).
3. Materialize editor graph so local place/route identities have remote ids before publish lane commit.
4. `publish:start` with summary and media manifest.
5. Upload media to Supabase bucket/object targets returned by backend.
6. `publish:media-complete`.
7. Chunked payload upload via `publish:payload-chunk`.
8. `publish:commit`.
9. Mirror server projection into local projection tables via `GET /api/v2/trips/{trip_id}/timeline` and `GET /api/v2/trips/{trip_id}/route`.
10. Persist publish-state digest and lifecycle status.

### 5.2 Publish flow (`TripsRepository.publishTrip`)
1. Enforces save gate by snapshot digest equality.
2. Enqueues editor media for publish lane.
3. Sets visibility to `public`.
4. Updates local publish-state to published.

### 5.3 409 behavior on save
1. If backend returns `active_publish_exists`, save is resumable and should be retried.
2. This is expected when previous publish job is still active, not always a hard failure.

## 6) Runtime and Environment Configuration
### 6.1 Flutter V2 flags
1. `ENABLE_LIVE_SYSTEM_V2`
2. `ENABLE_V2_LOCAL_JOURNAL`
3. `ENABLE_V2_LOCAL_COMPILER`
4. `ENABLE_V2_LIVE_EDITOR_UI_CONTRACT`
5. `ENABLE_V2_SESSION_COMMIT_WORKER`
6. `ENABLE_V2_TRIP_PUBLISH_WORKER`
7. `ENABLE_V2_BACKEND_INGEST`

### 6.2 Backend storage settings
1. `V2_STORAGE_BUCKET=photos` by default in `backend/.env.example`.
2. Backend upload target service now reads `settings.V2_STORAGE_BUCKET`.
3. Bucket and RLS policies in Supabase must allow authenticated upload to the resolved path.

## 7) Error Guide (What It Means and What To Check)
### 7.1 `bucket not found`
1. Backend issued upload target for bucket that does not exist in Supabase project.
2. Fix by aligning `V2_STORAGE_BUCKET` with actual bucket and restart backend.

### 7.2 `StorageException ... row-level security policy ... 403`
1. Bucket exists but policy denies insert/upload for current auth context.
2. Fix Supabase storage RLS policies for bucket/path/user ownership contract.

### 7.3 `409 active_publish_exists` on `publish:start`
1. Previous publish job for trip is still active.
2. Expected retry behavior is to resume/continue rather than creating a new job.

### 7.4 Route create backend 500 with `NoReferencedTableError`
1. ORM model registry was incomplete for FK target table.
2. Fixed by importing `trip_tracking_session` model in backend models package.

### 7.5 `No route to host`
1. Mobile device cannot reach backend IP:port.
2. This is host/network reachability, not timeline compiler regression.

## 8) Primary Code Map
1. Unified model: `flutter/lib/features/create/domain/unified_timeline_entry.dart`
2. Unified provider: `flutter/lib/features/create/presentation/providers/unified_timeline_provider.dart`
3. Editor screen and focus UX: `flutter/lib/features/create/presentation/screens/editor_screen.dart`
4. Timeline sidebar: `flutter/lib/features/create/presentation/widgets/timeline_sidebar.dart`
5. Resolver dock: `flutter/lib/features/live_tracking/v2/inbox/v2_unresolved_review_panel.dart`
6. Projection ordering DAO: `flutter/lib/core/storage/daos/v2/timeline_projection_local_dao.dart`
7. Projection repository: `flutter/lib/features/live_tracking/v2/compiler/v2_local_projection_repository.dart`
8. Compiler: `flutter/lib/features/live_tracking/v2/compiler/v2_local_timeline_compiler.dart`
9. Compile triggers: `flutter/lib/features/live_tracking/v2/v2_providers.dart`
10. Save/publish orchestration: `flutter/lib/features/trips/data/trips_repository.dart`
11. Trip controller hooks: `flutter/lib/features/trips/presentation/providers/trips_provider.dart`
12. Backend storage config: `backend/app/config.py`
13. Backend upload target service: `backend/app/services/v2_storage_service.py`
14. Backend model registry: `backend/app/models/__init__.py`

## 9) Verification Checklist
1. Create mixed timeline with manual places, live events, and routes.
2. Leave and reopen editor; verify all entities still appear in one merged lane.
3. Drag only manual place/city rows; verify persisted order after refresh.
4. Resolve an unresolved event with manual add; verify same place search/create flow opens.
5. Save trip and verify publish lane sequence completes through commit.
6. Verify timeline and route projection mirror calls occur after commit.
7. Reopen trip and verify merged lane and map correspondence remain stable.

## 10) Out of Scope for This Slice
1. Feed timeline redesign/rendering is intentionally deferred.
2. Live-event drag reorder remains disabled by product policy.
3. Full map visual polish beyond focus contract is tracked as subsequent UX iteration.
