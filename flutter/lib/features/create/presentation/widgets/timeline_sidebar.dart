import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/domain/unified_timeline_entry.dart';

class TimelineSidebar extends StatelessWidget {
  const TimelineSidebar({
    super.key,
    required this.entries,
    required this.selectedEntryId,
    required this.onEntryTap,
    required this.onReorder,
    required this.onAddPlace,
    this.onAddCity,
    this.onAddRoute,
    this.width = 280,
  });

  final List<UnifiedTimelineEntry> entries;
  final String? selectedEntryId;
  final ValueChanged<UnifiedTimelineEntry> onEntryTap;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAddPlace;
  final VoidCallback? onAddCity;
  final VoidCallback? onAddRoute;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          right: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          _TimelineHeader(itemCount: entries.length),
          Expanded(
            child: entries.isEmpty
                ? _buildEmptyState()
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    buildDefaultDragHandles: false,
                    itemCount: entries.length,
                    onReorder: onReorder,
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (_, __) {
                          return Material(
                            color: Colors.transparent,
                            elevation: 4,
                            borderRadius: AppRadius.borderMd,
                            child: child,
                          );
                        },
                      );
                    },
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final selected = selectedEntryId == entry.id;
                      return _TimelineRow(
                        key: ValueKey(entry.id),
                        entry: entry,
                        selected: selected,
                        index: index,
                        onTap: () => onEntryTap(entry),
                      );
                    },
                  ),
          ),
          Padding(
            padding: AppSpacing.allMd,
            child: SizedBox(
              width: double.infinity,
              child: entries.isEmpty
                  ? ElevatedButton.icon(
                      onPressed: onAddCity ?? onAddPlace,
                      icon: const Icon(Icons.add_location_alt, size: 18),
                      label: const Text('Add Your First Destination'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )
                  : _AddMenuButton(
                      onAddCity: onAddCity,
                      onAddPlace: onAddPlace,
                      onAddRoute: onAddRoute,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 32,
                color: AppColors.accent.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your journey starts here',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a city, place, or route to begin',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({
    required this.itemCount,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline, size: 18, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Timeline',
            style: AppTypography.h3.copyWith(fontSize: 16),
          ),
          const Spacer(),
          if (itemCount > 0)
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    super.key,
    required this.entry,
    required this.selected,
    required this.index,
    required this.onTap,
  });

  final UnifiedTimelineEntry entry;
  final bool selected;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    switch (entry) {
      case final UnifiedPlaceTimelineEntry placeEntry:
        final place = placeEntry.place;
        final isCity = place.placeType == 'city';
        return _BaseRow(
          selected: selected,
          onTap: onTap,
          leading: CircleAvatar(
            radius: 13,
            backgroundColor: (isCity ? AppColors.primary : AppColors.accent)
                .withValues(alpha: selected ? 1 : 0.18),
            child: Text(
              isCity ? 'C' : '${index + 1}',
              style: AppTypography.caption.copyWith(
                color: selected
                    ? Colors.white
                    : (isCity ? AppColors.primary : AppColors.accent),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: place.name,
          subtitle: place.address,
          chips: [
            _EntryChip(
              label: isCity ? 'City' : 'Place',
              tint: isCity ? AppColors.primary : AppColors.accent,
            ),
          ],
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(
              Icons.drag_handle,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        );

      case final UnifiedLiveEventTimelineEntry eventEntry:
        final event = eventEntry.event;
        return _BaseRow(
          selected: selected,
          onTap: onTap,
          leading: Icon(
            _eventIcon(event.eventType),
            size: 18,
            color: AppColors.accent,
          ),
          title: event.title,
          subtitle: event.subtitle ?? _eventFallbackSubtitle(eventEntry),
          chips: [
            _EntryChip(
              label: _bucketLabel(event.bucketType),
              tint: _bucketTint(event.bucketType),
            ),
            if (eventEntry.mediaCount > 0)
              _EntryChip(
                label: '${eventEntry.mediaCount} media',
                tint: AppColors.primary,
              ),
            _EntryChip(
              label: _formatTime(event.capturedAt),
              tint: AppColors.textSecondary,
            ),
          ],
          trailing: const SizedBox.shrink(),
        );

      case final UnifiedRouteTimelineEntry routeEntry:
        final route = routeEntry.route;
        final label = _routeLabel(route);
        final subtitle = [
          if (routeEntry.startPlaceName != null) routeEntry.startPlaceName!,
          if (routeEntry.endPlaceName != null) routeEntry.endPlaceName!,
        ].join(' -> ');
        return _BaseRow(
          selected: selected,
          onTap: onTap,
          leading: Icon(
            _routeIcon(route.transportMode),
            size: 18,
            color: AppColors.accent,
          ),
          title: label,
          subtitle: subtitle.isEmpty ? null : subtitle,
          chips: [
            if (route.distance != null)
              _EntryChip(
                label: '${route.distance!.toStringAsFixed(1)} km',
                tint: AppColors.accent,
              ),
            if (route.duration != null)
              _EntryChip(
                label: '${route.duration} min',
                tint: AppColors.textSecondary,
              ),
          ],
          trailing: const SizedBox.shrink(),
        );
    }
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _eventFallbackSubtitle(UnifiedLiveEventTimelineEntry entry) {
    final bind = entry.event.placeBindName?.trim();
    if (bind != null && bind.isNotEmpty) {
      return bind;
    }
    return _bucketLabel(entry.event.bucketType);
  }

  IconData _eventIcon(String eventType) {
    switch (eventType) {
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'media':
        return Icons.videocam_outlined;
      case 'warn':
        return Icons.warning_amber_rounded;
      case 'tag':
        return Icons.bookmark_added_outlined;
      case 'note':
      default:
        return Icons.note_alt_outlined;
    }
  }

  String _bucketLabel(String bucketType) {
    switch (bucketType) {
      case 'place':
        return 'Place-bound';
      case 'on_route':
        return 'Geo-tagged';
      case 'needs_review':
      default:
        return 'Needs review';
    }
  }

  Color _bucketTint(String bucketType) {
    switch (bucketType) {
      case 'place':
        return AppColors.success;
      case 'on_route':
        return AppColors.textSecondary;
      case 'needs_review':
      default:
        return AppColors.warning;
    }
  }

  IconData _routeIcon(String transportMode) {
    switch (transportMode) {
      case 'air':
        return Icons.flight;
      case 'foot':
      case 'walk':
      case 'walking':
        return Icons.directions_walk;
      case 'bike':
        return Icons.directions_bike;
      default:
        return Icons.directions_car;
    }
  }

  String _routeLabel(create_route.Route route) {
    if (route.name != null && route.name!.trim().isNotEmpty) {
      return route.name!;
    }
    switch (route.transportMode) {
      case 'air':
        return 'Flight route';
      case 'foot':
      case 'walk':
      case 'walking':
        return 'Walking route';
      case 'bike':
        return 'Cycling route';
      default:
        return 'Driving route';
    }
  }
}

class _BaseRow extends StatelessWidget {
  const _BaseRow({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.trailing,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String? subtitle;
  final List<Widget> chips;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: AppRadius.borderMd,
          border: selected
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: chips,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _EntryChip extends StatelessWidget {
  const _EntryChip({
    required this.label,
    required this.tint,
  });

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AddMenuButton extends StatelessWidget {
  const _AddMenuButton({
    this.onAddCity,
    required this.onAddPlace,
    this.onAddRoute,
  });

  final VoidCallback? onAddCity;
  final VoidCallback onAddPlace;
  final VoidCallback? onAddRoute;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'city':
            onAddCity?.call();
          case 'place':
            onAddPlace();
          case 'route':
            onAddRoute?.call();
        }
      },
      offset: const Offset(0, -140),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      color: AppColors.card,
      itemBuilder: (_) => [
        _menuItem('city', Icons.location_city, 'Add City'),
        _menuItem('place', Icons.add_location_alt, 'Add Place'),
        _menuItem('route', Icons.route, 'Draw Route'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.accent),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Add to Timeline',
              style: AppTypography.body.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.body),
        ],
      ),
    );
  }
}
