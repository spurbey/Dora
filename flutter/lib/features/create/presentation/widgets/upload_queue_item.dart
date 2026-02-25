import 'package:flutter/material.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/presentation/widgets/photo_grid_item.dart';

class UploadQueueItem extends StatelessWidget {
  const UploadQueueItem({
    super.key,
    required this.item,
    required this.onRetry,
    required this.onRemove,
    required this.onCancel,
  });

  final MediaItem item;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onCancel;

  @override
  Widget build(BuildContext context) {
    final statusText = _statusText(item);
    final errorText = item.errorMessage;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: PhotoGridItem(item: item),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: AppTypography.caption.copyWith(
                    color: _statusColor(item.uploadStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (errorText != null && errorText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    errorText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: _buildActions(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    final actions = <Widget>[
      TextButton(
        onPressed: () => onRemove(item.id),
        child: const Text('Remove'),
      ),
    ];
    if (item.uploadStatus == 'failed') {
      actions.insert(
        0,
        TextButton(
          onPressed: () => onRetry(item.id),
          child: const Text('Retry'),
        ),
      );
    } else if (item.uploadStatus == 'blocked') {
      actions.insert(
        0,
        TextButton(
          onPressed: () => onRetry(item.id),
          child: const Text('Retry'),
        ),
      );
    } else if (item.uploadStatus == 'queued' ||
        item.uploadStatus == 'compressing' ||
        item.uploadStatus == 'uploading') {
      actions.insert(
        0,
        TextButton(
          onPressed: () => onCancel(item.id),
          child: const Text('Cancel'),
        ),
      );
    }
    return actions;
  }

  String _statusText(MediaItem item) {
    final status = item.uploadStatus;
    if (status == 'uploading') {
      final percentage = (item.uploadProgress * 100).clamp(0, 100).round();
      return 'Uploading $percentage%';
    }
    return switch (status) {
      'queued' => 'Queued',
      'compressing' => 'Compressing',
      'failed' => 'Failed',
      'blocked' => 'Blocked',
      'uploaded' => 'Uploaded',
      'canceled' => 'Canceled',
      _ => status,
    };
  }

  Color _statusColor(String status) {
    return switch (status) {
      'uploaded' => AppColors.success,
      'failed' => AppColors.error,
      'blocked' => AppColors.warning,
      'uploading' || 'compressing' || 'queued' => AppColors.accent,
      'canceled' => AppColors.textSecondary,
      _ => AppColors.textSecondary,
    };
  }
}
