import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';

/// Shown when an export job completes: thumbnail, download, and share actions.
class SharePreviewScreen extends ConsumerWidget {
  const SharePreviewScreen({
    super.key,
    required this.job,
    required this.tripId,
  });

  final ExportJob job;
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: Text(
          'Export Ready',
          style: AppTypography.h3.copyWith(color: AppColors.darkText),
        ),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Done',
              style: AppTypography.body.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.allMd,
          children: [
            _buildThumbnail(job.thumbnailUrl),
            const SizedBox(height: AppSpacing.lg),
            _buildSuccessBadge(),
            const SizedBox(height: AppSpacing.lg),
            _DownloadButton(jobId: job.jobId),
            const SizedBox(height: AppSpacing.sm),
            _ShareButton(jobId: job.jobId),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Back to trips',
                  style: AppTypography.body.copyWith(color: AppColors.darkMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String? thumbnailUrl) {
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.darkMuted),
        ),
        child: const Center(
          child: Icon(Icons.videocam_outlined,
              color: AppColors.darkMuted, size: 48),
        ),
      );
    }
    return ClipRRect(
      borderRadius: AppRadius.borderMd,
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 220,
          color: AppColors.darkSurface,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 220,
          color: AppColors.darkSurface,
          child: const Center(
            child: Icon(Icons.broken_image_outlined,
                color: AppColors.darkMuted, size: 48),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 28),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Your video is ready',
          style: AppTypography.h3.copyWith(color: AppColors.darkText),
        ),
      ],
    );
  }
}

// ── Download button ──────────────────────────────────────────────────────────

class _DownloadButton extends ConsumerStatefulWidget {
  const _DownloadButton({required this.jobId});
  final String jobId;

  @override
  ConsumerState<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends ConsumerState<_DownloadButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.darkText,
        minimumSize: const Size.fromHeight(AppSpacing.xxl),
      ),
      onPressed: _loading ? null : _download,
      icon: _loading
          ? const SizedBox(
              width: AppSpacing.md,
              height: AppSpacing.md,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_outlined),
      label: const Text('Download Video'),
    );
  }

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final url =
          await ref.read(exportRepositoryProvider).getDownloadUrl(widget.jobId);
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open download link.')),
          );
        }
      }
    } on ExportRepositoryException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

// ── Share button ─────────────────────────────────────────────────────────────

class _ShareButton extends ConsumerStatefulWidget {
  const _ShareButton({required this.jobId});
  final String jobId;

  @override
  ConsumerState<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends ConsumerState<_ShareButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        side: const BorderSide(color: AppColors.darkMuted),
        minimumSize: const Size.fromHeight(AppSpacing.xxl),
      ),
      onPressed: _loading ? null : _copyShareLink,
      icon: _loading
          ? const SizedBox(
              width: AppSpacing.md,
              height: AppSpacing.md,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.link_outlined),
      label: const Text('Copy Share Link'),
    );
  }

  Future<void> _copyShareLink() async {
    setState(() => _loading = true);
    try {
      final url =
          await ref.read(exportRepositoryProvider).getShareUrl(widget.jobId);
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share link copied to clipboard.')),
        );
      }
    } on ExportRepositoryException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
