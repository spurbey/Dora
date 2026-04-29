import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_capture/providers/bottom_sheet_state_provider.dart';
import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';

/// Detail view for a single captured photo/video on the V3 bottom sheet.
///
/// **Action surface (per Phase 0 audit, read-first rule):**
/// - **Open in Maps** — launches the platform map at the capture location.
///   No-op (button hidden) if [item] has no coordinates.
/// - **Delete** — soft-deletes the media row via [MediaDao.softDelete].
///   Confirms via dialog before destroying. After delete, returns to
///   the timeline.
///
/// **Deferred** (no clean repo primitive yet — separate sprint):
/// - Edit caption (no caption field on the media schema)
/// - Attach to place (no clean trip-place picker primitive)
/// - Share via system (no `share_plus` dep yet)
class CapturedMediaDetail extends ConsumerWidget {
  const CapturedMediaDetail({
    super.key,
    required this.tripId,
    required this.item,
    required this.scrollController,
  });

  final String tripId;
  final TimelineMediaItem item;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _Header(
            tripId: tripId,
            onBack: () =>
                ref.read(bottomSheetStateProvider(tripId).notifier).backToTimeline(),
          ),
        ),
        SliverToBoxAdapter(
          child: _Photo(
            localPath: item.thumbnailLocalPath,
            remoteUrl: item.thumbnailRemoteUrl,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DoraSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatAbsoluteDateTime(item.capturedAt),
                  style: DoraTypography.bubble,
                ),
                const SizedBox(height: DoraSpacing.xs),
                if (!item.hasCoords)
                  const Row(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 16,
                        color: DoraColors.inkTertiary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Location unavailable',
                        style: TextStyle(
                          fontSize: 13,
                          color: DoraColors.inkTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '${item.latitude!.toStringAsFixed(5)}, '
                    '${item.longitude!.toStringAsFixed(5)}',
                    style: DoraTypography.bodyMuted,
                  ),
                const SizedBox(height: DoraSpacing.xl),
                _ActionRow(
                  hasCoords: item.hasCoords,
                  onOpenMaps: item.hasCoords
                      ? () => _openInMaps(item.latitude!, item.longitude!)
                      : null,
                  onDelete: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    final web = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this photo?'),
        content: const Text(
          "This removes it from the trip and the map. You can't undo this.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: DoraColors.warn,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final dao = ref.read(mediaDaoProvider);
    await dao.softDelete(item.mediaId);

    if (!context.mounted) return;
    ref.read(bottomSheetStateProvider(tripId).notifier).backToTimeline();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tripId, required this.onBack});
  // ignore: unused_element_parameter
  final String tripId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DoraSpacing.sm,
        DoraSpacing.sm,
        DoraSpacing.lg,
        DoraSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            color: DoraColors.inkPrimary,
            tooltip: 'Back to timeline',
          ),
          const Expanded(
            child: Text(
              'Photo',
              style: DoraTypography.displayMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.localPath, required this.remoteUrl});
  final String? localPath;
  final String? remoteUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 240,
      color: DoraColors.surfaceMint,
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_camera_outlined,
        size: 48,
        color: DoraColors.brandPrimary.withValues(alpha: 0.55),
      ),
    );

    Widget image;
    if (localPath != null && localPath!.isNotEmpty) {
      image = Image(
        image: FileImage(File(localPath!)),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      image = Image.network(
        remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (_, child, p) => p == null ? child : placeholder,
      );
    } else {
      image = placeholder;
    }

    return AspectRatio(aspectRatio: 4 / 3, child: image);
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.hasCoords,
    required this.onOpenMaps,
    required this.onDelete,
  });

  final bool hasCoords;
  final VoidCallback? onOpenMaps;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (hasCoords) ...[
          Expanded(
            child: _ActionButton(
              icon: Icons.map_outlined,
              label: 'Open in Maps',
              onTap: onOpenMaps,
            ),
          ),
          const SizedBox(width: DoraSpacing.md),
        ],
        Expanded(
          child: _ActionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Delete',
            onTap: onDelete,
            tint: DoraColors.warn,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint = DoraColors.brandPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint.withValues(alpha: 0.10),
      borderRadius: DoraRadius.chipAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: DoraRadius.chipAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DoraSpacing.lg,
            vertical: DoraSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: tint, size: 18),
              const SizedBox(width: DoraSpacing.sm),
              Text(
                label,
                style: DoraTypography.label.copyWith(color: tint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAbsoluteDateTime(DateTime when) {
  final local = when.toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final h = local.hour;
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  final ampm = h < 12 ? 'AM' : 'PM';
  final mm = local.minute.toString().padLeft(2, '0');
  return '${months[local.month - 1]} ${local.day}, ${local.year} · $h12:$mm $ampm';
}
