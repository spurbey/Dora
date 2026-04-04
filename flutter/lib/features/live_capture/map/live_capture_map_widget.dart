import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/live_capture/map/live_capture_map_controller.dart';

/// Full-screen Mapbox map widget dedicated to the live capture screen.
///
/// Owns a [LiveCaptureMapController] and feeds it [position], [bearing],
/// and [pathPoints] whenever they change (diffed — not on every build).
///
/// Exposes a recenter FAB that appears whenever the user has panned away.
/// Tapping the FAB calls [LiveCaptureMapController.recenterToPosition] and
/// hides itself.
class LiveCaptureMapWidget extends StatefulWidget {
  const LiveCaptureMapWidget({
    super.key,
    required this.initialCenter,
    this.initialZoom = 14.0,
    this.position,
    this.bearing,
    this.pathPoints = const <AppLatLng>[],
  });

  final AppLatLng initialCenter;
  final double initialZoom;
  final AppLatLng? position;
  final double? bearing;
  final List<AppLatLng> pathPoints;

  @override
  State<LiveCaptureMapWidget> createState() => _LiveCaptureMapWidgetState();
}

class _LiveCaptureMapWidgetState extends State<LiveCaptureMapWidget> {
  LiveCaptureMapController? _controller;
  bool _showRecenterFab = false;
  bool _styleLoaded = false;

  // Diffing: remember what we last pushed to the controller.
  AppLatLng? _lastPushedPosition;
  double? _lastPushedBearing;
  int _lastPushedPathLength = 0;

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
      _syncToController();
    });
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    if (!_styleLoaded) {
      setState(() => _styleLoaded = true);
      _syncToController();
    }
  }

  void _syncToController() {
    final ctrl = _controller;
    if (ctrl == null || !_styleLoaded) return;

    final pos = widget.position;
    final bearing = widget.bearing ?? _computeBearing(widget.pathPoints);
    final path = widget.pathPoints;

    final posChanged = pos != null && pos != _lastPushedPosition;
    final bearingChanged = bearing != _lastPushedBearing;

    if (posChanged || bearingChanged) {
      _lastPushedPosition = pos;
      _lastPushedBearing = bearing;
      if (pos != null) {
        ctrl.updatePosition(
          pos,
          bearingDeg: bearing,
        );
      }
    }

    if (path.length != _lastPushedPathLength) {
      _lastPushedPathLength = path.length;
      ctrl.updateLivePath(path);
    }
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
    final x =
        math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final bearing = (math.atan2(y, x) * 180.0 / math.pi + 360.0) % 360.0;
    return bearing;
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
