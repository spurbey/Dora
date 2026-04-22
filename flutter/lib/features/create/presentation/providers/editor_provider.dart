import 'dart:async';
import 'dart:math' show min, max, sqrt;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show EdgeInsets;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/directions/directions_provider.dart';
import 'package:dora/core/map/models/app_bounds.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/data/route_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/editor_state.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart';

part 'editor_provider.g.dart';

@riverpod
TripRepository tripRepository(TripRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final tripsApi = ref.watch(tripsApiProvider);
  final authService = ref.watch(authServiceProvider);
  return TripRepository(
    db,
    authService,
    tripsApi: tripsApi,
  );
}

@riverpod
PlaceRepository placeRepository(PlaceRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final tripRepository = ref.watch(tripRepositoryProvider);
  final searchApi = ref.watch(searchApiProvider);
  final placesApi = ref.watch(placesApiProvider);
  final authService = ref.watch(authServiceProvider);
  return PlaceRepository(
    db,
    tripRepository: tripRepository,
    searchApi: searchApi,
    placesApi: placesApi,
    authService: authService,
  );
}

@riverpod
RouteRepository routeRepository(RouteRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final directionsService = ref.watch(directionsServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final routesApi = ref.watch(routesApiProvider);
  final tripRepository = ref.watch(tripRepositoryProvider);
  final placeRepository = ref.watch(placeRepositoryProvider);
  return RouteRepository(
    db,
    directionsService: directionsService,
    authService: authService,
    routesApi: routesApi,
    tripRepository: tripRepository,
    placeRepository: placeRepository,
  );
}

@riverpod
class EditorController extends _$EditorController {
  Timer? _autoSaveTimer;
  final Map<String, int> _routeRecalcVersion = {};

  @override
  Future<EditorState> build(String tripId) async {
    ref.onDispose(() => _autoSaveTimer?.cancel());

    final tripRepository = ref.watch(tripRepositoryProvider);
    final placeRepository = ref.watch(placeRepositoryProvider);
    final routeRepository = ref.watch(routeRepositoryProvider);

    var trip = await tripRepository.getTrip(tripId);
    List<Place> places;
    List<Route> routes;

    if (trip == null) {
      // Trip exists in user_trips (synced from server) but not in the local
      // editor workspace. Hydrate trip + places + routes from backend so the
      // editor can open it seamlessly.
      trip = await tripRepository.hydrateTripFromBackend(tripId);
      if (trip == null) {
        throw Exception('Trip not found');
      }
      final (hydratedPlaces, placeIdMapping) =
          await placeRepository.hydratePlacesFromBackend(tripId, tripId);
      routes = await routeRepository.hydrateRoutesFromBackend(
        tripId,
        tripId,
        placeIdMapping,
      );
      places = hydratedPlaces;
    } else {
      places = await placeRepository.getPlaces(tripId);
      routes = await routeRepository.getRoutes(tripId);
    }

    return EditorState(
      trip: trip,
      places: places,
      routes: routes,
    );
  }

  void setMapController(AppMapController controller) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(mapController: controller));
  }

  void selectPlace(String id) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final place = current.places.firstWhere((p) => p.id == id);
    final isCity = place.placeType == 'city';
    current.mapController?.flyTo(
      place.coordinates,
      zoom: isCity ? 12 : 15,
    );
    state = AsyncData(current.copyWith(
      selectedItemId: id,
      selectedItemType: 'place',
      bottomPanelExpanded: true,
      mode: EditorMode.editItem,
    ));
  }

  void selectRoute(String id) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      selectedItemId: id,
      selectedItemType: 'route',
      routeStudioActive: false,
      bottomPanelExpanded: true,
      mode: EditorMode.editItem,
    ));
    try {
      final route = current.routes.firstWhere((r) => r.id == id);
      if (route.coordinates.length >= 2) {
        final coords = route.coordinates;
        final minLat = coords.map((c) => c.latitude).reduce(min);
        final maxLat = coords.map((c) => c.latitude).reduce(max);
        final minLon = coords.map((c) => c.longitude).reduce(min);
        final maxLon = coords.map((c) => c.longitude).reduce(max);
        current.mapController?.fitBounds(
          AppLatLngBounds(
            southwest: AppLatLng(latitude: minLat, longitude: minLon),
            northeast: AppLatLng(latitude: maxLat, longitude: maxLon),
          ),
          padding: const EdgeInsets.all(80),
        );
      }
    } catch (_) {}
  }

  void enterRouteStudio(String routeId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      selectedItemId: routeId,
      selectedItemType: 'route',
      routeStudioActive: true,
      bottomPanelExpanded: false,
      mode: EditorMode.editItem,
    ));
    // Fit camera to route bounds
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      if (route.coordinates.length >= 2) {
        final coords = route.coordinates;
        final minLat = coords.map((c) => c.latitude).reduce(min);
        final maxLat = coords.map((c) => c.latitude).reduce(max);
        final minLon = coords.map((c) => c.longitude).reduce(min);
        final maxLon = coords.map((c) => c.longitude).reduce(max);
        current.mapController?.fitBounds(
          AppLatLngBounds(
            southwest: AppLatLng(latitude: minLat, longitude: minLon),
            northeast: AppLatLng(latitude: maxLat, longitude: maxLon),
          ),
          padding: const EdgeInsets.all(80),
        );
      }
    } catch (_) {}
  }

  void exitRouteStudio() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      routeStudioActive: false,
      selectedItemId: null,
      selectedItemType: null,
      bottomPanelExpanded: false,
      mode: EditorMode.view,
    ));
  }

  void deselectAll() {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      selectedItemId: null,
      selectedItemType: null,
      bottomPanelExpanded: false,
      mode: EditorMode.view,
      routeStartItemId: null,
      routeStartItemType: null,
      routeEndItemId: null,
      routeStudioActive: false,
    ));
  }

  bool get _isRouteMode {
    final mode = state.valueOrNull?.mode;
    return mode == EditorMode.addRouteAir ||
        mode == EditorMode.addRouteCar ||
        mode == EditorMode.addRouteWalking;
  }

  void setMode(EditorMode mode) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      mode: mode,
      routeStartItemId: null,
      routeStartItemType: null,
      routeEndItemId: null,
    ));
  }

  void toggleBottomPanel() {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      bottomPanelExpanded: !current.bottomPanelExpanded,
    ));
  }

  void addPlace(Place place) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final updatedPlaces = [...current.places, place];
    final isCity = place.placeType == 'city';
    state = AsyncData(current.copyWith(
      places: updatedPlaces,
      selectedItemId: place.id,
      selectedItemType: 'place',
      bottomPanelExpanded: true,
      mode: EditorMode.editItem,
    ));
    current.mapController?.flyTo(place.coordinates, zoom: isCity ? 12 : 15);
    Future(() => ref.read(placeRepositoryProvider).addPlace(place));
  }

  void updateTripName(String name) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final updatedTrip = current.trip.copyWith(
      name: name,
      localUpdatedAt: DateTime.now(),
      syncStatus: 'pending',
    );
    state = AsyncData(current.copyWith(trip: updatedTrip));
    _scheduleAutoSave();
  }

  void handlePlaceTap(String id) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    if (_isRouteMode) {
      final place = current.places.firstWhere((p) => p.id == id);
      final isAir = current.mode == EditorMode.addRouteAir;

      if (current.routeStartItemId == null) {
        // Air routes can only start from cities
        if (isAir && place.placeType != 'city') return;
        selectRouteSource(id);
        return;
      }

      // Has source: tapping a valid destination from the map finalizes draft
      // and triggers route generation.
      if (current.isGeneratingRoute) return;
      if (isAir && place.placeType != 'city') return;
      if (id == current.routeStartItemId) return; // can't pick same place
      selectRouteDestination(id);
      unawaited(drawRoute(
        current.routeStartItemId!,
        id,
        capturedMode: current.mode,
      ));
      return;
    }

    selectPlace(id);
  }

  void updatePlace(Place place) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final updated = current.places
        .map((item) => item.id == place.id ? place : item)
        .toList();
    state = AsyncData(current.copyWith(places: updated));
    Future(() => ref.read(placeRepositoryProvider).updatePlace(place));
  }

  void removePlace(String id) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final updated = current.places.where((item) => item.id != id).toList();
    state = AsyncData(current.copyWith(places: updated));
    Future(() => ref.read(placeRepositoryProvider).deletePlace(id));
  }

  void reorderPlaces(int oldIndex, int newIndex) {
    final current = state.valueOrNull;
    if (current == null || current.places.isEmpty) {
      return;
    }

    final previousById = {
      for (final place in current.places) place.id: place,
    };
    final items = List<Place>.from(current.places);
    final moved = items.removeAt(oldIndex);
    final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    items.insert(targetIndex, moved);

    final updated = items.asMap().entries.map((entry) {
      final dayNumber = (entry.key ~/ 5) + 1;
      return entry.value.copyWith(
        orderIndex: entry.key,
        dayNumber: dayNumber,
      );
    }).toList();

    state = AsyncData(current.copyWith(places: updated));
    final changedPlaces = updated.where((place) {
      final previous = previousById[place.id];
      if (previous == null) {
        return true;
      }
      return previous.orderIndex != place.orderIndex ||
          previous.dayNumber != place.dayNumber;
    }).toList();

    if (changedPlaces.isNotEmpty) {
      unawaited(Future(() async {
        final repository = ref.read(placeRepositoryProvider);
        for (final place in changedPlaces) {
          await repository.updatePlace(place);
        }
      }));
    }
  }

  void reorderPlacesByGlobalSlots(Map<String, int> slotByPlaceId) {
    final current = state.valueOrNull;
    if (current == null || current.places.isEmpty || slotByPlaceId.isEmpty) {
      return;
    }

    final previousById = {
      for (final place in current.places) place.id: place,
    };
    final updated = current.places.map((place) {
      final slot = slotByPlaceId[place.id];
      if (slot == null) {
        return place;
      }
      return place.copyWith(
        orderIndex: slot,
        dayNumber: (slot ~/ 5) + 1,
      );
    }).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    state = AsyncData(current.copyWith(places: updated));

    final changedPlaces = updated.where((place) {
      final previous = previousById[place.id];
      if (previous == null) {
        return true;
      }
      return previous.orderIndex != place.orderIndex ||
          previous.dayNumber != place.dayNumber;
    }).toList(growable: false);

    if (changedPlaces.isEmpty) {
      return;
    }
    unawaited(Future(() async {
      final repository = ref.read(placeRepositoryProvider);
      for (final place in changedPlaces) {
        await repository.updatePlace(place);
      }
    }));
  }

  void addRoute(Route route) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(
      routes: [...current.routes, route],
      selectedItemId: route.id,
      selectedItemType: 'route',
      bottomPanelExpanded: false,
      routeStudioActive: true,
      mode: EditorMode.editItem,
      routeStartItemId: null,
      routeStartItemType: null,
      routeEndItemId: null,
      isGeneratingRoute: false,
    ));
    // Fly to fit the full route extent
    if (route.coordinates.length >= 2) {
      final coords = route.coordinates;
      final minLat = coords.map((c) => c.latitude).reduce(min);
      final maxLat = coords.map((c) => c.latitude).reduce(max);
      final minLon = coords.map((c) => c.longitude).reduce(min);
      final maxLon = coords.map((c) => c.longitude).reduce(max);
      current.mapController?.fitBounds(
        AppLatLngBounds(
          southwest: AppLatLng(latitude: minLat, longitude: minLon),
          northeast: AppLatLng(latitude: maxLat, longitude: maxLon),
        ),
        padding: const EdgeInsets.all(80),
      );
    }
    Future(() => ref.read(routeRepositoryProvider).addRoute(route));
  }

  void updateRoute(Route route) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final normalized = route.copyWith(
      localUpdatedAt: DateTime.now(),
      syncStatus: 'pending',
    );
    final updated = current.routes
        .map((item) => item.id == route.id ? normalized : item)
        .toList();
    state = AsyncData(current.copyWith(routes: updated));
    Future(() => ref.read(routeRepositoryProvider).updateRoute(normalized));
  }

  void removeRoute(String id) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final updated = current.routes.where((item) => item.id != id).toList();
    final wasSelected = current.selectedItemId == id;
    state = AsyncData(current.copyWith(
      routes: updated,
      selectedItemId: wasSelected ? null : current.selectedItemId,
      selectedItemType: wasSelected ? null : current.selectedItemType,
      bottomPanelExpanded: wasSelected ? false : current.bottomPanelExpanded,
      mode: wasSelected ? EditorMode.view : current.mode,
      routeStudioActive: wasSelected ? false : current.routeStudioActive,
    ));
    _routeRecalcVersion.remove(id);
    Future(() => ref.read(routeRepositoryProvider).deleteRoute(id));
  }

  void toggleRouteEditMode(String routeId) {
    final current = state.valueOrNull;
    if (current == null) return;
    final newMode = current.mode == EditorMode.editRoute
        ? EditorMode.editItem
        : EditorMode.editRoute;
    state = AsyncData(current.copyWith(
      mode: newMode,
      routeStudioActive: true,
    ));
  }

  Future<void> addWaypoint(String routeId, AppLatLng position) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      if (route.transportMode == 'air') return;
      final newWaypoints = [...route.waypoints, position];
      await _recalculateWithWaypoints(route, newWaypoints);
    } catch (_) {}
  }

  /// Insert a waypoint at a specific segment index (between logical nodes).
  /// segmentIndex 0 = before first waypoint, segmentIndex N = after last waypoint.
  Future<void> insertWaypointAtSegment(
      String routeId, int segmentIndex, AppLatLng position) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      if (route.transportMode == 'air') return;
      // segmentIndex maps to insertion index in waypoints list:
      // segment 0 = start→wp[0] gap → insert at index 0
      // segment N = wp[N-1]→end gap → insert at index N (= waypoints.length)
      final insertAt = segmentIndex.clamp(0, route.waypoints.length);
      final newWaypoints = [...route.waypoints]..insert(insertAt, position);
      await _recalculateWithWaypoints(route, newWaypoints);
    } catch (_) {}
  }

  Future<void> reorderWaypoints(
      String routeId, int oldIndex, int newIndex) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      if (route.transportMode == 'air') return;
      if (route.waypoints.length < 2) return;
      final wps = [...route.waypoints];
      final moved = wps.removeAt(oldIndex);
      final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
      wps.insert(target, moved);
      await _recalculateWithWaypoints(route, wps);
    } catch (_) {}
  }

  Future<void> removeWaypoint(String routeId, int index) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      if (route.transportMode == 'air') return;
      if (index < 0 || index >= route.waypoints.length) return;
      final newWaypoints = [...route.waypoints]..removeAt(index);
      await _recalculateWithWaypoints(route, newWaypoints);
    } catch (_) {}
  }

  Future<void> handleRouteLineTap(String routeId, AppLatLng position) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.mode == EditorMode.editRoute &&
        current.selectedItemId == routeId &&
        current.selectedItemType == 'route') {
      // In edit mode on THIS route, insert waypoint at tap point.
      try {
        final route = current.routes.firstWhere((r) => r.id == routeId);
        if (route.transportMode == 'air') return; // air routes not editable
        await _insertOrderedWaypoint(route, position);
      } catch (_) {}
    } else {
      // Not in edit mode, select the route.
      selectRoute(routeId);
    }
  }

  Future<void> _insertOrderedWaypoint(Route route, AppLatLng tap) async {
    final current = state.valueOrNull;
    if (current == null) return;

    try {
      final logicalNodes = _resolveLogicalNodes(current, route);
      if (logicalNodes == null || logicalNodes.length < 2) return;

      // Snap to rendered route geometry first so insertion follows what
      // the user sees, especially on curved directions polylines.
      final geometryNodes =
          route.coordinates.length >= 2 ? route.coordinates : logicalNodes;
      final snapPoint = _snapPointToPolyline(tap, geometryNodes);
      final insertAt = _nearestLogicalInsertIndex(snapPoint, logicalNodes);

      final newWaypoints = [...route.waypoints]..insert(insertAt, snapPoint);
      await _recalculateWithWaypoints(route, newWaypoints);
    } catch (_) {}
  }

  List<AppLatLng>? _resolveLogicalNodes(EditorState state, Route route) {
    if (route.startPlaceId == null || route.endPlaceId == null) return null;
    try {
      final startPlace =
          state.places.firstWhere((p) => p.id == route.startPlaceId);
      final endPlace = state.places.firstWhere((p) => p.id == route.endPlaceId);
      return [startPlace.coordinates, ...route.waypoints, endPlace.coordinates];
    } catch (_) {
      return null;
    }
  }

  AppLatLng _snapPointToPolyline(AppLatLng tap, List<AppLatLng> polyline) {
    if (polyline.length < 2) return tap;
    double minDist = double.infinity;
    AppLatLng snapped = tap;
    for (int i = 0; i < polyline.length - 1; i++) {
      final (dist, proj) =
          _projectPointToSegment(tap, polyline[i], polyline[i + 1]);
      if (dist < minDist) {
        minDist = dist;
        snapped = proj;
      }
    }
    return snapped;
  }

  int _nearestLogicalInsertIndex(
      AppLatLng point, List<AppLatLng> logicalNodes) {
    double minDist = double.infinity;
    int insertAt = logicalNodes.length - 2;
    for (int i = 0; i < logicalNodes.length - 1; i++) {
      final (dist, _) = _projectPointToSegment(
        point,
        logicalNodes[i],
        logicalNodes[i + 1],
      );
      if (dist < minDist) {
        minDist = dist;
        insertAt = i;
      }
    }
    return insertAt;
  }

  /// Projects [p] onto segment [a]->[b]. Returns (distance, snapped point).
  (double, AppLatLng) _projectPointToSegment(
      AppLatLng p, AppLatLng a, AppLatLng b) {
    final dx = b.longitude - a.longitude;
    final dy = b.latitude - a.latitude;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) {
      // Segment is a point
      final d = _dist(p, a);
      return (d, a);
    }
    final t =
        ((p.longitude - a.longitude) * dx + (p.latitude - a.latitude) * dy) /
            lenSq;
    final tc = t.clamp(0.0, 1.0);
    final snap = AppLatLng(
      latitude: a.latitude + tc * dy,
      longitude: a.longitude + tc * dx,
    );
    return (_dist(p, snap), snap);
  }

  double _dist(AppLatLng a, AppLatLng b) {
    final dx = a.longitude - b.longitude;
    final dy = a.latitude - b.latitude;
    return sqrt(dx * dx + dy * dy);
  }

  double _minDistanceToPolyline(AppLatLng point, List<AppLatLng> polyline) {
    if (polyline.length < 2) {
      return double.infinity;
    }
    var minDist = double.infinity;
    for (var i = 0; i < polyline.length - 1; i++) {
      final (dist, _) =
          _projectPointToSegment(point, polyline[i], polyline[i + 1]);
      if (dist < minDist) minDist = dist;
    }
    return minDist;
  }

  bool _isTapNearRouteLine(AppLatLng tap, Route route) {
    final current = state.valueOrNull;
    final logicalNodes = current == null
        ? const <AppLatLng>[]
        : (_resolveLogicalNodes(current, route) ?? const <AppLatLng>[]);
    final polyline =
        route.coordinates.length >= 2 ? route.coordinates : logicalNodes;
    // ~60m at the equator; tolerant enough for finger taps on mobile.
    return _minDistanceToPolyline(tap, polyline) <= 0.00055;
  }

  Route? _routeById(String routeId) {
    final current = state.valueOrNull;
    if (current == null) return null;
    for (final route in current.routes) {
      if (route.id == routeId) return route;
    }
    return null;
  }

  int _bumpRouteRecalcVersion(String routeId) {
    final version = (_routeRecalcVersion[routeId] ?? 0) + 1;
    _routeRecalcVersion[routeId] = version;
    return version;
  }

  Future<void> moveWaypoint(
      String routeId, int index, AppLatLng newPosition) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      if (route.transportMode == 'air') return;
      if (index < 0 || index >= route.waypoints.length) return;
      final newWaypoints = [...route.waypoints]..[index] = newPosition;
      await _recalculateWithWaypoints(route, newWaypoints);
    } catch (_) {}
  }

  Future<void> _recalculateWithWaypoints(
      Route route, List<AppLatLng> newWaypoints) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final baseRoute = _routeById(route.id) ?? route;
    if (baseRoute.transportMode == 'air') return;
    final version = _bumpRouteRecalcVersion(route.id);

    // Optimistic update: instant visual feedback.
    final optimistic = baseRoute.copyWith(
      waypoints: newWaypoints,
      localUpdatedAt: DateTime.now(),
      syncStatus: 'pending',
    );
    _updateRouteInState(optimistic);

    // Recalculate full path via directions API
    if (optimistic.startPlaceId == null || optimistic.endPlaceId == null) {
      return;
    }
    try {
      final fresh = state.valueOrNull;
      if (fresh == null) return;
      final startPlace =
          fresh.places.firstWhere((p) => p.id == optimistic.startPlaceId);
      final endPlace =
          fresh.places.firstWhere((p) => p.id == optimistic.endPlaceId);
      final allPoints = [
        startPlace.coordinates,
        ...newWaypoints,
        endPlace.coordinates,
      ];
      final result = await ref
          .read(directionsServiceProvider)
          .getRoute(allPoints, optimistic.transportMode);
      if (_routeRecalcVersion[route.id] != version) return;

      final latestRoute = _routeById(route.id);
      if (latestRoute == null) return;
      _updateRouteInState(latestRoute.copyWith(
        waypoints: newWaypoints,
        coordinates: result.coordinates,
        distance: result.distanceKm,
        duration: result.durationMins,
        routeGeojson: result.routeGeojson,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      ));
    } catch (_) {
      // Keep optimistic update if recalculation fails.
    }
  }

  void _updateRouteInState(Route route) {
    updateRoute(route);
  }

  Future<void> flipRoute(String routeId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      final flipVersion = _bumpRouteRecalcVersion(routeId);
      final flipped = route.copyWith(
        startPlaceId: route.endPlaceId,
        endPlaceId: route.startPlaceId,
        coordinates: route.coordinates.reversed.toList(),
        waypoints: route.waypoints.reversed.toList(),
        routeGeojson: null,
        localUpdatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      updateRoute(flipped);
      if (flipped.transportMode == 'air') {
        return;
      }
      // Recalculate with flipped endpoints + waypoints
      if (flipped.startPlaceId != null && flipped.endPlaceId != null) {
        final fresh = state.valueOrNull;
        if (fresh == null) return;
        final startPlace =
            fresh.places.firstWhere((p) => p.id == flipped.startPlaceId);
        final endPlace =
            fresh.places.firstWhere((p) => p.id == flipped.endPlaceId);
        final allWaypoints = [
          startPlace.coordinates,
          ...flipped.waypoints,
          endPlace.coordinates,
        ];
        try {
          final result = await ref
              .read(directionsServiceProvider)
              .getRoute(allWaypoints, flipped.transportMode);
          if (_routeRecalcVersion[routeId] != flipVersion) return;
          final latestRoute = _routeById(routeId);
          if (latestRoute == null) return;
          updateRoute(latestRoute.copyWith(
            coordinates: result.coordinates,
            distance: result.distanceKm,
            duration: result.durationMins,
            routeGeojson: result.routeGeojson,
            localUpdatedAt: DateTime.now(),
            syncStatus: 'pending',
          ));
        } catch (_) {}
      }
    } catch (_) {}
  }

  void startDrawingRoute([EditorMode mode = EditorMode.addRouteCar]) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      mode: mode,
      routeStartItemId: null,
      routeStartItemType: null,
      routeEndItemId: null,
      bottomPanelExpanded: true,
    ));
  }

  void selectRouteSource(String? id) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (id == null) {
      state = AsyncData(current.copyWith(
        routeStartItemId: null,
        routeStartItemType: null,
        routeEndItemId: null,
      ));
      return;
    }

    String? routeStartItemType;
    try {
      final selectedPlace = current.places.firstWhere((p) => p.id == id);
      routeStartItemType = selectedPlace.placeType == 'city' ? 'city' : 'place';
    } catch (_) {}

    state = AsyncData(current.copyWith(
      routeStartItemId: id,
      routeStartItemType: routeStartItemType,
      routeEndItemId:
          current.routeEndItemId == id ? null : current.routeEndItemId,
    ));
  }

  void selectRouteDestination(String? id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      routeEndItemId: id == current.routeStartItemId ? null : id,
    ));
  }

  void clearRouteDraft() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      routeStartItemId: null,
      routeStartItemType: null,
      routeEndItemId: null,
    ));
  }

  void cancelRouteMode() {
    clearRouteDraft();
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        mode: EditorMode.view,
        routeStudioActive: false,
        routeStartItemId: null,
        routeStartItemType: null,
        routeEndItemId: null,
      ));
    }
  }

  Future<void> handleMapTap(AppLatLng position) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.mode == EditorMode.editRoute &&
        current.selectedItemId != null &&
        current.selectedItemType == 'route') {
      try {
        final route =
            current.routes.firstWhere((r) => r.id == current.selectedItemId);
        if (route.transportMode == 'air') return;
        // Fallback path: if route-line tap didn't deliver a point on this
        // platform, a near-line map tap still inserts the waypoint.
        if (_isTapNearRouteLine(position, route)) {
          await _insertOrderedWaypoint(route, position);
        }
      } catch (_) {}
      return;
    }
    deselectAll();
  }

  Future<void> drawRoute(
    String startPlaceId,
    String endPlaceId, {
    EditorMode? capturedMode,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (startPlaceId == endPlaceId) return;

    // Use captured mode so we don't read stale state (mode may have been reset)
    final effectiveMode = capturedMode ?? current.mode;
    final transportMode = switch (effectiveMode) {
      EditorMode.addRouteAir => 'air',
      EditorMode.addRouteWalking => 'foot',
      _ => 'car',
    };

    state = AsyncData(current.copyWith(isGeneratingRoute: true));

    try {
      final fresh = state.valueOrNull!;
      final startPlace =
          fresh.places.firstWhere((place) => place.id == startPlaceId);
      final endPlace =
          fresh.places.firstWhere((place) => place.id == endPlaceId);

      final routeRepo = ref.read(routeRepositoryProvider);
      final route = transportMode == 'air'
          ? routeRepo.generateAirRoute(
              tripId: fresh.trip.id,
              start: startPlace.coordinates,
              end: endPlace.coordinates,
              startPlaceId: startPlaceId,
              endPlaceId: endPlaceId,
              orderIndex: fresh.places.length + fresh.routes.length,
            )
          : await routeRepo.generateRouteViaApi(
              tripId: fresh.trip.id,
              start: startPlace.coordinates,
              end: endPlace.coordinates,
              mode: transportMode,
              startPlaceId: startPlaceId,
              endPlaceId: endPlaceId,
              orderIndex: fresh.places.length + fresh.routes.length,
            );

      addRoute(route);
    } catch (error) {
      debugPrint('Route generation failed: $error');
      final afterError = state.valueOrNull;
      if (afterError != null) {
        state = AsyncData(afterError.copyWith(
          isGeneratingRoute: false,
        ));
      }
    }
  }

  Future<void> save() async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(saving: true));
    try {
      await ref.read(tripRepositoryProvider).updateTrip(current.trip);
      final latest = state.valueOrNull;
      if (latest != null) {
        state = AsyncData(latest.copyWith(saving: false));
      }
    } catch (_) {
      final latest = state.valueOrNull;
      if (latest != null) {
        state = AsyncData(latest.copyWith(saving: false));
      }
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 30), save);
  }
}
