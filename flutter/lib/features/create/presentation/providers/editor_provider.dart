import 'dart:async';
import 'dart:math' show min, max;

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
  final authService = ref.watch(authServiceProvider);
  return TripRepository(db, authService);
}

@riverpod
PlaceRepository placeRepository(PlaceRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final searchApi = ref.watch(searchApiProvider);
  final authService = ref.watch(authServiceProvider);
  return PlaceRepository(
    db,
    searchApi: searchApi,
    authService: authService,
  );
}

@riverpod
RouteRepository routeRepository(RouteRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final directionsService = ref.watch(directionsServiceProvider);
  return RouteRepository(db, directionsService: directionsService);
}

@riverpod
class EditorController extends _$EditorController {
  Timer? _autoSaveTimer;

  @override
  Future<EditorState> build(String tripId) async {
    ref.onDispose(() => _autoSaveTimer?.cancel());

    final tripRepository = ref.watch(tripRepositoryProvider);
    final placeRepository = ref.watch(placeRepositoryProvider);
    final routeRepository = ref.watch(routeRepositoryProvider);

    final trip = await tripRepository.getTrip(tripId);
    if (trip == null) {
      throw Exception('Trip not found');
    }

    final places = await placeRepository.getPlaces(tripId);
    final routes = await routeRepository.getRoutes(tripId);

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
      bottomPanelExpanded: true,
      mode: EditorMode.editItem,
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
    _scheduleAutoSave();
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

      // Has source — tapping selects/updates destination. Never auto-draws.
      if (isAir && place.placeType != 'city') return;
      if (id == current.routeStartItemId) return; // can't pick same place
      selectRouteDestination(id);
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
    _scheduleAutoSave();
  }

  void removePlace(String id) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final updated = current.places.where((item) => item.id != id).toList();
    state = AsyncData(current.copyWith(places: updated));
    Future(() => ref.read(placeRepositoryProvider).deletePlace(id));
    _scheduleAutoSave();
  }

  void reorderPlaces(int oldIndex, int newIndex) {
    final current = state.valueOrNull;
    if (current == null || current.places.isEmpty) {
      return;
    }

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
    _scheduleAutoSave();
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
      bottomPanelExpanded: true,
      mode: EditorMode.editItem,
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
    _scheduleAutoSave();
  }

  void updateRoute(Route route) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final updated = current.routes
        .map((item) => item.id == route.id ? route : item)
        .toList();
    state = AsyncData(current.copyWith(routes: updated));
    Future(() => ref.read(routeRepositoryProvider).updateRoute(route));
    _scheduleAutoSave();
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
    ));
    Future(() => ref.read(routeRepositoryProvider).deleteRoute(id));
    _scheduleAutoSave();
  }

  void toggleRouteEditMode(String routeId) {
    final current = state.valueOrNull;
    if (current == null) return;
    final newMode = current.mode == EditorMode.editRoute
        ? EditorMode.editItem
        : EditorMode.editRoute;
    state = AsyncData(current.copyWith(mode: newMode));
  }

  Future<void> addWaypoint(String routeId, AppLatLng position) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      final newWaypoints = [...route.waypoints, position];
      final updatedRoute = route.copyWith(waypoints: newWaypoints);
      updateRoute(updatedRoute);
      // Recalculate via API if we have start/end places
      if (route.startPlaceId != null && route.endPlaceId != null) {
        final startPlace = current.places
            .firstWhere((p) => p.id == route.startPlaceId);
        final endPlace = current.places
            .firstWhere((p) => p.id == route.endPlaceId);
        final allWaypoints = [
          startPlace.coordinates,
          ...newWaypoints,
          endPlace.coordinates,
        ];
        try {
          final result = await ref
              .read(directionsServiceProvider)
              .getRoute(allWaypoints, route.transportMode);
          updateRoute(updatedRoute.copyWith(
            coordinates: result.coordinates,
            distance: result.distanceKm,
            duration: result.durationMins,
          ));
        } catch (_) {
          // Keep the updated waypoints even if recalculation fails
        }
      }
    } catch (_) {}
  }

  Future<void> removeWaypoint(String routeId, int index) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      final newWaypoints = [...route.waypoints]..removeAt(index);
      final updatedRoute = route.copyWith(waypoints: newWaypoints);
      updateRoute(updatedRoute);
      // Recalculate
      if (route.startPlaceId != null && route.endPlaceId != null) {
        final startPlace = current.places
            .firstWhere((p) => p.id == route.startPlaceId);
        final endPlace = current.places
            .firstWhere((p) => p.id == route.endPlaceId);
        final allWaypoints = [
          startPlace.coordinates,
          ...newWaypoints,
          endPlace.coordinates,
        ];
        try {
          final result = await ref
              .read(directionsServiceProvider)
              .getRoute(allWaypoints, route.transportMode);
          updateRoute(updatedRoute.copyWith(
            coordinates: result.coordinates,
            distance: result.distanceKm,
            duration: result.durationMins,
          ));
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> flipRoute(String routeId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final route = current.routes.firstWhere((r) => r.id == routeId);
      final flipped = route.copyWith(
        startPlaceId: route.endPlaceId,
        endPlaceId: route.startPlaceId,
        coordinates: route.coordinates.reversed.toList(),
        waypoints: route.waypoints.reversed.toList(),
      );
      updateRoute(flipped);
      // Recalculate with flipped endpoints + waypoints
      if (flipped.startPlaceId != null && flipped.endPlaceId != null) {
        final startPlace = current.places
            .firstWhere((p) => p.id == flipped.startPlaceId);
        final endPlace = current.places
            .firstWhere((p) => p.id == flipped.endPlaceId);
        final allWaypoints = [
          startPlace.coordinates,
          ...flipped.waypoints,
          endPlace.coordinates,
        ];
        try {
          final result = await ref
              .read(directionsServiceProvider)
              .getRoute(allWaypoints, flipped.transportMode);
          updateRoute(flipped.copyWith(
            coordinates: result.coordinates,
            distance: result.distanceKm,
            duration: result.durationMins,
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

  void selectRouteSource(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(routeStartItemId: id));
  }

  void selectRouteDestination(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(routeEndItemId: id));
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
    setMode(EditorMode.view);
  }

  Future<void> handleMapTap(AppLatLng position) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.mode == EditorMode.editRoute &&
        current.selectedItemId != null &&
        current.selectedItemType == 'route') {
      await addWaypoint(current.selectedItemId!, position);
    } else {
      deselectAll();
    }
  }

  Future<void> drawRoute(
    String startPlaceId,
    String endPlaceId, {
    EditorMode? capturedMode,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

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

      // Clear draft + mark done before adding route (which changes selection)
      final afterDraft = state.valueOrNull!;
      state = AsyncData(afterDraft.copyWith(
        isGeneratingRoute: false,
        routeStartItemId: null,
        routeStartItemType: null,
        routeEndItemId: null,
      ));
      addRoute(route);
    } catch (_) {
      final afterError = state.valueOrNull;
      if (afterError != null) {
        state = AsyncData(afterError.copyWith(
          isGeneratingRoute: false,
          routeStartItemId: null,
          routeStartItemType: null,
          routeEndItemId: null,
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
      await ref.read(placeRepositoryProvider).savePlaces(current.places);
      await ref.read(routeRepositoryProvider).saveRoutes(current.routes);
      state = AsyncData(current.copyWith(saving: false));
    } catch (_) {
      state = AsyncData(current.copyWith(saving: false));
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 30), save);
  }
}
