import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_attempt_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_candidate_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/resolver_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_client.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_orchestrator.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';

void main() {
  group('V2ResolverOrchestrator', () {
    late AppDatabase database;
    late V2EventJournalRepository eventRepository;
    late V2ResolverJournalRepository resolverRepository;
    late _FakeResolverClient resolverClient;
    late V2ResolverOrchestrator orchestrator;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      eventRepository = V2EventJournalRepository(EventJournalDao(database));
      resolverRepository = V2ResolverJournalRepository(
        resolverCandidateDao: ResolverCandidateJournalDao(database),
        resolverAttemptDao: ResolverAttemptJournalDao(database),
      );
      resolverClient = _FakeResolverClient();
      orchestrator = V2ResolverOrchestrator(
        eventRepository: eventRepository,
        resolverRepository: resolverRepository,
        resolverClient: resolverClient,
        uuid: const Uuid(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('manual lock skips automatic resolver updates', () async {
      final now = DateTime.utc(2026, 4, 11, 8, 0);
      await eventRepository.upsertEvent(
        eventId: 'event-locked',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        eventType: 'note',
        capturedAt: now,
        latitude: 27.7,
        longitude: 85.3,
        resolverState: 'geotag_unresolved',
        manualLock: 1,
        decisionSource: 'user_keep_geotag',
        createdAt: now,
        updatedAt: now,
        eventSeq: 1,
      );

      await orchestrator.resolveCaptureCreated(
        tripId: 'trip-1',
        eventId: 'event-locked',
      );

      final event = await eventRepository.getEventById('event-locked');
      final attempts =
          await resolverRepository.listAttemptsForEvent('event-locked');
      expect(event, isNotNull);
      expect(event!.resolverState, 'geotag_unresolved');
      expect(attempts.length, 1);
      expect(attempts.first.resultKind, 'skipped_locked');
    });

    test('runs exactly one recovery retry after provider error', () async {
      final now = DateTime.utc(2026, 4, 11, 9, 0);
      await eventRepository.upsertEvent(
        eventId: 'event-retry',
        sessionId: 'session-1',
        tripLocalId: 'trip-1',
        eventType: 'photo',
        capturedAt: now,
        latitude: 27.7,
        longitude: 85.3,
        resolverState: 'geotag_unresolved',
        createdAt: now,
        updatedAt: now,
        eventSeq: 1,
      );

      resolverClient.failNext = true;
      await orchestrator.resolveCaptureCreated(
        tripId: 'trip-1',
        eventId: 'event-retry',
      );

      resolverClient.candidates = const [
        V2ResolverCandidate(
          providerPlaceId: 'gid:123',
          name: 'Cafe',
          label: 'Cafe label',
          coordinates: AppLatLng(latitude: 27.7001, longitude: 85.3001),
          confidenceScore: 0.85,
          distanceM: 24,
          rawJson: <String, dynamic>{},
        ),
      ];

      await orchestrator.runRecoveryForTrip(
        tripId: 'trip-1',
        source: V2ResolverTriggerSource.resumed,
      );
      await orchestrator.runRecoveryForTrip(
        tripId: 'trip-1',
        source: V2ResolverTriggerSource.editorOpen,
      );

      final attempts =
          await resolverRepository.listAttemptsForEvent('event-retry');
      final event = await eventRepository.getEventById('event-retry');

      expect(attempts.length, 2);
      expect(attempts[1].resultKind, 'provider_error');
      expect(attempts[0].resultKind, anyOf('auto_place', 'review_required'));
      expect(event, isNotNull);
      expect(event!.resolverState, 'place_bound');
    });
  });
}

class _FakeResolverClient extends V2ResolverClient {
  _FakeResolverClient()
      : super(
          apiKeyOverride: 'test',
        );

  bool failNext = false;
  List<V2ResolverCandidate> candidates = const <V2ResolverCandidate>[];

  @override
  Future<List<V2ResolverCandidate>> fetchReverseCandidates({
    required AppLatLng location,
    int size = 5,
  }) async {
    if (failNext) {
      failNext = false;
      throw const V2ResolverProviderException(
        code: 'ors_timeout',
        message: 'timeout',
      );
    }
    return candidates;
  }
}
