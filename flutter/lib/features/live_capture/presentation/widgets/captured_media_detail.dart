import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_capture/providers/bottom_sheet_state_provider.dart';
import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';

/// Detail view for a single captured photo/video on the V3 bottom sheet.
///
/// Location actions stay inside Dora: "Show on map" flies the in-app
/// Mapbox camera instead of launching any external map application.
class CapturedMediaDetail extends ConsumerWidget {
  const CapturedMediaDetail({
    super.key,
    required this.tripId,
    required this.item,
    required this.scrollController,
    this.onShowOnMap,
  });

  final String tripId;
  final TimelineMediaItem item;
  final ScrollController scrollController;
  final void Function(double lat, double lng)? onShowOnMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _Header(
            onBack: () => ref
                .read(bottomSheetStateProvider(tripId).notifier)
                .backToTimeline(),
          ),
        ),
        SliverToBoxAdapter(
          child: _Photo(
            thumbnailLocalPath: item.thumbnailLocalPath,
            localUri: item.localUri,
            thumbnailRemoteUrl: item.thumbnailRemoteUrl,
            remoteUrl: item.remoteUrl,
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
                  const _LocationUnavailable()
                else
                  _LocationMeta(
                    latitude: item.latitude!,
                    longitude: item.longitude!,
                  ),
                const SizedBox(height: DoraSpacing.xl),
                _ActionRow(
                  hasCoords: item.hasCoords,
                  onShowOnMap: item.hasCoords && onShowOnMap != null
                      ? () => _showOnMap(ref)
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

  void _showOnMap(WidgetRef ref) {
    if (!item.hasCoords || onShowOnMap == null) return;
    onShowOnMap!(item.latitude!, item.longitude!);
    ref.read(bottomSheetStateProvider(tripId).notifier).backToTimeline();
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
            style: TextButton.styleFrom(foregroundColor: DoraColors.warn),
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
  const _Header({required this.onBack});

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
            child: Text('Photo', style: DoraTypography.displayMedium),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({
    required this.thumbnailLocalPath,
    required this.localUri,
    required this.thumbnailRemoteUrl,
    required this.remoteUrl,
  });

  final String? thumbnailLocalPath;
  final String? localUri;
  final String? thumbnailRemoteUrl;
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

    final localPath = _firstNonEmpty([thumbnailLocalPath, localUri]);
    final remotePath = _firstNonEmpty([thumbnailRemoteUrl, remoteUrl]);
    final localFile = localPath == null ? null : _fileFromPath(localPath);

    final Widget image;
    if (localFile != null) {
      image = Image(
        image: FileImage(localFile),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (remotePath != null) {
      image = Image.network(
        remotePath,
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

class _LocationUnavailable extends StatelessWidget {
  const _LocationUnavailable();

  @override
  Widget build(BuildContext context) {
    return const Row(
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
    );
  }
}

class _LocationMeta extends StatelessWidget {
  const _LocationMeta({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: DoraColors.brandPrimary,
            ),
            SizedBox(width: 4),
            Text(
              'Saved location',
              style: TextStyle(
                fontSize: 13,
                color: DoraColors.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
          style: DoraTypography.caption.copyWith(
            color: DoraColors.inkTertiary,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.hasCoords,
    required this.onShowOnMap,
    required this.onDelete,
  });

  final bool hasCoords;
  final VoidCallback? onShowOnMap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (hasCoords) ...[
          Expanded(
            child: _ActionButton(
              icon: Icons.map_outlined,
              label: 'Show on map',
              onTap: onShowOnMap,
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
              Text(label, style: DoraTypography.label.copyWith(color: tint)),
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
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final h = local.hour;
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  final ampm = h < 12 ? 'AM' : 'PM';
  final mm = local.minute.toString().padLeft(2, '0');
  return '${months[local.month - 1]} ${local.day}, ${local.year} - $h12:$mm $ampm';
}

String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

File? _fileFromPath(String raw) {
  final parsed = Uri.tryParse(raw);
  if (parsed != null && parsed.scheme == 'file') {
    return File.fromUri(parsed);
  }
  return File(raw);
}
