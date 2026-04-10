import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/media_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_attempt_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_candidate_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

void main() {
  group('V2JournalDaos', () {
    late AppDatabase database;
    late SessionJournalDao sessionDao;
    late RoutePointJournalDao routePointDao;
    late EventJournalDao eventDao;
    late MediaJournalDao mediaDao;
    late ResolverCandidateJournalDao candidateDao;
    late ResolverAttemptJournalDao attemptDao;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionDao = SessionJournalDao(database);
      routePointDao = RoutePointJournalDao(database);
      eventDao = EventJournalDao(database);
      mediaDao = MediaJournalDao(database);
      candidateDao = ResolverCandidateJournalDao(database);
      attemptDao = ResolverAttemptJournalDao(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('session dao stores latest session and activity windows in order',
        () async {
      final now = DateTime.utc(2026, 4, 10, 8, 0);
      await sessionDao.upsertSession(
        SessionJournalCompanion.insert(
          sessionId: 'session-1',
          tripLocalId: 'trip-1',
          controlState: 'active',
          createdAt: now,
          updatedAt: now,
          sessionSeq: 1,
          deviceId: 'device-1',
          serverTripId: const Value('server-trip-1'),
        ),
      );
      await sessionDao.upsertSession(
        SessionJournalCompanion.insert(
          sessionId: 'session-2',
          tripLocalId: 'trip-1',
          controlState: 'sealed',
          createdAt: now.add(const Duration(minutes: 1)),
          updatedAt: now.add(const Duration(minutes: 1)),
          sessionSeq: 2,
          deviceId: 'device-1',
        ),
      );

      final latest = await sessionDao.getLatestSessionForTrip('trip-1');
      expect(latest, isNotNull);
      expect(latest!.sessionId, 'session-2');

      await sessionDao.upsertActivityWindow(
        SessionActivityWindowCompanion.insert(
          windowId: 'w2',
          sessionId: 'session-2',
          tripLocalId: 'trip-1',
          windowKind: 'paused',
          startedAt: now.add(const Duration(minutes: 5)),
          windowSeq: 2,
        ),
      );
      await sessionDao.upsertActivityWindow(
        SessionActivityWindowCompanion.insert(
          windowId: 'w1',
          sessionId: 'session-2',
          tripLocalId: 'trip-1',
          windowKind: 'active',
          startedAt: now.add(const Duration(minutes: 2)),
          windowSeq: 1,
        ),
      );

      final windows =
          await sessionDao.listActivityWindowsForSession('session-2');
      expect(windows.map((window) => window.windowId).toList(), ['w1', 'w2']);
    });

    test('route point dao orders points by point sequence', () async {
      final now = DateTime.utc(2026, 4, 10, 9, 0);
      await routePointDao.upsertPoint(
        RoutePointJournalCompanion.insert(
          pointId: 'p2',
          sessionId: 'session-1',
          tripLocalId: 'trip-1',
          capturedAt: now.add(const Duration(seconds: 10)),
          latitude: 27.71,
          longitude: 85.31,
          pointSeq: 2,
        ),
      );
      await routePointDao.upsertPoint(
        RoutePointJournalCompanion.insert(
          pointId: 'p1',
          sessionId: 'session-1',
          tripLocalId: 'trip-1',
          capturedAt: now,
          latitude: 27.70,
          longitude: 85.30,
          pointSeq: 1,
        ),
      );

      final points = await routePointDao.listPointsForSession('session-1');
      expect(points.map((point) => point.pointId).toList(), ['p1', 'p2']);
    });

    test('event dao unresolved query includes review and geotag unresolved',
        () async {
      final now = DateTime.utc(2026, 4, 10, 10, 0);
      await eventDao.upsertEvent(
        EventJournalCompanion.insert(
          eventId: 'e-resolved',
          sessionId: 'session-1',
          tripLocalId: 'trip-1',
          eventType: 'note',
          capturedAt: now,
          latitude: 27.7,
          longitude: 85.3,
          resolverState: 'place_bound',
          createdAt: now,
          updatedAt: now,
          eventSeq: 1,
        ),
      );
      await eventDao.upsertEvent(
        EventJournalCompanion.insert(
          eventId: 'e-review',
          sessionId: 'session-1',
          tripLocalId: 'trip-1',
          eventType: 'photo',
          capturedAt: now.add(const Duration(minutes: 1)),
          latitude: 27.8,
          longitude: 85.4,
          resolverState: 'review_required',
          createdAt: now.add(const Duration(minutes: 1)),
          updatedAt: now.add(const Duration(minutes: 1)),
          eventSeq: 2,
        ),
      );
      await eventDao.upsertEvent(
        EventJournalCompanion.insert(
          eventId: 'e-unresolved',
          sessionId: 'session-1',
          tripLocalId: 'trip-1',
          eventType: 'tag',
          capturedAt: now.add(const Duration(minutes: 2)),
          latitude: 27.9,
          longitude: 85.5,
          resolverState: 'geotag_unresolved',
          createdAt: now.add(const Duration(minutes: 2)),
          updatedAt: now.add(const Duration(minutes: 2)),
          eventSeq: 3,
        ),
      );

      final unresolved = await eventDao.listUnresolvedEventsForTrip('trip-1');
      expect(unresolved.map((event) => event.eventId).toList(), [
        'e-unresolved',
        'e-review',
      ]);
    });

    test('media dao persists and updates upload state', () async {
      final now = DateTime.utc(2026, 4, 10, 11, 0);
      await mediaDao.upsertMedia(
        MediaJournalCompanion.insert(
          mediaId: 'm1',
          eventId: 'e1',
          sessionId: 'session-1',
          tripLocalId: 'trip-1',
          mediaType: 'photo',
          localUri: '/tmp/photo.jpg',
          capturedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await mediaDao.markUploadState(
        mediaId: 'm1',
        uploadState: 'staged_for_commit',
        uploadRef: 'file-ref-1',
      );
      final media = await mediaDao.getMediaById('m1');
      expect(media, isNotNull);
      expect(media!.uploadState, 'staged_for_commit');
      expect(media.uploadRef, 'file-ref-1');
    });

    test('resolver candidate and attempt daos return latest deterministic sets',
        () async {
      final now = DateTime.utc(2026, 4, 10, 12, 0);
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c-old',
          eventId: 'event-1',
          candidateVersion: 1,
          provider: 'ors',
          name: 'Old Candidate',
          latitude: 27.7,
          longitude: 85.3,
          rankIndex: 0,
          createdAt: now,
        ),
      );
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c-latest-2',
          eventId: 'event-1',
          candidateVersion: 2,
          provider: 'ors',
          name: 'Latest Two',
          latitude: 27.7002,
          longitude: 85.3002,
          rankIndex: 1,
          createdAt: now.add(const Duration(seconds: 2)),
        ),
      );
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c-latest-1',
          eventId: 'event-1',
          candidateVersion: 2,
          provider: 'ors',
          name: 'Latest One',
          latitude: 27.7001,
          longitude: 85.3001,
          rankIndex: 0,
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      );

      final latest = await candidateDao.listLatestCandidatesForEvent('event-1');
      expect(latest.map((candidate) => candidate.candidateId).toList(), [
        'c-latest-1',
        'c-latest-2',
      ]);

      await attemptDao.upsertAttempt(
        ResolverAttemptJournalCompanion.insert(
          attemptId: 'a1',
          eventId: 'event-1',
          attemptNo: 1,
          triggerReason: 'capture_created',
          startedAt: now,
          resultKind: 'review_required',
        ),
      );
      await attemptDao.upsertAttempt(
        ResolverAttemptJournalCompanion.insert(
          attemptId: 'a2',
          eventId: 'event-1',
          attemptNo: 2,
          triggerReason: 'network_recovered',
          startedAt: now.add(const Duration(seconds: 10)),
          resultKind: 'auto_place',
        ),
      );

      final attempts = await attemptDao.listAttemptsForEvent('event-1');
      expect(
          attempts.map((attempt) => attempt.attemptId).toList(), ['a2', 'a1']);
    });
  });
}
