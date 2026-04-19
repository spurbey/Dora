import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/config/live_system_v2_gate.dart';
import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_chunk_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_job_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_media_item_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_orchestrator.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';

void main() {
  group('V2SessionCommitOrchestrator', () {
    late AppDatabase database;
    late SessionJournalDao sessionDao;
    late SessionCommitJobDao jobDao;
    late V2SessionCommitRepository commitRepository;
    late V2SessionCommitOrchestrator orchestrator;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionDao = SessionJournalDao(database);
      jobDao = SessionCommitJobDao(database);
      commitRepository = V2SessionCommitRepository(
        database: database,
        sessionDao: sessionDao,
        jobDao: jobDao,
        mediaItemDao: SessionCommitMediaItemDao(database),
        chunkDao: SessionCommitChunkDao(database),
        eventDao: EventJournalDao(database),
        mediaDao: database.mediaDao,
        mediaAttachmentsDao: database.mediaAttachmentsDao,
        routePointDao: RoutePointJournalDao(database),
      );
      orchestrator = V2SessionCommitOrchestrator(
        gate: LiveSystemV2Gate(
          readFlags: () => const LiveSystemV2FlagSnapshot(
            enableLiveSystemV2: true,
            enableV2LocalJournal: true,
            enableV2LocalCompiler: true,
            enableV2SessionCommitWorker: true,
            enableV2TripPublishWorker: false,
            enableV2BackendIngest: false,
            enableV2LiveEditorUiContract: true,
          ),
        ),
        sessionRepository: V2SessionJournalRepository(sessionDao),
        commitRepository: commitRepository,
        now: () => DateTime.utc(2026, 4, 12, 12, 0),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('backend ingest off prepares snapshot and stays commit_pending',
        () async {
      final now = DateTime.utc(2026, 4, 12, 12, 0);
      await sessionDao.upsertSession(
        SessionJournalCompanion.insert(
          sessionId: 'session-orchestrator',
          tripLocalId: 'trip-orchestrator',
          controlState: 'sealed',
          stopServerPending: const Value(0),
          startAckAt: Value(now.subtract(const Duration(minutes: 5))),
          stopAckAt: Value(now),
          startedAt: Value(now.subtract(const Duration(minutes: 5))),
          endedAt: Value(now),
          stopClientEventId: const Value('stop-session-orchestrator'),
          createdAt: now.subtract(const Duration(minutes: 5)),
          updatedAt: now,
          sealVersion: const Value(1),
          startRequestSeq: const Value(1),
          sessionSeq: 1,
          deviceId: 'device-1',
          serverTripId: const Value('remote-trip'),
        ),
      );

      await orchestrator.runForTrip(
        tripId: 'trip-orchestrator',
        source: V2CommitTriggerSource.editorOpen,
      );

      final job = await jobDao.getJobById('commit:session-orchestrator:1');
      expect(job, isNotNull);
      expect(job!.jobState, v2CommitStatePending);
      expect(job.snapshotHash, isNotNull);
      expect(job.snapshotCreatedAt, isNotNull);
      expect(job.isExecuting, 0);
    });
  });
}
