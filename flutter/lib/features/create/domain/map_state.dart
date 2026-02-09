import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';

part 'map_state.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState({
    AppMapController? controller,
    @Default([]) List<AppMarker> markers,
    @Default([]) List<AppRoute> routes,
    AppLatLng? center,
    double? zoom,
    @Default(false) bool showUserLocation,
  }) = _MapState;
}
