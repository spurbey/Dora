/// Canonical export job status values used by backend and Flutter UI.
enum ExportJobStatus {
  queued,
  processing,
  cancelRequested,
  completed,
  failed,
  blocked,
  canceled,
}

/// Canonical stage values for processing progress in the export pipeline.
enum ExportJobStage {
  snapshotting,
  assetFetch,
  rendering,
  encoding,
  uploading,
  finalizing,
}

/// Export job DTO used by Flutter status/polling flows.
class ExportJob {
  const ExportJob({
    required this.jobId,
    required this.status,
    required this.progress,
    this.stage,
    this.outputUrl,
    this.thumbnailUrl,
    this.errorCode,
    this.errorMessage,
  });

  final String jobId;
  final ExportJobStatus status;
  final double progress;
  final ExportJobStage? stage;
  final String? outputUrl;
  final String? thumbnailUrl;
  final String? errorCode;
  final String? errorMessage;
}
