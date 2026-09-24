/// Mobile stub: `WebMapView` is web-only. Never instantiated on mobile
/// (see the conditional import in `app_map_view.dart`).
library;

import 'package:flutter/material.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

class WebMapView extends StatelessWidget {
  const WebMapView({
    super.key,
    required this.initialCenter,
    this.initialZoom = 12.0,
    this.onMapCreated,
    this.onMapTap,
    this.onRouteTap,
    this.onRouteLineTap,
    this.markers,
    this.routes,
    this.showUserLocation = false,
    this.showCompass = true,
    this.showScaleBar = true,
    this.enableZoomGestures = true,
    this.enableRotateGestures = true,
    this.enableTiltGestures = true,
    this.enableScrollGestures = true,
  });

  final AppLatLng initialCenter;
  final double initialZoom;
  final void Function(AppMapController controller)? onMapCreated;
  final void Function(AppLatLng position)? onMapTap;
  final void Function(String routeId)? onRouteTap;
  final void Function(String routeId, AppLatLng position)? onRouteLineTap;
  final List<AppMarker>? markers;
  final List<AppRoute>? routes;
  final bool showUserLocation;
  final bool showCompass;
  final bool showScaleBar;
  final bool enableZoomGestures;
  final bool enableRotateGestures;
  final bool enableTiltGestures;
  final bool enableScrollGestures;

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError('WebMapView is web-only.');
  }
}
