import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart';
import 'package:dora/features/create/domain/trip.dart';

part 'editor_state.freezed.dart';

@freezed
class EditorState with _$EditorState {
  const factory EditorState({
    required Trip trip,
    @Default([]) List<Place> places,
    @Default([]) List<Route> routes,

    // Selection
    String? selectedItemId,
    String? selectedItemType, // 'place', 'city', 'route'

    // Editor mode
    @Default(EditorMode.view) EditorMode mode,

    // UI state
    @Default(false) bool saving,
    @Default(false) bool bottomPanelExpanded,

    // Map controller reference
    AppMapController? mapController,

    // Route drawing state
    String? routeStartItemId,
    String? routeStartItemType, // 'place' or 'city'
  }) = _EditorState;
}
