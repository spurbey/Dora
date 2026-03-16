import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

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
  DateTime? _lastTapAt;
  bool _pendingMapTap = false;
  // True while _handleLineTap is waiting for the map tap position to arrive.
  bool _lineTapPending = false;
  int _lineTapSerial = 0;

  final Map<String, PointAnnotation> _markers = {};
  final Map<String, AppMarker> _markerData = {};
  final Map<String, String> _annotationToMarkerId = {};
  final Map<String, Timer> _markerPulseTimers = {};

  final Map<String, PolylineAnnotation> _routes = {};
  final Map<String, String> _annotationToRouteId = {};
  final Map<String, int> _routeAnimationSerial = {};

  final Map<String, Uint8List> _markerImageCache = {};

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
      latitude:
          camera.center?.coordinates.lat.toDouble() ?? _lastCenter.latitude,
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
    _stopMarkerPulse(marker.id);

    final markerType = marker.markerType ?? 'place';
    final baseScale = _markerBaseScale(markerType);
    final shouldDrop = _shouldAnimateMarkerDrop(markerType);
    final shouldPulse = _shouldPulseMarker(markerType);

    final markerImage = await _markerImageFor(marker);
    final hasCustomImage = markerImage.isNotEmpty;
    final annotation = await manager.create(
      PointAnnotationOptions(
        geometry: _toPoint(marker.position),
        image: hasCustomImage ? markerImage : null,
        iconImage: hasCustomImage ? null : 'marker-15',
        iconColor: hasCustomImage ? null : marker.color?.value,
        textField: hasCustomImage ? null : marker.label ?? marker.title,
        textSize: hasCustomImage ? null : 12,
        textOffset: hasCustomImage ? null : const [0.0, 1.5],
        iconAnchor: IconAnchor.BOTTOM,
        iconSize: shouldDrop ? baseScale * 0.88 : baseScale,
        iconOpacity: shouldDrop ? 0.0 : 1.0,
        iconOffset: shouldDrop ? const [0.0, -2.6] : const [0.0, 0.0],
        symbolSortKey: _markerSortKey(markerType),
        isDraggable: marker.draggable,
      ),
    );
    _markers[marker.id] = annotation;
    _markerData[marker.id] = marker;
    _annotationToMarkerId[annotation.id] = marker.id;

    if (shouldDrop) {
      _startMarkerDropAnimation(
        markerId: marker.id,
        baseScale: baseScale,
        pulseAfterDrop: shouldPulse,
      );
    } else if (shouldPulse) {
      _startMarkerPulse(marker.id, baseScale);
    }
  }

  @override
  Future<void> removeMarker(String id) async {
    final manager = _pointManager;
    final annotation = _markers.remove(id);
    _markerData.remove(id);
    _stopMarkerPulse(id);
    if (annotation != null) {
      _annotationToMarkerId.remove(annotation.id);
      if (manager != null) {
        await manager.delete(annotation);
      }
    }
  }

  @override
  Future<void> updateMarker(AppMarker marker) async {
    final manager = await _ensurePointManager();
    final existing = _markers[marker.id];
    if (existing == null) {
      await addMarker(marker);
      return;
    }

    final markerType = marker.markerType ?? 'place';
    final baseScale = _markerBaseScale(markerType);
    final shouldPulse = _shouldPulseMarker(markerType);
    final markerImage = await _markerImageFor(marker);
    final hasCustomImage = markerImage.isNotEmpty;

    existing.geometry = _toPoint(marker.position);
    existing.image = hasCustomImage ? markerImage : null;
    existing.iconImage = hasCustomImage ? null : 'marker-15';
    existing.iconColor = hasCustomImage ? null : marker.color?.value;
    existing.textField = hasCustomImage ? null : marker.label ?? marker.title;
    existing.textSize = hasCustomImage ? null : 12;
    existing.textOffset = hasCustomImage ? null : const [0.0, 1.5];
    existing.iconAnchor = IconAnchor.BOTTOM;
    existing.iconSize = baseScale;
    existing.iconOpacity = 1.0;
    existing.iconOffset = const [0.0, 0.0];
    existing.symbolSortKey = _markerSortKey(markerType);
    existing.isDraggable = marker.draggable;

    await manager.update(existing);
    _markerData[marker.id] = marker;

    if (shouldPulse) {
      _startMarkerPulse(marker.id, baseScale);
    } else {
      _stopMarkerPulse(marker.id);
    }
  }

  @override
  Future<void> clearMarkers() async {
    final manager = _pointManager;
    _markers.clear();
    _markerData.clear();
    _annotationToMarkerId.clear();
    for (final timer in _markerPulseTimers.values) {
      timer.cancel();
    }
    _markerPulseTimers.clear();
    if (manager != null) {
      await manager.deleteAll();
    }
  }

  @override
  Future<void> addRoute(AppRoute route) async {
    final manager = await _ensureLineManager();
    final targetOpacity = route.color?.opacity ?? 1.0;
    final shouldAnimate = _shouldAnimateRouteEntry(route.id);
    final annotation = await manager.create(
      PolylineAnnotationOptions(
        geometry: _toLineString(route.coordinates),
        lineColor: (route.color ?? const Color(0xFF1F6F78)).value,
        lineWidth: route.width,
        lineOpacity: shouldAnimate ? 0.0 : targetOpacity,
      ),
    );
    _routes[route.id] = annotation;
    _annotationToRouteId[annotation.id] = route.id;

    if (shouldAnimate) {
      _startRouteFadeIn(route.id, targetOpacity);
    }
  }

  @override
  Future<void> removeRoute(String id) async {
    final manager = _lineManager;
    final annotation = _routes.remove(id);
    _routeAnimationSerial.remove(id);
    if (annotation != null) {
      _annotationToRouteId.remove(annotation.id);
      if (manager != null) {
        await manager.delete(annotation);
      }
    }
  }

  @override
  Future<void> updateRoute(AppRoute route) async {
    final manager = await _ensureLineManager();
    final existing = _routes[route.id];
    if (existing == null) {
      await addRoute(route);
      return;
    }

    existing.geometry = _toLineString(route.coordinates);
    existing.lineColor = (route.color ?? const Color(0xFF1F6F78)).value;
    existing.lineWidth = route.width;
    existing.lineOpacity = route.color?.opacity ?? 1.0;
    await manager.update(existing);
  }

  @override
  Future<void> clearRoutes() async {
    final manager = _lineManager;
    _routes.clear();
    _annotationToRouteId.clear();
    _routeAnimationSerial.clear();
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
    _mapboxMap.gestures.updateSettings(GesturesSettings(rotateEnabled: enable));
  }

  @override
  void enableTilt(bool enable) {
    _mapboxMap.gestures.updateSettings(GesturesSettings(pitchEnabled: enable));
  }

  @override
  void enableZoom(bool enable) {
    _mapboxMap.gestures
        .updateSettings(GesturesSettings(pinchToZoomEnabled: enable));
  }

  @override
  void enableScroll(bool enable) {
    _mapboxMap.gestures.updateSettings(GesturesSettings(scrollEnabled: enable));
  }

  @override
  void showCompass(bool show) {
    _mapboxMap.compass.updateSettings(CompassSettings(enabled: show));
  }

  @override
  void dispose() {
    _pointTapCancelable?.cancel();
    _lineTapCancelable?.cancel();
    _pointDragCancelable?.cancel();
    _pointTapCancelable = null;
    _lineTapCancelable = null;
    _pointDragCancelable = null;
    for (final timer in _markerPulseTimers.values) {
      timer.cancel();
    }
    _markerPulseTimers.clear();
    _markers.clear();
    _routes.clear();
    _markerData.clear();
    _annotationToMarkerId.clear();
    _annotationToRouteId.clear();
    _routeAnimationSerial.clear();
    _markerImageCache.clear();
    _lastTapPosition = null;
    _lastTapAt = null;
    _pendingMapTap = false;
    _lineTapPending = false;
    _lineTapSerial = 0;
  }

  void handleMapTap(MapContentGestureContext context) {
    final coordinates = context.point.coordinates;
    final pos = AppLatLng(
      latitude: coordinates.lat.toDouble(),
      longitude: coordinates.lng.toDouble(),
    );
    _lastTapPosition = pos;
    _lastTapAt = DateTime.now();
    // If a line tap is already pending, this map tap is from the same gesture.
    // Just record the position (for the line tap to pick up) and do not emit.
    if (_lineTapPending) {
      return;
    }
    _pendingMapTap = true;
    Future.microtask(() {
      if (_pendingMapTap) {
        _pendingMapTap = false;
        onMapTap?.call(pos);
        // Plain map taps should not leave stale tap coordinates behind.
        _lastTapPosition = null;
        _lastTapAt = null;
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
    // Cancel any already-queued map tap microtask; line tap wins.
    _pendingMapTap = false;

    final routeId = _annotationToRouteId[annotation.id];
    if (routeId == null) {
      return;
    }
    // Synthetic connector lines are not user-tappable.
    if (routeId.startsWith('_conn_')) {
      return;
    }

    // Annotation tap can fire before map onTapListener. Retry briefly so
    // slower map-tap callbacks can still provide the tap position.
    _lineTapPending = true;
    final serial = ++_lineTapSerial;
    _resolveDeferredLineTap(routeId, serial, 0);
  }

  void _resolveDeferredLineTap(String routeId, int serial, int attempt) {
    Future.delayed(const Duration(milliseconds: 60), () {
      if (serial != _lineTapSerial) {
        return;
      }

      final tappedRecently = _lastTapAt != null &&
          DateTime.now().difference(_lastTapAt!) <
              const Duration(milliseconds: 1200);
      final pos = tappedRecently ? _lastTapPosition : null;

      if (pos == null && attempt < 5) {
        _resolveDeferredLineTap(routeId, serial, attempt + 1);
        return;
      }

      _lineTapPending = false;
      _lastTapPosition = null;
      _lastTapAt = null;
      if (pos != null && onRouteLineTap != null) {
        onRouteLineTap!.call(routeId, pos);
      } else {
        onRouteTap?.call(routeId);
      }
    });
  }

  void _handlePointDragEnd(PointAnnotation annotation) {
    final markerId = _annotationToMarkerId[annotation.id];
    if (markerId == null) {
      return;
    }
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

  void _startMarkerDropAnimation({
    required String markerId,
    required double baseScale,
    required bool pulseAfterDrop,
  }) {
    unawaited(Future<void>(() async {
      const frameOpacity = <double>[0.18, 0.4, 0.68, 0.9, 1.0, 1.0];
      const frameOffset = <double>[-2.6, -1.8, -1.1, -0.4, 0.28, 0.0];
      const frameScale = <double>[0.88, 0.93, 0.98, 1.03, 0.98, 1.0];

      for (var i = 0; i < frameOpacity.length; i++) {
        final annotation = _markers[markerId];
        final manager = _pointManager;
        if (annotation == null || manager == null) {
          return;
        }
        annotation.iconOpacity = frameOpacity[i];
        annotation.iconOffset = [0.0, frameOffset[i]];
        annotation.iconSize = baseScale * frameScale[i];
        try {
          await manager.update(annotation);
        } catch (_) {
          return;
        }
        await Future.delayed(const Duration(milliseconds: 48));
      }

      final finalAnnotation = _markers[markerId];
      final finalManager = _pointManager;
      if (finalAnnotation != null && finalManager != null) {
        finalAnnotation.iconOffset = const [0.0, 0.0];
        finalAnnotation.iconOpacity = 1.0;
        finalAnnotation.iconSize = baseScale;
        try {
          await finalManager.update(finalAnnotation);
        } catch (_) {}
      }
      if (pulseAfterDrop) {
        _startMarkerPulse(markerId, baseScale);
      }
    }));
  }

  void _startMarkerPulse(String markerId, double baseScale) {
    _stopMarkerPulse(markerId);
    var phase = 0.0;
    _markerPulseTimers[markerId] =
        Timer.periodic(const Duration(milliseconds: 120), (timer) {
      final annotation = _markers[markerId];
      final manager = _pointManager;
      if (annotation == null || manager == null) {
        timer.cancel();
        _markerPulseTimers.remove(markerId);
        return;
      }
      phase += 0.46;
      final wave = (math.sin(phase) + 1) / 2;
      annotation.iconSize = baseScale * (1.0 + (wave * 0.16));
      unawaited(manager.update(annotation));
    });
  }

  void _stopMarkerPulse(String markerId) {
    final timer = _markerPulseTimers.remove(markerId);
    timer?.cancel();
  }

  void _startRouteFadeIn(String routeId, double targetOpacity) {
    final serial = (_routeAnimationSerial[routeId] ?? 0) + 1;
    _routeAnimationSerial[routeId] = serial;
    unawaited(Future<void>(() async {
      const frames = <double>[0.16, 0.34, 0.52, 0.72, 0.9, 1.0];
      for (final frame in frames) {
        if (_routeAnimationSerial[routeId] != serial) {
          return;
        }
        final route = _routes[routeId];
        final manager = _lineManager;
        if (route == null || manager == null) {
          return;
        }
        route.lineOpacity = frame * targetOpacity;
        try {
          await manager.update(route);
        } catch (_) {
          return;
        }
        await Future.delayed(const Duration(milliseconds: 45));
      }
    }));
  }

  double _markerSortKey(String markerType) {
    if (markerType == 'media_focus') {
      return 1100;
    }
    if (markerType.contains('selected')) {
      return 900;
    }
    if (markerType == 'midpoint') {
      return 800;
    }
    if (markerType == 'waypoint') {
      return 850;
    }
    return 600;
  }

  bool _shouldAnimateMarkerDrop(String markerType) {
    return markerType == 'city' ||
        markerType == 'place' ||
        markerType == 'city_selected' ||
        markerType == 'place_selected' ||
        markerType == 'media_focus';
  }

  bool _shouldPulseMarker(String markerType) {
    return markerType == 'media_focus' ||
        markerType == 'city_selected' ||
        markerType == 'place_selected';
  }

  bool _shouldAnimateRouteEntry(String routeId) {
    return !routeId.startsWith('_conn_');
  }

  double _markerBaseScale(String markerType) {
    switch (markerType) {
      case 'midpoint':
        return 0.72;
      case 'waypoint':
        return 0.8;
      case 'endpoint':
        return 0.84;
      case 'city_selected':
      case 'place_selected':
        return 1.02;
      case 'media_focus':
        return 1.08;
      case 'city':
        return 0.96;
      default:
        return 0.92;
    }
  }

  Future<Uint8List> _markerImageFor(AppMarker marker) async {
    final markerType = marker.markerType ?? 'place';
    final label = _markerGlyph(marker);
    final color = marker.color ?? const Color(0xFF1F6F78);
    final cacheKey = '$markerType|${color.value}|$label';
    final cached = _markerImageCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final isCompact = markerType == 'midpoint';
    final emphasized =
        markerType == 'media_focus' || markerType.contains('selected');
    final bytes = await _drawMarkerImage(
      color: color,
      label: label,
      compact: isCompact,
      emphasized: emphasized,
    );
    _markerImageCache[cacheKey] = bytes;
    return bytes;
  }

  String _markerGlyph(AppMarker marker) {
    final markerType = marker.markerType ?? 'place';
    final raw = (marker.label ?? '').trim();
    if (raw.isNotEmpty) {
      return raw.length <= 3 ? raw : raw.substring(0, 3);
    }
    switch (markerType) {
      case 'city':
      case 'city_selected':
        return 'C';
      case 'midpoint':
        return '+';
      case 'endpoint':
        return 'E';
      case 'media_focus':
        return 'M';
      default:
        return 'P';
    }
  }

  Future<Uint8List> _drawMarkerImage({
    required Color color,
    required String label,
    required bool compact,
    required bool emphasized,
  }) async {
    final width = compact ? 84 : 100;
    final height = compact ? 84 : 124;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = Offset(width / 2, compact ? height / 2 : height * 0.36);
    final outerRadius = compact ? 18.0 : (emphasized ? 24.0 : 22.0);
    final innerRadius = outerRadius * 0.58;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);
    canvas.drawCircle(
      Offset(center.dx, center.dy + (compact ? 1 : 3)),
      outerRadius,
      shadowPaint,
    );

    final bodyPaint = Paint()..color = color;
    if (!compact) {
      final tail = Path()
        ..moveTo(center.dx - outerRadius * 0.56, center.dy + outerRadius * 0.76)
        ..quadraticBezierTo(
          center.dx,
          height - 10,
          center.dx + outerRadius * 0.56,
          center.dy + outerRadius * 0.76,
        )
        ..close();
      canvas.drawPath(tail, bodyPaint);
    }

    canvas.drawCircle(center, outerRadius, bodyPaint);
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, innerRadius, innerPaint);

    final textColor = _darken(color, 0.15);
    final textStyle = TextStyle(
      color: textColor,
      fontSize: emphasized ? 20 : 18,
      fontWeight: FontWeight.w700,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout(maxWidth: innerRadius * 1.7);
    textPainter.paint(
      canvas,
      Offset(
        center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2),
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      return Uint8List(0);
    }
    return bytes.buffer.asUint8List();
  }

  Color _darken(Color color, [double amount = 0.2]) {
    final factor = 1 - amount.clamp(0.0, 1.0);
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).round(),
      (color.green * factor).round(),
      (color.blue * factor).round(),
    );
  }

  static Point _toPoint(AppLatLng point) {
    return Point(
      coordinates: Position(point.longitude, point.latitude),
    );
  }

  static LineString _toLineString(List<AppLatLng> points) {
    return LineString(
      coordinates:
          points.map((p) => Position(p.longitude, p.latitude)).toList(),
    );
  }
}
