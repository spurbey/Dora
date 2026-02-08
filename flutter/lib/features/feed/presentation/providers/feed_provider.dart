import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/feed/data/feed_api.dart';
import 'package:dora/features/feed/data/feed_repository.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';
import 'package:dora/features/feed/domain/feed_state.dart';

part 'feed_provider.g.dart';

@riverpod
class FeedController extends _$FeedController {
  static const _pageSize = 10;

  @override
  Future<FeedState> build() async {
    final repository = ref.watch(feedRepositoryProvider);
    final trips = await repository.getPublicTrips(page: 1, limit: _pageSize);

    return FeedState(
      trips: trips,
      currentPage: 1,
      hasMore: trips.length >= _pageSize,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(feedRepositoryProvider);
      final nextPage = currentState.currentPage + 1;

      final moreTrips = await repository.getPublicTrips(
        page: nextPage,
        limit: _pageSize,
        filter: currentState.filter,
      );

      state = AsyncData(FeedState(
        trips: [...currentState.trips, ...moreTrips],
        currentPage: nextPage,
        hasMore: moreTrips.length >= _pageSize,
        isLoadingMore: false,
        filter: currentState.filter,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(feedRepositoryProvider);
      final trips = await repository.getPublicTrips(
        page: 1,
        limit: _pageSize,
        forceRefresh: true,
      );

      state = AsyncData(FeedState(
        trips: trips,
        currentPage: 1,
        hasMore: trips.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> applyFilter(TripFilter filter) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(feedRepositoryProvider);
      final trips = await repository.getPublicTrips(
        page: 1,
        limit: _pageSize,
        filter: filter,
      );

      state = AsyncData(FeedState(
        trips: trips,
        currentPage: 1,
        hasMore: trips.length >= _pageSize,
        filter: filter,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

@riverpod
FeedRepository feedRepository(FeedRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(feedApiProvider);
  return FeedRepository(db, api);
}

@riverpod
FeedApi feedApi(FeedApiRef ref) {
  final tripsApi = ref.watch(tripsApiProvider);
  final placesApi = ref.watch(placesApiProvider);
  final routesApi = ref.watch(routesApiProvider);
  final searchApi = ref.watch(searchApiProvider);
  final authService = ref.watch(authServiceProvider);

  return FeedApi(
    tripsApi: tripsApi,
    placesApi: placesApi,
    routesApi: routesApi,
    searchApi: searchApi,
    authService: authService,
  );
}
