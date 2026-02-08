import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/features/feed/data/models/trip_detail_data.dart';
import 'package:dora/features/feed/presentation/providers/feed_provider.dart';

part 'trip_detail_provider.freezed.dart';
part 'trip_detail_provider.g.dart';

@riverpod
class TripDetailController extends _$TripDetailController {
  @override
  Future<TripDetailState> build(String tripId) async {
    final repository = ref.watch(feedRepositoryProvider);
    final data = await repository.getTripDetail(tripId);

    return TripDetailState(
      data: data,
      currentTab: 0,
    );
  }

  void setTab(int index) {
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(currentTab: index));
    }
  }

  Future<void> copyTrip() async {
    if (state.value == null) return;
    final repository = ref.read(feedRepositoryProvider);
    await repository.copyTrip(state.value!.data.trip.id);
  }

  Future<void> savePlace(String placeId, String userTripId) async {
    final repository = ref.read(feedRepositoryProvider);
    await repository.savePlace(placeId, userTripId);
  }

  Future<void> copyRoute(String routeId, String userTripId) async {
    final repository = ref.read(feedRepositoryProvider);
    await repository.copyRoute(routeId, userTripId);
  }
}

@freezed
class TripDetailState with _$TripDetailState {
  const factory TripDetailState({
    required TripDetailData data,
    @Default(0) int currentTab,
  }) = _TripDetailState;
}
