import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_repository.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_resolver.dart';

void main() {
  group('LiveTrackingEventRepository', () {
    late AppDatabase database;
    late SyncTaskDao syncTaskDao;
    late TrackingEventDao eventDao;
    late LiveTrackingEventRepository repository;
    late LiveTrackingEventResolver resolver;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      syncTaskDao = SyncTaskDao(database);
      eventDao = TrackingEventDao(database);
      resolver = LiveTrackingEventResolver(
        trackingEventDao: eventDao,
        placeDao: database.placeDao,
        syncTaskDao: syncTaskDao,
        geocodingService: _NoopGeocodingService(),
      );
      repository = LiveTrackingEventRepository(
        trackingEventDao: eventDao,
        syncTaskDao: syncTaskDao,
        resolver: resolver,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('createEventNow persists pending event rows and queues sync task',
        () async {
      final eventId = await repository.createEventNow(
        tripId: 'trip-1',
        eventType: LiveTrackingEventType.note,
        note: 'Reached hilltop',
        latitude: 27.7123,
        longitude: 85.3311,
        payload: const <String, dynamic>{
          'source': 'live_capture',
        },
      );

      final event = await eventDao.getEventById(eventId);
      expect(event, isNotNull);
      expect(event!.tripId, 'trip-1');
      expect(event.eventType, 'note');
      expect(event.note, 'Reached hilltop');
      expect(event.syncStatus, 'pending');
      expect(event.payloadJson, contains('"source":"live_capture"'));

      final syncTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingEvent,
        entityId: eventId,
      );
      expect(syncTask, isNotNull);
      expect(syncTask!.status, 'queued');
      expect(syncTask.operation, 'upload');
    });

    test('watchEventsForTrip returns rows ordered by recency', () async {
      await repository.createEventNow(
        tripId: 'trip-1',
        eventType: LiveTrackingEventType.tag,
        note: 'First',
      );
      await repository.createEventNow(
        tripId: 'trip-1',
        eventType: LiveTrackingEventType.warn,
        note: 'Second',
      );

      final rows = await repository.watchEventsForTrip('trip-1').first;
      expect(rows.length, 2);
      expect(rows.first.note, 'Second');
      expect(rows.last.note, 'First');
    });
  });
}

class _NoopGeocodingService implements AppGeocodingService {
  @override
  Future<GeocodingResult?> reverseGeocode(AppLatLng coordinates) async => null;

  @override
  Future<List<GeocodingResult>> searchCities(
    String query, {
    AppLatLng? proximity,
  }) async =>
      const <GeocodingResult>[];

  @override
  Future<List<GeocodingResult>> searchNearbyPoi(
    AppLatLng center, {
    int radiusMeters = 150,
    int limit = 5,
  }) async =>
      const <GeocodingResult>[];
}
