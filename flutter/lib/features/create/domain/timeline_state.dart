import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart';

part 'timeline_state.freezed.dart';

@freezed
class TimelineState with _$TimelineState {
  const factory TimelineState({
    @Default([]) List<Place> places,
    @Default([]) List<Route> routes,
    String? selectedItemId,
    String? selectedItemType,
    @Default(false) bool isReordering,
  }) = _TimelineState;
}
