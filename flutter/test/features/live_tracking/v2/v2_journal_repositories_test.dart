import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/media_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_attempt_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_candidate_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/media_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/resolver_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/route_point_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';

void main() {
  group('V2JournalRepositories', () {
    late AppDatabase database;
    late V2SessionJournalRepository sessionRepository;
    late V2RoutePointJournalRepository routePointRepository;
    late V2EventJournalRepository eventRepository;
    late V2MediaJournalRepository mediaRepository;
    late V2ResolverJournalRepository resolverRepository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionRepository =
          V2SessionJournalRepository(SessionJournalDao(database));
      routePointRepository =
          V2RoutePointJournalRepository(RoutePointJournalDao(database));
      eventRepository = V2EventJournalRepository(EventJournalDao(database));
      mediaRepository = V2MediaJournalRepository(MediaJournalDao(database));
      resolverRepository = V2ResolverJournalRepository(
        resolverCandidateDao: ResolverCandidateJournalDao(database),
        resolverAttemptDao: ResolverAttemptJournalDao(database),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('repositories persist and read local V2 journal entities', () async {
      final now = DateTime.utc(2026, 4, 10, 13, 0);
      await sessionRepository.upsertSession(
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        controlState: 'active',
        sessionSeq: 1,
        deviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );
      await sessionRepository.upsertActivityWindow(
        windowId: 'window-1',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        windowKind: 'active',
        startedAt: now,
        windowSeq: 1,
      );
      await routePointRepository.upsertPoint(
        pointId: 'point-1',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        capturedAt: now,
        latitude: 27.7,
        longitude: 85.3,
        pointSeq: 1,
      );
      await eventRepository.upsertEvent(
        eventId: 'event-1',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        eventType: 'note',
        capturedAt: now,
        latitude: 27.7,
        longitude: 85.3,
        resolverState: 'geotag_unresolved',
        createdAt: now,
        updatedAt: now,
        eventSeq: 1,
      );
      await mediaRepository.upsertMedia(
        mediaId: 'media-1',
        eventId: 'event-1',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        mediaType: 'photo',
        localUri: '/tmp/photo.jpg',
        capturedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      await resolverRepository.upsertCandidate(
        candidateId: 'candidate-1',
        eventId: 'event-1',
        candidateVersion: 1,
        provider: 'ors',
        name: 'Nearby Place',
        latitude: 27.7005,
        longitude: 85.3005,
        confidenceScore: 0.77,
        rankIndex: 0,
        createdAt: now,
      );
      await resolverRepository.upsertAttempt(
        attemptId: 'attempt-1',
        eventId: 'event-1',
        attemptNo: 1,
        triggerReason: 'capture_created',
        startedAt: now,
        resultKind: 'review_required',
      );

      final latestSession =
          await sessionRepository.getLatestSessionForTrip('trip-1');
      final points =
          await routePointRepository.listPointsForSession('session-1');
      final unresolved =
          await eventRepository.listUnresolvedEventsForTrip('trip-1');
      final media = await mediaRepository.listMediaForEvent('event-1');
      final candidates =
          await resolverRepository.listLatestCandidatesForEvent('event-1');
      final attempts = await resolverRepository.listAttemptsForEvent('event-1');

      expect(latestSession, isNotNull);
      expect(latestSession!.sessionId, 'session-1');
      expect(points.length, 1);
      expect(unresolved.length, 1);
      expect(unresolved.first.eventId, 'event-1');
      expect(media.length, 1);
      expect(candidates.length, 1);
      expect(candidates.first.name, 'Nearby Place');
      expect(attempts.length, 1);
      expect(attempts.first.resultKind, 'review_required');
    });

    test('repositories remain local-only without api dependencies', () async {
      final now = DateTime.utc(2026, 4, 10, 13, 30);
      await sessionRepository.upsertSession(
        sessionId: 'session-local-only',
        tripLocalId: 'trip-local-only',
        controlState: 'planned',
        sessionSeq: 1,
        deviceId: 'device-1',
        createdAt: now,
        updatedAt: now,
      );
      final session =
          await sessionRepository.getSessionById('session-local-only');
      expect(session, isNotNull);

      await mediaRepository.upsertMedia(
        mediaId: 'media-local-only',
        eventId: 'event-local-only',
        sessionId: 'session-local-only',
        tripLocalId: 'trip-local-only',
        mediaType: 'photo',
        localUri: '/tmp/local-only.jpg',
        capturedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      await mediaRepository.markUploadState(
        mediaId: 'media-local-only',
        uploadState: 'staged_for_commit',
        uploadRef: 'local-ref',
      );
      final media = await mediaRepository.getMediaById('media-local-only');
      expect(media, isNotNull);
      expect(media!.uploadState, 'staged_for_commit');

      final rows = await database.customSelect(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table' AND name = 'sync_tasks'
        ''',
      ).get();
      expect(rows, isNotEmpty);
      final pendingSyncTasks =
          await (database.select(database.syncTasks)).get();
      expect(pendingSyncTasks, isEmpty);
    });

    test('repository upserts map to dao rows deterministically', () async {
      final now = DateTime.utc(2026, 4, 10, 14, 0);
      await eventRepository.upsertEvent(
        eventId: 'event-map-1',
        sessionId: 'session-map',
        tripLocalId: 'trip-map',
        eventType: 'tag',
        capturedAt: now,
        latitude: 27.5,
        longitude: 85.2,
        resolverState: 'review_required',
        createdAt: now,
        updatedAt: now,
        eventSeq: 1,
      );
      await eventRepository.upsertEvent(
        eventId: 'event-map-2',
        sessionId: 'session-map',
        tripLocalId: 'trip-map',
        eventType: 'warn',
        capturedAt: now.add(const Duration(seconds: 1)),
        latitude: 27.6,
        longitude: 85.3,
        resolverState: 'place_bound',
        createdAt: now.add(const Duration(seconds: 1)),
        updatedAt: now.add(const Duration(seconds: 1)),
        eventSeq: 2,
      );

      final rows = await database.customSelect(
        '''
        SELECT event_id, resolver_state
        FROM event_journal
        WHERE trip_local_id = 'trip-map'
        ORDER BY captured_at DESC
        ''',
      ).get();
      expect(rows.length, 2);
      expect(rows.first.read<String>('event_id'), 'event-map-2');
      expect(rows.first.read<String>('resolver_state'), 'place_bound');
      expect(rows.last.read<String>('event_id'), 'event-map-1');
      expect(rows.last.read<String>('resolver_state'), 'review_required');
    });
  });
}
