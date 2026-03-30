import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_repository.dart';

void main() {
  group('LiveTrackingEventRepository', () {
    late AppDatabase database;
    late TrackingEventDao eventDao;
    late LiveTrackingEventRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      eventDao = TrackingEventDao(database);
      repository = LiveTrackingEventRepository(
        trackingEventDao: eventDao,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('createEventNow persists local-only event rows', () async {
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
      expect(event.syncStatus, 'local_only');
      expect(event.payloadJson, contains('"source":"live_capture"'));
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
