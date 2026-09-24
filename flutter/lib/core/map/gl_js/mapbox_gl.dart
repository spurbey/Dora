/// Minimal Mapbox GL JS bindings for the web map.
///
/// Only ever loaded on Flutter Web (`kIsWeb` branches). Importing this file
/// on mobile compiles fine (pure `dart:js_interop`) but calling anything
/// throws because `window.mapboxgl` only exists where `web/index.html`
/// includes the Mapbox GL JS script.
library;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Top-level `mapboxgl` namespace object.
@JS('mapboxgl')
external GlNamespace get mapboxgl;

extension type GlNamespace._(JSObject _) implements JSObject {
  external set accessToken(String token);
  external String get version;
}

/// `new mapboxgl.Map({...})`.
@JS('mapboxgl.Map')
extension type GlMap._(JSObject _) implements JSObject {
  external GlMap(JSObject options);

  external void on(String type, JSFunction listener);
  external void off(String type, JSFunction listener);
  external void remove();

  external void flyTo(JSObject options);
  external void fitBounds(JSAny bounds, JSObject options);
  external JSAny getCenter();
  external JSAny getZoom();

  external void addControl(JSAny control, [String? position]);
  external void removeControl(JSAny control);

  external JSAny getSource(String id);
  external JSAny getLayer(String id);
  external void addSource(String id, JSObject source);
  external void addLayer(JSObject layer);
  external void removeLayer(String id);
  external void removeSource(String id);

  external JSAny get scrollZoom;
  external JSAny get boxZoom;
  external JSAny get dragRotate;
  external JSAny get dragPan;
  external JSAny get touchZoomRotate;
  external JSAny get touchPitch;
}

/// `new mapboxgl.Marker(element?, options?)`.
@JS('mapboxgl.Marker')
extension type GlMarker._(JSObject _) implements JSObject {
  external GlMarker([JSAny? element, JSObject? options]);
  external GlMarker setLngLat(JSAny lngLat);
  external GlMarker addTo(GlMap map);
  external void remove();
  external void setDraggable(bool draggable);
  external JSAny getElement();
}

/// `new mapboxgl.NavigationControl(options?)`.
@JS('mapboxgl.NavigationControl')
extension type GlNavigationControl._(JSObject _) implements JSObject {
  external GlNavigationControl([JSObject? options]);
}

/// `new mapboxgl.ScaleControl(options?)`.
@JS('mapboxgl.ScaleControl')
extension type GlScaleControl._(JSObject _) implements JSObject {
  external GlScaleControl([JSObject? options]);
}

/// `new mapboxgl.GeolocateControl(options?)`.
@JS('mapboxgl.GeolocateControl')
extension type GlGeolocateControl._(JSObject _) implements JSObject {
  external GlGeolocateControl([JSObject? options]);
}

/// Read `[lng, lat]` from a GL JS `LngLat`-like object.
({double lng, double lat}) readLngLat(JSAny value) {
  final map = (value.dartify() as Map).cast<String, Object?>();
  return (
    lng: (map['lng'] as num).toDouble(),
    lat: (map['lat'] as num).toDouble(),
  );
}

/// The `<div>` backing a platform-view map instance.
web.HTMLDivElement createMapContainer(String viewId) {
  final div = web.document.createElement('div') as web.HTMLDivElement;
  div.id = 'dora-map-$viewId';
  div.style.width = '100%';
  div.style.height = '100%';
  div.style.position = 'absolute';
  div.style.top = '0';
  div.style.left = '0';
  return div;
}
