import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/data/route_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.token = 'test-token'});

  final String token;

  @override
  Stream<User?> get authStateChanges => Stream<User?>.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<String?> getAccessToken() async => token;

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

class _FakeRoutesApi extends openapi.RoutesApi {
  _FakeRoutesApi()
      : super(
          Dio(),
          openapi.standardSerializers,
        );

  int createCalls = 0;
  String? lastTripId;
  String? lastStartPlaceId;
  String? lastEndPlaceId;

  @override
  Future<Response<openapi.RouteResponse>>
      createRouteApiV1TripsTripIdRoutesPost({
    required String tripId,
    required String authorization,
    required openapi.RouteCreate routeCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCalls += 1;
    lastTripId = tripId;
    lastStartPlaceId = routeCreate.startPlaceId;
    lastEndPlaceId = routeCreate.endPlaceId;

    final now = DateTime.utc(2026, 2, 25);
    final payload = openapi.RouteResponse((builder) {
      builder
        ..id = 'remote-route-1'
        ..tripId = tripId
        ..userId = 'user-1'
        ..transportMode = openapi.RouteResponseTransportModeEnum.car
        ..routeCategory = openapi.RouteResponseRouteCategoryEnum.ground
        ..routeGeojson = JsonObject(const {
          'type': 'LineString',
          'coordinates': [
            [77.0, 12.0],
            [77.1, 12.1],
          ],
        })
        ..startPlaceId = routeCreate.startPlaceId
        ..endPlaceId = routeCreate.endPlaceId
        ..orderInTrip = routeCreate.orderInTrip ?? 0
        ..createdAt = now
        ..updatedAt = now;
    });

    return Response<openapi.RouteResponse>(
      data: payload,
      requestOptions: RequestOptions(path: '/api/v1/trips/$tripId/routes'),
      statusCode: 201,
    );
  }
}

Future<void> _insertTripRow({
  required AppDatabase database,
  required String localTripId,
  required String? serverTripId,
}) async {
  final now = DateTime.utc(2026, 2, 25);
  await database.tripDao.insertTrip(
    TripsCompanion(
      id: drift.Value(localTripId),
      serverTripId: drift.Value(serverTripId),
      userId: const drift.Value('user-1'),
      name: const drift.Value('Route Sync Trip'),
      description: const drift.Value.absent(),
      startDate: const drift.Value.absent(),
      endDate: const drift.Value.absent(),
      tags: const drift.Value(<String>[]),
      visibility: const drift.Value('private'),
      centerPoint: const drift.Value.absent(),
      zoom: const drift.Value(12.0),
      localUpdatedAt: drift.Value(now),
      serverUpdatedAt: drift.Value(now),
      syncStatus: const drift.Value('synced'),
      createdAt: drift.Value(now),
    ),
  );
}

Future<void> _insertPlaceRow({
  required AppDatabase database,
  required String localPlaceId,
  required String tripId,
  required String? serverPlaceId,
}) async {
  final now = DateTime.utc(2026, 2, 25);
  await database.placeDao.insertPlace(
    PlacesCompanion(
      id: drift.Value(localPlaceId),
      serverPlaceId: drift.Value(serverPlaceId),
      tripId: drift.Value(tripId),
      name: const drift.Value('Route Place'),
      address: const drift.Value.absent(),
      coordinates: const drift.Value(
        AppLatLng(latitude: 12.9716, longitude: 77.5946),
      ),
      notes: const drift.Value.absent(),
      visitTime: const drift.Value.absent(),
      dayNumber: const drift.Value.absent(),
      orderIndex: const drift.Value(0),
      photoUrls: const drift.Value(<String>[]),
      placeType: const drift.Value.absent(),
      rating: const drift.Value.absent(),
      localUpdatedAt: drift.Value(now),
      serverUpdatedAt: drift.Value(now),
      syncStatus: const drift.Value('pending'),
    ),
  );
}

Future<void> _insertRouteRow({
  required AppDatabase database,
  required String localRouteId,
  required String tripId,
  required String startPlaceId,
}) async {
  final now = DateTime.utc(2026, 2, 25);
  await database.routeDao.insertRoute(
    RoutesCompanion(
      id: drift.Value(localRouteId),
      serverRouteId: const drift.Value(null),
      tripId: drift.Value(tripId),
      coordinates: const drift.Value(
        [
          AppLatLng(latitude: 12.9716, longitude: 77.5946),
          AppLatLng(latitude: 12.9750, longitude: 77.6100),
        ],
      ),
      transportMode: const drift.Value('car'),
      distance: const drift.Value(2.0),
      duration: const drift.Value(8),
      dayNumber: const drift.Value.absent(),
      name: const drift.Value('Test Route'),
      description: const drift.Value.absent(),
      routeCategory: const drift.Value('ground'),
      startPlaceId: drift.Value(startPlaceId),
      endPlaceId: const drift.Value.absent(),
      orderIndex: const drift.Value(0),
      routeGeojson: const drift.Value.absent(),
      waypointsJson: const drift.Value(<AppLatLng>[]),
      localUpdatedAt: drift.Value(now),
      serverUpdatedAt: drift.Value(now),
      syncStatus: const drift.Value('pending'),
    ),
  );
}

void main() {
  group('RouteRepository dependency gating', () {
    late AppDatabase database;
    late _FakeAuthService authService;
    late TripRepository tripRepository;
    late PlaceRepository placeRepository;
    late _FakeRoutesApi routesApi;
    late RouteRepository routeRepository;
    late SyncTaskDao syncTaskDao;

    const localTripId = 'trip-1';
    const localPlaceId = 'place-1';
    const localRouteId = 'route-1';

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      authService = _FakeAuthService();
      tripRepository = TripRepository(database, authService);
      placeRepository = PlaceRepository(
        database,
        tripRepository: tripRepository,
      );
      routesApi = _FakeRoutesApi();
      routeRepository = RouteRepository(
        database,
        authService: authService,
        routesApi: routesApi,
        tripRepository: tripRepository,
        placeRepository: placeRepository,
      );
      syncTaskDao = SyncTaskDao(database);

      await _insertTripRow(
        database: database,
        localTripId: localTripId,
        serverTripId: 'remote-trip-1',
      );
      await _insertRouteRow(
        database: database,
        localRouteId: localRouteId,
        tripId: localTripId,
        startPlaceId: localPlaceId,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('defers route sync when start place dependency is queued', () async {
      await _insertPlaceRow(
        database: database,
        localPlaceId: localPlaceId,
        tripId: localTripId,
        serverPlaceId: null,
      );

      await syncTaskDao.upsertQueuedTask(
        id: 'place-task-queued',
        entityType: 'place',
        entityId: localPlaceId,
        operation: 'create',
        dependsOnEntityType: 'trip',
        dependsOnEntityId: localTripId,
      );

      await expectLater(
        routeRepository.syncRouteForTask(localRouteId, operation: 'create'),
        throwsA(
          isA<RouteIdentityException>()
              .having(
                (error) => error.retryable,
                'retryable',
                true,
              )
              .having(
                (error) => error.message,
                'message',
                contains('place dependency is not ready yet'),
              ),
        ),
      );

      expect(routesApi.createCalls, 0);
    });

    test('blocks route sync when start place dependency is blocked', () async {
      await _insertPlaceRow(
        database: database,
        localPlaceId: localPlaceId,
        tripId: localTripId,
        serverPlaceId: null,
      );

      final now = DateTime.utc(2026, 2, 25).millisecondsSinceEpoch;
      await database.customInsert(
        '''
        INSERT INTO sync_tasks (
          id,
          entity_type,
          entity_id,
          operation,
          status,
          retry_count,
          next_attempt_at,
          error_code,
          error_message,
          created_at,
          updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, NULL, ?, ?, ?, ?)
        ''',
        variables: [
          drift.Variable<String>('place-task-blocked'),
          drift.Variable<String>('place'),
          drift.Variable<String>(localPlaceId),
          drift.Variable<String>('create'),
          drift.Variable<String>('blocked'),
          drift.Variable<int>(3),
          drift.Variable<String>('place_create_forbidden'),
          drift.Variable<String>('Place sync blocked by upstream trip failure'),
          drift.Variable<int>(now),
          drift.Variable<int>(now),
        ],
      );

      await expectLater(
        routeRepository.syncRouteForTask(localRouteId, operation: 'create'),
        throwsA(
          isA<RouteIdentityException>()
              .having(
                (error) => error.retryable,
                'retryable',
                false,
              )
              .having(
                (error) => error.message,
                'message',
                contains('place dependency is blocked'),
              ),
        ),
      );

      expect(routesApi.createCalls, 0);
    });

    test('uses serverPlaceId directly even when place sync task is queued',
        () async {
      await _insertPlaceRow(
        database: database,
        localPlaceId: localPlaceId,
        tripId: localTripId,
        serverPlaceId: 'remote-place-1',
      );

      await syncTaskDao.upsertQueuedTask(
        id: 'place-task-queued-with-remote-id',
        entityType: 'place',
        entityId: localPlaceId,
        operation: 'update',
      );

      await routeRepository.syncRouteForTask(localRouteId, operation: 'create');

      expect(routesApi.createCalls, 1);
      expect(routesApi.lastTripId, 'remote-trip-1');
      expect(routesApi.lastStartPlaceId, 'remote-place-1');

      final route = await database.routeDao.getRouteById(localRouteId);
      expect(route, isNotNull);
      expect(route!.serverRouteId, 'remote-route-1');
    });

    test('enqueue delete route task with trip dependency for export guard',
        () async {
      await routeRepository.deleteRoute(localRouteId);

      final task = await syncTaskDao.getTaskByEntity(
        entityType: 'route',
        entityId: localRouteId,
      );

      expect(task, isNotNull);
      expect(task!.operation, 'delete');
      expect(task.dependsOnEntityType, 'trip');
      expect(task.dependsOnEntityId, localTripId);
    });
  });
}
