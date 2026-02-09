import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';

part 'app_route.freezed.dart';

@freezed
class AppRoute with _$AppRoute {
  const factory AppRoute({
    required String id,
    required List<AppLatLng> coordinates,
    Color? color,
    double? width,
    bool? dashed,
  }) = _AppRoute;
}
