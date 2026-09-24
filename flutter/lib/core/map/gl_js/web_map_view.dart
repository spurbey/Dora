/// Web map widget backed by Mapbox GL JS. Web-only.
///
/// Mirrors [AppMapView]'s public props so callers keep working; on style
/// load it hands a [GlJsMapAdapter] (an `AppMapController`) to `onMapCreated`
/// exactly like the native path does.
///
/// Mechanics: one `HtmlElementView` platform view per widget instance. The
/// registered factory stamps a `<div id="dora-map-<viewId>">`; the widget
/// claims its div after the first frame and hands it to GL JS as the map
/// container.
library;

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'package:dora/core/config/env_config.dart';
import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/gl_js/gl_js_map_adapter.dart';
import 'package:dora/core/map/gl_js/mapbox_gl.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

const String _kGlJsViewType = 'dora-mapbox-gljs';
bool _kGlJsFactoryRegistered = false;

/// View ids already claimed by a live widget instance.
final Set<String> _claimedDivIds = <String>{};

class WebMapView extends StatefulWidget {
  const WebMapView({
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
  State<WebMapView> createState() => _WebMapViewState();
}

class _WebMapViewState extends State<WebMapView> {
  GlMap? _map;
  GlJsMapAdapter? _adapter;
  String? _claimedDivId;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!_kGlJsFactoryRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(
        _kGlJsViewType,
        (int id) => createMapContainer('$id'),
      );
      _kGlJsFactoryRegistered = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _createMap());
  }

  void _createMap() {
    if (!mounted || _map != null) return;
    try {
      const token = Env.mapboxToken;
      if (token.isEmpty) {
        setState(() => _error = 'Mapbox token is missing.');
        return;
      }
      final container = _claimContainer();
      if (container == null) {
        setState(() => _error = 'Map container not ready.');
        return;
      }
      mapboxgl.accessToken = token;
      final map = GlMap(
        <String, Object?>{
          'container': container,
          'style': 'mapbox://styles/mapbox/streets-v12',
          'center': [
            widget.initialCenter.longitude,
            widget.initialCenter.latitude,
          ],
          'zoom': widget.initialZoom,
          'attributionControl': false,
        }.jsify() as JSObject,
      );
      _map = map;
      map.on(
        'load',
        (() {
          if (!mounted) return;
          final adapter = GlJsMapAdapter(
            map,
            onMapTap: widget.onMapTap,
            onRouteTap: widget.onRouteTap,
            onRouteLineTap: widget.onRouteLineTap,
          );
          adapter.bindDefaultInteractions();
          _adapter = adapter;
          setState(() => _ready = true);
          widget.onMapCreated?.call(adapter);
          _applySettings();
          _syncOverlays();
        }).toJS,
      );
      map.on(
        'error',
        ((JSAny e) {
          try {
            debugPrint('WebMapView GL error: ${e.dartify()}');
          } catch (_) {}
        }).toJS,
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Map failed to start: $e');
    }
  }

  /// Claims this instance's platform-view div (the one factory-stamped div
  /// not yet owned by another live map).
  web.HTMLDivElement? _claimContainer() {
    try {
      final divs =
          web.document.querySelectorAll('div[id^="dora-map-"]');
      for (var i = 0; i < divs.length; i++) {
        final node = divs.item(i);
        if (node is! web.HTMLDivElement) continue;
        if (_claimedDivIds.contains(node.id)) continue;
        _claimedDivIds.add(node.id);
        _claimedDivId = node.id;
        return node;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void didUpdateWidget(covariant WebMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ready) return;
    if (oldWidget.markers != widget.markers ||
        oldWidget.routes != widget.routes) {
      _syncOverlays();
    }
    _applySettings();
  }

  Future<void> _syncOverlays() async {
    final adapter = _adapter;
    if (adapter == null || !_ready) return;
    try {
      await adapter.clearMarkers();
      for (final marker in widget.markers ?? const <AppMarker>[]) {
        await adapter.addMarker(marker);
      }
      await adapter.clearRoutes();
      for (final route in widget.routes ?? const <AppRoute>[]) {
        await adapter.addRoute(route);
      }
    } catch (e) {
      debugPrint('WebMapView overlay sync failed: $e');
    }
  }

  void _applySettings() {
    final adapter = _adapter;
    if (adapter == null) return;
    adapter.showUserLocation(widget.showUserLocation);
    adapter.showCompass(widget.showCompass);
    adapter.showScaleBar(widget.showScaleBar);
    adapter.enableZoom(widget.enableZoomGestures);
    adapter.enableRotation(widget.enableRotateGestures);
    adapter.enableTilt(widget.enableTiltGestures);
    adapter.enableScroll(widget.enableScrollGestures);
  }

  @override
  void dispose() {
    if (_claimedDivId != null) {
      _claimedDivIds.remove(_claimedDivId);
      _claimedDivId = null;
    }
    _adapter?.dispose();
    try {
      _map?.remove();
    } catch (_) {}
    _map = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    return const HtmlElementView(viewType: _kGlJsViewType);
  }
}
