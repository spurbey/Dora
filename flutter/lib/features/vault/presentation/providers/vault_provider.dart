import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/location/location_permission.dart';
import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/vault/domain/vault_filter.dart';

/// Supabase auth uid of the current user, or `null` if signed out.
final currentUserIdProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});

/// Stream of every non-deleted media row owned by the logged-in user, sorted
/// by `captured_at` DESC. Empty stream when signed out.
final vaultAllMediaProvider =
    StreamProvider.autoDispose<List<MediaItem>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream<List<MediaItem>>.empty();
  }
  final db = ref.watch(appDatabaseProvider);
  return db.mediaDao.watchForOwner(userId);
});

/// Current filter state (time bucket + radius bucket). Autodispose so the
/// state resets when the user leaves the Vault screen.
final vaultFilterProvider =
    NotifierProvider.autoDispose<VaultFilterController, VaultFilter>(
  VaultFilterController.new,
);

class VaultFilterController extends AutoDisposeNotifier<VaultFilter> {
  @override
  VaultFilter build() => const VaultFilter.initial();

  void setTime(VaultTimeBucket time) {
    state = state.copyWith(time: time);
  }

  void setRadius(VaultRadiusBucket radius) {
    state = state.copyWith(radius: radius);
  }
}

/// Tracks whether the Vault is allowed to read the user's current location,
/// plus the most-recent successful position. Separating this from the filter
/// itself keeps the permission UI reactive without triggering a full refilter.
class VaultLocationState {
  const VaultLocationState({
    required this.accessState,
    required this.position,
  });

  const VaultLocationState.initial()
      : accessState = LocationAccessState.denied,
        position = null;

  final LocationAccessState accessState;
  final Position? position;

  bool get hasPosition =>
      accessState == LocationAccessState.granted && position != null;
}

final vaultLocationProvider = AsyncNotifierProvider.autoDispose<
    VaultLocationController, VaultLocationState>(VaultLocationController.new);

class VaultLocationController
    extends AutoDisposeAsyncNotifier<VaultLocationState> {
  @override
  Future<VaultLocationState> build() async {
    // Attempt once on tab open; do NOT request permission automatically —
    // we only ask when the user taps a radius chip or the Grant button.
    final service = ref.read(locationServiceProvider);
    final result = await service.getCurrentPositionResult(
      requestPermission: false,
    );
    return VaultLocationState(
      accessState: result.accessState,
      position: result.position,
    );
  }

  /// Explicitly request permission (e.g. from the "Grant" button).
  Future<void> requestPermission() async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(locationServiceProvider);
      final result = await service.getCurrentPositionResult(
        requestPermission: true,
      );
      state = AsyncValue.data(
        VaultLocationState(
          accessState: result.accessState,
          position: result.position,
        ),
      );
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Refresh the position without re-requesting permission.
  Future<void> refresh() async {
    final service = ref.read(locationServiceProvider);
    final result = await service.getCurrentPositionResult(
      requestPermission: false,
    );
    state = AsyncValue.data(
      VaultLocationState(
        accessState: result.accessState,
        position: result.position,
      ),
    );
  }
}

/// All user media that pass the current [VaultFilter] — applied in Dart, not
/// SQL, because the row count is expected to be small.
final vaultFilteredMediaProvider =
    Provider.autoDispose<List<MediaItem>>((ref) {
  final async = ref.watch(vaultAllMediaProvider);
  final filter = ref.watch(vaultFilterProvider);
  final location = ref.watch(vaultLocationProvider);

  return async.maybeWhen(
    data: (items) => _applyFilter(
      items: items,
      filter: filter,
      currentPosition: location.valueOrNull?.position,
    ),
    orElse: () => const <MediaItem>[],
  );
});

/// Filtered subset that can be placed on a map (has lat/lng).
final vaultGeotaggedMediaProvider =
    Provider.autoDispose<List<MediaItem>>((ref) {
  final filtered = ref.watch(vaultFilteredMediaProvider);
  return filtered
      .where((item) => item.latitude != null && item.longitude != null)
      .toList(growable: false);
});

/// Currently selected media id — shared by the map (tapped marker) and the
/// carousel/grid (swiped page). Null means nothing selected.
final vaultSelectedMediaIdProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});

List<MediaItem> _applyFilter({
  required List<MediaItem> items,
  required VaultFilter filter,
  required Position? currentPosition,
}) {
  final now = DateTime.now().toUtc();
  final radiusMeters = filter.radius.meters;
  final canRadius =
      radiusMeters != null && currentPosition != null && filter.radius.hasRadius;
  final out = <MediaItem>[];
  for (final item in items) {
    if (!filter.time.contains(item.capturedAt, now: now)) continue;
    if (canRadius) {
      if (item.latitude == null || item.longitude == null) {
        // With a radius active, skip non-geotagged media.
        continue;
      }
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        item.latitude!,
        item.longitude!,
      );
      if (distance > radiusMeters) continue;
    }
    out.add(item);
  }
  return out;
}

