import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_media_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_repository.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_resolver.dart';

void main() {
  group('LiveTrackingEventRepository', () {
    late AppDatabase database;
    late SyncTaskDao syncTaskDao;
    late TrackingEventDao eventDao;
    late TrackingEventMediaDao eventMediaDao;
    late LiveTrackingEventRepository repository;
    late LiveTrackingEventResolver resolver;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      syncTaskDao = SyncTaskDao(database);
      eventDao = TrackingEventDao(database);
      eventMediaDao = TrackingEventMediaDao(database);
      resolver = LiveTrackingEventResolver(
        trackingEventDao: eventDao,
        placeDao: database.placeDao,
        syncTaskDao: syncTaskDao,
        geocodingService: _NoopGeocodingService(),
      );
      repository = LiveTrackingEventRepository(
        trackingEventDao: eventDao,
        trackingEventMediaDao: eventMediaDao,
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

    test('createMediaCaptureNow writes media row and queues media sync task',
        () async {
      final result = await repository.createMediaCaptureNow(
        tripId: 'trip-2',
        eventType: LiveTrackingEventType.photo,
        localPath: 'C:/tmp/photo.jpg',
        latitude: 27.7,
        longitude: 85.3,
      );
      final mediaId = result.mediaId;

      final media = await eventMediaDao.getMediaById(mediaId);
      expect(media, isNotNull);
      expect(media!.bindMode, 'route');
      expect(media.bindState, 'queued_route_upload');
      expect(media.syncStatus, 'pending');
      expect(media.anchorLatitude, 27.7);
      expect(media.anchorLongitude, 85.3);
      expect(result.decision.state, 'on_route_unresolved');

      final eventTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingEvent,
        entityId: media.eventId,
      );
      expect(eventTask, isNotNull);

      final mediaTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingEventMedia,
        entityId: mediaId,
      );
      expect(mediaTask, isNotNull);
      expect(mediaTask!.dependsOnEntityType, SyncEntityTypes.trackingEvent);
      expect(mediaTask.dependsOnEntityId, media.eventId);
    });

    test('parsePlaceHints parses place ids when present', () {
      final hints = repository.parsePlaceHints(
        '[{"place_id":"p1","name":"Cafe","latitude":27.7,"longitude":85.3,"confidence":0.6,"reason":"trip_place_radius_match"}]',
      );
      expect(hints, hasLength(1));
      expect(hints.first.placeId, 'p1');
      expect(hints.first.name, 'Cafe');
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
