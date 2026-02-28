import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_error_strings.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';

/// 6A export studio entrypoint with pre-submit guard checks and submit action.
class ExportStudioScreen extends ConsumerStatefulWidget {
  const ExportStudioScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<ExportStudioScreen> createState() => _ExportStudioScreenState();
}

class _ExportStudioScreenState extends ConsumerState<ExportStudioScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final precheckAsync = ref.watch(exportPrecheckProvider(widget.tripId));

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
        child: precheckAsync.when(
          loading: _buildLoading,
          error: (error, _) => _buildError(error),
          data: _buildContent,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Preparing your video...',
            style: AppTypography.body.copyWith(color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
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
              onPressed: () {
                ref.invalidate(exportPrecheckProvider(widget.tripId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ExportPrecheckResult result) {
    final details = ExportErrorStrings.detailsForPrecheck(result);

    return ListView(
      padding: AppSpacing.allMd,
      children: [
        _CardBlock(
          title: 'Default 6A Preset',
          child: Text(
            'Template: classic\nAspect ratio: 9:16\nDuration: 15s\nQuality: 720p\nFPS: 30',
            style: AppTypography.body.copyWith(color: AppColors.darkText),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CardBlock(
          title: 'Pre-Submit Guard',
          child: result.canExport
              ? Text(
                  'All checks passed. You can submit export now.',
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '- $detail',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.darkMuted,
                          ),
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
              result.canExport && !_isSubmitting ? () => _submitExport() : null,
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
    setState(() {
      _isSubmitting = true;
    });

    final repository = ref.read(exportRepositoryProvider);

    try {
      final latestPrecheck =
          await ref.refresh(exportPrecheckProvider(widget.tripId).future);
      if (!latestPrecheck.canExport) {
        if (!mounted) {
          return;
        }
        final message = ExportErrorStrings.messageForFailure(
          latestPrecheck.failures.first,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }

      final result = await repository.submitClassicExport(widget.tripId);
      if (!mounted) {
        return;
      }
      final message = result.deduplicated
          ? 'Using existing export job ${result.jobId}.'
          : 'Export job queued: ${result.jobId}';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      ref.invalidate(exportPrecheckProvider(widget.tripId));
    } on ExportRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({
    required this.title,
    required this.child,
  });

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
