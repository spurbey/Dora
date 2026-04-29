import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/features/live_capture/map/live_capture_map_controller.dart';
import 'package:dora/features/live_capture/providers/trip_captured_media_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';

/// Full-screen Mapbox map widget dedicated to the live capture screen.
///
/// **V2 mode (default):** owns a [LiveCaptureMapController] and feeds
/// it [position], [bearing], [pathPoints], and [advisoryMarkers] —
/// flat top-down view, blue user dot, sky-blue polyline trail.
///
/// **V3 mode:** when [enableV3] is true the widget additionally:
///   - Calls [LiveCaptureMapController.setupV3Layers] after the style
///     loads (idempotent — safe across reloads).
///   - Pushes [memoryMarkers] / [eventMarkers] / [pathPoints] to the
///     V3 GeoJSON sources (memory + 3 event types + trail).
///   - Calls [LiveCaptureMapController.updatePositionV3] instead of the
///     V2 [updatePosition] — Dora compass user pin with optional
///     direction cone when [speedMps] > 1.
///   - Drives [LiveCaptureMapController.setDimensionalMode] from
///     [dimensionalMode] (standard / cinematic).
///   - Captures map taps and runs [hitTestV3] against the V3 layer
///     set, surfacing the topmost hit feature via [onV3MapTap].
///   - Exposes [onCameraChanged] so the host can re-anchor the
///     callout overlay when the user pans / zooms / rotates.
///
/// Both modes coexist on the same controller — only one user pin is
/// ever rendered at a time, so flipping `enableV3` at runtime is safe.
class LiveCaptureMapWidget extends StatefulWidget {
  const LiveCaptureMapWidget({
    super.key,
    required this.initialCenter,
    this.initialZoom = 14.0,
    this.position,
    this.bearing,
    this.speedMps,
    this.pathPoints = const <AppLatLng>[],
    this.advisoryMarkers = const <AdvisoryMapMarker>[],
    this.onAdvisoryMarkerTap,
    // V3 surface
    this.enableV3 = false,
    this.memoryMarkers = const <TripCapturedMediaMarker>[],
    this.eventMarkers = const <TripEventMapMarker>[],
    this.dimensionalMode = MapDimensionalMode.standard,
    this.onV3MapTap,
    this.onCameraChanged,
  });

  final AppLatLng initialCenter;
  final double initialZoom;
  final AppLatLng? position;
  final double? bearing;

  /// User's instantaneous speed in m/s. When V3 is enabled, drives
  /// the user-pin sprite swap (idle vs moving with direction cone).
  final double? speedMps;

  final List<AppLatLng> pathPoints;
  final List<AdvisoryMapMarker> advisoryMarkers;
  final void Function(String advisoryId)? onAdvisoryMarkerTap;

  // ── V3 props ───────────────────────────────────────────────────
  final bool enableV3;
  final List<TripCapturedMediaMarker> memoryMarkers;
  final List<TripEventMapMarker> eventMarkers;
  final MapDimensionalMode dimensionalMode;

  /// Invoked with the topmost V3 feature (memory / event / cluster)
  /// hit by a tap. Null when the tap missed all V3 layers (bare map,
  /// V2 advisory marker, etc.).
  final void Function(V3MapTap?)? onV3MapTap;

  /// Fires once per Mapbox camera-change event (pan / zoom / rotate).
  /// Used by the callout overlay to re-project its anchor pixel.
  final VoidCallback? onCameraChanged;

  @override
  LiveCaptureMapWidgetState createState() => LiveCaptureMapWidgetState();
}

/// Public so the host screen can reach in via [GlobalKey] for the
/// V3 paths that need access to the underlying [MapboxMap] (callout
/// projection) and the imperative camera-fly entry point.
class LiveCaptureMapWidgetState extends State<LiveCaptureMapWidget> {
  LiveCaptureMapController? _controller;

  /// The underlying [MapboxMap] handle, exposed so the host can pass it
  /// into the V3 callout overlay (which needs `pixelForCoordinate`).
  /// Nullable until the map finishes initializing.
  MapboxMap? get mapboxMap => _controller?.mapboxMap;
  bool _showRecenterFab = false;
  bool _styleLoaded = false;

  // Diffing: remember what we last pushed to the controller.
  AppLatLng? _lastPushedPosition;
  double? _lastPushedBearing;
  double? _lastPushedSpeed;
  int? _lastPushedPathSignature;
  int? _lastPushedMarkersSignature;
  int? _lastPushedMemoriesSignature;
  int? _lastPushedEventsSignature;
  MapDimensionalMode _lastPushedMode = MapDimensionalMode.standard;
  bool _lastEnableV3 = false;
  bool _v3LayersInstalled = false;

  @override
  void didUpdateWidget(LiveCaptureMapWidget old) {
    super.didUpdateWidget(old);
    _syncToController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onMapCreated(MapboxMap map) {
    final ctrl = LiveCaptureMapController();
    _controller = ctrl;
    ctrl.initialize(map).then((_) {
      if (!mounted) return;
      setState(() => _styleLoaded = true);
      _maybeInstallV3Layers();
      _syncToController();
    });
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    if (!_styleLoaded) {
      setState(() => _styleLoaded = true);
    }
    // Style reload wipes registered images + custom layers — re-install
    // every time the style finishes loading (idempotent inside the
    // controller).
    _v3LayersInstalled = false;
    _maybeInstallV3Layers();
    _syncToController();
  }

  void _onCameraChanged(CameraChangedEventData _) {
    widget.onCameraChanged?.call();
  }

  Future<void> _maybeInstallV3Layers() async {
    if (!widget.enableV3) return;
    if (!_styleLoaded) return;
    if (_v3LayersInstalled) return;
    final ctrl = _controller;
    if (ctrl == null) return;
    await ctrl.setupV3Layers();
    if (!mounted) return;
    _v3LayersInstalled = true;
    // Once layers are in, push whatever cached data we have.
    _syncToController();
  }

  void _syncToController() {
    final ctrl = _controller;
    if (ctrl == null || !_styleLoaded) return;

    // Detect a V2↔V3 transition; reset diff caches so the new path
    // sees its first call as "fresh."
    if (widget.enableV3 != _lastEnableV3) {
      _lastEnableV3 = widget.enableV3;
      _lastPushedPosition = null;
      _lastPushedBearing = null;
      _lastPushedSpeed = null;
      _lastPushedPathSignature = null;
      _lastPushedMemoriesSignature = null;
      _lastPushedEventsSignature = null;
    }

    final pos = widget.position;
    final bearing = widget.bearing ?? _computeBearing(widget.pathPoints);
    final speed = widget.speedMps;
    final path = widget.pathPoints;

    final posChanged = pos != null && pos != _lastPushedPosition;
    final bearingChanged = bearing != _lastPushedBearing;
    final speedChanged = speed != _lastPushedSpeed;

    if (posChanged || bearingChanged || (widget.enableV3 && speedChanged)) {
      _lastPushedPosition = pos;
      _lastPushedBearing = bearing;
      _lastPushedSpeed = speed;
      if (pos != null) {
        if (widget.enableV3) {
          ctrl.updatePositionV3(
            pos,
            bearingDeg: bearing,
            speedMps: speed,
          );
        } else {
          ctrl.updatePosition(pos, bearingDeg: bearing);
        }
      }
    }

    final pathSignature = _pathSignature(path);
    if (_lastPushedPathSignature != pathSignature) {
      _lastPushedPathSignature = pathSignature;
      if (widget.enableV3) {
        ctrl.setLivePathV3(path);
      } else {
        ctrl.updateLivePath(path);
      }
    }

    // Advisory markers (V2 surface — kept in V3 too, V3 just adds new
    // GeoJSON layers around them).
    ctrl.setOnAdvisoryMarkerTap(widget.onAdvisoryMarkerTap);
    final markersSig = _markersSignature(widget.advisoryMarkers);
    if (_lastPushedMarkersSignature != markersSig) {
      _lastPushedMarkersSignature = markersSig;
      ctrl.setAdvisoryMarkers(widget.advisoryMarkers);
    }

    if (widget.enableV3 && _v3LayersInstalled) {
      // Memory markers
      final memSig = _memoriesSignature(widget.memoryMarkers);
      if (_lastPushedMemoriesSignature != memSig) {
        _lastPushedMemoriesSignature = memSig;
        ctrl.setMemoryMarkers(widget.memoryMarkers);
      }
      // Event markers
      final evSig = _eventsSignature(widget.eventMarkers);
      if (_lastPushedEventsSignature != evSig) {
        _lastPushedEventsSignature = evSig;
        ctrl.setEventMarkers(widget.eventMarkers);
      }
      // Dimensional mode
      if (widget.dimensionalMode != _lastPushedMode) {
        _lastPushedMode = widget.dimensionalMode;
        ctrl.setDimensionalMode(widget.dimensionalMode);
      }
    }
  }

  int _markersSignature(List<AdvisoryMapMarker> markers) {
    int hash = 17;
    for (final m in markers) {
      hash = 31 * hash + m.advisoryId.hashCode;
      hash = 31 * hash + m.accepted.hashCode;
      hash = 31 * hash + m.lat.hashCode;
      hash = 31 * hash + m.lng.hashCode;
      hash = 31 * hash + m.categoryEmoji.hashCode;
    }
    return hash;
  }

  int _memoriesSignature(List<TripCapturedMediaMarker> markers) {
    int hash = 19;
    for (final m in markers) {
      hash = 31 * hash + m.mediaId.hashCode;
      hash = 31 * hash + m.latitude.hashCode;
      hash = 31 * hash + m.longitude.hashCode;
    }
    return hash;
  }

  int _eventsSignature(List<TripEventMapMarker> markers) {
    int hash = 23;
    for (final m in markers) {
      hash = 31 * hash + m.eventId.hashCode;
      hash = 31 * hash + m.kind.hashCode;
      hash = 31 * hash + m.latitude.hashCode;
      hash = 31 * hash + m.longitude.hashCode;
    }
    return hash;
  }

  /// Computes bearing (degrees) from the last two path points, or null.
  double? _computeBearing(List<AppLatLng> points) {
    if (points.length < 2) return null;
    final prev = points[points.length - 2];
    final curr = points[points.length - 1];
    final dLon = (curr.longitude - prev.longitude) * math.pi / 180.0;
    final lat1 = prev.latitude * math.pi / 180.0;
    final lat2 = curr.latitude * math.pi / 180.0;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final bearing = (math.atan2(y, x) * 180.0 / math.pi + 360.0) % 360.0;
    return bearing;
  }

  int _pathSignature(List<AppLatLng> points) {
    var hash = 17;
    for (final point in points) {
      hash = 37 * hash + point.latitude.toStringAsFixed(6).hashCode;
      hash = 37 * hash + point.longitude.toStringAsFixed(6).hashCode;
    }
    return hash;
  }

  void _onUserInteraction() {
    final ctrl = _controller;
    if (ctrl == null) return;
    if (ctrl.followMode) {
      ctrl.setFollowMode(false);
      setState(() => _showRecenterFab = true);
    }
  }

  Future<void> _onRecenter() async {
    await _controller?.recenterToPosition();
    if (mounted) setState(() => _showRecenterFab = false);
  }

  Future<void> _handleMapTap(MapContentGestureContext ctx) async {
    if (!widget.enableV3) return;
    final cb = widget.onV3MapTap;
    if (cb == null) return;
    final ctrl = _controller;
    if (ctrl == null) return;
    final hit = await ctrl.hitTestV3(screenPoint: ctx.touchPosition);
    if (!mounted) return;
    cb(hit);
  }

  /// Fly the camera to (lat, lng) at the given zoom. Used by the
  /// host's onCameraFly callback when a timeline row is tapped.
  Future<void> flyTo(double lat, double lng, {double zoom = 16}) async {
    final ctrl = _controller;
    if (ctrl == null) return;
    await ctrl.flyToV3(lat: lat, lng: lng, zoom: zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map with pointer listener to detect user panning
        Listener(
          onPointerDown: (_) => _onUserInteraction(),
          child: MapWidget(
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
            onCameraChangeListener: _onCameraChanged,
            onTapListener: _handleMapTap,
          ),
        ),

        // Recenter FAB
        AnimatedPositioned(
          duration: AnimationTokens.normal,
          curve: AnimationTokens.standard,
          right: 16,
          bottom: _showRecenterFab ? 120 : -56,
          child: AnimatedOpacity(
            opacity: _showRecenterFab ? 1.0 : 0.0,
            duration: AnimationTokens.fast,
            child: _RecenterFab(onTap: _onRecenter),
          ),
        ),
      ],
    );
  }
}

class _RecenterFab extends StatelessWidget {
  const _RecenterFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const ValueKey('liveCaptureRecenterFab'),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.7),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location,
          size: 20,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
