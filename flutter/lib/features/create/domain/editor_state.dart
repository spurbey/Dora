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
    String? selectedItemId,
    String? selectedItemType,
    @Default(EditorMode.view) EditorMode mode,
    @Default(false) bool saving,
    @Default(false) bool bottomPanelExpanded,
    AppMapController? mapController,
  }) = _EditorState;
}
