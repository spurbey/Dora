import 'package:flutter/foundation.dart';
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
  State<AppMapView> createState() => _AppMapViewState();
}

class _AppMapViewState extends State<AppMapView> {
  MapboxAdapter? _controller;
  MapboxMap? _mapboxMap;
  bool _styleLoaded = false;
  bool _syncInFlight = false;
  bool _needsResync = false;
  final Map<String, _MarkerRenderSignature> _markerSignatures = {};
  final Map<String, _RouteRenderSignature> _routeSignatures = {};

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
    if (!mounted || _controller == null || !_styleLoaded) {
      return;
    }
    _syncInFlight = true;
    _needsResync = false;
    try {
      await _syncOverlays();
    } catch (e) {
      // Keep the map alive; next state update will resync.
      debugPrint('AppMapView sync failed: $e');
      _needsResync = true;
    } finally {
      _syncInFlight = false;
    }
    if (_needsResync && mounted) {
      _doSync();
    }
  }

  Future<void> _syncOverlays() async {
    final controller = _controller;
    if (controller == null || !_styleLoaded) {
      return;
    }
    final nextMarkers = <String, AppMarker>{
      for (final marker in widget.markers ?? const <AppMarker>[])
        marker.id: marker,
    };
    final existingMarkerIds = Set<String>.from(_markerSignatures.keys);
    final nextMarkerIds = Set<String>.from(nextMarkers.keys);

    for (final removedId in existingMarkerIds.difference(nextMarkerIds)) {
      await controller.removeMarker(removedId);
      _markerSignatures.remove(removedId);
    }

    for (final entry in nextMarkers.entries) {
      final marker = entry.value;
      final signature = _MarkerRenderSignature.from(marker);
      final previous = _markerSignatures[entry.key];
      if (previous == null) {
        await controller.addMarker(marker);
        _markerSignatures[entry.key] = signature;
        continue;
      }
      if (previous != signature) {
        await controller.updateMarker(marker);
        _markerSignatures[entry.key] = signature;
      }
    }

    final nextRoutes = <String, AppRoute>{
      for (final route in widget.routes ?? const <AppRoute>[]) route.id: route,
    };
    final existingRouteIds = Set<String>.from(_routeSignatures.keys);
    final nextRouteIds = Set<String>.from(nextRoutes.keys);

    for (final removedId in existingRouteIds.difference(nextRouteIds)) {
      await controller.removeRoute(removedId);
      _routeSignatures.remove(removedId);
    }

    for (final entry in nextRoutes.entries) {
      final route = entry.value;
      final signature = _RouteRenderSignature.from(route);
      final previous = _routeSignatures[entry.key];
      if (previous == null) {
        await controller.addRoute(route);
        _routeSignatures[entry.key] = signature;
        continue;
      }
      if (previous != signature) {
        await controller.updateRoute(route);
        _routeSignatures[entry.key] = signature;
      }
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _styleLoaded = false;
    _mapboxMap = mapboxMap;
    _markerSignatures.clear();
    _routeSignatures.clear();
    _controller = MapboxAdapter(
      mapboxMap,
      onMapTap: widget.onMapTap,
      onRouteTap: widget.onRouteTap,
      onRouteLineTap: widget.onRouteLineTap,
    );
    widget.onMapCreated?.call(_controller!);
    _applySettings();
    _scheduleSync();
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    _styleLoaded = true;
    _markerSignatures.clear();
    _routeSignatures.clear();
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
    final mapboxMap = _mapboxMap;
    controller.showUserLocation(widget.showUserLocation);
    controller.showCompass(widget.showCompass);
    if (mapboxMap != null) {
      mapboxMap.scaleBar
          .updateSettings(ScaleBarSettings(enabled: widget.showScaleBar));
    }
    controller.enableZoom(widget.enableZoomGestures);
    controller.enableRotation(widget.enableRotateGestures);
    controller.enableTilt(widget.enableTiltGestures);
    controller.enableScroll(widget.enableScrollGestures);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _mapboxMap = null;
    _markerSignatures.clear();
    _routeSignatures.clear();
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

class _MarkerRenderSignature {
  const _MarkerRenderSignature({
    required this.lat,
    required this.lng,
    required this.title,
    required this.snippet,
    required this.iconAsset,
    required this.iconBytesLength,
    required this.iconBytesHash,
    required this.colorValue,
    required this.markerType,
    required this.label,
    required this.draggable,
    required this.hasTap,
    required this.hasDragEnd,
  });

  factory _MarkerRenderSignature.from(AppMarker marker) {
    final bytes = marker.iconPngBytes;
    return _MarkerRenderSignature(
      lat: marker.position.latitude,
      lng: marker.position.longitude,
      title: marker.title,
      snippet: marker.snippet,
      iconAsset: marker.iconAsset,
      iconBytesLength: bytes?.length ?? 0,
      // Identity-based hash avoids re-encoding on every rebuild while still
      // detecting when the caller swaps in a new Uint8List.
      iconBytesHash: bytes == null ? 0 : identityHashCode(bytes),
      colorValue: marker.color?.toARGB32(),
      markerType: marker.markerType,
      label: marker.label,
      draggable: marker.draggable,
      hasTap: marker.onTap != null,
      hasDragEnd: marker.onDragEnd != null,
    );
  }

  final double lat;
  final double lng;
  final String? title;
  final String? snippet;
  final String? iconAsset;
  final int iconBytesLength;
  final int iconBytesHash;
  final int? colorValue;
  final String? markerType;
  final String? label;
  final bool draggable;
  final bool hasTap;
  final bool hasDragEnd;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _MarkerRenderSignature &&
        lat == other.lat &&
        lng == other.lng &&
        title == other.title &&
        snippet == other.snippet &&
        iconAsset == other.iconAsset &&
        iconBytesLength == other.iconBytesLength &&
        iconBytesHash == other.iconBytesHash &&
        colorValue == other.colorValue &&
        markerType == other.markerType &&
        label == other.label &&
        draggable == other.draggable &&
        hasTap == other.hasTap &&
        hasDragEnd == other.hasDragEnd;
  }

  @override
  int get hashCode => Object.hash(
        lat,
        lng,
        title,
        snippet,
        iconAsset,
        iconBytesLength,
        iconBytesHash,
        colorValue,
        markerType,
        label,
        draggable,
        hasTap,
        hasDragEnd,
      );
}

class _RouteRenderSignature {
  const _RouteRenderSignature({
    required this.coordinates,
    required this.colorValue,
    required this.width,
    required this.dashed,
  });

  factory _RouteRenderSignature.from(AppRoute route) {
    return _RouteRenderSignature(
      coordinates: route.coordinates
          .map((point) => _LatLngTuple(point.latitude, point.longitude))
          .toList(growable: false),
      colorValue: route.color?.toARGB32(),
      width: route.width,
      dashed: route.dashed,
    );
  }

  final List<_LatLngTuple> coordinates;
  final int? colorValue;
  final double? width;
  final bool? dashed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _RouteRenderSignature &&
        listEquals(coordinates, other.coordinates) &&
        colorValue == other.colorValue &&
        width == other.width &&
        dashed == other.dashed;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(coordinates),
        colorValue,
        width,
        dashed,
      );
}

class _LatLngTuple {
  const _LatLngTuple(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _LatLngTuple && lat == other.lat && lng == other.lng;
  }

  @override
  int get hashCode => Object.hash(lat, lng);
}
