import 'package:dora/features/export/domain/export_state.dart';

/// User-facing copy for export pre-submit checks and local validation errors.
class ExportErrorStrings {
  const ExportErrorStrings._();

  static String messageForFailure(ExportPrecheckFailure failure) {
    switch (failure) {
      case ExportPrecheckFailure.tripNotFound:
        return 'Trip not found. Refresh and try again.';
      case ExportPrecheckFailure.tripNotSynced:
        return 'Trip must be synced before exporting.';
      case ExportPrecheckFailure.pendingMedia:
        return 'Finish pending media uploads before exporting.';
      case ExportPrecheckFailure.pendingSync:
        return 'Wait for sync queue to finish before exporting.';
    }
  }

  static List<String> detailsForPrecheck(ExportPrecheckResult result) {
    final details = <String>[];
    if (!result.tripExists) {
      details.add('Trip record is not available locally.');
      return details;
    }

    if (!result.hasServerTripId) {
      details.add('Trip has no backend identity yet (serverTripId missing).');
    }
    if (result.unresolvedMediaCount > 0) {
      details.add(
        '${result.unresolvedMediaCount} media item(s) are pending or failed.',
      );
    }
    if (result.blockingSyncTaskCount > 0) {
      details.add(
        '${result.blockingSyncTaskCount} sync task(s) are still active/blocked.',
      );
    }

    return details;
  }
}
