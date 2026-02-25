import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dora/core/media/media_permissions.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';
import 'package:dora/features/create/presentation/providers/place_media_provider.dart';
import 'package:dora/features/create/presentation/widgets/selected_photo_chip.dart';
import 'package:dora/features/create/presentation/widgets/upload_queue_item.dart';

class MediaUploadScreen extends ConsumerStatefulWidget {
  const MediaUploadScreen({
    super.key,
    required this.tripId,
    required this.placeId,
  });

  final String tripId;
  final String placeId;

  @override
  ConsumerState<MediaUploadScreen> createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends ConsumerState<MediaUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  MediaUploadContext get _context => MediaUploadContext(
        tripId: widget.tripId,
        placeId: widget.placeId,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mediaUploadControllerProvider(_context).notifier).startQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mediaUploadControllerProvider(_context));
    final controller = ref.read(mediaUploadControllerProvider(_context).notifier);
    final queueAsync = ref.watch(placeMediaProvider(widget.placeId));
    final pendingAsync = ref.watch(placePendingUploadCountProvider(widget.placeId));
    final blockedCount = queueAsync.maybeWhen(
      data: (items) => items.where((item) => item.uploadStatus == 'blocked').length,
      orElse: () => 0,
    );

    ref.listen(mediaUploadControllerProvider(_context), (previous, next) {
      final error = next.errorMessage;
      if (error != null && error.isNotEmpty && error != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }

      final info = next.infoMessage;
      if (info != null && info.isNotEmpty && info != previous?.infoMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(info)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Media Upload',
          style: AppTypography.h3,
        ),
        actions: [
          TextButton(
            onPressed: state.submitting ? null : () => _onDone(controller),
            child: state.submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Done'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Padding(
        padding: AppSpacing.allMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Selected ${state.selectedPaths.length}/10',
                    style: AppTypography.caption),
                const Spacer(),
                pendingAsync.when(
                  data: (count) {
                    final label = count > 0
                        ? 'Pending: $count'
                        : blockedCount > 0
                            ? 'Blocked: $blockedCount'
                            : 'Queue idle';
                    final color = count > 0
                        ? AppColors.accent
                        : blockedCount > 0
                            ? AppColors.warning
                            : AppColors.textSecondary;
                    return Text(
                      label,
                      style: AppTypography.caption.copyWith(color: color),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 80,
              child: state.selectedPaths.isEmpty
                  ? Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Pick up to 10 photos',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final path in state.selectedPaths)
                          SelectedPhotoChip(
                            path: path,
                            onRemove: () => controller.removeSelectedPath(path),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFromGallery(controller),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _captureFromCamera(controller),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Upload Queue', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: queueAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No media items yet.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return UploadQueueItem(
                        item: item,
                        onRetry: controller.retryUpload,
                        onRemove: controller.removeMedia,
                        onCancel: controller.cancelUpload,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    'Failed to load queue: $error',
                    style: AppTypography.caption.copyWith(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onDone(MediaUploadController controller) async {
    final success = await controller.enqueueSelection();
    if (!mounted || !success) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _captureFromCamera(MediaUploadController controller) async {
    final permissions = ref.read(mediaPermissionsProvider);
    final granted = await permissions.ensureCameraPermission();
    if (granted != MediaPermissionState.granted) {
      await _handlePermissionDenied(permissions);
      return;
    }

    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) {
      return;
    }
    if (!File(file.path).existsSync()) {
      return;
    }
    controller.addSelectedPaths([file.path]);
  }

  Future<void> _pickFromGallery(MediaUploadController controller) async {
    final permissions = ref.read(mediaPermissionsProvider);
    final granted = await permissions.ensureGalleryPermission();
    if (granted != MediaPermissionState.granted) {
      await _handlePermissionDenied(permissions);
      return;
    }

    final files = await _picker.pickMultiImage();
    if (files.isEmpty) {
      return;
    }
    final paths = files
        .where((file) => file.path.isNotEmpty && File(file.path).existsSync())
        .map((file) => file.path)
        .toList();
    controller.addSelectedPaths(paths);
  }

  Future<void> _handlePermissionDenied(MediaPermissions permissions) async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission required'),
        content: const Text(
            'Media access is required to pick or capture photos. Open app settings to allow access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await permissions.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
