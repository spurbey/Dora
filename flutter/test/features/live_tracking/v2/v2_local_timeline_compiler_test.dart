import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/media_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_projection_local_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/timeline_compile_cursor_dao.dart';
import 'package:dora/core/storage/daos/v2/timeline_projection_local_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_projection_repository.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_timeline_compiler.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/media_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/route_point_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';

void main() {
  group('V2LocalTimelineCompiler', () {
    late AppDatabase database;
    late V2SessionJournalRepository sessionRepository;
    late V2EventJournalRepository eventRepository;
    late V2MediaJournalRepository mediaRepository;
    late V2RoutePointJournalRepository routePointRepository;
    late V2LocalProjectionRepository projectionRepository;
    late V2LocalTimelineCompiler compiler;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionRepository =
          V2SessionJournalRepository(SessionJournalDao(database));
      eventRepository = V2EventJournalRepository(EventJournalDao(database));
      mediaRepository = V2MediaJournalRepository(MediaJournalDao(database));
      routePointRepository =
          V2RoutePointJournalRepository(RoutePointJournalDao(database));
      projectionRepository = V2LocalProjectionRepository(
        timelineDao: TimelineProjectionLocalDao(database),
        routeDao: RouteProjectionLocalDao(database),
        cursorDao: TimelineCompileCursorDao(database),
      );
      compiler = V2LocalTimelineCompiler(
        database: database,
        projectionRepository: projectionRepository,
        sessionRepository: sessionRepository,
        eventRepository: eventRepository,
        mediaRepository: mediaRepository,
        routePointRepository: routePointRepository,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('full compile writes timeline/route projection and chip fallback',
        () async {
      final startedAt = DateTime.utc(2026, 4, 11, 8, 0);
      await sessionRepository.upsertSession(
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        controlState: 'sealed',
        startedAt: startedAt,
        endedAt: startedAt.add(const Duration(minutes: 10)),
        sessionSeq: 1,
        deviceId: 'device-1',
        createdAt: startedAt,
        updatedAt: startedAt.add(const Duration(minutes: 10)),
      );
      await eventRepository.upsertEvent(
        eventId: 'event-place',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        eventType: 'note',
        capturedAt: startedAt.add(const Duration(minutes: 1)),
        latitude: 27.7000,
        longitude: 85.3000,
        resolverState: 'place_bound',
        placeBindKind: 'trip_place',
        placeBindId: 'place-1',
        placeBindName: 'Basantapur',
        decisionSource: 'manual_confirm_place',
        manualLock: 1,
        createdAt: startedAt.add(const Duration(minutes: 1)),
        updatedAt: startedAt.add(const Duration(minutes: 1)),
        eventSeq: 1,
      );
      await eventRepository.upsertEvent(
        eventId: 'event-route',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        eventType: 'photo',
        capturedAt: startedAt.add(const Duration(minutes: 2)),
        latitude: 27.7004,
        longitude: 85.3004,
        resolverState: 'geotag_final',
        geotagFinalReason: 'user_keep_geotag',
        createdAt: startedAt.add(const Duration(minutes: 2)),
        updatedAt: startedAt.add(const Duration(minutes: 2)),
        eventSeq: 2,
      );
      await mediaRepository.upsertMedia(
        mediaId: 'media-1',
        eventId: 'event-route',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        mediaType: 'photo',
        localUri: '/tmp/photo.jpg',
        capturedAt: startedAt.add(const Duration(minutes: 2)),
        createdAt: startedAt.add(const Duration(minutes: 2)),
        updatedAt: startedAt.add(const Duration(minutes: 2)),
      );
      await routePointRepository.upsertPoint(
        pointId: 'point-1',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        capturedAt: startedAt.add(const Duration(seconds: 30)),
        latitude: 27.7002,
        longitude: 85.3002,
        pointSeq: 1,
      );
      await routePointRepository.upsertPoint(
        pointId: 'point-2',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        capturedAt: startedAt.add(const Duration(minutes: 5)),
        latitude: 27.7005,
        longitude: 85.3005,
        pointSeq: 2,
      );
      await compiler.compileTrip(tripId: 'trip-1');

      final entries = await projectionRepository.listTimelineEntries('trip-1');
      final segments = await projectionRepository.listRouteSegments('trip-1');
      final cursor = await projectionRepository.getCursor('trip-1');
      expect(entries.length, 3);
      expect(segments.length, 1);
      expect(cursor, isNotNull);

      final placeEntry = entries.firstWhere(
        (entry) => entry.sourceId == 'event-place',
      );
      expect(placeEntry.bucketType, 'place');
      expect(placeEntry.placeBindName, 'Basantapur');
      expect(placeEntry.syncChipState, 'commit_pending');

      final routeEntry = entries.firstWhere(
        (entry) => entry.sourceId == 'event-route',
      );
      expect(routeEntry.bucketType, 'on_route');
      expect(routeEntry.routeSegmentKey, isNotNull);
      expect(routeEntry.routeDistanceM, isNotNull);
      expect(routeEntry.routeDistanceM!, lessThanOrEqualTo(100.0));
    });

    test('incremental compile updates rows and watermarks', () async {
      final now = DateTime.utc(2026, 4, 11, 9, 0);
      await sessionRepository.upsertSession(
        sessionId: 'session-2',
        tripLocalId: 'trip-2',
        controlState: 'active',
        startedAt: now,
        sessionSeq: 1,
        deviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );
      await eventRepository.upsertEvent(
        eventId: 'event-1',
        sessionId: 'session-2',
        tripLocalId: 'trip-2',
        eventType: 'note',
        capturedAt: now.add(const Duration(minutes: 1)),
        latitude: 27.71,
        longitude: 85.31,
        resolverState: 'geotag_unresolved',
        createdAt: now.add(const Duration(minutes: 1)),
        updatedAt: now.add(const Duration(minutes: 1)),
        eventSeq: 1,
      );

      await compiler.compileTrip(tripId: 'trip-2');
      final initialCursor = await projectionRepository.getCursor('trip-2');
      expect(initialCursor, isNotNull);

      final updatedAt = now.add(const Duration(minutes: 2));
      await eventRepository.updateResolverOutcome(
        eventId: 'event-1',
        resolverState: 'place_bound',
        decisionSource: 'manual_confirm_place',
        manualLock: 1,
        placeBindKind: 'trip_place',
        placeBindId: 'place-2',
        placeBindName: 'Bhaktapur',
        updatedAt: updatedAt,
      );

      await compiler.compileTrip(tripId: 'trip-2');

      final entries = await projectionRepository.listTimelineEntries('trip-2');
      final updatedEntry =
          entries.firstWhere((entry) => entry.sourceId == 'event-1');
      expect(updatedEntry.bucketType, 'place');
      expect(updatedEntry.placeBindName, 'Bhaktapur');

      final updatedCursor = await projectionRepository.getCursor('trip-2');
      expect(updatedCursor, isNotNull);
      expect(
        updatedCursor!.lastEventUpdatedAt!.isAfter(
          initialCursor!.lastEventUpdatedAt ??
              DateTime.fromMillisecondsSinceEpoch(0),
        ),
        isTrue,
      );
    });
  });
}
