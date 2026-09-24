/// `AppMapController` backed by Mapbox GL JS. Web-only.
///
/// Covers the phase-1 surface: camera, markers (default / label /
/// thumbnail), routes (solid + dashed + tap), gestures, compass/scale/
/// locate controls. Marker dragging is accepted in the model but not
/// honored yet (markers render non-draggable on web).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/gl_js/mapbox_gl.dart';
import 'package:dora/core/map/models/app_bounds.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

String _cssColor(Color? color, String fallback) {
  final c = color ?? const Color(0xFF1F6F78);
  final r = ((c.toARGB32() >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
  final g = ((c.toARGB32() >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
  final b = (c.toARGB32() & 0xFF).toRadixString(16).padLeft(2, '0');
  return '#$r$g$b';
}

void _setHandlerEnabled(JSAny handler, bool enabled) {
  (handler as JSObject).callMethod((enabled ? 'enable' : 'disable').toJS);
}

class GlJsMapAdapter implements AppMapController {
  GlJsMapAdapter(
    this._map, {
    this.onMapTap,
    this.onRouteTap,
    this.onRouteLineTap,
  });

  final GlMap _map;
  final void Function(AppLatLng position)? onMapTap;
  final void Function(String routeId)? onRouteTap;
  final void Function(String routeId, AppLatLng position)? onRouteLineTap;

  final Map<String, GlMarker> _markers = {};
  final Map<String, String> _routeLayerIds = {};
  bool _disposed = false;

  JSAny? _navControl;
  JSAny? _scaleControl;
  JSAny? _geoControl;
  AppLatLng? _lastFix;

  JSFunction? _clickListener;
  final Map<String, JSFunction> _routeClickListeners = {};

  /// Called once the GL style loads: map is interactive from here.
  void bindDefaultInteractions() {
    _clickListener = ((JSAny e) {
      final cb = onMapTap;
      if (cb == null || _disposed) return;
      try {
        final event = (e.dartify() as Map).cast<String, Object?>();
        final ll = (event['lngLat'] as Map).cast<String, Object?>();
        cb(AppLatLng(
          latitude: (ll['lat'] as num).toDouble(),
          longitude: (ll['lng'] as num).toDouble(),
        ));
      } catch (_) {
        // Ignore malformed gesture events.
      }
    }).toJS;
    _map.on('click', _clickListener!);
  }

  // ── Camera ──────────────────────────────────────────────────────────

  @override
  Future<void> flyTo(AppLatLng target, {double? zoom, Duration? duration}) async {
    _guard();
    final options = <String, Object?>{
      'center': [target.longitude, target.latitude],
      if (zoom != null) 'zoom': zoom,
      if (duration != null) 'duration': duration.inMilliseconds,
      'essential': true,
    }.jsify() as JSObject;
    _map.flyTo(options);
  }

  @override
  Future<void> fitBounds(AppLatLngBounds bounds, {EdgeInsets? padding}) async {
    _guard();
    final p = padding;
    final options = <String, Object?>{
      'padding': {
        'top': p?.top ?? 48,
        'bottom': p?.bottom ?? 48,
        'left': p?.left ?? 48,
        'right': p?.right ?? 48,
      },
    }.jsify() as JSObject;
    _map.fitBounds(
      [
        [bounds.southwest.longitude, bounds.southwest.latitude],
        [bounds.northeast.longitude, bounds.northeast.latitude],
      ].jsify()!,
      options,
    );
  }

  @override
  Future<AppLatLng> getCenter() async {
    final ll = readLngLat(_map.getCenter());
    return AppLatLng(latitude: ll.lat, longitude: ll.lng);
  }

  @override
  Future<double> getZoom() async {
    return ((_map.getZoom().dartify() as num)).toDouble();
  }

  // ── Markers ─────────────────────────────────────────────────────────

  @override
  Future<void> addMarker(AppMarker marker) async {
    _guard();
    await removeMarker(marker.id);
    final element = _buildMarkerElement(marker);
    final glMarker = GlMarker(
      element,
      {'anchor': marker.label != null ? 'bottom' : 'center'}.jsify()
          as JSObject,
    ).setLngLat(
        [marker.position.longitude, marker.position.latitude].jsify()!);
    if (marker.onTap != null) {
      element.onclick = ((web.MouseEvent _) {
        marker.onTap!.call();
      }).toJS;
    }
    glMarker.addTo(_map);
    _markers[marker.id] = glMarker;
  }

  @override
  Future<void> removeMarker(String id) async {
    _markers.remove(id)?.remove();
  }

  @override
  Future<void> updateMarker(AppMarker marker) async {
    await addMarker(marker);
  }

  @override
  Future<void> clearMarkers() async {
    for (final id in _markers.keys.toList()) {
      await removeMarker(id);
    }
  }

  web.HTMLElement _buildMarkerElement(AppMarker marker) {
    final doc = web.document;
    if (marker.iconPngBytes != null) {
      final img = doc.createElement('img') as web.HTMLImageElement;
      img.src = 'data:image/png;base64,${base64Encode(marker.iconPngBytes!)}';
      img.style.width = '44px';
      img.style.height = '44px';
      img.style.borderRadius = '50%';
      img.style.border = '2px solid white';
      img.style.boxShadow = '0 2px 6px rgba(0,0,0,.35)';
      if (marker.title != null) img.title = marker.title!;
      final wrap = doc.createElement('div') as web.HTMLDivElement;
      wrap.style.cursor = marker.onTap != null ? 'pointer' : 'default';
      wrap.appendChild(img);
      return wrap;
    }
    if (marker.label != null) {
      final pin = doc.createElement('div') as web.HTMLDivElement;
      pin.textContent = marker.label;
      final css = _cssColor(marker.color, '#1F6F78');
      pin.style.cssText =
          'min-width:30px;height:30px;padding:0 6px;border-radius:15px;'
          'background:$css;color:#fff;font:700 14px/30px system-ui;'
          'text-align:center;border:2px solid #fff;'
          'box-shadow:0 2px 6px rgba(0,0,0,.35);cursor:${marker.onTap != null ? 'pointer' : 'default'};';
      if (marker.title != null) pin.title = marker.title!;
      return pin;
    }
    final dot = doc.createElement('div') as web.HTMLDivElement;
    final css = _cssColor(marker.color, '#1F6F78');
    dot.style.cssText =
        'width:18px;height:18px;border-radius:50%;background:$css;'
        'border:3px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,.35);'
        'cursor:${marker.onTap != null ? 'pointer' : 'default'};';
    if (marker.title != null) dot.title = marker.title!;
    return dot;
  }

  // ── Routes ──────────────────────────────────────────────────────────

  String _sourceId(String routeId) => 'dora-route-src-$routeId';
  String _layerId(String routeId) => 'dora-route-$routeId';

  @override
  Future<void> addRoute(AppRoute route) async {
    _guard();
    await removeRoute(route.id);
    if (route.coordinates.length < 2) return;
    final coords = [
      for (final p in route.coordinates) [p.longitude, p.latitude],
    ];
    _map.addSource(
      _sourceId(route.id),
      <String, Object?>{
        'type': 'geojson',
        'data': <String, Object?>{
          'type': 'Feature',
          'geometry': <String, Object?>{'type': 'LineString', 'coordinates': coords},
        },
      }.jsify() as JSObject,
    );
    final paint = <String, Object?>{
      'line-color': _cssColor(route.color, '#1F6F78'),
      'line-width': route.width ?? 4,
      if (route.dashed == true) 'line-dasharray': [2, 2],
    };
    _map.addLayer(
      <String, Object?>{
        'id': _layerId(route.id),
        'type': 'line',
        'source': _sourceId(route.id),
        'layout': {'line-join': 'round', 'line-cap': 'round'},
        'paint': paint,
      }.jsify() as JSObject,
    );
    _routeLayerIds[route.id] = _layerId(route.id);
    if (onRouteTap != null || onRouteLineTap != null) {
      final listener = ((JSAny e) {
        if (_disposed) return;
        try {
          final event = (e.dartify() as Map).cast<String, Object?>();
          final ll = (event['lngLat'] as Map).cast<String, Object?>();
          final pos = AppLatLng(
            latitude: (ll['lat'] as num).toDouble(),
            longitude: (ll['lng'] as num).toDouble(),
          );
          onRouteLineTap?.call(route.id, pos);
          onRouteTap?.call(route.id);
        } catch (_) {
          onRouteTap?.call(route.id);
        }
      }).toJS;
      _routeClickListeners[route.id] = listener;
      (_map as JSObject).callMethod(
        'on'.toJS,
        'click'.toJS,
        _layerId(route.id).toJS,
        listener,
      );
    }
  }

  @override
  Future<void> removeRoute(String id) async {
    final layerId = _routeLayerIds.remove(id);
    if (layerId == null) return;
    final listener = _routeClickListeners.remove(id);
    if (listener != null) {
      try {
        (_map as JSObject).callMethod(
            'off'.toJS, 'click'.toJS, layerId.toJS, listener);
      } catch (_) {}
    }
    try {
      if (((_map.getLayer(layerId).dartify()) != null)) {
        _map.removeLayer(layerId);
      }
    } catch (_) {}
    try {
      if (((_map.getSource(_sourceId(id)).dartify()) != null)) {
        _map.removeSource(_sourceId(id));
      }
    } catch (_) {}
  }

  @override
  Future<void> updateRoute(AppRoute route) async {
    await addRoute(route);
  }

  @override
  Future<void> clearRoutes() async {
    for (final id in _routeLayerIds.keys.toList()) {
      await removeRoute(id);
    }
  }

  // ── User location ───────────────────────────────────────────────────

  @override
  Future<void> showUserLocation(bool show) async {
    if (show && _geoControl == null) {
      final control = GlGeolocateControl(
        <String, Object?>{
          'positionOptions': {'enableHighAccuracy': true},
          'trackUserLocation': true,
          'showUserHeading': true,
        }.jsify() as JSObject?,
      );
      (control as JSObject).callMethod('on'.toJS, 'geolocate'.toJS,
          ((JSAny e) {
        try {
          final event = (e.dartify() as Map).cast<String, Object?>();
          final coords =
              (event['coords'] as Map).cast<String, Object?>();
          _lastFix = AppLatLng(
            latitude: (coords['latitude'] as num).toDouble(),
            longitude: (coords['longitude'] as num).toDouble(),
          );
        } catch (_) {}
      }).toJS);
      _map.addControl(control, 'bottom-right');
      _geoControl = control;
    } else if (!show && _geoControl != null) {
      try {
        _map.removeControl(_geoControl!);
      } catch (_) {}
      _geoControl = null;
    }
  }

  @override
  Future<AppLatLng?> getUserLocation() async => _lastFix;

  // ── Gestures / UI ───────────────────────────────────────────────────

  @override
  void enableRotation(bool enable) {
    _setHandlerEnabled(_map.touchZoomRotate, enable);
    _setHandlerEnabled(_map.dragRotate, enable);
  }

  @override
  void enableTilt(bool enable) {
    try {
      _setHandlerEnabled(_map.touchPitch, enable);
    } catch (_) {}
  }

  @override
  void enableZoom(bool enable) {
    _setHandlerEnabled(_map.scrollZoom, enable);
    _setHandlerEnabled(_map.touchZoomRotate, enable);
    _setHandlerEnabled(_map.boxZoom, enable);
  }

  @override
  void enableScroll(bool enable) {
    _setHandlerEnabled(_map.dragPan, enable);
    _setHandlerEnabled(_map.scrollZoom, enable);
  }

  @override
  void showCompass(bool show) {
    if (show && _navControl == null) {
      final control = GlNavigationControl(
        {'showCompass': true, 'showZoom': false}.jsify() as JSObject?,
      );
      _map.addControl(control, 'top-right');
      _navControl = control;
    } else if (!show && _navControl != null) {
      try {
        _map.removeControl(_navControl!);
      } catch (_) {}
      _navControl = null;
    }
  }

  /// Called by the owning widget for the scale bar (no interface slot).
  void showScaleBar(bool show) {
    if (show && _scaleControl == null) {
      final control = GlScaleControl(
        {'maxWidth': 80, 'unit': 'metric'}.jsify() as JSObject?,
      );
      _map.addControl(control, 'bottom-left');
      _scaleControl = control;
    } else if (!show && _scaleControl != null) {
      try {
        _map.removeControl(_scaleControl!);
      } catch (_) {}
      _scaleControl = null;
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────────

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_clickListener != null) {
      try {
        _map.off('click', _clickListener!);
      } catch (_) {}
    }
    for (final id in _routeLayerIds.keys.toList()) {
      unawaited(removeRoute(id));
    }
    for (final marker in _markers.values) {
      try {
        marker.remove();
      } catch (_) {}
    }
    _markers.clear();
  }

  void _guard() {
    if (_disposed) {
      throw StateError('GlJsMapAdapter used after dispose');
    }
  }
}