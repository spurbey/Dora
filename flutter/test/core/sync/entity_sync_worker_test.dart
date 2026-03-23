import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/entity_sync_receipt.dart';
import 'package:dora/core/sync/entity_sync_worker.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/data/route_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';

class _FakeAuthService implements AuthService {
  const _FakeAuthService();

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<String?> getAccessToken() async => 'test-token';

  @override
  Future<String?> refreshAccessToken({bool force = false}) async =>
      'test-token';

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signUp(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }
}

class _TestTripRepository extends TripRepository {
  _TestTripRepository(
    super.db,
    super.authService,
  );

  Future<EntitySyncReceipt> Function(String localTripId, String operation)?
      onSyncTrip;
  Future<void> Function(String remoteTripId)? onDeleteTrip;

  int syncCalls = 0;
  int deleteCalls = 0;

  @override
  Future<EntitySyncReceipt> syncTripForTask(
    String localTripId, {
    required String operation,
  }) async {
    syncCalls += 1;
    final handler = onSyncTrip;
    if (handler != null) {
      return handler(localTripId, operation);
    }
    final now = DateTime.now();
    return EntitySyncReceipt(
      entityType: 'trip',
      localEntityId: localTripId,
      remoteEntityId: 'remote-$localTripId',
      serverUpdatedAt: now,
    );
  }

  @override
  Future<void> deleteRemoteTripById(String remoteTripId) async {
    deleteCalls += 1;
    final handler = onDeleteTrip;
    if (handler != null) {
      await handler(remoteTripId);
    }
  }
}

class _TestPlaceRepository extends PlaceRepository {
  _TestPlaceRepository(
    super.db, {
    required super.tripRepository,
  });

  Future<EntitySyncReceipt> Function(String localPlaceId, String operation)?
      onSyncPlace;
  Future<void> Function(String remotePlaceId)? onDeletePlace;

  int syncCalls = 0;
  int deleteCalls = 0;

  @override
  Future<EntitySyncReceipt> syncPlaceForTask(
    String localPlaceId, {
    required String operation,
  }) async {
    syncCalls += 1;
    final handler = onSyncPlace;
    if (handler != null) {
      return handler(localPlaceId, operation);
    }
    final now = DateTime.now();
    return EntitySyncReceipt(
      entityType: 'place',
      localEntityId: localPlaceId,
      remoteEntityId: 'remote-$localPlaceId',
      serverUpdatedAt: now,
    );
  }

  @override
  Future<void> deleteRemotePlaceById(String remotePlaceId) async {
    deleteCalls += 1;
    final handler = onDeletePlace;
    if (handler != null) {
      await handler(remotePlaceId);
    }
  }
}

class _TestRouteRepository extends RouteRepository {
  _TestRouteRepository(
    super.db, {
    required super.authService,
    required super.tripRepository,
    required super.placeRepository,
  });

  Future<EntitySyncReceipt> Function(String localRouteId, String operation)?
      onSyncRoute;
  Future<void> Function(String remoteRouteId)? onDeleteRoute;

  int syncCalls = 0;
  int deleteCalls = 0;

  @override
  Future<EntitySyncReceipt> syncRouteForTask(
    String localRouteId, {
    required String operation,
  }) async {
    syncCalls += 1;
    final handler = onSyncRoute;
    if (handler != null) {
      return handler(localRouteId, operation);
    }
    final now = DateTime.now();
    return EntitySyncReceipt(
      entityType: 'route',
      localEntityId: localRouteId,
      remoteEntityId: 'remote-$localRouteId',
      serverUpdatedAt: now,
    );
  }

  @override
  Future<void> deleteRemoteRouteById(String remoteRouteId) async {
    deleteCalls += 1;
    final handler = onDeleteRoute;
    if (handler != null) {
      await handler(remoteRouteId);
    }
  }
}

void main() {
  group('EntitySyncWorker', () {
    late AppDatabase database;
    late SyncTaskDao syncTaskDao;
    late _TestTripRepository tripRepository;
    late _TestPlaceRepository placeRepository;
    late _TestRouteRepository routeRepository;
    late EntitySyncWorker worker;

    Future<Map<String, Object?>> readTask(String taskId) async {
      final row = await database.customSelect(
        '''
        SELECT
          status,
          retry_count,
          next_attempt_at,
          error_code,
          error_message,
          worker_session_id
        FROM sync_tasks
        WHERE id = ?
        LIMIT 1
        ''',
        variables: [drift.Variable<String>(taskId)],
      ).getSingle();

      return <String, Object?>{
        'status': row.read<String>('status'),
        'retry_count': row.read<int>('retry_count'),
        'next_attempt_at': row.read<DateTime?>('next_attempt_at'),
        'error_code': row.read<String?>('error_code'),
        'error_message': row.read<String?>('error_message'),
        'worker_session_id': row.read<String?>('worker_session_id'),
      };
    }

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      syncTaskDao = SyncTaskDao(database);
      tripRepository = _TestTripRepository(
        database,
        const _FakeAuthService(),
      );
      placeRepository = _TestPlaceRepository(
        database,
        tripRepository: tripRepository,
      );
      routeRepository = _TestRouteRepository(
        database,
        authService: const _FakeAuthService(),
        tripRepository: tripRepository,
        placeRepository: placeRepository,
      );
      worker = EntitySyncWorker(
        db: database,
        syncTaskDao: syncTaskDao,
        tripRepository: tripRepository,
        placeRepository: placeRepository,
        routeRepository: routeRepository,
        maxConcurrency: 1,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('marks retryable trip identity failures as failed with backoff',
        () async {
      tripRepository.onSyncTrip = (_, __) async {
        throw const TripIdentityException(
          'Auth token unavailable',
          retryable: true,
        );
      };

      await syncTaskDao.upsertQueuedTask(
        id: 'task-trip-retryable',
        entityType: 'trip',
        entityId: 'trip-1',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-trip-retryable');
      expect(task['status'], 'failed');
      expect(task['retry_count'], 1);
      expect(task['next_attempt_at'], isNotNull);
      expect(task['error_code'], 'trip_identity_failure');
      expect(task['error_message'], contains('Auth token unavailable'));
      expect(task['worker_session_id'], isNull);
      expect(tripRepository.syncCalls, 1);
    });

    test('marks non-retryable trip identity failures as blocked', () async {
      tripRepository.onSyncTrip = (_, __) async {
        throw const TripIdentityException(
          'Trip create forbidden',
          retryable: false,
        );
      };

      await syncTaskDao.upsertQueuedTask(
        id: 'task-trip-blocked',
        entityType: 'trip',
        entityId: 'trip-2',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-trip-blocked');
      expect(task['status'], 'blocked');
      expect(task['retry_count'], 0);
      expect(task['next_attempt_at'], isNull);
      expect(task['error_code'], 'trip_identity_failure');
      expect(task['error_message'], contains('Trip create forbidden'));
      expect(task['worker_session_id'], isNull);
      expect(tripRepository.syncCalls, 1);
    });

    test('marks successful trip tasks as completed', () async {
      await syncTaskDao.upsertQueuedTask(
        id: 'task-trip-success',
        entityType: 'trip',
        entityId: 'trip-3',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-trip-success');
      expect(task['status'], 'completed');
      expect(task['retry_count'], 0);
      expect(task['next_attempt_at'], isNull);
      expect(task['error_code'], isNull);
      expect(task['error_message'], isNull);
      expect(task['worker_session_id'], isNull);
      expect(tripRepository.syncCalls, 1);
    });

    test('persists trip sync receipt into trip and user_trips rows', () async {
      final baseTime = DateTime(2026, 3, 20, 10, 0, 0);
      final receiptTime = DateTime(2026, 3, 20, 10, 5, 0);

      await database.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-receipt',
          userId: 'user-1',
          name: 'Trip Receipt',
          localUpdatedAt: baseTime,
          serverUpdatedAt: baseTime,
          syncStatus: 'pending',
          createdAt: baseTime,
        ),
      );
      await database.userTripsDao.insertTrip(
        UserTrip(
          id: 'trip-receipt',
          userId: 'user-1',
          name: 'Trip Receipt',
          description: null,
          coverPhotoUrl: null,
          startDate: null,
          endDate: null,
          visibility: 'private',
          placeCount: 0,
          status: 'editing',
          lastEditedAt: baseTime,
          localUpdatedAt: baseTime,
          serverUpdatedAt: baseTime,
          syncStatus: 'pending',
          createdAt: baseTime,
        ),
      );

      tripRepository.onSyncTrip = (_, __) async {
        return EntitySyncReceipt(
          entityType: 'trip',
          localEntityId: 'trip-receipt',
          remoteEntityId: 'remote-trip-receipt',
          serverUpdatedAt: receiptTime,
        );
      };

      await syncTaskDao.upsertQueuedTask(
        id: 'task-trip-receipt',
        entityType: 'trip',
        entityId: 'trip-receipt',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-trip-receipt');
      expect(task['status'], 'completed');

      final tripRow = await database.tripDao.getTripById('trip-receipt');
      expect(tripRow, isNotNull);
      expect(tripRow?.serverTripId, 'remote-trip-receipt');
      expect(tripRow?.serverUpdatedAt, receiptTime);
      expect(tripRow?.syncStatus, 'synced');

      final userTrip = await database.userTripsDao.getTripById('trip-receipt');
      expect(userTrip, isNotNull);
      expect(userTrip?.serverUpdatedAt, receiptTime);
      expect(userTrip?.syncStatus, 'synced');
    });

    test('keeps entity pending when task was requeued during in-progress',
        () async {
      final baseTime = DateTime(2026, 3, 20, 11, 0, 0);
      final firstReceiptTime = DateTime(2026, 3, 20, 11, 1, 0);
      final secondReceiptTime = DateTime(2026, 3, 20, 11, 2, 0);

      await database.placeDao.insertPlace(
        PlacesCompanion.insert(
          id: 'place-requeue',
          tripId: 'trip-1',
          name: 'Queue Test Place',
          coordinates: const AppLatLng(latitude: 27.7, longitude: 85.3),
          orderIndex: 0,
          localUpdatedAt: baseTime,
          serverUpdatedAt: baseTime,
          syncStatus: 'pending',
        ),
      );

      final firstStarted = Completer<void>();
      final releaseFirst = Completer<void>();
      final secondStarted = Completer<void>();
      final releaseSecond = Completer<void>();
      var callCount = 0;

      placeRepository.onSyncPlace = (_, __) async {
        callCount += 1;
        if (callCount == 1) {
          if (!firstStarted.isCompleted) {
            firstStarted.complete();
          }
          await releaseFirst.future;
          return EntitySyncReceipt(
            entityType: 'place',
            localEntityId: 'place-requeue',
            remoteEntityId: 'remote-place-requeue',
            serverUpdatedAt: firstReceiptTime,
          );
        }

        if (!secondStarted.isCompleted) {
          secondStarted.complete();
        }
        await releaseSecond.future;
        return EntitySyncReceipt(
          entityType: 'place',
          localEntityId: 'place-requeue',
          remoteEntityId: 'remote-place-requeue',
          serverUpdatedAt: secondReceiptTime,
        );
      };

      await syncTaskDao.upsertQueuedTask(
        id: 'task-place-requeue',
        entityType: 'place',
        entityId: 'place-requeue',
        operation: 'update',
      );

      final workerRun = worker.startIfIdle();
      await firstStarted.future;

      await syncTaskDao.upsertQueuedTask(
        id: 'task-place-requeue-next',
        entityType: 'place',
        entityId: 'place-requeue',
        operation: 'update',
      );

      releaseFirst.complete();
      await secondStarted.future;

      final placeDuringSecondRun = await database.placeDao.getPlaceById(
        'place-requeue',
      );
      expect(placeDuringSecondRun, isNotNull);
      expect(placeDuringSecondRun?.syncStatus, 'pending');

      final activeTask = await syncTaskDao.getTaskByEntity(
        entityType: 'place',
        entityId: 'place-requeue',
      );
      expect(activeTask, isNotNull);
      expect(activeTask?.status, 'in_progress');

      releaseSecond.complete();
      await workerRun;
    });

    test('completes trip delete task without remote id and skips remote delete',
        () async {
      await syncTaskDao.upsertQueuedTask(
        id: 'task-trip-delete-no-remote',
        entityType: 'trip',
        entityId: 'trip-4',
        operation: 'delete',
      );

      await worker.startIfIdle();

      final task = await readTask('task-trip-delete-no-remote');
      expect(task['status'], 'completed');
      expect(task['error_code'], isNull);
      expect(tripRepository.deleteCalls, 0);
    });

    test('leaves unknown entity types unclaimed', () async {
      await syncTaskDao.upsertQueuedTask(
        id: 'task-unsupported-entity',
        entityType: 'unknown',
        entityId: 'entity-1',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-unsupported-entity');
      expect(task['status'], 'queued');
      expect(task['retry_count'], 0);
      expect(task['error_code'], isNull);
      expect(task['error_message'], isNull);
      expect(task['worker_session_id'], isNull);
    });

    test('does not claim tracking queue entity types', () async {
      await syncTaskDao.upsertQueuedTask(
        id: 'task-trip-allowed',
        entityType: SyncEntityTypes.trip,
        entityId: 'trip-allowed-1',
        operation: 'create',
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-batch-idle',
        entityType: SyncEntityTypes.trackingPointBatch,
        entityId: 'tracking-batch-idle-1',
        operation: 'update',
      );

      await worker.startIfIdle();

      final allowedTask = await readTask('task-trip-allowed');
      expect(allowedTask['status'], 'completed');
      expect(allowedTask['error_code'], isNull);

      final trackingTask = await readTask('task-tracking-batch-idle');
      expect(trackingTask['status'], 'queued');
      expect(trackingTask['error_code'], isNull);
      expect(trackingTask['worker_session_id'], isNull);
    });

    test('marks non-retryable place identity failures as blocked', () async {
      placeRepository.onSyncPlace = (_, __) async {
        throw PlaceIdentityException(
          'Backend storage misconfigured',
          retryable: false,
        );
      };

      await syncTaskDao.upsertQueuedTask(
        id: 'task-place-blocked',
        entityType: 'place',
        entityId: 'place-1',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-place-blocked');
      expect(task['status'], 'blocked');
      expect(task['retry_count'], 0);
      expect(task['next_attempt_at'], isNull);
      expect(task['error_code'], 'place_identity_failure');
      expect(task['error_message'], contains('storage misconfigured'));
      expect(task['worker_session_id'], isNull);
      expect(placeRepository.syncCalls, 1);
    });

    test('marks retryable route identity failures as failed', () async {
      routeRepository.onSyncRoute = (_, __) async {
        throw const RouteIdentityException(
          'Route dependency not ready',
          retryable: true,
        );
      };

      await syncTaskDao.upsertQueuedTask(
        id: 'task-route-retryable',
        entityType: 'route',
        entityId: 'route-1',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-route-retryable');
      expect(task['status'], 'failed');
      expect(task['retry_count'], 1);
      expect(task['next_attempt_at'], isNotNull);
      expect(task['error_code'], 'route_identity_failure');
      expect(task['error_message'], contains('Route dependency not ready'));
      expect(routeRepository.syncCalls, 1);
    });
  });
}
