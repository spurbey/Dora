import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_capture/providers/bottom_sheet_state_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';
import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';

/// Detail view for a single note / warn / geotag event on the V3
/// bottom sheet.
///
/// Location actions stay inside Dora: "Show on map" flies the in-app
/// Mapbox camera instead of launching any external map application.
class EventDetail extends ConsumerWidget {
  const EventDetail({
    super.key,
    required this.tripId,
    required this.item,
    required this.scrollController,
    this.onShowOnMap,
  });

  final String tripId;
  final TimelineEventItem item;
  final ScrollController scrollController;
  final void Function(double lat, double lng)? onShowOnMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tint = _tintFor(item.kind);
    final icon = _iconFor(item.kind);
    final title = _titleFor(item.kind);
    final body = item.body.trim().isEmpty ? '(no content)' : item.body;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _Header(
            title: title,
            tint: tint,
            icon: icon,
            onBack: () => ref
                .read(bottomSheetStateProvider(tripId).notifier)
                .backToTimeline(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DoraSpacing.lg,
              DoraSpacing.sm,
              DoraSpacing.lg,
              DoraSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BodyCard(body: body, tint: tint),
                const SizedBox(height: DoraSpacing.xl),
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
                if (item.hasCoords && onShowOnMap != null)
                  _ShowOnMapButton(
                    onTap: () {
                      onShowOnMap!(item.latitude!, item.longitude!);
                      ref
                          .read(bottomSheetStateProvider(tripId).notifier)
                          .backToTimeline();
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static IconData _iconFor(TripEventMapKind kind) {
    switch (kind) {
      case TripEventMapKind.note:
        return Icons.edit_note_rounded;
      case TripEventMapKind.warn:
        return Icons.warning_amber_rounded;
      case TripEventMapKind.geotag:
        return Icons.location_on_outlined;
    }
  }

  static Color _tintFor(TripEventMapKind kind) {
    switch (kind) {
      case TripEventMapKind.note:
        return DoraColors.inkPrimary;
      case TripEventMapKind.warn:
        return DoraColors.warn;
      case TripEventMapKind.geotag:
        return DoraColors.brandPrimary;
    }
  }

  static String _titleFor(TripEventMapKind kind) {
    switch (kind) {
      case TripEventMapKind.note:
        return 'Note';
      case TripEventMapKind.warn:
        return 'Warning';
      case TripEventMapKind.geotag:
        return 'Geotag';
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.tint,
    required this.icon,
    required this.onBack,
  });

  final String title;
  final Color tint;
  final IconData icon;
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(width: DoraSpacing.md),
          Text(title, style: DoraTypography.displayMedium),
        ],
      ),
    );
  }
}

class _BodyCard extends StatelessWidget {
  const _BodyCard({required this.body, required this.tint});

  final String body;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DoraSpacing.lg),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: DoraRadius.cardAll,
        border: Border.all(
          color: tint.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Text(body, style: DoraTypography.body),
    );
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

class _ShowOnMapButton extends StatelessWidget {
  const _ShowOnMapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DoraColors.brandPrimary.withValues(alpha: 0.10),
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
              const Icon(
                Icons.map_outlined,
                color: DoraColors.brandPrimary,
                size: 18,
              ),
              const SizedBox(width: DoraSpacing.sm),
              Text(
                'Show on map',
                style: DoraTypography.label.copyWith(
                  color: DoraColors.brandPrimary,
                ),
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
