import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_state.dart';

/// Dependency provider for the export repository.
final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return ExportRepository(db, apiClient.dio);
});

/// Loads local pre-submit guard state for a trip before export submission.
final exportPrecheckProvider =
    FutureProvider.autoDispose.family<ExportPrecheckResult, String>(
  (ref, tripId) async {
    final repository = ref.watch(exportRepositoryProvider);
    return repository.evaluatePreSubmitGuards(tripId);
  },
);
