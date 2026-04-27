# Flutter Data Layer with Drift - Complete Guide

This document explains how local data storage works in Flutter using Drift (SQLite), and how to add new tables for offline-first features like live tracking.

---

## Quick Reference

| Term | What | You Write? |
|------|------|------------|
| **Table** | Schema definition | ✅ Yes |
| **.g.dart** | Auto-generated code | ❌ No |
| **DAO** | Low-level DB access | ✅ Yes |
| **Repository** | Business logic | ✅ Yes |
| **build_runner** | Generates .g.dart | Run command |
| **OpenAPI** | For backend API calls | Not needed for local DB |

---

## Architecture Layers

```
┌────────────────────────────────────────────────────────────┐
│                    YOUR CODE                               │
│                                                            │
│    UI (screens, buttons) ──────────────────────────────►  │
│                                                            │
│         │                                                  │
│         ▼                                                  │
│    REPOSITORY (business logic)                            │
│         │  "createEventNow()"                             │
│         │  "getEventsForTrip()"                           │
│         │                                                  │
│         ▼                                                  │
│    DAO (database operations)                              │
│         │  "insert()" "watch()" "update()"               │
│         │                                                  │
│         ▼                                                  │
│    .g.dart (generated code)  ◄── auto-generated!         │
│         │                                                  │
│         ▼                                                  │
│    Drift Database (SQLite)                                │
│         │  (actual tables in phone)                       │
│         │                                                  │
└────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
flutter/lib/
└── core/
    └── storage/
        ├── drift_database.dart      ← Main database file
        ├── tables/                  ← Table definitions
        │   ├── tracking_sessions_table.dart
        │   ├── tracking_moments_table.dart
        │   └── tracking_events_table.dart    ← Example
        ├── daos/                    ← DAO files
        │   ├── tracking_sessions_dao.dart
        │   ├── tracking_moments_dao.dart
        │   └── tracking_events_dao.dart      ← Example
        └── database.dart            ← Generated entry point
```

---

## When To Use What

| Task | When | Command |
|------|------|---------|
| **Create NEW table** | When you need new local storage | Write in `*_table.dart` |
| **Run code generation** | After creating/modifying tables | `dart run build_runner build --delete-conflicting-outputs` |
| **Create DAO** | When you need to access that table | Write in `*_dao.dart` |
| **Create Repository** | When you need business logic | Write in `*_repository.dart` |
| **Generate OpenAPI client** | When backend has NEW APIs | `npx openapi-generator ...` |

---

## Step-by-Step: Adding a New Table

Let's say you want to add `tracking_events` table for live capture.

### Step 1: Define the Table Schema

**File:** `flutter/lib/core/storage/tables/tracking_events_table.dart`

```dart
import 'package:drift/drift.dart';

class TrackingEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tripId => text()();
  TextColumn get eventType => text()(); // note, tag, warn, photo, media
  TextColumn get note => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text()(); // local_only, synced, pending
  TextColumn get payload => text().nullable()(); // JSON extra data
}
```

**What is this?** This defines the columns of your table (like Excel headers).

---

### Step 2: Register Table in Database

**File:** `flutter/lib/core/storage/drift_database.dart`

Add the import and register in `@DriftDatabase()`:

```dart
import 'tables/tracking_events_table.dart';

@DriftDatabase(tables: [
  TrackingSessions,
  TrackingMoments,
  TrackingEvents,  // ← ADD THIS
])
class AppDatabase extends _$AppDatabase {
  // ... existing code
}
```

**Why?** Tells Drift about your new table so it knows it exists.

---

### Step 3: Run Code Generation

**Command:**

```bash
cd flutter
dart run build_runner build --delete-conflicting-outputs
```

**What happens:**
- Drift reads your table definition
- Auto-generates ~500+ lines in `tracking_events_table.g.dart`
- Creates: insert, update, delete, watch, select functions

**Why?** You shouldn't write this boilerplate manually - let the tool do it!

---

### Step 4: Create DAO

**File:** `flutter/lib/core/storage/dao/tracking_events_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../tables/tracking_events_table.dart';

part 'tracking_events_dao.g.dart';

@DriftAccessor(tables: [TrackingEvents])
class TrackingEventsDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingEventsDaoMixin {
  TrackingEventsDao(super.db);

  // Insert a new event
  Future<int> insertEvent(TrackingEventsCompanion event) {
    return into(trackingEvents).insert(event);
  }

  // Watch events for a trip (auto-updates UI)
  Stream<List<TrackingEvent>> watchEventsByTrip(String tripId) {
    return (select(trackingEvents)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  // Get events once
  Future<List<TrackingEvent>> getEventsByTrip(String tripId) {
    return (select(trackingEvents)
          ..where((t) => t.tripId.equals(tripId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  // Update sync status
  Future<bool> updateSyncStatus(int id, String status) {
    return (update(trackingEvents)..where((t) => t.id.equals(id)))
        .write(TrackingEventsCompanion(syncStatus: Value(status)))
        .then((rows) => rows > 0);
  }
}
```

**Why?** Low-level functions to read/write the table.

---

### Step 5: Register DAO in Database

**File:** `flutter/lib/core/storage/drift_database.dart`

```dart
// Add inside AppDatabase class
late final TrackingEventsDao trackingEventsDao;

@override
void doCreateMigrator(Migrator m) {
  // ... existing migrations
  m.create(trackingEvents);  // Creates the table!
}

@override
void beforeOpen(QueryExecutor e) async {
  // ... existing setup
  trackingEventsDao = TrackingEventsDao(this);
}
```

**Why?** Makes DAO accessible throughout the app.

---

### Step 6: Create Repository

**File:** `flutter/lib/features/create/data/live_tracking_event_repository.dart`

```dart
import 'package:drift/drift.dart';
import '../../core/storage/dao/tracking_events_dao.dart';
import '../../core/storage/drift_database.dart';

class LiveTrackingEventRepository {
  final TrackingEventsDao _dao;

  LiveTrackingEventRepository(this._dao);

  // Create event - what UI calls
  Future<void> createEventNow({
    required String tripId,
    required String eventType,
    String? note,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? payload,
  }) async {
    await _dao.insertEvent(TrackingEventsCompanion(
      tripId: Value(tripId),
      eventType: Value(eventType),
      note: Value(note),
      latitude: Value(latitude),
      longitude: Value(longitude),
      createdAt: Value(DateTime.now()),
      syncStatus: const Value('local_only'),
      payload: Value(payload != null ? jsonEncode(payload) : null),
    ));
  }

  // Watch recent events - for live screen UI
  Stream<List<TrackingEvent>> watchRecentEvents(String tripId) {
    return _dao.watchEventsByTrip(tripId)
        .map((events) => events.take(10).toList());
  }

  // Get events once
  Future<List<TrackingEvent>> getEvents(String tripId) {
    return _dao.getEventsByTrip(tripId);
  }
}
```

**Why?** Business logic layer - what your UI actually calls.

---

### Step 7: Register Provider (Riverpod)

**File:** Typically in `flutter/lib/features/create/providers/` or same file

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/drift_database.dart';
import 'live_tracking_event_repository.dart';

// DAO Provider
final trackingEventsDaoProvider = Provider<TrackingEventsDao>((ref) {
  return ref.watch(appDatabaseProvider).trackingEventsDao;
});

// Repository Provider
final liveTrackingEventRepositoryProvider = Provider<LiveTrackingEventRepository>((ref) {
  final dao = ref.watch(trackingEventsDaoProvider);
  return LiveTrackingEventRepository(dao);
});
```

**Why?** Makes repository accessible via Riverpod dependency injection.

---

### Step 8: Wire to UI

**File:** `flutter/lib/features/live_capture/presentation/screens/live_capture_screen.dart`

```dart
// In your build method:

// OLD (uses moments)
final momentsAsync = ref.watch(liveTrackingMomentsProvider(tripId));

// NEW (uses events)
final eventsAsync = ref.watch(liveTrackingEventRepositoryProvider)
    .watchRecentEvents(tripId);

// Use in UI
eventsAsync.when(
  data: (events) => LiveCaptureRecentEventsStrip(events: events),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

**Why?** Now your UI shows data from the new table!

---

## One-Line Summary

```
Write table → Register → Generate → Write DAO → Register → Write Repo → Register Provider → Use in UI
```

---

## What is .g.dart?

When you run `build_runner`, Drift auto-generates a `.g.dart` file.

For a table like `tracking_events_table.dart`, it generates `tracking_events_table.g.dart`:

```dart
// THIS IS AUTO-GENERATED - DON'T EDIT MANUALLY

class $TrackingEventsTable extends TrackingEvents
    with TableInfo<TrackingEvents, TrackingEvent> {
  // 500+ lines of code!
  // Contains: insert(), update(), delete(), watch(), select(), etc.
}

class TrackingEvent {
  int id;
  String tripId;
  String eventType;
  String? note;
  // ... getters/setters
}
```

This saves you from writing hundreds of lines of boilerplate code.

---

## Drift vs OpenAPI

| This is for: | Not this: |
|--------------|------------|
| Local phone storage (SQLite) | Backend API calls |
| Offline-first features | Calling REST endpoints |
| Tables in your app | OpenAPI/Swagger |

**OpenAPI** is for generating Dart code to call backend APIs.

**Drift** is for storing data locally on the phone.

---

## Common Commands

```bash
# Generate Drift code after table changes
cd flutter
dart run build_runner build --delete-conflicting-outputs

# Generate only drift (faster)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (during development)
dart run build_runner build --watch

# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

## Migration (When Schema Changes)

If you modify a table (add column, change type), you need to create a migration:

**File:** `flutter/lib/core/storage/migrations/` (or within drift_database.dart)

```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      // Run on first creation
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Run when upgrading schema versions
      if (from < 2) {
        // Add new column
        await m.addColumn(trackingEvents, trackingEvents.payload);
      }
    },
  );
}
```

---

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Table not found" | Run `dart run build_runner build` |
| "Method not found" | Regenerate with build_runner |
| "DAOs not registered" | Add to `beforeOpen()` in drift_database.dart |
| "Provider not found" | Check provider is registered in main.dart |

---

## Related Concepts

- **Offline-first**: Data stored locally first, synced later
- **Sync worker**: Background task that syncs local data to backend
- **Conflict resolution**: What happens when local and server data differ

---

## When You Need Backend (API)

If you need to call a NEW backend endpoint:

1. Backend must add the endpoint first
2. Run: `curl http://localhost:8000/openapi.json -o flutter/openapi.json`
3. Run: `cd flutter && npx @openapitools/openapi-generator-cli generate -c openapi-generator-config.yaml`
4. Use generated API in your repository

**For C2 (current work):** We are NOT calling new backend APIs - just storing locally.

---

## Summary

| Step | File | What to Do |
|------|------|------------|
| 1 | `tables/*_table.dart` | Define columns |
| 2 | `drift_database.dart` | Register table |
| 3 | Terminal | Run `dart run build_runner build` |
| 4 | `daos/*_dao.dart` | Write DAO |
| 5 | `drift_database.dart` | Register DAO |
| 6 | `*_repository.dart` | Write business logic |
| 7 | Provider file | Register in Riverpod |
| 8 | Screen | Use in UI |
