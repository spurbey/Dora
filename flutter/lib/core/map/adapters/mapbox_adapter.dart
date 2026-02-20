import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/models/app_bounds.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

class MapboxAdapter implements AppMapController {
  MapboxAdapter(
    this._mapboxMap, {
    this.onMapTap,
    this.onRouteTap,
    this.onRouteLineTap,
  });

  final MapboxMap _mapboxMap;
  final void Function(AppLatLng position)? onMapTap;
  final void Function(String routeId)? onRouteTap;
  final void Function(String routeId, AppLatLng position)? onRouteLineTap;

  PointAnnotationManager? _pointManager;
  PolylineAnnotationManager? _lineManager;
  Cancelable? _pointTapCancelable;
  Cancelable? _lineTapCancelable;
  Cancelable? _pointDragCancelable;

  // Deferred tap: line tap fires before map tap resolves in same gesture
  AppLatLng? _lastTapPosition;
  bool _pendingMapTap = false;

  final Map<String, PointAnnotation> _markers = {};
  final Map<String, AppMarker> _markerData = {};
  final Map<String, String> _annotationToMarkerId = {};

  final Map<String, PolylineAnnotation> _routes = {};
  final Map<String, String> _annotationToRouteId = {};

  AppLatLng _lastCenter = const AppLatLng(latitude: 0, longitude: 0);
  double _lastZoom = 12.0;

  @override
  Future<void> flyTo(
    AppLatLng target, {
    double? zoom,
    Duration? duration,
  }) async {
    _lastCenter = target;
    if (zoom != null) {
      _lastZoom = zoom;
    }
    await _mapboxMap.flyTo(
      CameraOptions(
        center: _toPoint(target),
        zoom: zoom ?? _lastZoom,
      ),
      MapAnimationOptions(duration: duration?.inMilliseconds),
    );
  }

  @override
  Future<void> fitBounds(
    AppLatLngBounds bounds, {
    EdgeInsets? padding,
  }) async {
    final edgeInsets = padding ?? EdgeInsets.zero;
    final camera = await _mapboxMap.cameraForCoordinateBounds(
      CoordinateBounds(
        southwest: _toPoint(bounds.southwest),
        northeast: _toPoint(bounds.northeast),
        infiniteBounds: false,
      ),
      MbxEdgeInsets(
        top: edgeInsets.top,
        left: edgeInsets.left,
        bottom: edgeInsets.bottom,
        right: edgeInsets.right,
      ),
      null,
      null,
      null,
      null,
    );
    _lastCenter = AppLatLng(
      latitude: camera.center?.coordinates.lat.toDouble() ?? _lastCenter.latitude,
      longitude:
          camera.center?.coordinates.lng.toDouble() ?? _lastCenter.longitude,
    );
    if (camera.zoom != null) {
      _lastZoom = camera.zoom!;
    }
    await _mapboxMap.flyTo(camera, null);
  }

  @override
  Future<AppLatLng> getCenter() async {
    final state = await _mapboxMap.getCameraState();
    final coordinates = state.center.coordinates;
    _lastCenter = AppLatLng(
      latitude: coordinates.lat.toDouble(),
      longitude: coordinates.lng.toDouble(),
    );
    _lastZoom = state.zoom;
    return _lastCenter;
  }

  @override
  Future<double> getZoom() async {
    final state = await _mapboxMap.getCameraState();
    _lastZoom = state.zoom;
    return _lastZoom;
  }

  @override
  Future<void> addMarker(AppMarker marker) async {
    final manager = await _ensurePointManager();
    final isCity = marker.markerType == 'city';
    final iconSize = isCity ? 1.25 : 1.0;
    final annotation = await manager.create(
      PointAnnotationOptions(
        geometry: _toPoint(marker.position),
        iconImage: marker.iconAsset ?? 'marker-15',
        iconSize: iconSize,
        textField: marker.label ?? marker.title,
        textOffset: [0, 1.5],
        textSize: 12,
        iconColor: marker.color?.value,
        isDraggable: marker.draggable,
      ),
    );
    _markers[marker.id] = annotation;
    _markerData[marker.id] = marker;
    _annotationToMarkerId[annotation.id] = marker.id;
  }

  @override
  Future<void> removeMarker(String id) async {
    final manager = _pointManager;
    final annotation = _markers.remove(id);
    _markerData.remove(id);
    if (annotation != null) {
      _annotationToMarkerId.remove(annotation.id);
      if (manager != null) {
        await manager.delete(annotation);
      }
    }
  }

  @override
  Future<void> updateMarker(AppMarker marker) async {
    if (_markers.containsKey(marker.id)) {
      await removeMarker(marker.id);
    }
    await addMarker(marker);
  }

  @override
  Future<void> clearMarkers() async {
    final manager = _pointManager;
    _markers.clear();
    _markerData.clear();
    _annotationToMarkerId.clear();
    if (manager != null) {
      await manager.deleteAll();
    }
  }

  @override
  Future<void> addRoute(AppRoute route) async {
    final manager = await _ensureLineManager();
    final annotation = await manager.create(
      PolylineAnnotationOptions(
        geometry: _toLineString(route.coordinates),
        lineColor: (route.color ?? const Color(0xFF1F6F78)).value,
        lineWidth: route.width,
        lineOpacity: route.color?.opacity ?? 1.0,
      ),
    );
    _routes[route.id] = annotation;
    _annotationToRouteId[annotation.id] = route.id;
  }

  @override
  Future<void> removeRoute(String id) async {
    final manager = _lineManager;
    final annotation = _routes.remove(id);
    if (annotation != null) {
      _annotationToRouteId.remove(annotation.id);
      if (manager != null) {
        await manager.delete(annotation);
      }
    }
  }

  @override
  Future<void> updateRoute(AppRoute route) async {
    if (_routes.containsKey(route.id)) {
      await removeRoute(route.id);
    }
    await addRoute(route);
  }

  @override
  Future<void> clearRoutes() async {
    final manager = _lineManager;
    _routes.clear();
    _annotationToRouteId.clear();
    if (manager != null) {
      await manager.deleteAll();
    }
  }

  @override
  Future<void> showUserLocation(bool show) async {
    await _mapboxMap.location.updateSettings(
      LocationComponentSettings(enabled: show),
    );
  }

  @override
  Future<AppLatLng?> getUserLocation() async => null;

  @override
  void enableRotation(bool enable) {
    _mapboxMap.gestures
        .updateSettings(GesturesSettings(rotateEnabled: enable));
  }

  @override
  void enableTilt(bool enable) {
    _mapboxMap.gestures
        .updateSettings(GesturesSettings(pitchEnabled: enable));
  }

  @override
  void enableZoom(bool enable) {
    _mapboxMap.gestures
        .updateSettings(GesturesSettings(pinchToZoomEnabled: enable));
  }

  @override
  void enableScroll(bool enable) {
    _mapboxMap.gestures
        .updateSettings(GesturesSettings(scrollEnabled: enable));
  }

  @override
  void showCompass(bool show) {
    _mapboxMap.compass
        .updateSettings(CompassSettings(enabled: show));
  }

  @override
  void dispose() {
    _pointTapCancelable?.cancel();
    _lineTapCancelable?.cancel();
    _pointDragCancelable?.cancel();
    _pointTapCancelable = null;
    _lineTapCancelable = null;
    _pointDragCancelable = null;
    _markers.clear();
    _routes.clear();
    _markerData.clear();
    _annotationToMarkerId.clear();
    _annotationToRouteId.clear();
  }

  void handleMapTap(MapContentGestureContext context) {
    final coordinates = context.point.coordinates;
    final pos = AppLatLng(
      latitude: coordinates.lat.toDouble(),
      longitude: coordinates.lng.toDouble(),
    );
    _lastTapPosition = pos;
    _pendingMapTap = true;
    Future.microtask(() {
      if (_pendingMapTap) {
        _pendingMapTap = false;
        onMapTap?.call(pos);
      }
    });
  }

  Future<PointAnnotationManager> _ensurePointManager() async {
    if (_pointManager != null) {
      return _pointManager!;
    }
    final manager = await _mapboxMap.annotations.createPointAnnotationManager();
    _pointTapCancelable ??= manager.tapEvents(onTap: _handlePointTap);
    _pointDragCancelable ??= manager.dragEvents(onEnd: _handlePointDragEnd);
    _pointManager = manager;
    return manager;
  }

  Future<PolylineAnnotationManager> _ensureLineManager() async {
    if (_lineManager != null) {
      return _lineManager!;
    }
    final manager =
        await _mapboxMap.annotations.createPolylineAnnotationManager();
    _lineTapCancelable ??= manager.tapEvents(onTap: _handleLineTap);
    _lineManager = manager;
    return manager;
  }

  void _handlePointTap(PointAnnotation annotation) {
    final markerId = _annotationToMarkerId[annotation.id];
    if (markerId == null) {
      return;
    }
    _markerData[markerId]?.onTap?.call();
  }

  void _handleLineTap(PolylineAnnotation annotation) {
    // Cancel the generic map tap — line tap wins for the same gesture
    _pendingMapTap = false;

    final routeId = _annotationToRouteId[annotation.id];
    if (routeId == null) {
      return;
    }
    // Synthetic connector lines are not user-tappable
    if (routeId.startsWith('_conn_')) {
      return;
    }
    final pos = _lastTapPosition;
    if (pos != null && onRouteLineTap != null) {
      onRouteLineTap!.call(routeId, pos);
    } else {
      onRouteTap?.call(routeId);
    }
  }

  void _handlePointDragEnd(PointAnnotation annotation) {
    final markerId = _annotationToMarkerId[annotation.id];
    if (markerId == null) return;
    final coords = annotation.geometry.coordinates;
    final newPos = AppLatLng(
      latitude: coords.lat.toDouble(),
      longitude: coords.lng.toDouble(),
    );
    _markerData[markerId]?.onDragEnd?.call(newPos);
    // Update cached position so subsequent reads are accurate
    final existing = _markerData[markerId];
    if (existing != null) {
      _markerData[markerId] = existing.copyWith(position: newPos);
    }
  }

  static Point _toPoint(AppLatLng point) {
    return Point(
      coordinates: Position(point.longitude, point.latitude),
    );
  }

  static LineString _toLineString(List<AppLatLng> points) {
    return LineString(
      coordinates: points
          .map((p) => Position(p.longitude, p.latitude))
          .toList(),
    );
  }
}
