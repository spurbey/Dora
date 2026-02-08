import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/profile/presentation/providers/profile_provider.dart';
import 'package:dora/features/trips/data/mock_trips_api.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora/features/trips/data/trips_api.dart';
import 'package:dora/features/trips/data/trips_repository.dart';
import 'package:dora/features/trips/domain/trips_state.dart';

part 'trips_provider.g.dart';

@riverpod
TripsApi userTripsApi(UserTripsApiRef ref) {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id ?? 'mock-user';
  return MockTripsApi(userId: userId);
}

@riverpod
TripsRepository tripsRepository(TripsRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(userTripsApiProvider);
  return TripsRepository(db, api);
}

@riverpod
class TripsController extends _$TripsController {
  Timer? _debounce;

  @override
  Future<TripsState> build() async {
    ref.onDispose(() => _debounce?.cancel());

    final repository = ref.watch(tripsRepositoryProvider);
    final trips = await repository.getUserTrips();
    ref.invalidate(profileControllerProvider);

    return TripsState(
      allTrips: trips,
      trips: _applyFilters(trips, TripsFilter.all, ''),
    );
  }

  void applyFilter(TripsFilter filter) {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final filtered = _applyFilters(current.allTrips, filter, current.searchQuery);
    state = AsyncData(current.copyWith(
      currentFilter: filter,
      trips: filtered,
    ));
  }

  void toggleViewMode() {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final nextMode = current.viewMode == TripsViewMode.grid
        ? TripsViewMode.list
        : TripsViewMode.grid;

    state = AsyncData(current.copyWith(viewMode: nextMode));
  }

  void setSearchQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final current = state.valueOrNull;
      if (current == null) {
        return;
      }

      final filtered =
          _applyFilters(current.allTrips, current.currentFilter, query);
      state = AsyncData(current.copyWith(
        searchQuery: query,
        trips: filtered,
      ));
    });
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final repository = ref.read(tripsRepositoryProvider);

    try {
      final trips = await repository.getUserTrips(forceRefresh: true);
      final filtered = _applyFilters(
        trips,
        current?.currentFilter ?? TripsFilter.all,
        current?.searchQuery ?? '',
      );
      state = AsyncData(
        (current ?? const TripsState()).copyWith(
          allTrips: trips,
          trips: filtered,
          syncFailed: false,
        ),
      );
      ref.invalidate(profileControllerProvider);
    } catch (e, st) {
      if (current != null) {
        state = AsyncData(current.copyWith(syncFailed: true));
      } else {
        state = AsyncError(e, st);
      }
    }
  }

  Future<bool> deleteTrip(String id) async {
    final current = state.valueOrNull;
    if (current == null) {
      return false;
    }

    final updatedAll = current.allTrips.where((trip) => trip.id != id).toList();
    final updatedTrips = _applyFilters(
      updatedAll,
      current.currentFilter,
      current.searchQuery,
    );

    state = AsyncData(current.copyWith(allTrips: updatedAll, trips: updatedTrips));

    try {
      await ref.read(tripsRepositoryProvider).deleteTrip(id);
      ref.invalidate(profileControllerProvider);
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(syncFailed: true));
      return false;
    }
  }

  Future<bool> duplicateTrip(String id) async {
    final current = state.valueOrNull;
    if (current == null) {
      return false;
    }

    try {
      final duplicated = await ref.read(tripsRepositoryProvider).duplicateTrip(id);
      final updatedAll = [duplicated, ...current.allTrips];
      final updatedTrips = _applyFilters(
        updatedAll,
        current.currentFilter,
        current.searchQuery,
      );
      state = AsyncData(current.copyWith(allTrips: updatedAll, trips: updatedTrips));
      ref.invalidate(profileControllerProvider);
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(syncFailed: true));
      return false;
    }
  }

  Future<bool> updateVisibility(String id, String visibility) async {
    final current = state.valueOrNull;
    if (current == null) {
      return false;
    }

    final optimisticAll = current.allTrips
        .map((trip) => trip.id == id
            ? trip.copyWith(
                visibility: visibility,
                status: visibility == 'public' ? 'shared' : trip.status,
              )
            : trip)
        .toList();

    state = AsyncData(current.copyWith(
      allTrips: optimisticAll,
      trips: _applyFilters(
        optimisticAll,
        current.currentFilter,
        current.searchQuery,
      ),
    ));

    try {
      final updated =
          await ref.read(tripsRepositoryProvider).updateVisibility(id, visibility);
      final refreshedAll = optimisticAll
          .map((trip) => trip.id == id ? updated : trip)
          .toList();
      state = AsyncData(current.copyWith(
        allTrips: refreshedAll,
        trips: _applyFilters(
          refreshedAll,
          current.currentFilter,
          current.searchQuery,
        ),
      ));
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(syncFailed: true));
      return false;
    }
  }

  List<UserTrip> _applyFilters(
    List<UserTrip> trips,
    TripsFilter filter,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    Iterable<UserTrip> filtered = trips;

    switch (filter) {
      case TripsFilter.active:
        filtered = filtered.where((trip) => trip.isActive);
        break;
      case TripsFilter.completed:
        filtered = filtered.where((trip) => trip.isCompleted);
        break;
      case TripsFilter.shared:
        filtered = filtered.where((trip) => trip.isShared);
        break;
      case TripsFilter.all:
        break;
    }

    if (normalizedQuery.isNotEmpty) {
      filtered = filtered.where(
        (trip) => trip.name.toLowerCase().contains(normalizedQuery),
      );
    }

    return filtered.toList();
  }
}
