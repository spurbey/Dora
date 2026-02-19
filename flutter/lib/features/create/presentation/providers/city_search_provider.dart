import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/geocoding/geocoding_provider.dart';
import 'package:dora/core/map/models/app_latlng.dart';

part 'city_search_provider.g.dart';

@riverpod
class CitySearchController extends _$CitySearchController {
  Timer? _debounce;

  @override
  AsyncValue<List<GeocodingResult>> build() {
    ref.onDispose(() => _debounce?.cancel());
    return const AsyncData([]);
  }

  void search(String query, {AppLatLng? proximity}) {
    if (query.trim().length < 2) {
      state = const AsyncData([]);
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      state = const AsyncLoading();
      try {
        final service = ref.read(geocodingServiceProvider);
        final results = await service.searchCities(
          query,
          proximity: proximity,
        );
        state = AsyncData(results);
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const AsyncData([]);
  }
}
