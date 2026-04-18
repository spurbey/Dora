import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dora_api/dora_api.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_state.dart';

void main() {
  group('ExportRepository pre-submit guards', () {
    late AppDatabase database;
    late _FakeExportsApi api;
    late ExportRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      api = _FakeExportsApi();
      repository = ExportRepository(database, api, Dio(), () async => 'fake-token');
    });

    tearDown(() async {
      await database.close();
    });

    test('returns tripNotFound when trip does not exist', () async {
      final result = await repository.evaluatePreSubmitGuards('missing-trip');

      expect(result.tripExists, isFalse);
      expect(result.canExport, isFalse);
      expect(result.failures, [ExportPrecheckFailure.tripNotFound]);
    });

    test('blocks export when trip has no serverTripId', () async {
      await _insertTrip(
        database,
        tripId: 'trip-local-only',
        serverTripId: null,
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-local-only');

      expect(result.tripExists, isTrue);
      expect(result.hasServerTripId, isFalse);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.tripNotSynced));
    });

    test('blocks export when media queue has pending or failed items',
        () async {
      await _insertTrip(
        database,
        tripId: 'trip-with-media-issues',
        serverTripId: 'server-trip-1',
      );
      await _insertMedia(
        database,
        mediaId: 'media-queued',
        tripId: 'trip-with-media-issues',
        uploadStatus: 'queued',
      );
      await _insertMedia(
        database,
        mediaId: 'media-failed',
        tripId: 'trip-with-media-issues',
        uploadStatus: 'failed',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-with-media-issues');

      expect(result.pendingMediaCount, 1);
      expect(result.failedMediaCount, 1);
      expect(result.unresolvedMediaCount, 2);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.pendingMedia));
    });

    test('blocks export when V2 session is active', () async {
      await _insertTrip(
        database,
        tripId: 'trip-active-session',
        serverTripId: 'server-trip-2',
      );
      await _insertSessionJournal(
        database,
        sessionId: 'session-1',
        tripLocalId: 'trip-active-session',
        controlState: 'active',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-active-session');

      expect(result.blockingV2ConditionCount, 1);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.activeSessionOrPublish));
    });

    test('blocks export when V2 session is paused', () async {
      await _insertTrip(
        database,
        tripId: 'trip-paused-session',
        serverTripId: 'server-trip-3',
      );
      await _insertSessionJournal(
        database,
        sessionId: 'session-2',
        tripLocalId: 'trip-paused-session',
        controlState: 'paused',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-paused-session');

      expect(result.blockingV2ConditionCount, 1);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.activeSessionOrPublish));
    });

    test('blocks export when V2 publish is in progress', () async {
      await _insertTrip(
        database,
        tripId: 'trip-publishing',
        serverTripId: 'server-trip-4',
      );
      await _insertTripPublishState(
        database,
        tripLocalId: 'trip-publishing',
        publishState: 'publishing',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-publishing');

      expect(result.blockingV2ConditionCount, 1);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.activeSessionOrPublish));
    });

    test('allows export when V2 session is sealed (not active/paused)', () async {
      await _insertTrip(
        database,
        tripId: 'trip-sealed-session',
        serverTripId: 'server-trip-5',
      );
      await _insertSessionJournal(
        database,
        sessionId: 'session-3',
        tripLocalId: 'trip-sealed-session',
        controlState: 'sealed',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-sealed-session');

      expect(result.blockingV2ConditionCount, 0);
      expect(result.canExport, isTrue);
    });

    test('allows export when V2 publish is completed', () async {
      await _insertTrip(
        database,
        tripId: 'trip-published',
        serverTripId: 'server-trip-6',
      );
      await _insertTripPublishState(
        database,
        tripLocalId: 'trip-published',
        publishState: 'published',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-published');

      expect(result.blockingV2ConditionCount, 0);
      expect(result.canExport, isTrue);
    });

    test('allows export when all pre-submit guards pass', () async {
      await _insertTrip(
        database,
        tripId: 'trip-ready',
        serverTripId: 'server-trip-ready',
      );

      final result = await repository.evaluatePreSubmitGuards('trip-ready');

      expect(result.tripExists, isTrue);
      expect(result.hasServerTripId, isTrue);
      expect(result.pendingMediaCount, 0);
      expect(result.failedMediaCount, 0);
      expect(result.blockingV2ConditionCount, 0);
      expect(result.failures, isEmpty);
      expect(result.canExport, isTrue);
    });

    test('submit handles nested duplicate envelope (409) and reuses job id',
        () async {
      await _insertTrip(
        database,
        tripId: 'trip-submit-duplicate',
        serverTripId: 'server-trip-duplicate',
      );

      api.onCreate = (_, __) async {
        throw _dioError(
          statusCode: 409,
          body: const <String, dynamic>{
            'detail': <String, dynamic>{
              'error': 'duplicate_job',
              'existing_job_id': 'job-existing-123',
              'detail': 'An identical export is already queued or processing.',
            },
          },
        );
      };

      final result =
          await repository.submitClassicExport('trip-submit-duplicate');

      expect(result.deduplicated, isTrue);
      expect(result.jobId, 'job-existing-123');
    });

    test('submit maps nested 422 reason envelope to user-facing message',
        () async {
      await _insertTrip(
        database,
        tripId: 'trip-submit-422',
        serverTripId: 'server-trip-422',
      );

      api.onCreate = (_, __) async {
        throw _dioError(
          statusCode: 422,
          body: const <String, dynamic>{
            'detail': <String, dynamic>{
              'error': 'export_precondition_failed',
              'reason': 'pending_sync',
              'detail': 'Trip changes are still syncing.',
            },
          },
        );
      };

      await expectLater(
        repository.submitClassicExport('trip-submit-422'),
        throwsA(
          isA<ExportRepositoryException>().having(
            (error) => error.message,
            'message',
            'Wait for sync queue to finish before exporting.',
          ),
        ),
      );
    });

    test('submit re-validates local guards before calling export API',
        () async {
      await _insertTrip(
        database,
        tripId: 'trip-submit-revalidate',
        serverTripId: 'server-trip-revalidate',
      );
      await _insertMedia(
        database,
        mediaId: 'media-pending-submit',
        tripId: 'trip-submit-revalidate',
        uploadStatus: 'queued',
      );

      await expectLater(
        repository.submitClassicExport('trip-submit-revalidate'),
        throwsA(
          isA<ExportRepositoryException>().having(
            (error) => error.message,
            'message',
            'Finish pending media uploads before exporting.',
          ),
        ),
      );
      expect(api.createCalled, isFalse);
    });
  });
}

Future<void> _insertTrip(
  AppDatabase database, {
  required String tripId,
  required String? serverTripId,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.trips).insert(
        TripsCompanion.insert(
          id: tripId,
          userId: 'user-1',
          name: 'Test Trip',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
          serverTripId: Value(serverTripId),
        ),
      );
}

Future<void> _insertMedia(
  AppDatabase database, {
  required String mediaId,
  required String tripId,
  required String uploadStatus,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.media).insert(
        MediaCompanion.insert(
          id: mediaId,
          tripId: tripId,
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
          uploadStatus: Value(uploadStatus),
        ),
      );
}

Future<void> _insertSessionJournal(
  AppDatabase database, {
  required String sessionId,
  required String tripLocalId,
  required String controlState,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.sessionJournal).insert(
        SessionJournalCompanion.insert(
          sessionId: sessionId,
          tripLocalId: tripLocalId,
          controlState: controlState,
          sessionSeq: 1,
          deviceId: 'device-1',
          startedAt: Value(now),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> _insertTripPublishState(
  AppDatabase database, {
  required String tripLocalId,
  required String publishState,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.tripPublishState).insert(
        TripPublishStateCompanion.insert(
          tripLocalId: tripLocalId,
          publishState: Value(publishState),
          updatedAt: now,
        ),
      );
}

/// Fake [ExportsApi] that lets tests control the create-export response.
class _FakeExportsApi extends ExportsApi {
  _FakeExportsApi() : super(Dio(), standardSerializers);

  bool createCalled = false;
  Future<Response<ExportCreateResponse>> Function(
    String tripId,
    String authorization,
  )? onCreate;

  @override
  Future<Response<ExportCreateResponse>>
      createExportApiV1TripsTripIdExportPost({
    required String tripId,
    required String authorization,
    required ExportCreateRequest exportCreateRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCalled = true;
    final handler = onCreate;
    if (handler != null) {
      return handler(tripId, authorization);
    }
    final responseObj = ExportCreateResponse((b) => b
      ..jobId = 'job-default-1'
      ..status = ExportStatus.queued
      ..progress = 0);
    return Response<ExportCreateResponse>(
      data: responseObj,
      requestOptions: RequestOptions(path: '/api/v1/trips/$tripId/export'),
      statusCode: 200,
    );
  }
}

DioException _dioError({
  required int statusCode,
  required Map<String, dynamic> body,
}) {
  final requestOptions = RequestOptions(path: '/api/v1/trips/test/export');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: body,
    ),
  );
}
