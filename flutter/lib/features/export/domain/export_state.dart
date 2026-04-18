/// Local pre-submit failure reasons for export initiation.
enum ExportPrecheckFailure {
  tripNotFound,
  tripNotSynced,
  pendingMedia,
  activeSessionOrPublish,
}

/// Snapshot of all local pre-submit checks for an export request.
class ExportPrecheckResult {
  const ExportPrecheckResult({
    required this.tripId,
    required this.tripExists,
    required this.hasServerTripId,
    required this.pendingMediaCount,
    required this.failedMediaCount,
    required this.blockingV2ConditionCount,
  });

  final String tripId;
  final bool tripExists;
  final bool hasServerTripId;
  final int pendingMediaCount;
  final int failedMediaCount;

  /// Count of blocking V2 conditions: active/paused sessions + in-progress publishes.
  final int blockingV2ConditionCount;

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
    if (blockingV2ConditionCount > 0) {
      values.add(ExportPrecheckFailure.activeSessionOrPublish);
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
