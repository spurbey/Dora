import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_candidate_journal_dao.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_inbox_provider.dart';

void main() {
  group('V2 unresolved inbox provider', () {
    late AppDatabase db;
    late ProviderContainer container;
    late EventJournalDao eventDao;
    late ResolverCandidateJournalDao candidateDao;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      eventDao = EventJournalDao(db);
      candidateDao = ResolverCandidateJournalDao(db);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('uses latest candidate version per event and caps to top 3', () async {
      final now = DateTime.utc(2026, 4, 11, 10, 0);
      await eventDao.upsertEvent(
        EventJournalCompanion.insert(
          eventId: 'e1',
          sessionId: 's1',
          tripLocalId: 't1',
          eventType: 'note',
          capturedAt: now,
          latitude: 27.7,
          longitude: 85.3,
          resolverState: 'review_required',
          createdAt: now,
          updatedAt: now,
          eventSeq: 1,
        ),
      );
      await eventDao.upsertEvent(
        EventJournalCompanion.insert(
          eventId: 'e2',
          sessionId: 's1',
          tripLocalId: 't1',
          eventType: 'tag',
          capturedAt: now.add(const Duration(minutes: 1)),
          latitude: 27.71,
          longitude: 85.31,
          resolverState: 'geotag_unresolved',
          createdAt: now.add(const Duration(minutes: 1)),
          updatedAt: now.add(const Duration(minutes: 1)),
          eventSeq: 2,
        ),
      );

      // Event e1: version 1 candidates.
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c1',
          eventId: 'e1',
          candidateVersion: 1,
          provider: 'ors',
          name: 'Old A',
          latitude: 27.7001,
          longitude: 85.3001,
          rankIndex: 0,
          createdAt: now,
        ),
      );
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c2',
          eventId: 'e1',
          candidateVersion: 1,
          provider: 'ors',
          name: 'Old B',
          latitude: 27.7002,
          longitude: 85.3002,
          rankIndex: 1,
          createdAt: now,
        ),
      );
      // Event e1: version 2 candidates (latest).
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c3',
          eventId: 'e1',
          candidateVersion: 2,
          provider: 'ors',
          name: 'New A',
          latitude: 27.7003,
          longitude: 85.3003,
          rankIndex: 0,
          createdAt: now.add(const Duration(seconds: 10)),
        ),
      );
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c4',
          eventId: 'e1',
          candidateVersion: 2,
          provider: 'ors',
          name: 'New B',
          latitude: 27.7004,
          longitude: 85.3004,
          rankIndex: 1,
          createdAt: now.add(const Duration(seconds: 11)),
        ),
      );
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c5',
          eventId: 'e1',
          candidateVersion: 2,
          provider: 'ors',
          name: 'New C',
          latitude: 27.7005,
          longitude: 85.3005,
          rankIndex: 2,
          createdAt: now.add(const Duration(seconds: 12)),
        ),
      );
      await candidateDao.upsertCandidate(
        ResolverCandidateJournalCompanion.insert(
          candidateId: 'c6',
          eventId: 'e1',
          candidateVersion: 2,
          provider: 'ors',
          name: 'New D',
          latitude: 27.7006,
          longitude: 85.3006,
          rankIndex: 3,
          createdAt: now.add(const Duration(seconds: 13)),
        ),
      );

      final inbox =
          await container.read(v2UnresolvedInboxProvider('t1').future);
      expect(inbox.length, 2);

      final e1 = inbox.firstWhere((item) => item.eventId == 'e1');
      expect(e1.topCandidates.map((c) => c.name).toList(), [
        'New A',
        'New B',
        'New C',
      ]);

      final e2 = inbox.firstWhere((item) => item.eventId == 'e2');
      expect(e2.topCandidates, isEmpty);
    });
  });
}
