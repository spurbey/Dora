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

  final markers = editor.places
      .map((place) => AppMarker(
            id: place.id,
            position: place.coordinates,
            title: place.name,
            color: AppColors.accent,
            onTap: () => ref
                .read(editorControllerProvider(tripId).notifier)
                .handlePlaceTap(place.id),
          ))
      .toList();

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
    case 'walk':
      return const Color(0xFFB96B2B);
    case 'air':
      return const Color(0xFF4F46E5);
    default:
      return AppColors.accent;
  }
}
