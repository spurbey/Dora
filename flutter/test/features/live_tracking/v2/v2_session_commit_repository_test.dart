import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/media_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_chunk_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_job_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_media_item_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_repository.dart';

void main() {
  group('V2SessionCommitRepository', () {
    late AppDatabase database;
    late SessionJournalDao sessionDao;
    late SessionCommitJobDao jobDao;
    late SessionCommitMediaItemDao mediaItemDao;
    late SessionCommitChunkDao chunkDao;
    late EventJournalDao eventDao;
    late MediaJournalDao mediaDao;
    late RoutePointJournalDao routePointDao;
    late V2SessionCommitRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionDao = SessionJournalDao(database);
      jobDao = SessionCommitJobDao(database);
      mediaItemDao = SessionCommitMediaItemDao(database);
      chunkDao = SessionCommitChunkDao(database);
      eventDao = EventJournalDao(database);
      mediaDao = MediaJournalDao(database);
      routePointDao = RoutePointJournalDao(database);
      repository = V2SessionCommitRepository(
        database: database,
        sessionDao: sessionDao,
        jobDao: jobDao,
        mediaItemDao: mediaItemDao,
        chunkDao: chunkDao,
        eventDao: eventDao,
        mediaDao: mediaDao,
        routePointDao: routePointDao,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test(
        'reuses deterministic job for same seal and creates new job for new seal',
        () async {
      final now = DateTime.utc(2026, 4, 12, 8, 0);
      await _insertSealedSession(
        sessionDao: sessionDao,
        sessionId: 'session-1',
        tripId: 'trip-1',
        sealVersion: 1,
        now: now,
      );

      final first =
          await repository.ensureJobForSession(sessionId: 'session-1');
      final second =
          await repository.ensureJobForSession(sessionId: 'session-1');
      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.jobId, 'commit:session-1:1');
      expect(second!.jobId, first.jobId);

      await sessionDao.upsertSession(
        SessionJournalCompanion(
          sessionId: const Value('session-1'),
          tripLocalId: const Value('trip-1'),
          controlState: const Value('sealed'),
          stopServerPending: const Value(0),
          startAckAt: Value(now),
          stopAckAt: Value(now),
          startedAt: Value(now.subtract(const Duration(minutes: 10))),
          endedAt: Value(now),
          stopClientEventId: const Value('stop-1'),
          createdAt: Value(now.subtract(const Duration(minutes: 10))),
          updatedAt: Value(now.add(const Duration(minutes: 1))),
          sealVersion: const Value(2),
          startRequestSeq: const Value(1),
          sessionSeq: const Value(1),
          deviceId: const Value('device-1'),
          serverTripId: const Value('remote-trip-1'),
        ),
      );

      final third =
          await repository.ensureJobForSession(sessionId: 'session-1');
      expect(third, isNotNull);
      expect(third!.jobId, 'commit:session-1:2');
    });

    test('lease prevents steal before TTL and allows stale takeover', () async {
      final now = DateTime.utc(2026, 4, 12, 9, 0);
      await _insertSealedSession(
        sessionDao: sessionDao,
        sessionId: 'session-lease',
        tripId: 'trip-lease',
        sealVersion: 1,
        now: now,
      );
      final job =
          await repository.ensureJobForSession(sessionId: 'session-lease');
      expect(job, isNotNull);

      final ownerA = await repository.acquireLease(
        jobId: job!.jobId,
        ownerId: 'owner-a',
        now: now,
      );
      expect(ownerA, isNotNull);

      final ownerBTooSoon = await repository.acquireLease(
        jobId: job.jobId,
        ownerId: 'owner-b',
        now: now.add(const Duration(minutes: 1)),
      );
      expect(ownerBTooSoon, isNull);

      final ownerBStale = await repository.acquireLease(
        jobId: job.jobId,
        ownerId: 'owner-b',
        now: now.add(const Duration(minutes: 6)),
      );
      expect(ownerBStale, isNotNull);
      expect(ownerBStale!.executionOwnerId, 'owner-b');
      expect(ownerBStale.leaseVersion, greaterThan(1));
    });

    test('prepareSnapshotIfMissing is immutable across retries', () async {
      final now = DateTime.utc(2026, 4, 12, 10, 0);
      await _insertSealedSession(
        sessionDao: sessionDao,
        sessionId: 'session-snapshot',
        tripId: 'trip-snapshot',
        sealVersion: 1,
        now: now,
      );
      await _insertEventMediaAndPoint(
        eventDao: eventDao,
        mediaDao: mediaDao,
        routePointDao: routePointDao,
        sessionId: 'session-snapshot',
        tripId: 'trip-snapshot',
        suffix: 'a',
        at: now,
      );

      final job =
          await repository.ensureJobForSession(sessionId: 'session-snapshot');
      expect(job, isNotNull);
      await repository.prepareSnapshotIfMissing(jobId: job!.jobId);
      final first = await repository.getJobById(job.jobId);
      final firstChunks = await chunkDao.listChunksForJob(job.jobId);
      final firstMedia = await mediaItemDao.listItemsForJob(job.jobId);

      await _insertEventMediaAndPoint(
        eventDao: eventDao,
        mediaDao: mediaDao,
        routePointDao: routePointDao,
        sessionId: 'session-snapshot',
        tripId: 'trip-snapshot',
        suffix: 'b',
        at: now.add(const Duration(minutes: 1)),
      );
      await repository.prepareSnapshotIfMissing(jobId: job.jobId);

      final second = await repository.getJobById(job.jobId);
      final secondChunks = await chunkDao.listChunksForJob(job.jobId);
      final secondMedia = await mediaItemDao.listItemsForJob(job.jobId);

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(second!.snapshotHash, first!.snapshotHash);
      expect(second.snapshotEventCount, first.snapshotEventCount);
      expect(second.snapshotMediaCount, first.snapshotMediaCount);
      expect(second.snapshotPointCount, first.snapshotPointCount);
      expect(secondChunks.length, firstChunks.length);
      expect(secondMedia.length, firstMedia.length);

      final decodedPayload =
          jsonDecode(firstChunks.first.payloadJson) as Map<String, dynamic>;
      final events = decodedPayload['events'] as List<dynamic>;
      final media = decodedPayload['media'] as List<dynamic>;
      final routePoints = decodedPayload['route_points'] as List<dynamic>;
      final firstEvent = events.first as Map<String, dynamic>;
      expect(firstEvent.containsKey('latitude'), isTrue);
      expect(firstEvent.containsKey('decision_source'), isTrue);
      expect(firstEvent.containsKey('manual_lock'), isTrue);
      expect(firstEvent.containsKey('place_bind_name'), isTrue);
      expect(firstEvent.containsKey('geotag_final_reason'), isTrue);
      expect((media.first as Map<String, dynamic>).containsKey('bytes_size'),
          isTrue);
      expect((media.first as Map<String, dynamic>).containsKey('upload_state'),
          isTrue);
      expect(routePoints, isNotEmpty);
      expect(
          (routePoints.first as Map<String, dynamic>).containsKey('point_seq'),
          isTrue);
    });
  });
}

Future<void> _insertSealedSession({
  required SessionJournalDao sessionDao,
  required String sessionId,
  required String tripId,
  required int sealVersion,
  required DateTime now,
}) {
  return sessionDao.upsertSession(
    SessionJournalCompanion.insert(
      sessionId: sessionId,
      tripLocalId: tripId,
      controlState: 'sealed',
      stopServerPending: const Value(0),
      startAckAt: Value(now.subtract(const Duration(minutes: 10))),
      stopAckAt: Value(now),
      startedAt: Value(now.subtract(const Duration(minutes: 10))),
      endedAt: Value(now),
      stopClientEventId: Value('stop-$sessionId'),
      createdAt: now.subtract(const Duration(minutes: 10)),
      updatedAt: now,
      sealVersion: Value(sealVersion),
      startRequestSeq: const Value(1),
      sessionSeq: 1,
      deviceId: 'device-1',
      serverTripId: const Value('remote-trip'),
    ),
  );
}

Future<void> _insertEventMediaAndPoint({
  required EventJournalDao eventDao,
  required MediaJournalDao mediaDao,
  required RoutePointJournalDao routePointDao,
  required String sessionId,
  required String tripId,
  required String suffix,
  required DateTime at,
}) async {
  await eventDao.upsertEvent(
    EventJournalCompanion.insert(
      eventId: 'event-$suffix',
      sessionId: sessionId,
      tripLocalId: tripId,
      eventType: 'note',
      capturedAt: at,
      latitude: 27.7,
      longitude: 85.3,
      resolverState: 'geotag_unresolved',
      decisionSource: const Value(null),
      manualLock: const Value(0),
      placeBindKind: const Value(null),
      placeBindId: const Value(null),
      placeBindName: const Value(null),
      geotagFinalReason: const Value(null),
      candidateSetVersion: const Value(0),
      createdAt: at,
      updatedAt: at,
      eventSeq: 1,
    ),
  );

  await mediaDao.upsertMedia(
    MediaJournalCompanion.insert(
      mediaId: 'media-$suffix',
      eventId: 'event-$suffix',
      sessionId: sessionId,
      tripLocalId: tripId,
      mediaType: 'photo',
      localUri: '/tmp/photo-$suffix.jpg',
      mimeType: const Value('image/jpeg'),
      bytesSize: const Value(2048),
      capturedAt: at,
      uploadState: const Value('local_only'),
      uploadRef: const Value(null),
      createdAt: at,
      updatedAt: at,
    ),
  );

  await routePointDao.upsertPoint(
    RoutePointJournalCompanion.insert(
      pointId: 'point-$suffix',
      sessionId: sessionId,
      tripLocalId: tripId,
      capturedAt: at,
      latitude: 27.7,
      longitude: 85.3,
      source: const Value('device_gps'),
      pointSeq: 1,
      accuracyM: const Value(5),
      speedMps: const Value(0.5),
    ),
  );
}
