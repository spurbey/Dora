import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/presentation/widgets/timeline_item.dart';

class TimelineSidebar extends StatelessWidget {
  const TimelineSidebar({
    super.key,
    required this.places,
    required this.routes,
    required this.selectedItemId,
    required this.selectedItemType,
    required this.onItemTap,
    required this.onReorder,
    required this.onAddPlace,
    this.width = 280,
  });

  final List<Place> places;
  final List<create_route.Route> routes;
  final String? selectedItemId;
  final String? selectedItemType;
  final void Function(String id, String type) onItemTap;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAddPlace;
  final double width;

  /// Find the route that connects place at [fromIndex] to the next place.
  create_route.Route? _findRouteBetween(int fromIndex) {
    if (fromIndex >= places.length - 1) return null;
    // Routes don't have explicit fromPlace/toPlace in the model,
    // so we display them in order they exist in the routes list.
    if (fromIndex < routes.length) {
      return routes[fromIndex];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlaces = List<Place>.from(places)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(right: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Column(
        children: [
          // Header
          Container(
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
                Icon(Icons.timeline, size: 18, color: AppColors.accent),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Timeline',
                  style: AppTypography.h3.copyWith(fontSize: 16),
                ),
                const Spacer(),
                if (places.isNotEmpty)
                  Text(
                    '${places.length} ${places.length == 1 ? 'place' : 'places'}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: sortedPlaces.isEmpty
                ? _buildEmptyState()
                : _buildTimeline(sortedPlaces),
          ),
          // Add button
          Padding(
            padding: AppSpacing.allMd,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddPlace,
                icon: const Icon(Icons.add_location_alt, size: 18),
                label: Text(
                  sortedPlaces.isEmpty ? 'Add Your First Place' : '+ Add Place',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      sortedPlaces.isEmpty ? AppColors.accent : AppColors.card,
                  foregroundColor:
                      sortedPlaces.isEmpty ? Colors.white : AppColors.accent,
                  elevation: sortedPlaces.isEmpty ? 2 : 0,
                  side: sortedPlaces.isEmpty
                      ? null
                      : const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
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
              'Add your first place to begin\nbuilding your travelogue',
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

  Widget _buildTimeline(List<Place> sortedPlaces) {
    // Build merged list: day headers + places + route connectors
    final widgets = <Widget>[];
    int? lastDay;

    for (int i = 0; i < sortedPlaces.length; i++) {
      final place = sortedPlaces[i];
      final isFirst = i == 0;
      final isLast = i == sortedPlaces.length - 1;

      // Day header
      if (place.dayNumber != null && place.dayNumber != lastDay) {
        lastDay = place.dayNumber;
        widgets.add(TimelineDayHeader(dayNumber: place.dayNumber!));
      }

      // Place item
      final subtitleParts = <String>[];
      if (place.visitTime != null) {
        subtitleParts.add(_capitalizeFirst(place.visitTime!));
      }
      if (place.address != null && place.address!.isNotEmpty) {
        subtitleParts.add(place.address!);
      }
      final subtitle =
          subtitleParts.isEmpty ? null : subtitleParts.join(' · ');

      widgets.add(
        TimelinePlaceItem(
          key: ValueKey('place_${place.id}'),
          orderNumber: i + 1,
          title: place.name,
          subtitle: subtitle,
          selected:
              selectedItemId == place.id && selectedItemType == 'place',
          onTap: () => onItemTap(place.id, 'place'),
          isFirst: isFirst,
          isLast: isLast && _findRouteBetween(i) == null,
        ),
      );

      // Route connector (between this place and next)
      final route = _findRouteBetween(i);
      if (route != null) {
        widgets.add(
          TimelineRouteConnector(
            key: ValueKey('route_${route.id}'),
            transportMode: route.transportMode,
            distance: route.distance,
            duration: route.duration,
            selected:
                selectedItemId == route.id && selectedItemType == 'route',
            onTap: () => onItemTap(route.id, 'route'),
          ),
        );
      }
    }

    return ReorderableListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Material(
            color: Colors.transparent,
            elevation: 4,
            borderRadius: AppRadius.borderMd,
            child: child,
          ),
          child: child,
        );
      },
      children: [
        for (int i = 0; i < widgets.length; i++)
          KeyedSubtree(
            key: widgets[i].key ?? ValueKey('timeline_$i'),
            child: widgets[i],
          ),
      ],
    );
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
