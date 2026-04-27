# Live Tracking System - Complete Data Flow

This document provides a comprehensive overview of the live tracking system architecture, from user action to data storage, sync, and backend processing. It serves as a reference for understanding how data flows through the system and what components are responsible for each stage.

---

## 1. System Overview (Simplified)

```
USER ACTION          FLUTTER APP              DATABASE              BACKEND              RESULT
    │                    │                       │                     │                  │
    ▼                    ▼                       ▼                     ▼                  ▼
┌─────────┐        ┌─────────┐          ┌─────────┐         ┌─────────┐         ┌─────────┐
│ Note/   │───────▶│Capture  │───────▶│tracking_ │───────▶│  API    │───────▶│Event    │
│ Tag/    │        │Coord.   │        │ events   │        │ Endpoint│         │Stored   │
│ Warn    │        │         │        │ table    │         │         │         │in DB    │
└─────────┘        └─────────┘          └─────────┘         └─────────┘         └─────────┘
    │                    │                       │                     │                  │
    ▼                    ▼                       ▼                     ▼                  ▼
┌─────────┐        ┌─────────┐          ┌─────────┐         ┌─────────┐         ┌─────────┐
│ Session │───────▶│Runtime  │───────▶│tracking_ │───────▶│ Session │───────▶│Session  │
│ Start/  │        │Repo    │        │ sessions│        │ Commands│         │Created  │
│ Pause/  │        │         │        │ table    │         │         │         │         │
│ Stop    │        │         │        │          │         │         │         │         │
└─────────┘        └─────────┘          └─────────┘         └─────────┘         └─────────┘
    │                    │                       │                     │                  │
    ▼                    ▼                       ▼                     ▼                  ▼
┌─────────┐        ┌─────────┐          ┌─────────┐         ┌─────────┐         ┌─────────┐
│ GPS     │───────▶│Point   │───────▶│point    │───────▶│ Points  │───────▶│Points   │
│ Points  │        │Ingest  │        │ batches │        │ Batch   │         │Stored   │
│         │        │        │        │         │        │ Endpoint│         │         │
└─────────┘        └─────────┘          └─────────┘         └─────────┘         └─────────┘
```

### Full Data Flow

| Stage | What Happens | Key Files |
|-------|--------------|------------|
| **1. User Action** | User taps Note/Tag/Warn/Start/Pause/Stop | `live_capture_screen.dart` |
| **2. Coordinator** | Validates permissions, manages active sessions | `live_tracking_capture_coordinator.dart` |
| **3. Repository** | Writes to local DB, creates sync task | `live_tracking_event_repository.dart`, `live_tracking_runtime_repository.dart` |
| **4. Local DB** | Data stored in Drift tables | `tracking_events`, `tracking_sessions`, `sync_tasks` |
| **5. Sync Worker** | Background worker claims and processes tasks | `tracking_sync_worker.dart` |
| **6. API Client** | Makes HTTP calls to backend | `live_tracking_api.dart` |
| **7. Backend** | Validates, processes, stores in PostgreSQL | `live_tracking.py`, `live_tracking_service.py` |
| **8. Response** | Returns accepted/rejected, worker updates local status | Sync status updated in Drift |

---

## 2. Event Capture Flow (User Action to Local Storage)

### 2.1 User Actions

**Location:** `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`

User actions trigger data creation:

```dart
// Tag action (checkpoint)
onTag: () => _captureQuickEvent(
      eventType: LiveTrackingEventType.tag,
      note: 'Checkpoint',
      successMessage: 'Checkpoint captured locally.',
      position: capturePosition,
    ),

// Note action
onNote: () => _promptForTextCapture(
      title: 'Add Quick Note',
      eventType: LiveTrackingEventType.note,
      successMessage: 'Note captured locally.',
      position: capturePosition,
    ),

// Warn action
onWarn: () => _promptForTextCapture(
      title: 'Add Warning',
      defaultPrefix: '[Warn] ',
      eventType: LiveTrackingEventType.warn,
      successMessage: 'Warning captured locally.',
      position: capturePosition,
    ),
```

### 2.2 Repository Layer

**Location:** `flutter/lib/features/live_capture/data/live_tracking_event_repository.dart`

The repository creates the event and sync task:

```dart
Future<String> createEventNow({
  required String tripId,
  required LiveTrackingEventType eventType,
  String? note,
  double? latitude,
  double? longitude,
  Map<String, dynamic>? payload,
}) async {
  final now = _now().toUtc();
  final eventId = _uuid.v4();
  
  // Step 1: Insert event into tracking_events table
  await _trackingEventDao.upsertEvent(
    TrackingEventsCompanion.insert(
      id: eventId,
      tripId: tripId,
      eventType: eventType.wireName,  // note, warn, tag, photo, media
      note: Value(_normalizeNote(note)),
      latitude: Value(latitude),
      longitude: Value(longitude),
      payloadJson: Value(_encodeJson(payload ?? const <String, dynamic>{})),
      clientEventId: Value(_uuid.v4()),
      syncStatus: const Value('local_only'),
      localUpdatedAt: now,
      serverUpdatedAt: const Value(null),
      createdAt: now,
      updatedAt: now,
    ),
  );
  
  // Step 2: Create sync task to upload this event
  await _syncTaskDao.upsertQueuedTask(
    id: _uuid.v4(),
    entityType: SyncEntityTypes.trackingEvent,
    entityId: eventId,
    operation: 'upload',
  );
  
  return eventId;
}
```

### 2.3 Local Storage Schema

**Location:** `flutter/lib/core/storage/tables/tracking_events_table.dart`

```dart
class TrackingEvents extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get eventType => text()();         // note, warn, tag, photo, media
  TextColumn get note => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get clientEventId => text().nullable()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

---

## 3. Sync Flow (Local to Backend)

### 3.1 Worker Processing

**Location:** `flutter/lib/core/sync/tracking_sync_worker.dart`

The worker continuously claims and processes tasks:

```dart
Future<void> startIfIdle() async {
  if (_isRunning) return;
  _isRunning = true;
  try {
    while (true) {
      final sessionId = _newSessionId();
      // Claim up to maxConcurrency tasks (default: 2)
      final claimed = await _syncTaskDao.claimRunnableTasks(
        workerSessionId: sessionId,
        limit: _maxConcurrency,
        allowedEntityTypes: SyncEntityTypes.supportedByTrackingSyncWorker,
      );
      if (claimed.isEmpty) break;
      // Process each claimed task
      await Future.wait(claimed.map(_processClaimedTask), eagerError: false);
    }
  } finally {
    _isRunning = false;
  }
}
```

### 3.2 Event Processing

```dart
Future<void> _processTrackingEventTask({
  required SyncTaskRow task,
  required String? sessionId,
}) async {
  // 1. Fetch the event from local DB
  final row = await _trackingEventDao.getEventById(task.entityId);
  
  // 2. Build event payload
  final eventMap = <String, dynamic>{
    'client_event_id': clientEventId,
    'event_type': row.eventType,
    'captured_at': row.createdAt.toUtc().toIso8601String(),
    if (row.note != null) 'note': row.note!.trim(),
    if (row.latitude != null) 'location': {'latitude': row.latitude, 'longitude': row.longitude},
    if (payload.isNotEmpty) 'payload': payload,
  };
  
  // 3. Call API to upload events
  final response = await _liveTrackingApi.uploadEventsBatch(
    tripId: remoteTripId,
    idempotencyKey: _idempotencyKey(task.id, task.operation),
    events: <Map<String, dynamic>>[eventMap],
  );
  
  // 4. Handle response - check accepted/rejected
  final accepted = _asJsonList(response['accepted']);
  final rejected = _asJsonList(response['rejected']);
  
  // 5. Mark as synced or throw error
  await _trackingEventDao.markSynced(eventId: row.id, ...);
}
```

### 3.3 API Client

**Location:** `flutter/lib/core/network/live_tracking_api.dart`

```dart
@override
Future<Map<String, dynamic>> uploadEventsBatch({
  required String tripId,
  required String idempotencyKey,
  required List<Map<String, dynamic>> events,
}) async {
  final response = await _dio.post<dynamic>(
    _v1Path('/trips/$tripId/tracking/events:batch'),
    data: <String, dynamic>{
      'events': events,
    },
    options: _idempotentOptions(idempotencyKey),
  );
  return _asJsonMap(response.data);
}
```

---

## 4. Backend Processing

### 4.1 API Endpoint

**Location:** `backend/app/api/v1/live_tracking.py`

```python
@router.post(
    "/trips/{trip_id}/tracking/events:batch",
    response_model=TrackingEventsBatchResponse,
)
async def ingest_events_batch(
    trip_id: UUID,
    request: TrackingEventsBatchRequest,
    response: Response,
    x_idempotency_key: str = Header(..., alias="X-Idempotency-Key"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    service = LiveTrackingService(db)
    result = service.run_idempotent_mutation(
        user_id=current_user.id,
        endpoint_signature="POST:/trips/{trip_id}/tracking/events:batch",
        idempotency_key=x_idempotency_key,
        request_payload=_idempotency_payload(request.model_dump(mode="json"), trip_id=trip_id),
        operation=lambda: service.ingest_events_batch(
            trip_id=trip_id,
            user_id=current_user.id,
            events=[event.model_dump() for event in request.events],
        ),
    )
```

### 4.2 Service Processing

**Location:** `backend/app/services/live_tracking_service.py`

```python
def ingest_events_batch(self, *, trip_id: UUID, user_id: UUID, events: list[dict]) -> tuple[int, dict]:
    self._get_owned_trip(trip_id=trip_id, user_id=user_id)
    
    accepted = []
    rejected = []
    
    for raw_event in events:
        # Validate client_event_id (required, must be UUID)
        client_event_id = self._parse_uuid(item.get("client_event_id"))
        
        # Validate event_type (must be note|warn|tag|photo|media)
        event_type = str(item.get("event_type")).strip().lower()
        
        # Validate captured_at (ISO-8601 datetime)
        captured_at = self._coerce_datetime(item.get("captured_at"))
        
        # Check for duplicates
        existing = self.db.query(TripTrackingEvent).filter(
            TripTrackingEvent.trip_id == trip_id,
            TripTrackingEvent.user_id == user_id,
            TripTrackingEvent.client_event_id == client_event_id,
        ).first()
        
        if existing:
            accepted.append({"client_event_id": str(client_event_id), "event_id": str(existing.id), "duplicate": True})
            continue
        
        # Create new event in database
        event = TripTrackingEvent(
            trip_id=trip_id,
            user_id=user_id,
            session_id=session_id,
            client_event_id=client_event_id,
            event_type=event_type,
            captured_at=captured_at,
            latitude=latitude,
            longitude=longitude,
            note=note,
            payload=payload,
        )
        self.db.add(event)
        accepted.append({"client_event_id": str(client_event_id), "event_id": str(event.id), "duplicate": False})
    
    return status.HTTP_202_ACCEPTED, {
        "trip_id": trip_id,
        "accepted": accepted,
        "rejected": rejected,
        "accepted_count": len(accepted),
        "rejected_count": len(rejected),
    }
```

### 4.3 Response Format

```json
{
  "trip_id": "uuid",
  "accepted": [
    {"client_event_id": "uuid", "event_id": "uuid", "duplicate": false}
  ],
  "rejected": [
    {"client_event_id": "uuid", "reason": "invalid_event_type"}
  ],
  "accepted_count": 1,
  "rejected_count": 0,
  "idempotency_replayed": false
}
```

---

## 5. Session Lifecycle Flow

### 5.1 User Action to API

**Location:** `flutter/lib/features/create/data/live_tracking_capture_coordinator.dart`

```dart
Future<TrackingSessionRow> startTracking({
  required String tripId,
  String? timezone,
  Map<String, dynamic>? deviceContext,
}) async {
  await _requireLocationAccess(requestIfDenied: true);
  final session = await _repository.startSession(
    tripId: tripId,
    timezone: timezone,
    deviceContext: deviceContext,
  );
  _activeSessions[session.id] = _ActiveTrackingSession(
    sessionId: session.id,
    tripId: session.tripId,
  );
  await _syncCaptureSubscription();
  return session;
}

Future<TrackingSessionRow?> pauseTracking({required String tripId}) async {
  final paused = await _repository.pauseSession(tripId: tripId);
  if (paused == null) return null;
  _activeSessions.remove(paused.id);
  await _syncCaptureSubscription();
  return paused;
}

Future<TrackingSessionRow?> resumeTracking({required String tripId}) async {
  await _requireLocationAccess(requestIfDenied: true);
  final resumed = await _repository.resumeSession(tripId: tripId);
  if (resumed == null) return null;
  _activeSessions[resumed.id] = _ActiveTrackingSession(...);
  await _syncCaptureSubscription();
  return resumed;
}

Future<TrackingSessionRow?> stopTracking({required String tripId}) async {
  final stopped = await _repository.stopSession(tripId: tripId);
  if (stopped == null) return null;
  _activeSessions.remove(stopped.id);
  await _syncCaptureSubscription();
  return stopped;
}
```

### 5.2 Key Design Decision: Commands are Write-Through

The session lifecycle commands (start/pause/resume/stop) are **NOT queued** - they execute immediately via direct API calls. This is a deliberate design choice:

- **No queue for commands** - Commands are write-through
- **Fail-fast** - If identity is missing, fail immediately with actionable error
- **No deferred tasks** - Session operations never create sync tasks

---

## 6. GPS Point Flow

### 6.1 Point Capture

**Location:** `flutter/lib/features/create/data/live_tracking_capture_coordinator.dart`

```dart
Future<void> _syncCaptureSubscription() async {
  if (_activeSessions.isEmpty) return;
  
  _pointSubscription = _pointStreamFactory().listen(
    (sample) {
      _restartAttempt = 0;
      _enqueuePointIngestion(sample);
    },
    onError: (_, __) { /* handle error */ },
    onDone: () { /* handle done */ },
    cancelOnError: false,
  );
}

void _enqueuePointIngestion(TrackingPointSample sample) {
  final sessions = _activeSessions.values.toList();
  _ingestTail = _ingestTail.catchError((_, __) {}).then((_) async {
    for (final session in sessions) {
      await _repository.ingestPoint(
        tripId: session.tripId,
        sessionId: session.sessionId,
        point: sample,
      );
    }
  });
}
```

### 6.2 Point Storage

The repository stores points in batches and creates sync tasks:

- Points are collected in batches
- Each batch creates a sync task
- Worker uploads batch via `POST /trips/{tripId}/tracking/points:batch`

---

## 7. Future Modules

### 7.1 Resolver (P6) - Place Binding

**Purpose:** Automatically bind events to places based on proximity

**Thresholds:**
- 50m → Check existing trip places
- 80m → Check prior resolved anchor points
- 100m → Reverse geocode
- 150m → Check nearby POIs
- fallback → on_route_unresolved

**Output:** `event.resolved_place_id`, `confidence`, `reason_code`

**Persisted on:** Event row (NOT creating new places)

**Live Strip Badges:**
- "Near X" (place matched within threshold)
- "On Route" (matched to route path)
- No badge (unresolved)

### 7.2 Compiler/Projection (P7) - Timeline Generation

**Purpose:** Transform tracking_events to editor-visible timeline entries

**Key Principle:** NEVER mutate original tracking_events rows

**Transform:**
- Group by date/day
- Sort by timestamp
- Attach resolver outputs (place badges)
- Group into timeline segments

**Output:** TimelineEntry[] → Editor Screen

### 7.3 Advisory Pipeline (P4-P5) - Guidance

**Purpose:** Provide real-time guidance during tracking

**Sources:** Google Places API, Reddit, TripAdvisor

**Pipeline:**
1. Fetch raw signals → external_signals_raw
2. Normalize → extract title, rating, place hints
3. Canonicalize → match to place graph
4. Score → compute relevance per trip/session
5. Deliver → in-app notification + optional push

---

## 8. User Perception by Screen

### 8.1 Live Capture Screen

| Component | Description |
|-----------|-------------|
| Map | Real-time GPS path drawn (from tracking/path API) + current marker |
| Top Bar | Trip name, sync status (synced/pending/blocked), current time |
| Action Dock | Photo/Media/Tag/Note/Warn buttons |
| Bottom Panel | Start/Pause/Resume/Stop controls (based on session state) |
| Recent Events Strip | Shows last N events with sync status indicators |
| Future | Weather/Traffic advisories overlay |

### 8.2 Editor Screen

| Component | Description |
|-----------|-------------|
| Map | Full trip with places, routes, and timeline markers |
| Sidebar | Trip metadata, sync status |
| Timeline | Day-by-day view with event cards |
| Live Tracking Panel | Current session state (if tracking) |
| Future | Timeline auto-populated from tracking_events (projection) |

### 8.3 My Trips Screen

| Component | Description |
|-----------|-------------|
| Trip Cards | Trip name, date range, place count, status |
| Actions | Open Editor, Start Live Tracking |
| Status Badges | "Planned", "Has Data", "Completed" |

---

## 9. Decision Summary

### Locked Decisions

| # | Decision | Details |
|---|----------|---------|
| 1 | Commands are write-through | start/pause/resume/stop are command-plane only, never queued |
| 2 | Identity-blocked start fails immediately | No queue for start, show actionable error |
| 3 | Session state is truth | session.state (active/paused/ended) is runtime truth |
| 4 | trip.status is content only | trip.status (planned/has_*/completed) is trip lifecycle only |
| 5 | Events use partial accept | events:batch returns accepted/rejected arrays |

### Completed Work

| Component | Status |
|-----------|---------|
| trip_tracking_events table | ✅ Done |
| POST events:batch endpoint | ✅ Done |
| Flutter event sync lane | ✅ Done |
| Session decoupling | ✅ Done |
| Identity recovery (404) | ✅ Done |
| Command-plane hardening | ✅ Done |

### Pending Work

| Component | Phase |
|-----------|-------|
| Resolver (place binding) | P6 |
| Compiler (timeline projection) | P7 |
| Advisory pipeline | P4-P5 |
| Real map rendering | Future |
| Media upload lane | Future (needs resolver) |

---

## 10. File Reference

### Flutter Files

| Component | File Path |
|-----------|-----------|
| User Action | `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart` |
| Coordinator | `flutter/lib/features/create/data/live_tracking_capture_coordinator.dart` |
| Event Repository | `flutter/lib/features/live_capture/data/live_tracking_event_repository.dart` |
| Runtime Repository | `flutter/lib/features/create/data/live_tracking_runtime_repository.dart` |
| Event Table | `flutter/lib/core/storage/tables/tracking_events_table.dart` |
| Event DAO | `flutter/lib/core/storage/daos/tracking_event_dao.dart` |
| Sync Worker | `flutter/lib/core/sync/tracking_sync_worker.dart` |
| API Client | `flutter/lib/core/network/live_tracking_api.dart` |

### Backend Files

| Component | File Path |
|-----------|-----------|
| API Endpoint | `backend/app/api/v1/live_tracking.py` |
| Service | `backend/app/services/live_tracking_service.py` |
| Event Model | `backend/app/models/trip_tracking_event.py` |
| Migration | `backend/alembic/versions/c9e4b7a1d2f6_add_trip_tracking_events_and_backfill_trip_statuses.py` |

---

*Document Version: 1.0*
*Last Updated: 2026-03-31*
*Purpose: Complete reference for live tracking system architecture and data flows*
