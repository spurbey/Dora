import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dora/core/map/adapters/mapbox_adapter.dart';
import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

class AppMapView extends StatefulWidget {
  const AppMapView({
    super.key,
    required this.initialCenter,
    this.initialZoom = 12.0,
    this.onMapCreated,
    this.onMapTap,
    this.onRouteTap,
    this.markers,
    this.routes,
    this.showUserLocation = false,
    this.showCompass = true,
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
  final List<AppMarker>? markers;
  final List<AppRoute>? routes;
  final bool showUserLocation;
  final bool showCompass;
  final bool enableZoomGestures;
  final bool enableRotateGestures;
  final bool enableTiltGestures;
  final bool enableScrollGestures;

  @override
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  MapboxAdapter? _controller;
  bool _styleLoaded = false;
  bool _syncInFlight = false;
  bool _needsResync = false;

  @override
  void didUpdateWidget(covariant AppMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markers != widget.markers ||
        oldWidget.routes != widget.routes) {
      _scheduleSync();
    }
    _applySettings();
  }

  void _scheduleSync() {
    if (_controller == null || !_styleLoaded) {
      return;
    }
    if (_syncInFlight) {
      _needsResync = true;
      return;
    }
    _doSync();
  }

  Future<void> _doSync() async {
    _syncInFlight = true;
    _needsResync = false;
    await _syncOverlays();
    _syncInFlight = false;
    if (_needsResync && mounted) {
      _doSync();
    }
  }

  Future<void> _syncOverlays() async {
    final controller = _controller;
    if (controller == null || !_styleLoaded) {
      return;
    }
    await controller.clearMarkers();
    for (final marker in widget.markers ?? const <AppMarker>[]) {
      await controller.addMarker(marker);
    }

    await controller.clearRoutes();
    for (final route in widget.routes ?? const <AppRoute>[]) {
      await controller.addRoute(route);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _controller = MapboxAdapter(
      mapboxMap,
      onMapTap: widget.onMapTap,
      onRouteTap: widget.onRouteTap,
    );
    widget.onMapCreated?.call(_controller!);
    _applySettings();
    _scheduleSync();
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    _styleLoaded = true;
    _scheduleSync();
  }

  void _onMapTap(MapContentGestureContext context) {
    _controller?.handleMapTap(context);
  }

  void _applySettings() {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    controller.showUserLocation(widget.showUserLocation);
    controller.showCompass(widget.showCompass);
    controller.enableZoom(widget.enableZoomGestures);
    controller.enableRotation(widget.enableRotateGestures);
    controller.enableTilt(widget.enableTiltGestures);
    controller.enableScroll(widget.enableScrollGestures);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            widget.initialCenter.longitude,
            widget.initialCenter.latitude,
          ),
        ),
        zoom: widget.initialZoom,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: _onStyleLoaded,
      onTapListener: _onMapTap,
    );
  }
}
