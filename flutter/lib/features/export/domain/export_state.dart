/// Local pre-submit failure reasons for export initiation.
enum ExportPrecheckFailure {
  tripNotFound,
  tripNotSynced,
  pendingMedia,
  pendingSync,
}

/// Snapshot of all local pre-submit checks for an export request.
class ExportPrecheckResult {
  const ExportPrecheckResult({
    required this.tripId,
    required this.tripExists,
    required this.hasServerTripId,
    required this.pendingMediaCount,
    required this.failedMediaCount,
    required this.blockingSyncTaskCount,
  });

  final String tripId;
  final bool tripExists;
  final bool hasServerTripId;
  final int pendingMediaCount;
  final int failedMediaCount;
  final int blockingSyncTaskCount;

  int get unresolvedMediaCount => pendingMediaCount + failedMediaCount;

  List<ExportPrecheckFailure> get failures {
    final values = <ExportPrecheckFailure>[];

    if (!tripExists) {
      values.add(ExportPrecheckFailure.tripNotFound);
      return values;
    }

    if (!hasServerTripId) {
      values.add(ExportPrecheckFailure.tripNotSynced);
    }
    if (unresolvedMediaCount > 0) {
      values.add(ExportPrecheckFailure.pendingMedia);
    }
    if (blockingSyncTaskCount > 0) {
      values.add(ExportPrecheckFailure.pendingSync);
    }

    return values;
  }

  bool get canExport => failures.isEmpty;
}

/// Result returned after an export create call to backend.
class ExportSubmitResult {
  const ExportSubmitResult({
    required this.jobId,
    required this.deduplicated,
  });

  final String jobId;
  final bool deduplicated;
}
