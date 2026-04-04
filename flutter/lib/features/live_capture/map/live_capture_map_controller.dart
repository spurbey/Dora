import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/utils/marker_image_painter.dart';
import 'package:dora/core/theme/animation_tokens.dart';

/// Purpose-built Mapbox controller for the live capture screen.
///
/// Distinct from [MapboxAdapter] (which serves the editor via annotations).
/// This controller:
/// - Manages a single growing route line via [PolylineAnnotationManager].
/// - Manages a single GPS position dot via [PointAnnotationManager].
/// - Coalesces rapid [updateLivePath] calls so only the latest wins.
/// - Follows the user's position with [easeTo] (camera follow mode).
/// - Provides [recenterToPosition] for an explicit [flyTo] recenter.
///
/// Does NOT implement [AppMapController] — wrong interface shape for live GPS.
class LiveCaptureMapController {
  MapboxMap? _map;

  PointAnnotationManager? _pointManager;
  PointAnnotation? _positionAnnotation;
  Uint8List? _positionMarkerImage;

  PolylineAnnotationManager? _lineManager;
  PolylineAnnotation? _routeAnnotation;

  bool _followMode = true;
  AppLatLng? _lastKnownPosition;

  // Coalescing for path updates
  bool _pathUpdateInFlight = false;
  List<AppLatLng>? _pendingPathPoints;

  static const Color _routeColor = Color(0xFF0EA5E9);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> initialize(MapboxMap map) async {
    _map = map;

    // Pre-render the GPS dot image once
    _positionMarkerImage = await MarkerImagePainter.drawLivePositionDot(
      color: _routeColor,
    );

    _pointManager = await map.annotations.createPointAnnotationManager();
    _lineManager = await map.annotations.createPolylineAnnotationManager();
  }

  void dispose() {
    _map = null;
    _pointManager = null;
    _lineManager = null;
    _positionAnnotation = null;
    _routeAnnotation = null;
    _positionMarkerImage = null;
    _pendingPathPoints = null;
    _pathUpdateInFlight = false;
    _lastKnownPosition = null;
  }

  // ── Position marker ────────────────────────────────────────────────────────

  /// Updates the GPS position dot and optionally the marker bearing.
  ///
  /// Uses [easeTo] with [AnimationTokens.markerLerpMs] for smooth movement
  /// when [_followMode] is enabled.
  Future<void> updatePosition(
    AppLatLng position, {
    double? bearingDeg,
  }) async {
    final map = _map;
    final manager = _pointManager;
    if (map == null || manager == null) return;
    _lastKnownPosition = position;

    final geometry = _toPoint(position);

    if (_positionAnnotation == null) {
      final image = _positionMarkerImage;
      _positionAnnotation = await manager.create(
        PointAnnotationOptions(
          geometry: geometry,
          image: image,
          iconAnchor: IconAnchor.CENTER,
          iconSize: 1.0,
          iconRotate: bearingDeg ?? 0,
          symbolSortKey: 1200,
        ),
      );
    } else {
      _positionAnnotation!.geometry = geometry;
      if (bearingDeg != null) {
        _positionAnnotation!.iconRotate = bearingDeg;
      }
      try {
        await manager.update(_positionAnnotation!);
      } catch (_) {
        // Annotation may have been cleared — recreate on next call.
        _positionAnnotation = null;
      }
    }

    if (_followMode) {
      try {
        await map.easeTo(
          CameraOptions(center: geometry),
          MapAnimationOptions(duration: AnimationTokens.markerLerpMs),
        );
      } catch (_) {}
    }
  }

  // ── Route line ─────────────────────────────────────────────────────────────

  /// Updates the live route path.
  ///
  /// Rapid successive calls are coalesced: only the last pending update
  /// is applied after the in-flight update completes.
  Future<void> updateLivePath(List<AppLatLng> points) async {
    final map = _map;
    if (map == null) return;

    if (points.isEmpty) {
      await _clearRoute();
      return;
    }

    if (_pathUpdateInFlight) {
      _pendingPathPoints = List<AppLatLng>.unmodifiable(points);
      return;
    }

    _pathUpdateInFlight = true;
    try {
      await _applyPathUpdate(points);
    } finally {
      _pathUpdateInFlight = false;
      final pending = _pendingPathPoints;
      if (pending != null) {
        _pendingPathPoints = null;
        unawaited(updateLivePath(pending));
      }
    }
  }

  Future<void> _applyPathUpdate(List<AppLatLng> points) async {
    final manager = _lineManager;
    if (manager == null || points.length < 2) return;

    final geometry = LineString(
      coordinates: points
          .map((p) => Position(p.longitude, p.latitude))
          .toList(growable: false),
    );

    if (_routeAnnotation == null) {
      _routeAnnotation = await manager.create(
        PolylineAnnotationOptions(
          geometry: geometry,
          lineColor: _routeColor.toARGB32(),
          lineWidth: 5.0,
          lineOpacity: 1.0,
        ),
      );
    } else {
      _routeAnnotation!.geometry = geometry;
      try {
        await manager.update(_routeAnnotation!);
      } catch (_) {
        _routeAnnotation = null;
      }
    }
  }

  Future<void> _clearRoute() async {
    final annotation = _routeAnnotation;
    final manager = _lineManager;
    if (annotation != null && manager != null) {
      try {
        await manager.delete(annotation);
      } catch (_) {}
    }
    _routeAnnotation = null;
  }

  // ── Camera follow ──────────────────────────────────────────────────────────

  bool get followMode => _followMode;

  void setFollowMode(bool following) {
    _followMode = following;
  }

  /// Flies to the last known GPS position and re-enables camera follow.
  ///
  /// Uses [AnimationTokens.cameraRecenterMs] (420 ms).
  Future<void> recenterToPosition() async {
    final map = _map;
    final position = _lastKnownPosition;
    if (map == null || position == null) return;
    _followMode = true;
    try {
      await map.flyTo(
        CameraOptions(
          center: _toPoint(position),
          zoom: 15,
        ),
        MapAnimationOptions(duration: AnimationTokens.cameraRecenterMs),
      );
    } catch (_) {}
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Point _toPoint(AppLatLng p) =>
      Point(coordinates: Position(p.longitude, p.latitude));
}
