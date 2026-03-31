import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_resolver.dart';

void main() {
  group('LiveTrackingEventResolver', () {
    late AppDatabase database;
    late TrackingEventDao eventDao;
    late SyncTaskDao syncTaskDao;
    late _FakeGeocodingService geocoding;
    late LiveTrackingEventResolver resolver;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      eventDao = TrackingEventDao(database);
      syncTaskDao = SyncTaskDao(database);
      geocoding = _FakeGeocodingService();
      resolver = LiveTrackingEventResolver(
        trackingEventDao: eventDao,
        placeDao: database.placeDao,
        syncTaskDao: syncTaskDao,
        geocodingService: geocoding,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('resolves against existing trip place within 50m', () async {
      final now = DateTime.utc(2026, 4, 1, 10, 0);
      await _insertPlace(
        database,
        id: 'place-1',
        tripId: 'trip-1',
        name: 'Cafe One',
        latitude: 27.7000,
        longitude: 85.3000,
        now: now,
      );
      final eventId = await _insertEvent(
        eventDao,
        id: 'event-1',
        tripId: 'trip-1',
        latitude: 27.70012,
        longitude: 85.30002,
        now: now,
      );

      final decision = await resolver.resolveEventNow(eventId);
      final updated = await eventDao.getEventById(eventId);

      expect(decision.state, 'resolved');
      expect(updated, isNotNull);
      expect(updated!.resolverState, 'resolved');
      expect(updated.resolvedPlaceId, 'place-1');
      expect(updated.resolverReasonCode, 'trip_place_radius_match');
      expect(updated.bindConfidence, greaterThanOrEqualTo(0.75));
    });

    test('resolves using nearby anchor within 80m', () async {
      final now = DateTime.utc(2026, 4, 1, 11, 0);
      await _insertEvent(
        eventDao,
        id: 'anchor-1',
        tripId: 'trip-2',
        latitude: 27.7100,
        longitude: 85.3100,
        resolvedPlaceId: 'place-anchor',
        resolverState: 'resolved',
        resolverReasonCode: 'trip_place_radius_match',
        bindConfidence: 0.91,
        now: now.subtract(const Duration(minutes: 4)),
      );
      final eventId = await _insertEvent(
        eventDao,
        id: 'event-2',
        tripId: 'trip-2',
        latitude: 27.7103,
        longitude: 85.3102,
        now: now,
      );

      final decision = await resolver.resolveEventNow(eventId);
      final updated = await eventDao.getEventById(eventId);

      expect(decision.state, 'resolved');
      expect(updated, isNotNull);
      expect(updated!.resolverState, 'resolved');
      expect(updated.resolvedPlaceId, 'place-anchor');
      expect(updated.resolverReasonCode, 'anchor_match');
    });

    test('high-confidence poi auto-creates draft place and queues place task',
        () async {
      final now = DateTime.utc(2026, 4, 1, 12, 0);
      geocoding.poi = <GeocodingResult>[
        const GeocodingResult(
          name: 'Hidden Garden',
          coordinates: AppLatLng(latitude: 27.7200, longitude: 85.3200),
        ),
      ];
      final eventId = await _insertEvent(
        eventDao,
        id: 'event-3',
        tripId: 'trip-3',
        latitude: 27.7200,
        longitude: 85.3200,
        now: now,
      );

      final decision = await resolver.resolveEventNow(eventId);
      final updated = await eventDao.getEventById(eventId);

      expect(decision.state, 'resolved');
      expect(updated, isNotNull);
      expect(updated!.resolverState, 'resolved');
      expect(updated.resolverReasonCode, 'poi_auto_created');
      expect(updated.resolvedPlaceId, isNotNull);

      final createdPlace =
          await database.placeDao.getPlaceById(updated.resolvedPlaceId!);
      expect(createdPlace, isNotNull);
      expect(createdPlace!.placeType, 'auto_resolved');

      final placeTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.place,
        entityId: updated.resolvedPlaceId!,
      );
      expect(placeTask, isNotNull);
      expect(placeTask!.operation, 'create');
      expect(placeTask.dependsOnEntityType, SyncEntityTypes.trip);
      expect(placeTask.dependsOnEntityId, 'trip-3');
    });

    test('medium-confidence candidate becomes review_required with hints',
        () async {
      final now = DateTime.utc(2026, 4, 1, 13, 0);
      geocoding.poi = <GeocodingResult>[
        GeocodingResult(
          name: 'Quiet Terrace',
          coordinates: AppLatLng(
            latitude: 27.7300 + _offsetLat(95),
            longitude: 85.3300,
          ),
        ),
      ];
      final eventId = await _insertEvent(
        eventDao,
        id: 'event-4',
        tripId: 'trip-4',
        latitude: 27.7300,
        longitude: 85.3300,
        now: now,
      );

      final decision = await resolver.resolveEventNow(eventId);
      final updated = await eventDao.getEventById(eventId);

      expect(decision.state, 'review_required');
      expect(updated, isNotNull);
      expect(updated!.resolverState, 'review_required');
      expect(updated.resolverReasonCode, 'ambiguous_candidates');
      expect(updated.resolutionHintJson, isNotNull);

      final places = await database.placeDao.getPlacesForTrip('trip-4');
      expect(places, isEmpty);
    });

    test('no candidate stays on_route_unresolved', () async {
      final now = DateTime.utc(2026, 4, 1, 14, 0);
      final eventId = await _insertEvent(
        eventDao,
        id: 'event-5',
        tripId: 'trip-5',
        latitude: 27.7400,
        longitude: 85.3400,
        now: now,
      );

      final decision = await resolver.resolveEventNow(eventId);
      final updated = await eventDao.getEventById(eventId);

      expect(decision.state, 'on_route_unresolved');
      expect(updated, isNotNull);
      expect(updated!.resolverState, 'on_route_unresolved');
      expect(updated.resolverReasonCode, 'no_candidate');
    });

    test('threshold boundaries respect >=0.75 and >=0.45 rules', () async {
      final now = DateTime.utc(2026, 4, 1, 15, 0);

      geocoding.poi = <GeocodingResult>[
        const GeocodingResult(
          name: 'Exact Threshold High',
          coordinates: AppLatLng(latitude: 27.7500, longitude: 85.3500),
        ),
      ];
      final resolvedId = await _insertEvent(
        eventDao,
        id: 'event-6',
        tripId: 'trip-6',
        latitude: 27.7500,
        longitude: 85.3500,
        now: now,
      );
      await resolver.resolveEventNow(resolvedId);
      final resolved = await eventDao.getEventById(resolvedId);
      expect(resolved, isNotNull);
      expect(resolved!.resolverState, 'resolved');
      expect(resolved.bindConfidence, greaterThanOrEqualTo(0.75));

      geocoding.poi = <GeocodingResult>[
        GeocodingResult(
          name: 'Exact Threshold Mid',
          coordinates: AppLatLng(
            latitude: 27.7510 + _offsetLat(98),
            longitude: 85.3510,
          ),
        ),
      ];
      final reviewId = await _insertEvent(
        eventDao,
        id: 'event-7',
        tripId: 'trip-7',
        latitude: 27.7510,
        longitude: 85.3510,
        now: now,
      );
      await resolver.resolveEventNow(reviewId);
      final review = await eventDao.getEventById(reviewId);
      expect(review, isNotNull);
      expect(review!.resolverState, 'review_required');
      expect(review.bindConfidence, greaterThanOrEqualTo(0.45));
    });
  });
}

Future<String> _insertEvent(
  TrackingEventDao dao, {
  required String id,
  required String tripId,
  required double latitude,
  required double longitude,
  required DateTime now,
  String? resolvedPlaceId,
  String resolverState = 'on_route_unresolved',
  String? resolverReasonCode,
  double? bindConfidence,
}) async {
  await dao.upsertEvent(
    TrackingEventsCompanion.insert(
      id: id,
      tripId: tripId,
      eventType: 'note',
      latitude: Value(latitude),
      longitude: Value(longitude),
      payloadJson: const Value('{}'),
      clientEventId: Value('client-$id'),
      resolverState: Value(resolverState),
      resolverReasonCode: Value(resolverReasonCode),
      bindConfidence: Value(bindConfidence),
      resolvedPlaceId: Value(resolvedPlaceId),
      syncStatus: const Value('pending'),
      localUpdatedAt: now,
      createdAt: now,
      updatedAt: now,
      serverUpdatedAt: const Value(null),
    ),
  );
  return id;
}

Future<void> _insertPlace(
  AppDatabase database, {
  required String id,
  required String tripId,
  required String name,
  required double latitude,
  required double longitude,
  required DateTime now,
}) {
  return database.placeDao.insertPlace(
    PlacesCompanion.insert(
      id: id,
      tripId: tripId,
      name: name,
      coordinates: AppLatLng(latitude: latitude, longitude: longitude),
      orderIndex: 0,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
      serverPlaceId: const Value(null),
    ),
  );
}

double _offsetLat(double meters) => meters / 111111.0;

class _FakeGeocodingService implements AppGeocodingService {
  GeocodingResult? reverse;
  List<GeocodingResult> poi = const <GeocodingResult>[];

  @override
  Future<GeocodingResult?> reverseGeocode(AppLatLng coordinates) async =>
      reverse;

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
      poi;
}
