import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/location/location_provider.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';

part 'place_search_provider.freezed.dart';
part 'place_search_provider.g.dart';

@riverpod
class PlaceSearchController extends _$PlaceSearchController {
  Timer? _debounce;

  @override
  Future<PlaceSearchState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    return const PlaceSearchState();
  }

  void search(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        state = AsyncData(state.valueOrNull?.copyWith(query: '') ??
            const PlaceSearchState());
        return;
      }

      state = const AsyncLoading();
      try {
        final repository = ref.read(placeRepositoryProvider);
        final position =
            await ref.read(locationServiceProvider).getCurrentPosition();
        final latitude = position?.latitude ?? 0.0;
        final longitude = position?.longitude ?? 0.0;

        final results = await repository.searchPlaces(
          query: trimmed,
          latitude: latitude,
          longitude: longitude,
        );

        state = AsyncData(PlaceSearchState(
          query: trimmed,
          results: results,
        ));
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }
}

@freezed
class PlaceSearchState with _$PlaceSearchState {
  const factory PlaceSearchState({
    @Default('') String query,
    @Default([]) List<PlaceSearchResult> results,
  }) = _PlaceSearchState;
}
