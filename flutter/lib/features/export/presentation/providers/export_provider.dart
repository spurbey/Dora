import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_state.dart';

/// Dependency provider for the export repository.
final exportRepositoryProvider = Provider<ExportRepositoryContract>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final exportsApi = ref.watch(exportsApiProvider);
  final authService = ref.watch(authServiceProvider);
  return ExportRepository(db, exportsApi, authService.getAccessToken);
});

/// Loads local pre-submit guard state for a trip before export submission.
final exportPrecheckProvider =
    FutureProvider.autoDispose.family<ExportPrecheckResult, String>(
  (ref, tripId) async {
    final repository = ref.watch(exportRepositoryProvider);
    return repository.evaluatePreSubmitGuards(tripId);
  },
);

/// Polls a job's status from the backend at back-off intervals:
///   - 2s while processing or cancel_requested
///   - 10s while queued
/// Stops emitting once the job reaches a terminal state.
final exportJobPollingProvider =
    StreamProvider.autoDispose.family<ExportJob, String>(
  (ref, jobId) => _pollJobStatus(ref, jobId),
);

Stream<ExportJob> _pollJobStatus(Ref ref, String jobId) async* {
  final repository = ref.read(exportRepositoryProvider);
  while (true) {
    final job = await repository.getJobStatus(jobId);
    yield job;
    if (_isTerminal(job.status)) break;
    final interval = job.status == ExportJobStatus.queued
        ? const Duration(seconds: 10)
        : const Duration(seconds: 2);
    await Future.delayed(interval);
  }
}

bool _isTerminal(ExportJobStatus status) =>
    status == ExportJobStatus.completed ||
    status == ExportJobStatus.failed ||
    status == ExportJobStatus.canceled ||
    status == ExportJobStatus.blocked;
