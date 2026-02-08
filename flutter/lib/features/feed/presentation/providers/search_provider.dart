import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dora/core/location/location_provider.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/presentation/providers/feed_provider.dart';

part 'search_provider.freezed.dart';
part 'search_provider.g.dart';

@riverpod
class SearchController extends _$SearchController {
  static const _maxRecentSearches = 10;
  Timer? _debounce;

  @override
  Future<SearchState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final recent = await _loadRecentSearches();
    return SearchState(recentSearches: recent);
  }

  void search(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.trim().isEmpty) {
        if (state.value != null) {
          state = AsyncData(state.value!.copyWith(query: null, places: [], trips: []));
        }
        return;
      }

      state = const AsyncLoading();

      try {
        final repository = ref.read(feedRepositoryProvider);
        final position =
            await ref.read(locationServiceProvider).getCurrentPosition();

        final latitude = position?.latitude ?? 0.0;
        final longitude = position?.longitude ?? 0.0;

        final places = await repository.searchPlaces(
          query: query,
          latitude: latitude,
          longitude: longitude,
        );
        final trips = await repository.searchTrips(query);

        state = AsyncData(SearchState(
          query: query,
          places: places,
          trips: trips,
          recentSearches: state.value?.recentSearches ?? [],
        ));

        await _saveRecentSearch(query);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  Future<void> searchNearby() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(feedRepositoryProvider);
      final position =
          await ref.read(locationServiceProvider).getCurrentPosition();
      if (position == null) {
        throw Exception('Location unavailable');
      }

      final places = await repository.getNearbyPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = AsyncData(SearchState(
        query: 'Nearby',
        places: places,
        recentSearches: state.value?.recentSearches ?? [],
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');

    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(recentSearches: []));
    }
  }

  Future<void> removeRecent(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = await _loadRecentSearches();
    recent.remove(query);
    await prefs.setStringList('recent_searches', recent);

    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(recentSearches: recent));
    }
  }

  Future<List<String>> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_searches') ?? [];
  }

  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = await _loadRecentSearches();

    recent.remove(query);
    recent.insert(0, query);
    if (recent.length > _maxRecentSearches) {
      recent.removeLast();
    }

    await prefs.setStringList('recent_searches', recent);

    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(recentSearches: recent));
    }
  }
}

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    String? query,
    @Default([]) List<PlaceSearchResult> places,
    @Default([]) List<PublicTrip> trips,
    @Default([]) List<String> recentSearches,
  }) = _SearchState;
}
