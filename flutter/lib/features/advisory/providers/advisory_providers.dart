import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/features/advisory/data/advisory_repository.dart';
import 'package:dora/features/advisory/data/models/advisory_brain_state.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora_api/dora_api.dart';

/// Singleton advisory repository — reuses shared authenticated Dio + AuthService.
final advisoryRepositoryProvider = Provider<AdvisoryRepository>((ref) {
  final api = ref.watch(advisoryApiProvider);
  final authService = ref.watch(authServiceProvider);
  return AdvisoryRepository(api, authService);
});

/// Resolves a local Drift trip ID to the server PostgreSQL UUID.
///
/// The Flutter app is local-first: `widget.tripId` in editor/live screens is
/// a Drift UUID, NOT the backend's trip ID. All advisory API calls need the
/// server ID. This provider calls `ensureRemoteTripId` (which creates the
/// backend trip if it doesn't exist yet) and caches the result.
final serverTripIdProvider =
    FutureProvider.family<String, String>((ref, localTripId) async {
  final tripRepo = ref.watch(tripRepositoryProvider);
  return tripRepo.ensureRemoteTripId(localTripId, allowCreate: true);
});

/// Trip-scoped brain state (resolves server ID automatically).
final advisoryBrainStateProvider =
    FutureProvider.family<AdvisoryBrainState, String>(
        (ref, localTripId) async {
  final serverTripId = await ref.watch(serverTripIdProvider(localTripId).future);
  final repo = ref.watch(advisoryRepositoryProvider);
  return repo.getAdvisoryState(serverTripId);
});

/// Trip-scoped insights inbox (resolves server ID automatically).
final advisoryInsightsProvider =
    FutureProvider.family<AdvisoryInsightListResponse, String>(
        (ref, localTripId) async {
  final serverTripId = await ref.watch(serverTripIdProvider(localTripId).future);
  final repo = ref.watch(advisoryRepositoryProvider);
  return repo.listInsights(serverTripId);
});

/// Trip-scoped jobs list (resolves server ID automatically).
final advisoryJobsProvider =
    FutureProvider.family<AdvisoryJobListResponse, String>(
        (ref, localTripId) async {
  final serverTripId = await ref.watch(serverTripIdProvider(localTripId).future);
  final repo = ref.watch(advisoryRepositoryProvider);
  return repo.listJobs(serverTripId);
});

/// Action notifier — records user feedback and invalidates dependent providers.
///
/// Takes localTripId; resolves server ID internally for API calls and uses
/// localTripId for provider invalidation (since that's the family key).
class AdvisoryActionNotifier extends StateNotifier<AsyncValue<void>> {
  AdvisoryActionNotifier(this._repo, this._ref, this._localTripId)
      : super(const AsyncValue.data(null));

  final AdvisoryRepository _repo;
  final Ref _ref;
  final String _localTripId;

  Future<void> recordAction(
    String advisoryId,
    UserActionType action,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repo.recordAction(advisoryId, action);
      // Invalidate using localTripId (the family key).
      _ref.invalidate(advisoryInsightsProvider(_localTripId));
      _ref.invalidate(advisoryBrainStateProvider(_localTripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final advisoryActionNotifierProvider = StateNotifierProvider.family<
    AdvisoryActionNotifier, AsyncValue<void>, String>((ref, localTripId) {
  final repo = ref.watch(advisoryRepositoryProvider);
  return AdvisoryActionNotifier(repo, ref, localTripId);
});
