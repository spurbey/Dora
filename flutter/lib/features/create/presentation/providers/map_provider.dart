import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/map_state.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';

part 'map_provider.g.dart';

@riverpod
MapState mapState(MapStateRef ref, String tripId) {
  final editor = ref.watch(editorControllerProvider(tripId)).valueOrNull;
  if (editor == null) {
    return const MapState();
  }

  final routeStartId = editor.routeStartItemId;
  final routeEndId = editor.routeEndItemId;
  final selectedPlaceId =
      editor.selectedItemType == 'place' ? editor.selectedItemId : null;

  // Number non-city places sequentially
  int placeNumber = 0;
  final sortedPlaces = List.of(editor.places)
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  final markers = sortedPlaces.map((place) {
    final isCity = place.placeType == 'city';
    if (!isCity) placeNumber++;

    final isRouteStart = routeStartId == place.id;
    final isRouteEnd = routeEndId == place.id;
    final isSelectedPlace = selectedPlaceId == place.id;
    final Color markerColor;
    if (isRouteStart) {
      markerColor = const Color(0xFFE53935); // red = source
    } else if (isRouteEnd) {
      markerColor = const Color(0xFF1565C0); // blue = destination
    } else if (isSelectedPlace) {
      markerColor = isCity
          ? const Color(0xFF355C7D)
          : const Color(0xFF0D7377); // stronger highlight for active selection
    } else if (isCity) {
      markerColor = AppColors.primary;
    } else {
      markerColor = AppColors.accent;
    }

    final markerType = isRouteStart
        ? 'route_start'
        : isRouteEnd
            ? 'route_end'
            : isCity
                ? (isSelectedPlace ? 'city_selected' : 'city')
                : (isSelectedPlace ? 'place_selected' : 'place');
    final label = isRouteStart
        ? 'S'
        : isRouteEnd
            ? 'D'
            : isCity
                ? (isSelectedPlace ? 'CTY' : 'C')
                : '$placeNumber';

    return AppMarker(
      id: place.id,
      position: place.coordinates,
      title: place.name,
      color: markerColor,
      markerType: markerType,
      label: label,
      onTap: () => ref
          .read(editorControllerProvider(tripId).notifier)
          .handlePlaceTap(place.id),
    );
  }).toList();

  // In Route Studio: add waypoint markers for the selected route
  final isEditRoute = editor.mode == EditorMode.editRoute;
  final isRouteStudio = editor.routeStudioActive;
  final studioRouteId = isRouteStudio && editor.selectedItemType == 'route'
      ? editor.selectedItemId
      : null;

  if (studioRouteId != null) {
    try {
      final editingRoute =
          editor.routes.firstWhere((r) => r.id == studioRouteId);
      if (editingRoute.coordinates.isNotEmpty) {
        final start = editingRoute.coordinates.first;
        markers.add(AppMarker(
          id: '_ep_start_$studioRouteId',
          position: start,
          title: 'Start',
          color: const Color(0xFF2E7D32), // green
          markerType: 'endpoint',
          label: 'S',
        ));
      }
      if (editingRoute.coordinates.length > 1) {
        final end = editingRoute.coordinates.last;
        markers.add(AppMarker(
          id: '_ep_end_$studioRouteId',
          position: end,
          title: 'End',
          color: const Color(0xFFC62828), // red
          markerType: 'endpoint',
          label: 'E',
        ));
      }
      for (int i = 0; i < editingRoute.waypoints.length; i++) {
        final wp = editingRoute.waypoints[i];
        final capturedIndex = i;
        markers.add(AppMarker(
          id: '_wp_${studioRouteId}_$i',
          position: wp,
          title: 'Waypoint ${i + 1}',
          color: const Color(0xFF7B1FA2), // purple
          markerType: 'waypoint',
          label: '${i + 1}',
          draggable: isEditRoute,
          onTap: isEditRoute
              ? () => ref
                  .read(editorControllerProvider(tripId).notifier)
                  .removeWaypoint(studioRouteId, capturedIndex)
              : null,
          onDragEnd: isEditRoute
              ? (newPos) => ref
                  .read(editorControllerProvider(tripId).notifier)
                  .moveWaypoint(studioRouteId, capturedIndex, newPos)
              : null,
        ));
      }
      // In editRoute mode: add midpoint handles between each pair of logical nodes
      if (isEditRoute && editingRoute.transportMode != 'air') {
        final logicalNodes = <AppLatLng>[];
        try {
          final startPlace = editor.places
              .firstWhere((p) => p.id == editingRoute.startPlaceId);
          final endPlace =
              editor.places.firstWhere((p) => p.id == editingRoute.endPlaceId);
          logicalNodes.addAll([
            startPlace.coordinates,
            ...editingRoute.waypoints,
            endPlace.coordinates,
          ]);
        } catch (_) {}

        for (int i = 0; i < logicalNodes.length - 1; i++) {
          final a = logicalNodes[i];
          final b = logicalNodes[i + 1];
          final mid = AppLatLng(
            latitude: (a.latitude + b.latitude) / 2,
            longitude: (a.longitude + b.longitude) / 2,
          );
          final capturedSegment = i;
          markers.add(AppMarker(
            id: '_mid_${studioRouteId}_$i',
            position: mid,
            title: 'Add waypoint',
            color: const Color(0xFF90CAF9), // light blue
            markerType: 'midpoint',
            label: '+',
            onTap: () => ref
                .read(editorControllerProvider(tripId).notifier)
                .insertWaypointAtSegment(studioRouteId, capturedSegment, mid),
          ));
        }
      }
    } catch (_) {}
  }

  final selectedRouteId =
      editor.selectedItemType == 'route' ? editor.selectedItemId : null;

  final routes = editor.routes.map((route) {
    final isSelected = route.id == selectedRouteId;
    final baseWidth = switch (route.transportMode) {
      'air' => 2.0,
      'foot' || 'walk' || 'walking' => 2.0,
      _ => 4.0,
    };
    final widthMultiplier = isSelected && isEditRoute
        ? 3.0
        : (isSelected && isRouteStudio ? 2.0 : (isSelected ? 1.5 : 1.0));
    return AppRoute(
      id: route.id,
      coordinates: route.coordinates,
      color: _routeColor(route.transportMode),
      width: baseWidth * widthMultiplier,
      dashed: route.transportMode == 'air',
    );
  }).toList();

  // Build a set of place-pair keys covered by explicit routes (both directions)
  final explicitRouteKeys = <String>{};
  for (final r in editor.routes) {
    if (r.startPlaceId != null && r.endPlaceId != null) {
      explicitRouteKeys.add('${r.startPlaceId}_${r.endPlaceId}');
      explicitRouteKeys.add('${r.endPlaceId}_${r.startPlaceId}');
    }
  }

  // Synthetic connectors: thin gray dashed lines for consecutive unconnected places
  for (int i = 0; i < sortedPlaces.length - 1; i++) {
    final from = sortedPlaces[i];
    final to = sortedPlaces[i + 1];
    final key = '${from.id}_${to.id}';
    if (!explicitRouteKeys.contains(key)) {
      routes.add(AppRoute(
        id: '_conn_${from.id}_${to.id}',
        coordinates: [from.coordinates, to.coordinates],
        color: const Color(0xFFCCCCCC),
        width: 1.5,
        dashed: true,
      ));
    }
  }

  return MapState(
    controller: editor.mapController,
    markers: markers,
    routes: routes,
    center: editor.trip.centerPoint,
    zoom: editor.trip.zoom,
  );
}

Color _routeColor(String mode) {
  switch (mode) {
    case 'bike':
      return const Color(0xFF1D9A6C);
    case 'foot':
    case 'walk':
      return const Color(0xFFB96B2B);
    case 'air':
      return const Color(0xFF4F46E5);
    default:
      return AppColors.accent;
  }
}
