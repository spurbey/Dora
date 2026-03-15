import 'package:dora/features/export/domain/export_job.dart';

class ExportJobSummary {
  const ExportJobSummary({
    required this.jobId,
    required this.tripId,
    required this.tripTitle,
    required this.template,
    required this.status,
    required this.stage,
    required this.progress,
    required this.outputUrl,
    required this.thumbnailUrl,
    required this.errorCode,
    required this.errorMessage,
    required this.createdAt,
    required this.completedAt,
  });

  final String jobId;
  final String tripId;
  final String? tripTitle;
  final String template;
  final ExportJobStatus status;
  final ExportJobStage? stage;
  final double progress;
  final String? outputUrl;
  final String? thumbnailUrl;
  final String? errorCode;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
}

class ExportJobListResult {
  const ExportJobListResult({
    required this.exports,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<ExportJobSummary> exports;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
}
