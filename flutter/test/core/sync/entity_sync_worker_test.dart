import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/entity_sync_worker.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/data/route_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';

class _FakeAuthService implements AuthService {
  const _FakeAuthService();

  @override
  Stream<User?> get authStateChanges => const Stream<User?>.empty();

  @override
  User? get currentUser => null;

  @override
  Future<String?> getAccessToken() async => 'test-token';

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
}

class _TestTripRepository extends TripRepository {
  _TestTripRepository(
    super.db,
    super.authService,
  );

  Future<void> Function(String localTripId, String operation)? onSyncTrip;
  Future<void> Function(String remoteTripId)? onDeleteTrip;

  int syncCalls = 0;
  int deleteCalls = 0;

  @override
  Future<void> syncTripForTask(
    String localTripId, {
    required String operation,
  }) async {
    syncCalls += 1;
    final handler = onSyncTrip;
    if (handler != null) {
      await handler(localTripId, operation);
    }
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

  Future<void> Function(String localPlaceId, String operation)? onSyncPlace;
  Future<void> Function(String remotePlaceId)? onDeletePlace;

  int syncCalls = 0;
  int deleteCalls = 0;

  @override
  Future<void> syncPlaceForTask(
    String localPlaceId, {
    required String operation,
  }) async {
    syncCalls += 1;
    final handler = onSyncPlace;
    if (handler != null) {
      await handler(localPlaceId, operation);
    }
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

  Future<void> Function(String localRouteId, String operation)? onSyncRoute;
  Future<void> Function(String remoteRouteId)? onDeleteRoute;

  int syncCalls = 0;
  int deleteCalls = 0;

  @override
  Future<void> syncRouteForTask(
    String localRouteId, {
    required String operation,
  }) async {
    syncCalls += 1;
    final handler = onSyncRoute;
    if (handler != null) {
      await handler(localRouteId, operation);
    }
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

    test('blocks unsupported entity types with explicit error code', () async {
      await syncTaskDao.upsertQueuedTask(
        id: 'task-unsupported-entity',
        entityType: 'unknown',
        entityId: 'entity-1',
        operation: 'create',
      );

      await worker.startIfIdle();

      final task = await readTask('task-unsupported-entity');
      expect(task['status'], 'blocked');
      expect(task['retry_count'], 0);
      expect(task['error_code'], 'unsupported_entity_type');
      expect(
        task['error_message'],
        contains('Unsupported sync entity type'),
      );
      expect(task['worker_session_id'], isNull);
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
