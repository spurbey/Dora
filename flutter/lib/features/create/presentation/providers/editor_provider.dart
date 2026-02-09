import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/map/app_map_controller.dart';
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
  return RouteRepository(db);
}

@riverpod
class EditorController extends _$EditorController {
  Timer? _autoSaveTimer;
  String? _routeStartPlaceId;

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
    current.mapController?.flyTo(place.coordinates, zoom: 15);
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
    ));
  }

  void setMode(EditorMode mode) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }
    if (mode != EditorMode.drawRoute) {
      _routeStartPlaceId = null;
    }
    state = AsyncData(current.copyWith(mode: mode));
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
    state = AsyncData(current.copyWith(places: updatedPlaces));
    current.mapController?.flyTo(place.coordinates, zoom: 15);
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

    if (current.mode == EditorMode.drawRoute) {
      if (_routeStartPlaceId == null) {
        _routeStartPlaceId = id;
        return;
      }

      final startId = _routeStartPlaceId!;
      _routeStartPlaceId = null;
      drawRoute(startId, id);
      setMode(EditorMode.view);
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
      mode: EditorMode.view,
    ));
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
    state = AsyncData(current.copyWith(routes: updated));
    Future(() => ref.read(routeRepositoryProvider).deleteRoute(id));
    _scheduleAutoSave();
  }

  void startDrawingRoute() {
    setMode(EditorMode.drawRoute);
  }

  Future<void> drawRoute(String startPlaceId, String endPlaceId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final startPlace =
        current.places.firstWhere((place) => place.id == startPlaceId);
    final endPlace =
        current.places.firstWhere((place) => place.id == endPlaceId);

    final route = ref.read(routeRepositoryProvider).generateRoute(
          tripId: current.trip.id,
          start: startPlace.coordinates,
          end: endPlace.coordinates,
        );

    addRoute(route);
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
