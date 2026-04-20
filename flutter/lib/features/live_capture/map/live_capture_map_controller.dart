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

  PointAnnotationManager? _advisoryManager;
  final Map<String, PointAnnotation> _advisoryAnnotations = {};
  final Map<String, AdvisoryMapMarker> _advisoryKnown = {};
  // Cache rendered marker images by composite cache key "emoji|tint|accepted"
  final Map<String, Uint8List> _advisoryIconCache = {};
  void Function(String advisoryId)? _onAdvisoryMarkerTap;

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
    _advisoryManager = await map.annotations.createPointAnnotationManager();
    _advisoryManager?.addOnPointAnnotationClickListener(
      _AdvisoryClickListener(this),
    );
  }

  void setOnAdvisoryMarkerTap(void Function(String advisoryId)? handler) {
    _onAdvisoryMarkerTap = handler;
  }

  void dispose() {
    _map = null;
    _pointManager = null;
    _lineManager = null;
    _advisoryManager = null;
    _advisoryAnnotations.clear();
    _advisoryKnown.clear();
    _advisoryIconCache.clear();
    _onAdvisoryMarkerTap = null;
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

  // ── Advisory POI markers ──────────────────────────────────────────────────

  /// Reconciles the advisory markers against the given list.
  ///
  /// Diff-based: creates new, updates changed (style only), removes stale.
  /// Does not rebuild unchanged markers. Safe to call on every advisory
  /// provider update.
  Future<void> setAdvisoryMarkers(List<AdvisoryMapMarker> markers) async {
    final manager = _advisoryManager;
    if (manager == null) return;

    final nextIds = markers.map((m) => m.advisoryId).toSet();

    // Remove stale
    for (final staleId in _advisoryAnnotations.keys
        .where((id) => !nextIds.contains(id))
        .toList()) {
      final ann = _advisoryAnnotations.remove(staleId);
      _advisoryKnown.remove(staleId);
      if (ann != null) {
        try {
          await manager.delete(ann);
        } catch (_) {}
      }
    }

    // Add / update
    for (final m in markers) {
      final existing = _advisoryAnnotations[m.advisoryId];
      final known = _advisoryKnown[m.advisoryId];
      final unchanged = known != null &&
          known.lat == m.lat &&
          known.lng == m.lng &&
          known.categoryEmoji == m.categoryEmoji &&
          known.accepted == m.accepted &&
          known.tint == m.tint;
      if (existing != null && unchanged) continue;

      final image = await _getOrRenderIcon(m);
      final geometry = Point(coordinates: Position(m.lng, m.lat));

      if (existing == null) {
        final created = await manager.create(
          PointAnnotationOptions(
            geometry: geometry,
            image: image,
            iconAnchor: IconAnchor.CENTER,
            iconSize: 0.62,
            symbolSortKey: 900,
            textField: m.advisoryId, // sentinel to identify on click
            textOpacity: 0,
            textSize: 0.01,
          ),
        );
        _advisoryAnnotations[m.advisoryId] = created;
      } else {
        existing.geometry = geometry;
        existing.image = image;
        existing.textField = m.advisoryId;
        try {
          await manager.update(existing);
        } catch (_) {
          _advisoryAnnotations.remove(m.advisoryId);
        }
      }
      _advisoryKnown[m.advisoryId] = m;
    }
  }

  Future<Uint8List> _getOrRenderIcon(AdvisoryMapMarker m) async {
    final key = '${m.categoryEmoji}|${m.tint.toARGB32()}|${m.accepted}';
    final cached = _advisoryIconCache[key];
    if (cached != null) return cached;
    final image = await MarkerImagePainter.drawAdvisoryMarker(
      emoji: m.categoryEmoji,
      tint: m.tint,
      accepted: m.accepted,
    );
    _advisoryIconCache[key] = image;
    return image;
  }

  void _handleAdvisoryClick(PointAnnotation annotation) {
    final id = annotation.textField;
    if (id == null || id.isEmpty) return;
    _onAdvisoryMarkerTap?.call(id);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Point _toPoint(AppLatLng p) =>
      Point(coordinates: Position(p.longitude, p.latitude));
}

/// Data for a single advisory POI marker.
@immutable
class AdvisoryMapMarker {
  const AdvisoryMapMarker({
    required this.advisoryId,
    required this.lat,
    required this.lng,
    required this.categoryEmoji,
    required this.tint,
    required this.accepted,
  });

  final String advisoryId;
  final double lat;
  final double lng;
  final String categoryEmoji;
  final Color tint;
  final bool accepted;
}

class _AdvisoryClickListener extends OnPointAnnotationClickListener {
  _AdvisoryClickListener(this._controller);
  final LiveCaptureMapController _controller;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    _controller._handleAdvisoryClick(annotation);
  }
}
