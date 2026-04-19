import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';

part 'app_marker.freezed.dart';

@freezed
class AppMarker with _$AppMarker {
  const factory AppMarker({
    required String id,
    required AppLatLng position,
    String? title,
    String? snippet,
    String? iconAsset,
    // Optional pre-rendered PNG bytes for custom marker imagery (e.g. Vault
    // thumbnails). When set it's handed straight to Mapbox, bypassing the
    // adapter's default glyph rendering. Caller is responsible for caching.
    Uint8List? iconPngBytes,
    Color? color,
    VoidCallback? onTap,
    String? markerType, // 'city', 'place', 'waypoint', 'endpoint', 'vault_media'
    String? label, // 'C' for cities, '1','2','3' for places
    @Default(false) bool draggable,
    ValueChanged<AppLatLng>? onDragEnd,
  }) = _AppMarker;
}
