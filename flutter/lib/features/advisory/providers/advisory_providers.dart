import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/features/advisory/data/advisory_repository.dart';
import 'package:dora/features/advisory/data/models/advisory_brain_state.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora_api/dora_api.dart';

/// Singleton advisory repository — reuses shared authenticated Dio + AuthService.
final advisoryRepositoryProvider = Provider<AdvisoryRepository>((ref) {
  final api = ref.watch(advisoryApiProvider);
  final authService = ref.watch(authServiceProvider);
  return AdvisoryRepository(api, authService);
});

/// Trip-scoped brain state.
final advisoryBrainStateProvider =
    FutureProvider.family<AdvisoryBrainState, String>((ref, tripId) async {
  final repo = ref.watch(advisoryRepositoryProvider);
  return repo.getAdvisoryState(tripId);
});

/// Trip-scoped insights inbox.
final advisoryInsightsProvider =
    FutureProvider.family<AdvisoryInsightListResponse, String>(
        (ref, tripId) async {
  final repo = ref.watch(advisoryRepositoryProvider);
  return repo.listInsights(tripId);
});

/// Trip-scoped jobs list.
final advisoryJobsProvider =
    FutureProvider.family<AdvisoryJobListResponse, String>(
        (ref, tripId) async {
  final repo = ref.watch(advisoryRepositoryProvider);
  return repo.listJobs(tripId);
});

/// Action notifier — records user feedback and invalidates dependent providers.
class AdvisoryActionNotifier extends StateNotifier<AsyncValue<void>> {
  AdvisoryActionNotifier(this._repo, this._ref, this._tripId)
      : super(const AsyncValue.data(null));

  final AdvisoryRepository _repo;
  final Ref _ref;
  final String _tripId;

  Future<void> recordAction(
    String advisoryId,
    UserActionType action,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _repo.recordAction(advisoryId, action);
      // Invalidate insights + brain state so they re-fetch.
      _ref.invalidate(advisoryInsightsProvider(_tripId));
      _ref.invalidate(advisoryBrainStateProvider(_tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final advisoryActionNotifierProvider = StateNotifierProvider.family<
    AdvisoryActionNotifier, AsyncValue<void>, String>((ref, tripId) {
  final repo = ref.watch(advisoryRepositoryProvider);
  return AdvisoryActionNotifier(repo, ref, tripId);
});
