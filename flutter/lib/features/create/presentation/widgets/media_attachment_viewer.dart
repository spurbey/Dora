import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/shared/widgets/memory_aware_image.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class MediaAttachmentViewer extends StatefulWidget {
  const MediaAttachmentViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onShowOnMap,
    this.onManageMedia,
  });

  final List<MediaItem> items;
  final int initialIndex;
  final ValueChanged<MediaItem>? onShowOnMap;
  final VoidCallback? onManageMedia;

  @override
  State<MediaAttachmentViewer> createState() => _MediaAttachmentViewerState();
}

class _MediaAttachmentViewerState extends State<MediaAttachmentViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.items.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.items.length - 1).toInt();
    _index = safeIndex;
    _pageController = PageController(initialPage: safeIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final item = widget.items[_index];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.borderMd,
                child: ColoredBox(
                  color: Colors.black,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.items.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) {
                      final media = widget.items[index];
                      final image = _resolveImage(media);
                      if (image == null) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                            size: 36,
                          ),
                        );
                      }
                      return InteractiveViewer(
                        minScale: 0.8,
                        maxScale: 4.0,
                        child: Center(
                          child: Image(
                            image: image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  'Attachment ${_index + 1}/${widget.items.length}',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                _StatusBadge(status: item.uploadState),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onShowOnMap == null
                        ? null
                        : () => widget.onShowOnMap!(item),
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('Show on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (widget.onManageMedia != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: widget.onManageMedia,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Manage'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object>? _resolveImage(MediaItem item) {
    final memImage = memoryImageIfHot(item.localUri, item.thumbnailLocalPath);
    if (memImage != null) return memImage;
    final thumb = item.thumbnailLocalPath;
    if (thumb != null && thumb.isNotEmpty) {
      if (thumb.startsWith('http')) {
        return NetworkImage(thumb);
      }
      final file = File(thumb);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    final localUri = item.localUri;
    if (localUri != null && localUri.isNotEmpty) {
      final file = File(localUri);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    final url = item.remoteUrl;
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return null;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'uploaded' => AppColors.success,
      'failed' => AppColors.error,
      'blocked' => AppColors.warning,
      _ => AppColors.accent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        normalized.toUpperCase(),
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
