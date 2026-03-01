import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dora_api/dora_api.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_error_strings.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';
import 'package:dora/features/export/presentation/screens/share_preview_screen.dart';

enum _ExportPhase { configure, tracking }

/// Export Studio: template picker → guard checks → submit → progress tracking.
class ExportStudioScreen extends ConsumerStatefulWidget {
  const ExportStudioScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<ExportStudioScreen> createState() => _ExportStudioScreenState();
}

class _ExportStudioScreenState extends ConsumerState<ExportStudioScreen> {
  _ExportPhase _phase = _ExportPhase.configure;
  ExportTemplate _selectedTemplate = ExportTemplate.classic;
  String? _activeJobId;
  bool _isSubmitting = false;
  bool _isCanceling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: Text(
          'Export Studio',
          style: AppTypography.h3.copyWith(color: AppColors.darkText),
        ),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
      ),
      body: SafeArea(
        child: _phase == _ExportPhase.configure
            ? _buildConfigurePhase()
            : _buildTrackingPhase(),
      ),
    );
  }

  // ── Configure phase ───────────────────────────────────────────────────────

  Widget _buildConfigurePhase() {
    final precheckAsync = ref.watch(exportPrecheckProvider(widget.tripId));
    return precheckAsync.when(
      loading: _buildSpinner,
      error: (error, _) => _buildPrecheckError(error),
      data: _buildConfigureContent,
    );
  }

  Widget _buildSpinner() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildPrecheckError(Object error) {
    return Center(
      child: Padding(
        padding: AppSpacing.horizontalMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not prepare export checks.',
              style: AppTypography.h3.copyWith(color: AppColors.darkText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTypography.body.copyWith(color: AppColors.darkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkText,
                side: const BorderSide(color: AppColors.darkMuted),
              ),
              onPressed: () =>
                  ref.invalidate(exportPrecheckProvider(widget.tripId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigureContent(ExportPrecheckResult result) {
    final details = ExportErrorStrings.detailsForPrecheck(result);
    return ListView(
      padding: AppSpacing.allMd,
      children: [
        _SectionCard(
          title: 'Template',
          child: _TemplatePicker(
            selected: _selectedTemplate,
            onSelect: (t) => setState(() => _selectedTemplate = t),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Pre-Submit Check',
          child: result.canExport
              ? Text(
                  'All checks passed.',
                  style: AppTypography.body.copyWith(color: AppColors.success),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ExportErrorStrings.messageForFailure(
                          result.failures.first),
                      style:
                          AppTypography.body.copyWith(color: AppColors.error),
                    ),
                    if (details.isNotEmpty)
                      const SizedBox(height: AppSpacing.sm),
                    for (final detail in details)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '- $detail',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.darkMuted),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.darkText,
            minimumSize: const Size.fromHeight(AppSpacing.xxl),
          ),
          onPressed:
              result.canExport && !_isSubmitting ? _submitExport : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: AppSpacing.md,
                  height: AppSpacing.md,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Start Export'),
        ),
      ],
    );
  }

  Future<void> _submitExport() async {
    setState(() => _isSubmitting = true);
    final repository = ref.read(exportRepositoryProvider);
    try {
      final latestPrecheck =
          await ref.refresh(exportPrecheckProvider(widget.tripId).future);
      if (!latestPrecheck.canExport) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ExportErrorStrings.messageForFailure(
                latestPrecheck.failures.first)),
          ),
        );
        return;
      }

      final result =
          await repository.submitExport(widget.tripId, _selectedTemplate);
      if (!mounted) return;
      setState(() {
        _activeJobId = result.jobId;
        _phase = _ExportPhase.tracking;
      });
    } on ExportRepositoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Tracking phase ────────────────────────────────────────────────────────

  Widget _buildTrackingPhase() {
    final jobId = _activeJobId;
    if (jobId == null) return _buildSpinner();

    final jobAsync = ref.watch(exportJobPollingProvider(jobId));
    return jobAsync.when(
      loading: _buildSpinner,
      error: (error, _) => _buildTrackingError(error, jobId),
      data: _buildTrackingContent,
    );
  }

  Widget _buildTrackingError(Object error, String jobId) {
    return Center(
      child: Padding(
        padding: AppSpacing.horizontalMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lost connection to export service.',
              style: AppTypography.h3.copyWith(color: AppColors.darkText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTypography.body.copyWith(color: AppColors.darkMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkText,
                side: const BorderSide(color: AppColors.darkMuted),
              ),
              onPressed: () =>
                  ref.invalidate(exportJobPollingProvider(jobId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingContent(ExportJob job) {
    // Navigate to SharePreviewScreen post-frame when completed.
    if (job.status == ExportJobStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) =>
                SharePreviewScreen(job: job, tripId: widget.tripId),
          ),
        );
      });
    }

    return Center(
      child: Padding(
        padding: AppSpacing.allMd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatusCard(job: job),
            if (_isCancelable(job.status)) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: _isCanceling ? null : () => _requestCancel(job),
                child: _isCanceling
                    ? const SizedBox(
                        width: AppSpacing.md,
                        height: AppSpacing.md,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Cancel Export'),
              ),
            ],
            if (_isTerminal(job.status) &&
                job.status != ExportJobStatus.completed) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.darkText,
                ),
                onPressed: () => setState(() {
                  _phase = _ExportPhase.configure;
                  _activeJobId = null;
                }),
                child: const Text('Start New Export'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isCancelable(ExportJobStatus status) =>
      status == ExportJobStatus.queued ||
      status == ExportJobStatus.processing;

  bool _isTerminal(ExportJobStatus status) =>
      status == ExportJobStatus.completed ||
      status == ExportJobStatus.failed ||
      status == ExportJobStatus.canceled ||
      status == ExportJobStatus.blocked;

  Future<void> _requestCancel(ExportJob job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          'Cancel export?',
          style: AppTypography.h3.copyWith(color: AppColors.darkText),
        ),
        content: Text(
          'The video will stop rendering.',
          style: AppTypography.body.copyWith(color: AppColors.darkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Keep waiting',
              style: TextStyle(color: AppColors.darkText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel export',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isCanceling = true);
    try {
      await ref.read(exportRepositoryProvider).cancelJob(job.jobId);
    } on ExportRepositoryException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }
}

// ── Status card ──────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.job});

  final ExportJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.darkMuted),
      ),
      child: Column(
        children: [
          _statusIcon(),
          const SizedBox(height: AppSpacing.md),
          Text(
            _headline(),
            style: AppTypography.h3.copyWith(color: AppColors.darkText),
            textAlign: TextAlign.center,
          ),
          if (job.status == ExportJobStatus.processing ||
              job.status == ExportJobStatus.cancelRequested) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ExportErrorStrings.stageLabel(job.stage),
              style:
                  AppTypography.caption.copyWith(color: AppColors.darkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: job.progress > 0 ? job.progress : null,
              backgroundColor: AppColors.darkMuted.withValues(alpha: 0.3),
              color: AppColors.accent,
            ),
          ],
          if (job.status == ExportJobStatus.queued) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          if (job.status == ExportJobStatus.blocked) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ExportErrorStrings.messageForBlockedCode(job.errorCode),
              style: AppTypography.body.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
          if (job.status == ExportJobStatus.failed &&
              (job.errorMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              job.errorMessage!,
              style:
                  AppTypography.body.copyWith(color: AppColors.darkMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusIcon() {
    switch (job.status) {
      case ExportJobStatus.queued:
      case ExportJobStatus.processing:
      case ExportJobStatus.cancelRequested:
        return const CircularProgressIndicator();
      case ExportJobStatus.completed:
        return const Icon(Icons.check_circle,
            color: AppColors.success, size: AppSpacing.xl);
      case ExportJobStatus.failed:
      case ExportJobStatus.blocked:
        return const Icon(Icons.error_outline,
            color: AppColors.error, size: AppSpacing.xl);
      case ExportJobStatus.canceled:
        return const Icon(Icons.cancel_outlined,
            color: AppColors.darkMuted, size: AppSpacing.xl);
    }
  }

  String _headline() {
    switch (job.status) {
      case ExportJobStatus.queued:
        return 'Waiting in queue...';
      case ExportJobStatus.processing:
        return 'Rendering your video...';
      case ExportJobStatus.cancelRequested:
        return 'Canceling...';
      case ExportJobStatus.completed:
        return 'Export ready!';
      case ExportJobStatus.failed:
        return 'Export failed';
      case ExportJobStatus.canceled:
        return 'Export canceled';
      case ExportJobStatus.blocked:
        return 'Export blocked';
    }
  }
}

// ── Template picker ──────────────────────────────────────────────────────────

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({required this.selected, required this.onSelect});

  final ExportTemplate selected;
  final ValueChanged<ExportTemplate> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TemplateCard(
            label: 'Classic',
            description: 'Ken Burns slides\n9:16 · 720p · 30fps',
            isSelected: selected == ExportTemplate.classic,
            onTap: () => onSelect(ExportTemplate.classic),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TemplateCard(
            label: 'Cinematic',
            description: 'Cinematic cuts\n(preview — renders as Classic)',
            isSelected: selected == ExportTemplate.cinematic,
            badge: 'Preview',
            onTap: () => onSelect(ExportTemplate.cinematic),
          ),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.allSm,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.darkMuted,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body
                        .copyWith(color: AppColors.darkText),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accent,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTypography.caption
                  .copyWith(color: AppColors.darkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.darkMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h3.copyWith(color: AppColors.darkText),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
