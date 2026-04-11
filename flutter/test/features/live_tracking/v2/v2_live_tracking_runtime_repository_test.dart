import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/data/route_point_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_command_api.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_live_tracking_runtime_repository.dart';

void main() {
  group('V2LiveTrackingRuntimeRepository', () {
    late AppDatabase database;
    late V2SessionJournalRepository sessionRepository;
    late V2RoutePointJournalRepository routePointRepository;
    late _FakeCommandApi commandApi;
    late V2LiveTrackingRuntimeRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionRepository =
          V2SessionJournalRepository(SessionJournalDao(database));
      routePointRepository =
          V2RoutePointJournalRepository(RoutePointJournalDao(database));
      commandApi = _FakeCommandApi();
      repository = V2LiveTrackingRuntimeRepository(
        sessionRepository: sessionRepository,
        routePointRepository: routePointRepository,
        commandApi: commandApi,
        resolveRemoteTripId: (_) async => 'remote-trip-1',
        now: () => DateTime.utc(2026, 4, 12, 13, 0),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('stop rotates stop_client_event_id for new seal version', () async {
      await sessionRepository.upsertSession(
        sessionId: 'session-stop-id',
        tripLocalId: 'trip-stop-id',
        serverTripId: 'remote-trip-1',
        controlState: 'active',
        startAckAt: DateTime.utc(2026, 4, 12, 12, 50),
        startedAt: DateTime.utc(2026, 4, 12, 12, 50),
        stopClientEventId: 'stop-old-id',
        sessionSeq: 1,
        deviceId: 'device-1',
        startRequestSeq: 1,
      );

      final stopped = await repository.stopSession(tripId: 'trip-stop-id');
      expect(stopped, isNotNull);
      expect(commandApi.stopClientEventIds, hasLength(1));
      expect(commandApi.stopClientEventIds.single, isNot('stop-old-id'));

      final persisted =
          await sessionRepository.getSessionById('session-stop-id');
      expect(persisted, isNotNull);
      expect(
          persisted!.stopClientEventId, commandApi.stopClientEventIds.single);
    });
  });
}

class _FakeCommandApi implements V2CommandApi {
  final List<String> stopClientEventIds = <String>[];

  @override
  Future<V2StartCommandResult> start({
    required String remoteTripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    return V2StartCommandResult(
      remoteSessionId: 'remote-session-1',
      startedAt: startedAt,
    );
  }

  @override
  Future<void> stop({
    required String remoteTripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime stoppedAt,
    String? remoteSessionId,
    String? reason,
  }) async {
    stopClientEventIds.add(clientEventId);
  }
}
