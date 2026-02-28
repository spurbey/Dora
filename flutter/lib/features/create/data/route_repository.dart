import 'dart:convert';
import 'dart:math';

import 'package:built_value/json_object.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/directions/app_directions_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/arc_generator.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';
import 'package:dora/features/create/domain/route.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class RouteRepository {
  RouteRepository(
    this._db, {
    AppDirectionsService? directionsService,
    AuthService? authService,
    openapi.RoutesApi? routesApi,
    TripRepository? tripRepository,
    PlaceRepository? placeRepository,
  })  : _directionsService = directionsService,
        _authService = authService,
        _routesApi = routesApi,
        _tripRepository = tripRepository,
        _placeRepository = placeRepository,
        _syncTaskDao = SyncTaskDao(_db);

  final AppDatabase _db;
  final AppDirectionsService? _directionsService;
  final AuthService? _authService;
  final openapi.RoutesApi? _routesApi;
  final TripRepository? _tripRepository;
  final PlaceRepository? _placeRepository;
  final SyncTaskDao _syncTaskDao;
  final Map<String, Future<String>> _ensureRemoteRouteIdInFlight = {};

  Future<List<Route>> getRoutes(String tripId) async {
    final rows = await _db.routeDao.getRoutesForTrip(tripId);
    return rows.map(_mapRow).toList();
  }

  Future<Route?> getRoute(String id) async {
    final row = await _db.routeDao.getRouteById(id);
    return row == null ? null : _mapRow(row);
  }

  Future<Route> addRoute(Route route) async {
    final now = DateTime.now();
    final updated = route.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.routeDao.insertRoute(_toCompanion(updated));
    await _enqueueRouteSyncTask(
      routeId: updated.id,
      tripId: updated.tripId,
      operation:
          (updated.serverRouteId == null || updated.serverRouteId!.isEmpty)
              ? 'create'
              : 'update',
    );
    return updated;
  }

  Future<void> updateRoute(Route route) async {
    final existing = await _db.routeDao.getRouteById(route.id);
    final existingServerRouteId = existing?.serverRouteId;
    final resolvedServerRouteId =
        (existingServerRouteId != null && existingServerRouteId.isNotEmpty)
            ? existingServerRouteId
            : route.serverRouteId;
    final now = DateTime.now();
    final updated = route.copyWith(
      serverRouteId: resolvedServerRouteId,
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.routeDao.updateRoute(_toCompanion(updated));
    await _enqueueRouteSyncTask(
      routeId: updated.id,
      tripId: updated.tripId,
      operation:
          (updated.serverRouteId == null || updated.serverRouteId!.isEmpty)
              ? 'create'
              : 'update',
    );
  }

  Future<void> deleteRoute(String id) async {
    final existing = await _db.routeDao.getRouteById(id);
    if (existing == null) {
      return;
    }
    await _db.routeDao.deleteRoute(id);
    await _enqueueRouteSyncTask(
      routeId: id,
      tripId: existing.tripId,
      operation: 'delete',
      remoteEntityId: existing.serverRouteId,
    );
  }

  Future<void> saveRoutes(List<Route> routes) async {
    if (routes.isEmpty) {
      return;
    }
    final existingRows =
        await _db.routeDao.getRoutesForTrip(routes.first.tripId);
    final existingById = {
      for (final row in existingRows) row.id: row.serverRouteId,
    };
    final now = DateTime.now();
    final normalizedRoutes = routes.map((route) {
      final existingServerRouteId = existingById[route.id];
      final resolvedServerRouteId =
          (existingServerRouteId != null && existingServerRouteId.isNotEmpty)
              ? existingServerRouteId
              : route.serverRouteId;
      return route.copyWith(
        serverRouteId: resolvedServerRouteId,
        localUpdatedAt: now,
        syncStatus: 'pending',
      );
    }).toList();
    final companions = normalizedRoutes.map(_toCompanion).toList();
    await _db.routeDao.insertRoutes(companions);
    for (final route in normalizedRoutes) {
      await _enqueueRouteSyncTask(
        routeId: route.id,
        tripId: route.tripId,
        operation: (route.serverRouteId == null || route.serverRouteId!.isEmpty)
            ? 'create'
            : 'update',
      );
    }
  }

  Route generateRoute({
    required String tripId,
    required AppLatLng start,
    required AppLatLng end,
    String transportMode = 'car',
    String? startPlaceId,
    String? endPlaceId,
    int orderIndex = 0,
  }) {
    final distance = _haversineKm(start, end);
    final duration = _estimateDuration(distance, transportMode);
    final routeCategory = transportMode == 'air' ? 'air' : 'ground';
    final now = DateTime.now();

    return Route(
      id: const Uuid().v4(),
      serverRouteId: null,
      tripId: tripId,
      coordinates: [start, end],
      transportMode: transportMode,
      distance: distance,
      duration: duration,
      routeCategory: routeCategory,
      startPlaceId: startPlaceId,
      endPlaceId: endPlaceId,
      orderIndex: orderIndex,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  /// Generate air route with great-circle arc interpolation (slerp).
  Route generateAirRoute({
    required String tripId,
    required AppLatLng start,
    required AppLatLng end,
    String? startPlaceId,
    String? endPlaceId,
    int orderIndex = 0,
  }) {
    final arcCoordinates = ArcGenerator.generateArc(start, end, points: 50);
    final distance = _haversineKm(start, end);
    final duration = _estimateDuration(distance, 'air');
    final now = DateTime.now();

    return Route(
      id: const Uuid().v4(),
      serverRouteId: null,
      tripId: tripId,
      coordinates: arcCoordinates,
      transportMode: 'air',
      distance: distance,
      duration: duration,
      routeCategory: 'air',
      startPlaceId: startPlaceId,
      endPlaceId: endPlaceId,
      orderIndex: orderIndex,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  /// Generate a route via the backend Directions API (real road geometry).
  /// Falls back to haversine straight-line if the API call fails.
  Future<Route> generateRouteViaApi({
    required String tripId,
    required AppLatLng start,
    required AppLatLng end,
    required String mode,
    String? startPlaceId,
    String? endPlaceId,
    int orderIndex = 0,
  }) async {
    if (_directionsService == null) {
      throw StateError('Directions service is not configured');
    }

    final result = await _directionsService!.getRoute([start, end], mode);
    final now = DateTime.now();
    return Route(
      id: const Uuid().v4(),
      serverRouteId: null,
      tripId: tripId,
      transportMode: mode,
      coordinates: result.coordinates,
      distance: result.distanceKm,
      duration: result.durationMins,
      routeCategory: 'ground',
      startPlaceId: startPlaceId,
      endPlaceId: endPlaceId,
      orderIndex: orderIndex,
      routeGeojson: result.routeGeojson,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  Route _mapRow(RouteRow row) {
    return Route(
      id: row.id,
      serverRouteId: row.serverRouteId,
      tripId: row.tripId,
      coordinates: row.coordinates,
      transportMode: row.transportMode,
      distance: row.distance,
      duration: row.duration,
      dayNumber: row.dayNumber,
      name: row.name,
      description: row.description,
      routeCategory: row.routeCategory,
      startPlaceId: row.startPlaceId,
      endPlaceId: row.endPlaceId,
      orderIndex: row.orderIndex,
      routeGeojson: row.routeGeojson,
      waypoints: row.waypointsJson,
      localUpdatedAt: row.localUpdatedAt,
      serverUpdatedAt: row.serverUpdatedAt,
      syncStatus: row.syncStatus,
    );
  }

  RoutesCompanion _toCompanion(Route route) {
    return RoutesCompanion(
      id: Value(route.id),
      serverRouteId: Value(route.serverRouteId),
      tripId: Value(route.tripId),
      coordinates: Value(route.coordinates),
      transportMode: Value(route.transportMode),
      distance: Value(route.distance),
      duration: Value(route.duration),
      dayNumber: Value(route.dayNumber),
      name: Value(route.name),
      description: Value(route.description),
      routeCategory: Value(route.routeCategory),
      startPlaceId: Value(route.startPlaceId),
      endPlaceId: Value(route.endPlaceId),
      orderIndex: Value(route.orderIndex),
      routeGeojson: Value(route.routeGeojson),
      waypointsJson: Value(route.waypoints),
      localUpdatedAt: Value(route.localUpdatedAt),
      serverUpdatedAt: Value(route.serverUpdatedAt),
      syncStatus: Value(route.syncStatus),
    );
  }

  Future<void> syncRouteForTask(
    String localRouteId, {
    required String operation,
  }) async {
    switch (operation) {
      case 'create':
        await ensureRemoteRouteId(localRouteId);
        return;
      case 'update':
        await _syncRemoteRouteUpdate(localRouteId);
        return;
      case 'delete':
        throw const RouteIdentityException(
          'Route delete requires remote route id context.',
        );
      default:
        throw RouteIdentityException(
          'Unsupported route sync operation: $operation',
        );
    }
  }

  Future<String> ensureRemoteRouteId(String localRouteId) async {
    final inFlight = _ensureRemoteRouteIdInFlight[localRouteId];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _ensureRemoteRouteIdInternal(localRouteId);
    _ensureRemoteRouteIdInFlight[localRouteId] = future;
    try {
      return await future;
    } finally {
      _ensureRemoteRouteIdInFlight.remove(localRouteId);
    }
  }

  Future<void> deleteRemoteRouteById(String remoteRouteId) async {
    final routesApi = _routesApi;
    final authService = _authService;
    if (routesApi == null || authService == null) {
      throw const RouteIdentityException(
        'Cannot delete backend route: Routes API/auth service unavailable.',
      );
    }

    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const RouteIdentityException(
        'Cannot delete backend route: auth token unavailable.',
        retryable: true,
      );
    }

    await routesApi.deleteRouteApiV1RoutesRouteIdDelete(
      routeId: remoteRouteId,
      authorization: 'Bearer $token',
    );
  }

  Future<String> _ensureRemoteRouteIdInternal(String localRouteId) async {
    final local = await getRoute(localRouteId);
    if (local == null) {
      throw RouteIdentityException(
        'Cannot resolve remote route id: local route not found ($localRouteId)',
      );
    }

    final existingRemoteId = local.serverRouteId;
    if (existingRemoteId != null && existingRemoteId.isNotEmpty) {
      return existingRemoteId;
    }

    final routesApi = _routesApi;
    final authService = _authService;
    final tripRepository = _tripRepository;
    final placeRepository = _placeRepository;
    if (routesApi == null ||
        authService == null ||
        tripRepository == null ||
        placeRepository == null) {
      throw const RouteIdentityException(
        'Cannot resolve remote route id: sync dependencies unavailable.',
      );
    }

    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const RouteIdentityException(
        'Cannot resolve remote route id: auth token unavailable.',
        retryable: true,
      );
    }

    late final String remoteTripId;
    try {
      remoteTripId = await tripRepository.ensureRemoteTripId(local.tripId);
    } on TripIdentityException catch (error) {
      throw RouteIdentityException(
        error.message,
        retryable: error.retryable,
      );
    }
    final remoteStartPlaceId = await _resolveRemotePlaceId(
      localPlaceId: local.startPlaceId,
      placeRepository: placeRepository,
    );
    final remoteEndPlaceId = await _resolveRemotePlaceId(
      localPlaceId: local.endPlaceId,
      placeRepository: placeRepository,
    );

    final payload = openapi.RouteCreate((builder) {
      builder
        ..transportMode = _mapTransportMode(local.transportMode)
        ..routeCategory = _mapRouteCategory(local.routeCategory)
        ..routeGeojson = JsonObject(_resolveRouteGeoJson(local))
        ..orderInTrip = local.orderIndex;

      final name = local.name;
      if (name != null && name.isNotEmpty) {
        builder.name = name;
      }
      final description = local.description;
      if (description != null && description.isNotEmpty) {
        builder.description = description;
      }
      if (remoteStartPlaceId != null && remoteStartPlaceId.isNotEmpty) {
        builder.startPlaceId = remoteStartPlaceId;
      }
      if (remoteEndPlaceId != null && remoteEndPlaceId.isNotEmpty) {
        builder.endPlaceId = remoteEndPlaceId;
      }
    });

    final response = await routesApi.createRouteApiV1TripsTripIdRoutesPost(
      tripId: remoteTripId,
      authorization: 'Bearer $token',
      routeCreate: payload,
    );
    final remoteRouteId = response.data?.id;
    if (remoteRouteId == null || remoteRouteId.isEmpty) {
      throw const RouteIdentityException(
        'Cannot resolve remote route id: backend returned empty id.',
      );
    }

    await (_db.update(_db.routes)..where((r) => r.id.equals(localRouteId)))
        .write(
      RoutesCompanion(
        serverRouteId: Value(remoteRouteId),
        localUpdatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
    return remoteRouteId;
  }

  Future<void> _syncRemoteRouteUpdate(String localRouteId) async {
    final local = await getRoute(localRouteId);
    if (local == null) {
      throw RouteIdentityException(
        'Cannot sync route update: local route not found ($localRouteId)',
      );
    }

    final remoteRouteId = await ensureRemoteRouteId(localRouteId);
    final routesApi = _routesApi;
    final authService = _authService;
    if (routesApi == null || authService == null) {
      throw const RouteIdentityException(
        'Cannot sync route update: Routes API/auth service unavailable.',
      );
    }

    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const RouteIdentityException(
        'Cannot sync route update: auth token unavailable.',
        retryable: true,
      );
    }

    final payload = openapi.RouteUpdate((builder) {
      final name = local.name;
      if (name != null && name.isNotEmpty) {
        builder.name = name;
      }
      final description = local.description;
      if (description != null && description.isNotEmpty) {
        builder.description = description;
      }
      builder
        ..orderInTrip = local.orderIndex
        ..routeGeojson = JsonObject(_resolveRouteGeoJson(local));
    });

    await routesApi.updateRouteApiV1RoutesRouteIdPatch(
      routeId: remoteRouteId,
      authorization: 'Bearer $token',
      routeUpdate: payload,
    );
  }

  Future<String?> _resolveRemotePlaceId({
    required String? localPlaceId,
    required PlaceRepository placeRepository,
  }) async {
    if (localPlaceId == null || localPlaceId.isEmpty) {
      return null;
    }

    final localPlace = await placeRepository.getPlace(localPlaceId);
    if (localPlace == null) {
      throw RouteIdentityException(
        'Cannot resolve remote place id: local place not found ($localPlaceId)',
      );
    }

    final existingRemotePlaceId = localPlace.serverPlaceId;
    if (existingRemotePlaceId != null && existingRemotePlaceId.isNotEmpty) {
      return existingRemotePlaceId;
    }

    final placeTask = await _syncTaskDao.getTaskByEntity(
      entityType: 'place',
      entityId: localPlaceId,
    );
    _throwIfPlaceDependencyNotReady(
      task: placeTask,
      localPlaceId: localPlaceId,
    );

    try {
      return await placeRepository.ensureRemotePlaceId(localPlaceId);
    } on PlaceIdentityException catch (error) {
      throw RouteIdentityException(
        error.message,
        retryable: error.retryable,
      );
    }
  }

  void _throwIfPlaceDependencyNotReady({
    required SyncTaskRow? task,
    required String localPlaceId,
  }) {
    if (task == null || task.status == 'completed') {
      return;
    }

    final status = task.status;
    final reason = task.errorMessage;
    if (status == 'blocked') {
      throw RouteIdentityException(
        'Route sync blocked: place dependency is blocked '
        '(placeId=$localPlaceId). '
        '${reason ?? 'Resolve place sync issue and retry.'}',
      );
    }

    if (status == 'queued' || status == 'in_progress' || status == 'failed') {
      throw RouteIdentityException(
        'Route sync deferred: place dependency is not ready yet '
        '(status=$status, placeId=$localPlaceId).',
        retryable: true,
      );
    }

    throw RouteIdentityException(
      'Route sync blocked: place dependency is in unsupported sync state '
      '(status=$status, placeId=$localPlaceId). '
      '${reason ?? ''}',
    );
  }

  Object _resolveRouteGeoJson(Route route) {
    final raw = route.routeGeojson;
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        // fall through to generated linestring
      }
    }
    final coordinates = route.coordinates;
    if (coordinates.length < 2) {
      throw RouteIdentityException(
        'Cannot sync route: geometry requires at least 2 coordinates '
        '(routeId=${route.id}).',
      );
    }
    return {
      'type': 'LineString',
      'coordinates': coordinates
          .map((point) => [point.longitude, point.latitude])
          .toList(),
    };
  }

  openapi.RouteCreateTransportModeEnum _mapTransportMode(String mode) {
    return switch (mode) {
      'bike' || 'cycling' => openapi.RouteCreateTransportModeEnum.bike,
      'foot' ||
      'walk' ||
      'walking' =>
        openapi.RouteCreateTransportModeEnum.foot,
      'air' => openapi.RouteCreateTransportModeEnum.air,
      'bus' => openapi.RouteCreateTransportModeEnum.bus,
      'train' => openapi.RouteCreateTransportModeEnum.train,
      _ => openapi.RouteCreateTransportModeEnum.car,
    };
  }

  openapi.RouteCreateRouteCategoryEnum _mapRouteCategory(String category) {
    return category == 'air'
        ? openapi.RouteCreateRouteCategoryEnum.air
        : openapi.RouteCreateRouteCategoryEnum.ground;
  }

  Future<void> _enqueueRouteSyncTask({
    required String routeId,
    required String tripId,
    required String operation,
    String? remoteEntityId,
  }) async {
    final dependency = await _resolveRouteSyncDependency(
      routeId: routeId,
      tripId: tripId,
      operation: operation,
    );

    await _syncTaskDao.upsertQueuedTask(
      id: const Uuid().v4(),
      entityType: 'route',
      entityId: routeId,
      operation: operation,
      remoteEntityId: remoteEntityId,
      dependsOnEntityType: dependency.entityType,
      dependsOnEntityId: dependency.entityId,
    );
  }

  Future<_SyncTaskDependency> _resolveRouteSyncDependency({
    required String routeId,
    required String tripId,
    required String operation,
  }) async {
    if (operation == 'delete') {
      return _SyncTaskDependency(
        entityType: 'trip',
        entityId: tripId,
      );
    }

    final tripTask = await _syncTaskDao.getTaskByEntity(
      entityType: 'trip',
      entityId: tripId,
    );
    if (_isDependencyPending(tripTask)) {
      return _SyncTaskDependency(
        entityType: 'trip',
        entityId: tripId,
      );
    }

    final route = await _db.routeDao.getRouteById(routeId);
    if (route == null) {
      return _SyncTaskDependency(
        entityType: 'trip',
        entityId: tripId,
      );
    }

    final placeIds = <String>[
      if (route.startPlaceId != null && route.startPlaceId!.isNotEmpty)
        route.startPlaceId!,
      if (route.endPlaceId != null && route.endPlaceId!.isNotEmpty)
        route.endPlaceId!,
    ];

    for (final placeId in placeIds) {
      final placeTask = await _syncTaskDao.getTaskByEntity(
        entityType: 'place',
        entityId: placeId,
      );
      if (_isDependencyPending(placeTask)) {
        return _SyncTaskDependency(
          entityType: 'place',
          entityId: placeId,
        );
      }

      final place = await _db.placeDao.getPlaceById(placeId);
      final serverPlaceId = place?.serverPlaceId;
      if (serverPlaceId == null || serverPlaceId.trim().isEmpty) {
        return _SyncTaskDependency(
          entityType: 'place',
          entityId: placeId,
        );
      }
    }

    return _SyncTaskDependency(
      entityType: 'trip',
      entityId: tripId,
    );
  }

  bool _isDependencyPending(SyncTaskRow? task) {
    if (task == null) {
      return false;
    }
    return task.status != 'completed';
  }

  static double _haversineKm(AppLatLng start, AppLatLng end) {
    const earthRadius = 6371.0;
    final dLat = _degToRad(end.latitude - start.latitude);
    final dLon = _degToRad(end.longitude - start.longitude);
    final lat1 = _degToRad(start.latitude);
    final lat2 = _degToRad(end.latitude);

    final a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static int _estimateDuration(double distanceKm, String mode) {
    final speedKmh = switch (mode) {
      // Keep backward compatibility for legacy 'walk' while using 'foot' as canonical.
      'foot' || 'walk' || 'walking' => 5,
      'bike' || 'cycling' => 15,
      'air' => 700,
      _ => 60,
    };
    return max(1, (distanceKm / speedKmh * 60).round());
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
}

class RouteIdentityException implements Exception {
  const RouteIdentityException(
    this.message, {
    this.retryable = false,
  });

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}

class _SyncTaskDependency {
  const _SyncTaskDependency({
    this.entityType,
    this.entityId,
  });

  final String? entityType;
  final String? entityId;
}
