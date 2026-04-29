import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/utils/marker_image_painter.dart';
import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_capture/providers/trip_captured_media_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';

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

  // ── V3 layer state ─────────────────────────────────────────────────────────
  //
  // Lazily initialized when [setupV3Layers] is first called. All V3 layers
  // share these IDs as constants so callers can reference them in
  // queryRenderedFeatures for tap detection.
  bool _v3LayersInstalled = false;
  // Cache the most recent feature lists so re-registration after a style
  // reload can rebuild the source data without the widget needing to push
  // again immediately.
  List<TripCapturedMediaMarker> _v3Memories = const [];
  List<TripEventMapMarker> _v3Events = const [];
  List<AppLatLng> _v3TrailPoints = const [];

  // V3 user pin sprite cache (lazily rendered on first call). Two
  // variants: idle (compass disc only) and moving (compass disc + cone).
  Uint8List? _v3UserPinIdle;
  Uint8List? _v3UserPinMoving;
  // True when the active position annotation currently shows the
  // moving variant — used to decide whether to swap the image.
  bool _v3UserPinIsMoving = false;

  /// Active dimensional mode. Defaults to standard so first-paint of
  /// the live screen is tap-friendly; users opt into cinematic via the
  /// [DimensionalModeToggle] widget.
  MapDimensionalMode _dimensionalMode = MapDimensionalMode.standard;
  MapDimensionalMode get dimensionalMode => _dimensionalMode;

  /// Underlying [MapboxMap] handle for callers that need to project
  /// coordinates → screen pixels (e.g. the V3 callout overlay).
  /// Nullable while the map is initializing.
  MapboxMap? get mapboxMap => _map;

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
    _advisoryManager?.tapEvents(onTap: _handleAdvisoryClick);
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

  /// V3 variant of [updatePosition] — swaps the user-pin sprite to the
  /// Dora compass disc, with an additional direction cone variant when
  /// the user is moving (`speedMps > 1`).
  ///
  /// Distinct from [updatePosition] (which renders the V2 sky-blue dot).
  /// V3 call sites use this instead. Both methods drive the same
  /// [_pointManager] annotation, so only one user pin is ever on the
  /// map at a time — flipping the V3 flag at runtime is safe.
  Future<void> updatePositionV3(
    AppLatLng position, {
    double? bearingDeg,
    double? speedMps,
  }) async {
    final map = _map;
    final manager = _pointManager;
    if (map == null || manager == null) return;
    _lastKnownPosition = position;

    // Lazily render both sprite variants on first call. Cheap (~ms)
    // and only happens once per session.
    _v3UserPinIdle ??= await MarkerImagePainter.drawDoraUserPin();
    final wantMoving = (speedMps ?? 0) > 1.0;
    if (wantMoving) {
      _v3UserPinMoving ??= await MarkerImagePainter.drawDoraUserPinWithCone();
    }
    final image = wantMoving ? _v3UserPinMoving : _v3UserPinIdle;

    final geometry = _toPoint(position);

    if (_positionAnnotation == null) {
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
      _v3UserPinIsMoving = wantMoving;
    } else {
      _positionAnnotation!.geometry = geometry;
      if (bearingDeg != null) {
        _positionAnnotation!.iconRotate = bearingDeg;
      }
      // Only swap the image when the moving/idle state actually flips —
      // image swaps trigger a sprite re-upload across the platform
      // channel which is more expensive than just nudging geometry.
      if (wantMoving != _v3UserPinIsMoving) {
        _positionAnnotation!.image = image;
        _v3UserPinIsMoving = wantMoving;
      }
      try {
        await manager.update(_positionAnnotation!);
      } catch (_) {
        _positionAnnotation = null;
        _v3UserPinIsMoving = false;
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

  // ── V3 GeoJSON layers (Live Screen V3) ─────────────────────────────────────
  //
  // V3 surfaces captured photos and trip events (note / warn / geotag) as
  // map pins backed by GeoJSON sources + Symbol/Circle layers, NOT
  // [PointAnnotationManager]. Annotations are kept for the user-position
  // dot and existing advisory markers (low-volume, interactive).
  //
  // Source/layer IDs are exposed as constants so the widget can pass them
  // to [MapboxMap.queryRenderedFeatures] when handling map taps.

  static const String v3MemoriesSourceId = 'dora_v3_memories';
  static const String v3NotesSourceId = 'dora_v3_notes';
  static const String v3WarnsSourceId = 'dora_v3_warns';
  static const String v3GeotagsSourceId = 'dora_v3_geotags';
  static const String v3TrailSourceId = 'dora_v3_trail';

  static const String v3TrailGlowLayerId = 'dora_v3_trail_glow_layer';
  static const String v3TrailGradientLayerId = 'dora_v3_trail_gradient_layer';
  static const String v3MemoryLayerId = 'dora_v3_memory_layer';
  static const String v3MemoryClusterLayerId = 'dora_v3_memory_cluster_layer';
  static const String v3MemoryClusterCountLayerId =
      'dora_v3_memory_cluster_count_layer';
  static const String v3NoteLayerId = 'dora_v3_note_layer';
  static const String v3WarnPulseLayerId = 'dora_v3_warn_pulse_layer';
  static const String v3WarnLayerId = 'dora_v3_warn_layer';
  static const String v3GeotagLayerId = 'dora_v3_geotag_layer';

  /// V3 cinematic-mode-only source/layer IDs (added/removed when the
  /// dimensional mode toggles).
  static const String _v3TerrainSourceId = 'dora_v3_terrain_dem';
  static const String _v3BuildingsLayerId = 'dora_v3_buildings_layer';

  static const String _v3PolaroidSpriteId = 'dora_v3_polaroid_sprite';
  static const String _v3ClusterStackSpriteId = 'dora_v3_cluster_stack_sprite';
  static const String _v3NoteSpriteId = 'dora_v3_note_sprite';
  static const String _v3WarnSpriteId = 'dora_v3_warn_sprite';
  static const String _v3GeotagSpriteId = 'dora_v3_geotag_sprite';

  /// Returns the V3 tap-target layer IDs in z-order (top to bottom).
  ///
  /// Pass to [MapboxMap.queryRenderedFeatures] so taps hit topmost layers
  /// first. Cluster layer is included so cluster taps can be distinguished
  /// from individual-pin taps.
  static const List<String> v3TapTargetLayers = [
    v3MemoryClusterLayerId,
    v3MemoryLayerId,
    v3WarnLayerId,
    v3NoteLayerId,
    v3GeotagLayerId,
  ];

  /// Installs V3 sources, layers, and sprites. Idempotent — safe to call
  /// from both initial style-load and `onStyleLoadedListener` callbacks
  /// (style reload wipes registered images and custom layers).
  ///
  /// Call this AFTER [initialize] AND AFTER the map's style has loaded.
  /// The widget owns the style-loaded subscription.
  Future<void> setupV3Layers() async {
    final map = _map;
    if (map == null) return;
    final style = map.style;

    // Render sprites once (cheap — they're vector pixel images).
    final polaroid = await MarkerImagePainter.drawPolaroidPin();
    final cluster = await MarkerImagePainter.drawClusterStack();
    final note = await MarkerImagePainter.drawNotePin();
    final warn = await MarkerImagePainter.drawWarnPin();
    final geotag = await MarkerImagePainter.drawGeotagPin();

    await _registerSprite(_v3PolaroidSpriteId, polaroid, 80);
    await _registerSprite(_v3ClusterStackSpriteId, cluster, 80);
    await _registerSprite(_v3NoteSpriteId, note, 48);
    await _registerSprite(_v3WarnSpriteId, warn, 48);
    await _registerSprite(_v3GeotagSpriteId, geotag, 56);

    // Sources
    // Trail source — line-metrics enabled so LineLayer can use line-progress
    // expressions for the gradient fade.
    await _addOrReplaceSource(
      style,
      GeoJsonSource(
        id: v3TrailSourceId,
        data: _emptyFeatureCollection,
        lineMetrics: true,
      ),
    );
    await _addOrReplaceSource(
      style,
      GeoJsonSource(
        id: v3MemoriesSourceId,
        data: _emptyFeatureCollection,
        cluster: true,
        clusterRadius: 50,
        clusterMaxZoom: 17,
        clusterMinPoints: 3,
      ),
    );
    await _addOrReplaceSource(
      style,
      GeoJsonSource(id: v3NotesSourceId, data: _emptyFeatureCollection),
    );
    await _addOrReplaceSource(
      style,
      GeoJsonSource(id: v3WarnsSourceId, data: _emptyFeatureCollection),
    );
    await _addOrReplaceSource(
      style,
      GeoJsonSource(id: v3GeotagsSourceId, data: _emptyFeatureCollection),
    );

    // Layers — z-order: trail glow (bottom) → trail gradient → warn pulse →
    // geotag → note → warn → memory → memory cluster (top). Symbol layers
    // are sort-key-driven within their layer so we don't need explicit
    // symbolSortKey here.
    //
    // Trail glow — wider, low-opacity, blurred underneath the gradient.
    // Gives the trail a soft "lit" presence on the map without being loud.
    await _addOrReplaceLayer(
      style,
      LineLayer(
        id: v3TrailGlowLayerId,
        sourceId: v3TrailSourceId,
        lineColor: DoraColors.brandPrimary.toARGB32(),
        lineOpacity: 0.20,
        lineWidth: 16,
        lineBlur: 4,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      ),
    );
    // Trail gradient — main visible line. line-progress goes 0.0 → 1.0
    // along the line; we interpolate cream → mint → teal so older parts
    // of the trail fade and the leading edge pops in brand color. This
    // requires lineMetrics on the source (set above).
    await _addOrReplaceLayer(
      style,
      LineLayer(
        id: v3TrailGradientLayerId,
        sourceId: v3TrailSourceId,
        lineWidth: 5,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
        lineGradientExpression: const [
          'interpolate',
          ['linear'],
          ['line-progress'],
          0.0,
          // surface.cream
          'rgb(255,244,230)',
          0.5,
          // brand.accent (mint) — softer mid-trail
          'rgb(94,234,212)',
          1.0,
          // brand.primary (teal) — leading edge
          'rgb(14,165,160)',
        ],
      ),
    );
    await _addOrReplaceLayer(
      style,
      CircleLayer(
        id: v3WarnPulseLayerId,
        sourceId: v3WarnsSourceId,
        circleRadius: 18,
        circleColor: DoraColors.warn.toARGB32(),
        circleOpacity: 0.25,
        circleBlur: 0.4,
      ),
    );
    await _addOrReplaceLayer(
      style,
      SymbolLayer(
        id: v3GeotagLayerId,
        sourceId: v3GeotagsSourceId,
        iconImage: _v3GeotagSpriteId,
        iconAllowOverlap: true,
        iconAnchor: IconAnchor.BOTTOM,
        iconSize: 1.0,
      ),
    );
    await _addOrReplaceLayer(
      style,
      SymbolLayer(
        id: v3NoteLayerId,
        sourceId: v3NotesSourceId,
        iconImage: _v3NoteSpriteId,
        iconAllowOverlap: true,
        iconAnchor: IconAnchor.CENTER,
        iconSize: 1.0,
      ),
    );
    await _addOrReplaceLayer(
      style,
      SymbolLayer(
        id: v3WarnLayerId,
        sourceId: v3WarnsSourceId,
        iconImage: _v3WarnSpriteId,
        iconAllowOverlap: true,
        iconAnchor: IconAnchor.CENTER,
        iconSize: 1.0,
      ),
    );
    // Memory layer renders only the unclustered points (filter on cluster
    // property absence). Per-feature rotation drives the polaroid tilt.
    await _addOrReplaceLayer(
      style,
      SymbolLayer(
        id: v3MemoryLayerId,
        sourceId: v3MemoriesSourceId,
        iconImage: _v3PolaroidSpriteId,
        iconAllowOverlap: true,
        iconAnchor: IconAnchor.CENTER,
        iconSize: 0.9,
        iconRotateExpression: const [
          'coalesce',
          ['get', 'rotation'],
          0
        ],
        filter: const ['!', ['has', 'point_count']],
      ),
    );
    // Cluster layer — only when point_count is present.
    await _addOrReplaceLayer(
      style,
      SymbolLayer(
        id: v3MemoryClusterLayerId,
        sourceId: v3MemoriesSourceId,
        iconImage: _v3ClusterStackSpriteId,
        iconAllowOverlap: true,
        iconAnchor: IconAnchor.CENTER,
        iconSize: 0.9,
        filter: const ['has', 'point_count'],
      ),
    );
    // Cluster count text rendered as a separate symbol layer on the same
    // source. text-field reads `point_count_abbreviated` (provided by
    // Mapbox cluster aggregation automatically).
    await _addOrReplaceLayer(
      style,
      SymbolLayer(
        id: v3MemoryClusterCountLayerId,
        sourceId: v3MemoriesSourceId,
        textFieldExpression: const ['get', 'point_count_abbreviated'],
        textSize: 14,
        textColor: DoraColors.inkPrimary.toARGB32(),
        textHaloColor: DoraColors.surfaceWhite.toARGB32(),
        textHaloWidth: 1.5,
        textAllowOverlap: true,
        textIgnorePlacement: true,
        filter: const ['has', 'point_count'],
      ),
    );

    _v3LayersInstalled = true;

    // Re-push the cached marker lists in case the style reloaded after
    // we'd already received some data.
    if (_v3Memories.isNotEmpty) {
      await setMemoryMarkers(_v3Memories);
    }
    if (_v3Events.isNotEmpty) {
      await setEventMarkers(_v3Events);
    }
    if (_v3TrailPoints.isNotEmpty) {
      await setLivePathV3(_v3TrailPoints);
    }
  }

  /// Flies the camera to [lat, lng] at [zoom] over 800 ms with a smooth
  /// ease curve. Used by the V3 timeline row tap → camera follow flow.
  /// Disables follow mode so the user pin doesn't immediately drag the
  /// camera back; tapping the recenter FAB re-enables follow.
  Future<void> flyToV3({
    required double lat,
    required double lng,
    double zoom = 16,
  }) async {
    final map = _map;
    if (map == null) return;
    _followMode = false;
    try {
      await map.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(lng, lat)),
          zoom: zoom,
        ),
        MapAnimationOptions(duration: 800),
      );
    } catch (_) {}
  }

  // ── V3 dimensional mode (standard ↔ cinematic) ─────────────────────────────

  /// Switches between [MapDimensionalMode.standard] (pitch 20°, no
  /// terrain, no 3D buildings) and [MapDimensionalMode.cinematic]
  /// (pitch 50°, terrain on, 3D buildings on).
  ///
  /// Camera transition is animated over 800 ms; layer add/remove happens
  /// in parallel — there's a brief moment where pitch is mid-transition
  /// while terrain renders in, but the pitch animation hides it.
  ///
  /// Idempotent — calling with the current mode is a no-op.
  Future<void> setDimensionalMode(MapDimensionalMode mode) async {
    if (mode == _dimensionalMode) return;
    final map = _map;
    if (map == null) return;

    _dimensionalMode = mode;
    final pitch = mode == MapDimensionalMode.cinematic ? 50.0 : 20.0;

    // Camera animation in parallel with layer install/remove. We don't
    // await this — the easeTo Future completes when the animation ends,
    // but we want layer changes to happen during the tilt, not after.
    unawaited(
      map.easeTo(
        CameraOptions(pitch: pitch),
        MapAnimationOptions(duration: 800),
      ),
    );

    if (mode == MapDimensionalMode.cinematic) {
      await _installCinematicLayers();
    } else {
      await _removeCinematicLayers();
    }
  }

  /// Installs the terrain raster-dem source + 3D buildings extrusion
  /// layer. Idempotent — silent on duplicate-add via [_addOrReplaceSource]
  /// / [_addOrReplaceLayer].
  Future<void> _installCinematicLayers() async {
    final map = _map;
    if (map == null) return;
    final style = map.style;

    // Mapbox terrain DEM tileset.
    await _addOrReplaceSource(
      style,
      RasterDemSource(
        id: _v3TerrainSourceId,
        url: 'mapbox://mapbox.mapbox-terrain-dem-v1',
        tileSize: 514,
      ),
    );

    // Apply terrain to the style. setStyleTerrain expects a JSON string
    // describing the terrain config.
    try {
      await style.setStyleTerrain(
        '{"source":"$_v3TerrainSourceId","exaggeration":1.2}',
      );
    } catch (_) {
      // Style may not support terrain (e.g. some custom styles); fail-soft.
    }

    // 3D buildings — fill-extrusion on the style's `composite` source's
    // `building` layer (standard for outdoor/streets styles).
    await _addOrReplaceLayer(
      style,
      FillExtrusionLayer(
        id: _v3BuildingsLayerId,
        sourceId: 'composite',
        sourceLayer: 'building',
        minZoom: 14,
        filter: const ['==', ['get', 'extrude'], 'true'],
        fillExtrusionColor: DoraColors.brandPrimary.toARGB32(),
        fillExtrusionOpacity: 0.35,
        fillExtrusionHeightExpression: const ['get', 'height'],
        fillExtrusionBaseExpression: const ['get', 'min_height'],
      ),
    );
  }

  /// Removes the cinematic-only source + layer. Style continues to render
  /// as the flat 2D + pin/trail/marker stack.
  Future<void> _removeCinematicLayers() async {
    final map = _map;
    if (map == null) return;
    final style = map.style;
    try {
      await style.setStyleTerrain('{}');
    } catch (_) {}
    try {
      await style.removeStyleLayer(_v3BuildingsLayerId);
    } catch (_) {}
    try {
      await style.removeStyleSource(_v3TerrainSourceId);
    } catch (_) {}
  }

  /// Updates the V3 GPS trail source with [points].
  ///
  /// Distinct from [updateLivePath] (V2 path that uses a
  /// [PolylineAnnotationManager]) — this writes to the V3 GeoJSON source
  /// so the line-gradient + glow + dasharray-on-newest layers light up.
  /// V2 and V3 trails do NOT both render simultaneously; the call site
  /// chooses one based on the V3 feature flag.
  ///
  /// Edge cases:
  ///   - Empty list → empty FeatureCollection (line disappears).
  ///   - Single point → empty FeatureCollection (LineString needs ≥2).
  Future<void> setLivePathV3(List<AppLatLng> points) async {
    _v3TrailPoints = List.unmodifiable(points);
    if (!_v3LayersInstalled) return;
    final source = await _map?.style.getSource(v3TrailSourceId);
    if (source is! GeoJsonSource) return;
    await source.updateGeoJSON(_buildTrailFeatureCollection(points));
  }

  /// Builds a FeatureCollection containing a single LineString feature
  /// for the trail. Returns the empty-features sentinel when there are
  /// fewer than 2 points (Mapbox can't render a 0- or 1-point line).
  static String _buildTrailFeatureCollection(List<AppLatLng> points) {
    if (points.length < 2) return _emptyFeatureCollection;
    final buffer = StringBuffer(
      '{"type":"FeatureCollection","features":[{"type":"Feature",'
      '"properties":{},"geometry":{"type":"LineString","coordinates":[',
    );
    for (var i = 0; i < points.length; i++) {
      if (i > 0) buffer.write(',');
      final p = points[i];
      buffer
        ..write('[')
        ..write(p.longitude)
        ..write(',')
        ..write(p.latitude)
        ..write(']');
    }
    buffer.write(']}}]}');
    return buffer.toString();
  }

  /// Replaces the memory-pin source data with [markers].
  ///
  /// Fast path: no annotation diffing — Mapbox handles incremental updates
  /// of GeoJSON sources internally.
  Future<void> setMemoryMarkers(List<TripCapturedMediaMarker> markers) async {
    _v3Memories = List.unmodifiable(markers);
    if (!_v3LayersInstalled) return;
    final source = await _map?.style.getSource(v3MemoriesSourceId);
    if (source is! GeoJsonSource) return;
    await source.updateGeoJSON(_buildMemoryFeatureCollection(markers));
  }

  /// Replaces the event-pin source data with [markers]. Splits into
  /// 3 GeoJSON FeatureCollections (notes / warns / geotags), one per
  /// source so taps hit the correct layer.
  Future<void> setEventMarkers(List<TripEventMapMarker> markers) async {
    _v3Events = List.unmodifiable(markers);
    if (!_v3LayersInstalled) return;
    final notes = <TripEventMapMarker>[];
    final warns = <TripEventMapMarker>[];
    final geotags = <TripEventMapMarker>[];
    for (final m in markers) {
      switch (m.kind) {
        case TripEventMapKind.note:
          notes.add(m);
        case TripEventMapKind.warn:
          warns.add(m);
        case TripEventMapKind.geotag:
          geotags.add(m);
      }
    }
    final style = _map?.style;
    if (style == null) return;
    final notesSource = await style.getSource(v3NotesSourceId);
    final warnsSource = await style.getSource(v3WarnsSourceId);
    final geotagsSource = await style.getSource(v3GeotagsSourceId);
    if (notesSource is GeoJsonSource) {
      await notesSource.updateGeoJSON(_buildEventFeatureCollection(notes));
    }
    if (warnsSource is GeoJsonSource) {
      await warnsSource.updateGeoJSON(_buildEventFeatureCollection(warns));
    }
    if (geotagsSource is GeoJsonSource) {
      await geotagsSource.updateGeoJSON(_buildEventFeatureCollection(geotags));
    }
  }

  // ── V3 tap detection ───────────────────────────────────────────────────────

  /// Identifies which V3 feature was tapped at [screenPoint], if any.
  ///
  /// Runs `queryRenderedFeatures` against the V3 layer set in z-order
  /// (cluster → memory → warn → note → geotag). Returns `null` if no V3
  /// feature was hit (the tap landed on bare map / a V2 advisory marker
  /// / the GPS trail line).
  ///
  /// Caller passes [screenPoint] in logical pixels (typically from a
  /// GestureDetector onTapDown's local position). Returns a typed
  /// [V3MapTap] for the topmost hit feature; the widget then sets
  /// callout state from this.
  Future<V3MapTap?> hitTestV3({
    required ScreenCoordinate screenPoint,
  }) async {
    final map = _map;
    if (map == null || !_v3LayersInstalled) return null;

    final List<QueriedRenderedFeature?> hits;
    try {
      hits = await map.queryRenderedFeatures(
        RenderedQueryGeometry.fromScreenCoordinate(screenPoint),
        RenderedQueryOptions(layerIds: v3TapTargetLayers),
      );
    } catch (_) {
      return null;
    }

    if (hits.isEmpty) return null;

    // queryRenderedFeatures returns features in z-order top-to-bottom.
    for (final hit in hits) {
      if (hit == null) continue;
      final qf = hit.queriedFeature;
      final layers = hit.layers;
      final layerId = layers.isNotEmpty ? layers.first : null;
      final feature = qf.feature;

      if (layerId == v3MemoryClusterLayerId) {
        // Cluster hit — the feature carries `point_count` aggregated
        // by Mapbox. We surface this so the widget can show a "12
        // memories here" callout. Cluster expansion (zoom-in) is the
        // widget's responsibility.
        final geom = _extractCoords(feature);
        if (geom == null) continue;
        final pointCount = _extractInt(feature, 'point_count');
        return V3MapTap(
          kind: V3MapTapKind.memoryCluster,
          id: 'cluster:${_extractInt(feature, 'cluster_id') ?? 0}',
          latitude: geom.$1,
          longitude: geom.$2,
          clusterCount: pointCount,
        );
      }
      if (layerId == v3MemoryLayerId) {
        final geom = _extractCoords(feature);
        if (geom == null) continue;
        final mediaId = _extractString(feature, 'media_id');
        if (mediaId == null) continue;
        return V3MapTap(
          kind: V3MapTapKind.memory,
          id: mediaId,
          latitude: geom.$1,
          longitude: geom.$2,
        );
      }
      if (layerId == v3WarnLayerId ||
          layerId == v3NoteLayerId ||
          layerId == v3GeotagLayerId) {
        final geom = _extractCoords(feature);
        if (geom == null) continue;
        final eventId = _extractString(feature, 'event_id');
        if (eventId == null) continue;
        final tapKind = layerId == v3WarnLayerId
            ? V3MapTapKind.warn
            : layerId == v3NoteLayerId
                ? V3MapTapKind.note
                : V3MapTapKind.geotag;
        return V3MapTap(
          kind: tapKind,
          id: eventId,
          latitude: geom.$1,
          longitude: geom.$2,
        );
      }
    }
    return null;
  }

  /// Extracts (lat, lng) from a GeoJSON Feature properties map.
  /// Returns null if geometry is missing or malformed.
  static (double, double)? _extractCoords(Map<String?, Object?> feature) {
    final geometry = feature['geometry'];
    if (geometry is! Map) return null;
    final coords = geometry['coordinates'];
    if (coords is! List || coords.length < 2) return null;
    final lng = coords[0];
    final lat = coords[1];
    if (lat is! num || lng is! num) return null;
    return (lat.toDouble(), lng.toDouble());
  }

  static String? _extractString(Map<String?, Object?> feature, String key) {
    final props = feature['properties'];
    if (props is! Map) return null;
    final value = props[key];
    if (value is String) return value;
    return null;
  }

  static int? _extractInt(Map<String?, Object?> feature, String key) {
    final props = feature['properties'];
    if (props is! Map) return null;
    final value = props[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  // ── V3 helpers ─────────────────────────────────────────────────────────────

  /// Empty FeatureCollection used as the initial source data so layers
  /// can attach immediately even before any markers have been pushed.
  static const String _emptyFeatureCollection =
      '{"type":"FeatureCollection","features":[]}';

  static String _buildMemoryFeatureCollection(
    List<TripCapturedMediaMarker> markers,
  ) {
    final buffer = StringBuffer('{"type":"FeatureCollection","features":[');
    for (var i = 0; i < markers.length; i++) {
      if (i > 0) buffer.write(',');
      final m = markers[i];
      buffer
        ..write('{"type":"Feature","geometry":')
        ..write('{"type":"Point","coordinates":[')
        ..write(m.longitude)
        ..write(',')
        ..write(m.latitude)
        ..write(']},')
        ..write('"properties":{"media_id":')
        ..write(_jsonString(m.mediaId))
        ..write(',"rotation":')
        ..write(m.rotationDegrees.toStringAsFixed(2))
        ..write('}}');
    }
    buffer.write(']}');
    return buffer.toString();
  }

  static String _buildEventFeatureCollection(
    List<TripEventMapMarker> markers,
  ) {
    final buffer = StringBuffer('{"type":"FeatureCollection","features":[');
    for (var i = 0; i < markers.length; i++) {
      if (i > 0) buffer.write(',');
      final m = markers[i];
      buffer
        ..write('{"type":"Feature","geometry":')
        ..write('{"type":"Point","coordinates":[')
        ..write(m.longitude)
        ..write(',')
        ..write(m.latitude)
        ..write(']},')
        ..write('"properties":{"event_id":')
        ..write(_jsonString(m.eventId))
        ..write(',"kind":"')
        ..write(m.kind.name)
        ..write('"}}');
    }
    buffer.write(']}');
    return buffer.toString();
  }

  /// Minimal JSON string escaping for the FeatureCollection encoder.
  /// Handles the characters that show up in UUIDs and short text previews;
  /// the preview field isn't included in features (only IDs are emitted),
  /// so we don't need a full JSON encoder here.
  static String _jsonString(String raw) {
    final escaped = raw
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"');
    return '"$escaped"';
  }

  Future<void> _registerSprite(
    String spriteId,
    Uint8List bytes,
    int sizePx,
  ) async {
    final style = _map?.style;
    if (style == null) return;
    final image = MbxImage(
      width: sizePx,
      height: sizePx,
      data: bytes,
    );
    try {
      await style.addStyleImage(
        spriteId,
        // pixelRatio
        1.0,
        image,
        // sdf
        false,
        // stretchX / stretchY / content
        const <ImageStretches>[],
        const <ImageStretches>[],
        null,
      );
    } catch (_) {
      // Sprite may already be registered after a hot reload. Mapbox
      // throws on duplicate add — we don't have a removeStyleImage-then-
      // add pattern to use here without a getStyleImage probe. Swallow.
    }
  }

  Future<void> _addOrReplaceSource(StyleManager style, Source source) async {
    try {
      await style.addSource(source);
    } catch (_) {
      // Source already exists (e.g., style hot-reloaded but addSource
      // re-attempted). Mapbox doesn't expose a clean replace; the
      // setMemoryMarkers / setEventMarkers paths will rewrite data
      // anyway via setStyleSourceProperty('data', ...).
    }
  }

  Future<void> _addOrReplaceLayer(StyleManager style, Layer layer) async {
    try {
      await style.addLayer(layer);
    } catch (_) {
      // Layer already exists — same idempotency story as sources.
    }
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

/// V3 map dimensional mode — drives camera pitch + presence of 3D
/// terrain and building extrusion layers.
///
/// **standard** is the default and the tap-friendly option (subtle 20°
/// pitch, no terrain, no buildings). **cinematic** is the wow-factor
/// upgrade for users who opt in via the [DimensionalModeToggle].
enum MapDimensionalMode { standard, cinematic }

/// What kind of V3 feature was hit by a map tap.
enum V3MapTapKind { memory, memoryCluster, note, warn, geotag }

/// Result of [LiveCaptureMapController.hitTestV3] — the topmost V3
/// feature at the tapped point, with enough information for the widget
/// to position a callout AND open the correct detail surface.
@immutable
class V3MapTap {
  const V3MapTap({
    required this.kind,
    required this.id,
    required this.latitude,
    required this.longitude,
    this.clusterCount,
  });

  final V3MapTapKind kind;

  /// Feature identifier — `media_id` for memories, `event_id` for events,
  /// `cluster:<n>` for clusters. Use as the callout's stable key.
  final String id;
  final double latitude;
  final double longitude;

  /// Number of memories aggregated into this cluster. Only set when
  /// [kind] is [V3MapTapKind.memoryCluster].
  final int? clusterCount;
}

