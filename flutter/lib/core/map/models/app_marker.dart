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
    Color? color,
    VoidCallback? onTap,
  }) = _AppMarker;
}
