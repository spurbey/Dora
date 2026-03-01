import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_state.dart';

/// User-facing copy for export pre-submit checks, status labels, and errors.
class ExportErrorStrings {
  const ExportErrorStrings._();

  // ─── Pre-submit guard copy ────────────────────────────────────────────────

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

  // ─── Stage label (shown during processing) ────────────────────────────────

  static String stageLabel(ExportJobStage? stage) {
    switch (stage) {
      case ExportJobStage.snapshotting:
        return 'Preparing snapshot...';
      case ExportJobStage.assetFetch:
        return 'Verifying media assets...';
      case ExportJobStage.rendering:
        return 'Rendering video...';
      case ExportJobStage.encoding:
        return 'Encoding...';
      case ExportJobStage.uploading:
        return 'Uploading to storage...';
      case ExportJobStage.finalizing:
        return 'Finalizing...';
      case null:
        return 'Processing...';
    }
  }

  // ─── Blocked error copy (PRD §5 taxonomy) ────────────────────────────────

  static String messageForBlockedCode(String? errorCode) {
    switch (errorCode) {
      case 'asset_all_404':
        return 'All media in this trip is unavailable. Re-upload your photos and try again.';
      case 'trip_deleted':
        return 'This trip no longer exists on the server.';
      case 'auth_revoked':
        return 'Your session has expired. Sign in again to export.';
      case 'quota_exceeded':
        return 'Export quota reached. Please contact support.';
      default:
        return 'Export was blocked due to an unrecoverable error. Please contact support.';
    }
  }
}
