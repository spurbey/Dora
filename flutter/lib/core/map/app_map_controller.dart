import 'package:flutter/material.dart';

import 'package:dora/core/map/models/app_bounds.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

abstract class AppMapController {
  // Camera Control
  Future<void> flyTo(AppLatLng target, {double? zoom, Duration? duration});
  Future<void> fitBounds(AppLatLngBounds bounds, {EdgeInsets? padding});
  Future<AppLatLng> getCenter();
  Future<double> getZoom();

  // Markers
  Future<void> addMarker(AppMarker marker);
  Future<void> removeMarker(String id);
  Future<void> updateMarker(AppMarker marker);
  Future<void> clearMarkers();

  // Routes
  Future<void> addRoute(AppRoute route);
  Future<void> removeRoute(String id);
  Future<void> updateRoute(AppRoute route);
  Future<void> clearRoutes();

  // User Location
  Future<void> showUserLocation(bool show);
  Future<AppLatLng?> getUserLocation();

  // Gestures
  void enableRotation(bool enable);
  void enableTilt(bool enable);
  void enableZoom(bool enable);
  void enableScroll(bool enable);

  // UI
  void showCompass(bool show);

  // Lifecycle
  void dispose();
}
