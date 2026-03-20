# Live Tracking Travelogue PRD

Status: Draft  
Last Updated: 2026-03-19  
Primary Audience: Backend, Flutter, Product, QA, AI coding agents  
Scope Boundary: Backend + Flutter only, `frontend/` excluded

## 1. Purpose

This document defines the complete plan for introducing **semi-manual live trip capture** in Dora:

- Users can still create and edit trips manually (existing behavior).
- Dora captures movement and likely check-ins automatically while a trip is active.
- Dora asks for user confirmation via push notifications before committing important inferred events.
- Users can capture photos/notes/geotags during the trip and attach them to the active trip.
- Dora can end inactive trips and auto-compose a draft travelogue for user review.

This PRD is the one-stop implementation reference for what exists today, what is missing, what to build, and how to build it.

## 2. Current State Audit (What We Found)

## 2.1 Backend Today

- Trips, places, and routes are manual CRUD entities.
- Trip model has no live tracking lifecycle fields.
- Place and route models have no source provenance (`manual` vs `auto`) or confidence.
- Media upload is attached to a `trip_place_id` only.
- Unified trip timeline is place + route only.
- Durable worker pattern exists (export worker), but no tracking worker pipeline.

### Key Existing Files

- `backend/app/models/trip.py`
- `backend/app/models/place.py`
- `backend/app/models/route.py`
- `backend/app/models/media.py`
- `backend/app/models/trip_component.py`
- `backend/app/api/v1/trips.py`
- `backend/app/api/v1/places.py`
- `backend/app/api/v1/routes.py`
- `backend/app/api/v1/media.py`
- `backend/app/api/v1/components.py`
- `backend/app/services/search_service.py`
- `backend/app/workers/export_worker.py`
- `backend/app/main.py`
- `backend/app/config.py`

## 2.2 Flutter Today

- Trip creation is manual form -> editor workflow.
- Offline-first sync exists for trip/place/route with durable local queue.
- Media upload queue exists, currently place-bound.
- Location service is one-shot current position fetch, not continuous tracking.
- Push notification infrastructure for tracking confirmations is not wired.
- Permissions currently include foreground location and camera, not full live tracking needs.

### Key Existing Files

- `flutter/lib/features/create/presentation/screens/pre_create_screen.dart`
- `flutter/lib/features/create/presentation/screens/editor_screen.dart`
- `flutter/lib/core/sync/entity_sync_worker.dart`
- `flutter/lib/core/media/upload_queue_worker.dart`
- `flutter/lib/core/location/location_service.dart`
- `flutter/lib/core/storage/drift_database.dart`
- `flutter/lib/core/storage/tables/sync_tasks_table.dart`
- `flutter/lib/core/storage/tables/media_table.dart`
- `flutter/lib/features/feed/presentation/screens/feed_screen.dart`
- `flutter/android/app/src/main/AndroidManifest.xml`
- `flutter/ios/Runner/Info.plist`
- `flutter/pubspec.yaml`

## 2.3 Critical Gaps

1. No raw GPS ingestion pipeline.
2. No trip tracking session lifecycle.
3. No stay/move segmentation or check-in inference engine.
4. No pending confirmation queue and no push confirmation workflow.
5. No trip-level quick-capture model for notes/photos before place confirmation.
6. No auto-end and auto-compose travelogue pipeline.

## 3. Product Goals

## 3.1 Goals

1. Make trip logging semi-automatic while preserving manual control.
2. Reduce user manual effort for check-ins and route logging.
3. Keep user trust high using explicit confirmation for inferred events.
4. Produce an editable auto-drafted travelogue at trip end.

## 3.2 Non-Goals (V1)

1. Full autonomous journaling with zero user confirmation.
2. Perfect POI detection in every city/category.
3. Real-time multi-user collaborative trip tracking.
4. Web frontend implementation.

## 4. User Experience Definition

## 4.1 Core Journey

1. User creates trip manually (same as today).
2. User taps `Start Live Capture` on that trip.
3. App captures movement in background and uploads points in batches.
4. Backend detects likely stays/check-ins and sends confirmation push.
5. User confirms/rejects/snoozes each suggestion.
6. User can add photo/note/geotag at any point as a trip moment.
7. On inactivity or planned end date, Dora prompts to end trip.
8. Dora auto-generates draft travelogue (places/routes/moments mapped).
9. User edits manually in editor and marks trip complete/share.

## 4.2 UX Principles

1. Manual edits always override automatic inference.
2. User can pause/resume tracking at any time.
3. Every inferred place/route is clearly labeled as auto-generated until confirmed.
4. Battery and privacy controls are explicit and transparent.

## 5. Functional Requirements

## 5.1 Trip Tracking Lifecycle

- Trip status states:
  - `planned`
  - `tracking_active`
  - `tracking_paused`
  - `review_pending`
  - `completed`
  - `shared`
- Tracking session states:
  - `active`
  - `paused`
  - `ended`
  - `abandoned`

Requirements:

1. Only one active tracking session per trip per user.
2. User may pause/resume session without ending trip.
3. Ending session moves trip to `review_pending` if auto-draft exists.

## 5.2 Raw Location Capture

1. App collects location points with timestamp, accuracy, speed, heading.
2. Upload uses batched endpoint to reduce network and battery cost.
3. Failed uploads are persisted in local queue and retried with backoff.
4. Duplicate point ingestion must be idempotent.

## 5.3 Inference and Check-ins

1. Backend creates stay clusters from raw points.
2. Backend matches clusters to likely POIs (local + provider).
3. Backend creates candidate check-ins with confidence score.
4. Backend sends push for confirmation when confidence passes threshold.
5. User response updates candidate status and trip timeline draft.

## 5.4 Moments (Photo/Note/Geotag)

1. User can add a moment to active trip instantly from app.
2. Moment stores media/note/location/timestamp independent of confirmed place.
3. System can auto-link moment to nearest confirmed/inferred place later.
4. User can manually reattach moment to any place in trip editor.

## 5.5 Auto-End and Auto-Compose

1. If inactivity threshold is exceeded, prompt trip end.
2. If trip end date passes, prompt trip end.
3. If user does not respond, configurable grace period then auto-end.
4. Auto-compose creates draft places/routes ordered chronologically.
5. User can finalize after manual editing.

## 5.6 Manual Editing Compatibility

1. Existing create/editor flows remain functional and default-safe.
2. Auto-generated entities are editable like manual ones.
3. Deleting or editing auto entities should not reappear unexpectedly.
4. System records provenance and lock markers to avoid overwrite conflicts.

## 6. Non-Functional Requirements

1. Battery: adaptive sampling, batching, and pause detection.
2. Reliability: offline queue with retries and idempotent ingest.
3. Privacy: explicit consent, disable tracking option, data deletion support.
4. Performance: p95 ingest request < 500 ms, worker backlogs drained continuously.
5. Observability: full metrics + structured logs + error taxonomy.

## 7. Proposed Architecture

## 7.1 High-Level Data Flow

1. Flutter tracking service captures GPS points.
2. Points are persisted locally and synced in batches.
3. Backend stores raw points and enqueues inference jobs.
4. Inference worker produces stay/move segments and check-in candidates.
5. Notification worker sends confirmation push.
6. User action (confirm/reject) updates candidate status.
7. Composer worker builds draft `trip_places` + `routes` + linked moments.
8. User edits final timeline and completes/shares trip.

## 7.2 Compute Strategy

Use deterministic heuristics first (V1), not heavy ML:

- Point quality filtering.
- Stay cluster detection.
- Candidate place matching by distance/category/provider score.
- Route stitching from sequential movement segments.

## 8. Backend Design

## 8.1 Schema Changes

### Extend Existing Tables

1. `trips`
   - `status` (enum/string)
   - `tracking_enabled` (bool)
   - `tracking_started_at` (timestamp)
   - `tracking_ended_at` (timestamp)
   - `timezone` (string)
   - `auto_end_reason` (nullable string)
2. `trip_places`
   - `source` (`manual|auto|edited_auto`)
   - `confidence` (nullable float)
   - `candidate_id` (nullable UUID)
3. `routes`
   - `source` (`manual|auto|edited_auto`)
   - `confidence` (nullable float)
   - `inferred_from_session_id` (nullable UUID)

### New Tables

1. `trip_tracking_sessions`
2. `trip_location_points`
3. `trip_stay_clusters`
4. `trip_checkin_candidates`
5. `trip_moments`
6. `user_device_tokens`
7. `trip_tracking_notifications` (audit/log)

## 8.2 API Surface (New)

All endpoints under `/api/v1`.

1. `POST /trips/{trip_id}/tracking/start`
2. `POST /trips/{trip_id}/tracking/pause`
3. `POST /trips/{trip_id}/tracking/resume`
4. `POST /trips/{trip_id}/tracking/stop`
5. `POST /trips/{trip_id}/tracking/points:batch`
6. `GET /trips/{trip_id}/checkins/pending`
7. `POST /checkins/{candidate_id}/confirm`
8. `POST /checkins/{candidate_id}/reject`
9. `POST /checkins/{candidate_id}/snooze`
10. `POST /trips/{trip_id}/moments`
11. `PATCH /moments/{moment_id}`
12. `POST /trips/{trip_id}/auto-finalize/preview`
13. `POST /trips/{trip_id}/auto-finalize/commit`
14. `POST /devices/push-token/register`
15. `DELETE /devices/push-token/{token}`

## 8.3 Inference Rules (Initial Thresholds)

Configurable via `backend/app/config.py`:

1. Discard points with accuracy > 80m.
2. Deduplicate near-identical points (distance < 15m and delta < 20s).
3. Stay cluster if points remain within 120m radius for >= 10 minutes.
4. Candidate matching radius 250m from cluster centroid.
5. Push confirmation threshold >= 0.65 confidence.
6. Auto-end inactivity threshold default 6 hours without meaningful movement.

## 8.4 Workers

Add new workers parallel to export worker pattern:

1. `tracking_ingest_worker.py` for normalization and queue fan-out.
2. `tracking_inference_worker.py` for clusters/segments/candidates.
3. `tracking_notification_worker.py` for push dispatch.
4. `trip_autofinalize_worker.py` for inactivity/end-date closure.

## 8.5 Services

Add service layer modules:

1. `tracking_service.py`
2. `checkin_service.py`
3. `moment_service.py`
4. `trip_autofinalize_service.py`
5. `push_service.py`

Use existing `search_service.py` to rank nearby POIs.

## 9. Flutter Design

## 9.1 New Dependencies

Add to `flutter/pubspec.yaml`:

1. `firebase_messaging`
2. `flutter_local_notifications`
3. `workmanager` (background task scheduling)
4. Optional later: dedicated background geolocation plugin if reliability gaps remain

## 9.2 Local Storage Additions (Drift)

Add tables:

1. `tracking_sessions_table.dart`
2. `tracking_points_table.dart`
3. `checkin_prompts_table.dart`
4. `trip_moments_table.dart`

Bump `schemaVersion` and migration logic in `drift_database.dart`.

## 9.3 New Workers/Services

1. `tracking_capture_service.dart` (continuous GPS capture with adaptive interval).
2. `tracking_sync_worker.dart` (batch upload + retries).
3. `push_message_handler.dart` (notification -> in-app action routing).
4. `moment_capture_repository.dart` (quick add media/note/geotag).

## 9.4 UI Changes

1. `Start/Pause/Resume/End Live Capture` controls in trip/editor surface.
2. Pending confirmation inbox and deep link from push.
3. Moment quick actions in active trip UI.
4. Auto-generated badges for inferred places/routes.
5. End trip suggestion modal on inactivity/date boundary.

## 9.5 Platform Permissions

Android:

1. Add background location permission when needed.
2. Add notification runtime permission (`POST_NOTIFICATIONS`) for Android 13+.

iOS:

1. Add `NSLocationAlwaysAndWhenInUseUsageDescription`.
2. Enable background modes for location updates.
3. Add notification permission request flow.

## 10. Conflict Resolution Rules

1. Manual field edits lock that field against silent auto-overwrite.
2. Auto pipeline may append suggestions, not destructively mutate locked manual data.
3. If user rejects candidate, do not recreate same candidate within cooldown window.
4. If user deletes auto place/route, mark tombstone to prevent immediate regeneration.

## 11. Security, Privacy, and Compliance

1. Explicit tracking consent screen before first live session.
2. Clear in-app controls to pause/stop/delete collected tracking data.
3. Encrypt transport with HTTPS/TLS (existing API standard).
4. Restrict raw location access to trip owner and authorized workers.
5. Data retention policy:
   - raw points retained 90 days by default
   - aggregated trip artifacts retained with trip
   - immediate deletion path for user account deletion requests

## 12. Observability and Analytics

Metrics:

1. active tracking sessions
2. points ingested per minute
3. candidate generation rate
4. confirmation acceptance/rejection rates
5. auto-finalize trigger rate
6. battery impact telemetry (client sampled)

Logs:

1. structured request IDs and session IDs in all tracking endpoints
2. worker stage logs with error codes
3. push dispatch result logs (sent/delivered/opened if available)

## 13. Testing Strategy

## 13.1 Backend

1. Unit tests for clustering/inference thresholds.
2. Service tests for candidate state transitions.
3. API integration tests for tracking endpoints and auth guards.
4. Worker idempotency and retry behavior tests.

## 13.2 Flutter

1. Repository tests for local queue and retry semantics.
2. Drift migration tests for new schema versions.
3. Widget tests for trip controls and confirmation UI.
4. Integration tests for push deep links and manual override behavior.

## 13.3 End-to-End Scenario

Paris -> India scenario acceptance:

1. Create trip with dates.
2. Start live capture in Paris.
3. Capture airport movement and flight transition.
4. Confirm two inferred check-ins in India.
5. Add one photo and one note as moments.
6. Trigger inactivity and end prompt.
7. Auto-compose draft appears in editor with editable timeline.

## 14. Rollout Plan

## Phase 1: Foundations

1. DB schema + tracking session APIs + batch ingest.
2. Flutter local tracking queue and capture controls.
3. Basic observability and feature flags.

## Phase 2: Inference + Confirmation

1. Stay/move inference worker.
2. Candidate matching and pending check-in APIs.
3. Push notification integration and confirmation UI.

## Phase 3: Moments + Auto-Compose

1. Moment model and capture flows.
2. Auto-finalize preview/commit APIs.
3. Editor integration with auto-generated artifacts.

## Phase 4: Hardening

1. Threshold tuning from real telemetry.
2. Battery optimization and backpressure controls.
3. UX polish, reliability, and regression hardening.

## 15. Delivery Backlog (Implementation Checklist)

## 15.1 Backend Checklist

1. Add migrations for new/extended tracking tables.
2. Add models and schemas for tracking/candidates/moments/device tokens.
3. Add tracking router and include in `main.py`.
4. Add services for tracking, checkins, moments, push.
5. Add worker processes and startup scripts.
6. Add tests and seed fixtures for movement/check-in scenarios.
7. Update OpenAPI and regenerate Flutter `dora_api` client package.

## 15.2 Flutter Checklist

1. Add dependencies for messaging/notifications/background tasks.
2. Add Drift tables + migrations + DAOs.
3. Implement tracking capture and sync workers.
4. Implement push token registration and deep-link handlers.
5. Add live capture controls to trip surfaces.
6. Add candidate confirmation UI.
7. Add moment quick-capture flow and editor mapping.
8. Add tests for migrations, queues, and UX state transitions.

## 16. Risks and Mitigations

1. Battery drain from frequent sampling.
   - Mitigation: adaptive intervals, pause when stationary, batching.
2. False positive check-ins.
   - Mitigation: user confirmation + confidence threshold + cooldown.
3. Background tracking OS restrictions.
   - Mitigation: platform-specific fallback modes and robust retry queues.
4. Privacy concerns.
   - Mitigation: clear consent, retention controls, and transparent toggles.
5. Sync conflict between auto and manual edits.
   - Mitigation: provenance fields, manual lock semantics, tombstones.

## 17. Open Questions (To Resolve Before Phase 2)

1. Exact inactivity duration by market/user tier.
2. Should airport transitions be explicit first-class event type in V1.
3. Whether moments should appear in unified components timeline in V1 or V2.
4. Whether to use only FCM or add APNs direct provider abstraction now.
5. Retention policy defaults for raw points by region/legal requirement.

## 18. Definition of Done (V1)

1. User can start/pause/resume/end live tracking from trip.
2. App captures and syncs points reliably with offline recovery.
3. Backend generates check-in candidates and sends confirmation pushes.
4. User can confirm/reject candidates and see editable trip draft.
5. User can add moments during tracking and keep them linked to trip.
6. Trip can auto-end by inactivity/end-date and generate reviewable draft.
7. Manual editing remains stable and is never overridden silently.
8. Core metrics, logs, and test coverage are in place.

## 19. Immediate Next Action

Start Phase 1 with a technical design review of:

1. data model migration set
2. tracking API contracts
3. Flutter local queue schema
4. background execution strategy per platform

