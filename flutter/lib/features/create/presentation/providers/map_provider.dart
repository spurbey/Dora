import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/theme/app_colors.dart';
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

  // Number non-city places sequentially
  int placeNumber = 0;
  final sortedPlaces = List.of(editor.places)
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  final markers = sortedPlaces.map((place) {
    final isCity = place.placeType == 'city';
    if (!isCity) placeNumber++;

    final isRouteStart = routeStartId == place.id;
    final Color markerColor;
    if (isRouteStart) {
      markerColor = const Color(0xFFE53935);
    } else if (isCity) {
      markerColor = AppColors.primary;
    } else {
      markerColor = AppColors.accent;
    }

    return AppMarker(
      id: place.id,
      position: place.coordinates,
      title: place.name,
      color: markerColor,
      markerType: isCity ? 'city' : 'place',
      label: isCity ? 'C' : '$placeNumber',
      onTap: () => ref
          .read(editorControllerProvider(tripId).notifier)
          .handlePlaceTap(place.id),
    );
  }).toList();

  final routes = editor.routes
      .map((route) => AppRoute(
            id: route.id,
            coordinates: route.coordinates,
            color: _routeColor(route.transportMode),
            width: 4,
          ))
      .toList();

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
