import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/utils/date_time_utils.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_job_summary.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';

class MyTripsExportScreen extends ConsumerStatefulWidget {
  const MyTripsExportScreen({super.key});

  @override
  ConsumerState<MyTripsExportScreen> createState() =>
      _MyTripsExportScreenState();
}

class _MyTripsExportScreenState extends ConsumerState<MyTripsExportScreen> {
  late Future<ExportJobListResult> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _loadJobs();
  }

  Future<ExportJobListResult> _loadJobs() {
    return ref.read(exportRepositoryProvider).listExportJobs(pageSize: 100);
  }

  void _refresh() {
    setState(() {
      _jobsFuture = _loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<ExportJobListResult>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppSpacing.horizontalMd,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load export history.',
                      style: AppTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      snapshot.error.toString(),
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final jobs = snapshot.data?.exports ?? const <ExportJobSummary>[];

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'In Progress'),
                    Tab(text: 'Completed'),
                    Tab(text: 'Failed/Blocked'),
                    Tab(text: 'Canceled'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSectionList(
                        jobs.where(_isInProgress).toList(),
                      ),
                      _buildSectionList(
                        jobs
                            .where((job) => job.status == ExportJobStatus.completed)
                            .toList(),
                      ),
                      _buildSectionList(
                        jobs.where(_isFailedOrBlocked).toList(),
                      ),
                      _buildSectionList(
                        jobs
                            .where((job) => job.status == ExportJobStatus.canceled)
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionList(List<ExportJobSummary> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          'No exports in this section.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView.separated(
        padding: AppSpacing.allMd,
        itemCount: jobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => _ExportJobCard(
          job: jobs[index],
          onCancel: _handleCancel,
          onDownload: _handleDownload,
          onShare: _handleShare,
          onReExport: (job) => context.push(Routes.exportStudioPath(job.tripId)),
        ),
      ),
    );
  }

  bool _isInProgress(ExportJobSummary job) {
    return job.status == ExportJobStatus.queued ||
        job.status == ExportJobStatus.processing ||
        job.status == ExportJobStatus.cancelRequested;
  }

  bool _isFailedOrBlocked(ExportJobSummary job) {
    return job.status == ExportJobStatus.failed ||
        job.status == ExportJobStatus.blocked;
  }

  Future<void> _handleCancel(ExportJobSummary job) async {
    try {
      await ref.read(exportRepositoryProvider).cancelJob(job.jobId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cancel requested')),
      );
      _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _handleDownload(ExportJobSummary job) async {
    try {
      final url = await ref.read(exportRepositoryProvider).getDownloadUrl(job.jobId);
      await _launchExternal(url);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _handleShare(ExportJobSummary job) async {
    try {
      final url = await ref.read(exportRepositoryProvider).getShareUrl(job.jobId);
      await _launchExternal(url);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw const FormatException('Invalid URL');
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw const FormatException('Could not open URL');
    }
  }
}

class _ExportJobCard extends StatelessWidget {
  const _ExportJobCard({
    required this.job,
    required this.onCancel,
    required this.onDownload,
    required this.onShare,
    required this.onReExport,
  });

  final ExportJobSummary job;
  final Future<void> Function(ExportJobSummary job) onCancel;
  final Future<void> Function(ExportJobSummary job) onDownload;
  final Future<void> Function(ExportJobSummary job) onShare;
  final void Function(ExportJobSummary job) onReExport;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(job.status);
    final statusColor = _statusColor(job.status);
    final canCancel = job.status == ExportJobStatus.queued ||
        job.status == ExportJobStatus.processing ||
        job.status == ExportJobStatus.cancelRequested;
    final canDownload = job.status == ExportJobStatus.completed;
    final canShare = job.status == ExportJobStatus.completed;
    final canReExport = job.status == ExportJobStatus.failed ||
        job.status == ExportJobStatus.blocked ||
        job.status == ExportJobStatus.canceled;

    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.tripTitle ?? 'Trip ${job.tripId.substring(0, 8)}',
                  style: AppTypography.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Text(
                  status,
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Template: ${job.template} · ${DateTimeUtils.formatRelativeTime(job.createdAt)}',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          if (canCancel) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: job.progress > 0 ? job.progress : null,
              backgroundColor: AppColors.divider,
              color: AppColors.accent,
            ),
          ],
          if ((job.errorMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              job.errorMessage!,
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (canCancel)
                OutlinedButton(
                  onPressed: () => onCancel(job),
                  child: const Text('Cancel'),
                ),
              if (canDownload)
                OutlinedButton(
                  onPressed: () => onDownload(job),
                  child: const Text('Download'),
                ),
              if (canShare)
                OutlinedButton(
                  onPressed: () => onShare(job),
                  child: const Text('Share'),
                ),
              if (canReExport)
                OutlinedButton(
                  onPressed: () => onReExport(job),
                  child: const Text('Re-export'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(ExportJobStatus status) {
    switch (status) {
      case ExportJobStatus.queued:
        return 'Queued';
      case ExportJobStatus.processing:
        return 'Processing';
      case ExportJobStatus.cancelRequested:
        return 'Canceling';
      case ExportJobStatus.completed:
        return 'Completed';
      case ExportJobStatus.failed:
        return 'Failed';
      case ExportJobStatus.blocked:
        return 'Blocked';
      case ExportJobStatus.canceled:
        return 'Canceled';
    }
  }

  Color _statusColor(ExportJobStatus status) {
    switch (status) {
      case ExportJobStatus.completed:
        return AppColors.success;
      case ExportJobStatus.failed:
      case ExportJobStatus.blocked:
        return AppColors.error;
      case ExportJobStatus.canceled:
        return AppColors.textSecondary;
      case ExportJobStatus.queued:
      case ExportJobStatus.processing:
      case ExportJobStatus.cancelRequested:
        return AppColors.warning;
    }
  }
}
