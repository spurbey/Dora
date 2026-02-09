import 'package:flutter/material.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/models/app_bounds.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

class FlutterMapAdapter implements AppMapController {
  @override
  Future<void> addMarker(AppMarker marker) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> addRoute(AppRoute route) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> clearMarkers() async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> clearRoutes() async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  void dispose() {}

  @override
  void enableRotation(bool enable) {}

  @override
  void enableTilt(bool enable) {}

  @override
  void enableZoom(bool enable) {}

  @override
  void enableScroll(bool enable) {}

  @override
  Future<void> fitBounds(AppLatLngBounds bounds, {EdgeInsets? padding}) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> flyTo(AppLatLng target,
      {double? zoom, Duration? duration}) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<AppLatLng> getCenter() async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<double> getZoom() async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<AppLatLng?> getUserLocation() async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> removeMarker(String id) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> removeRoute(String id) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> showUserLocation(bool show) async {}

  @override
  void showCompass(bool show) {}

  @override
  Future<void> updateMarker(AppMarker marker) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }

  @override
  Future<void> updateRoute(AppRoute route) async {
    throw UnimplementedError('Flutter map adapter not implemented.');
  }
}
