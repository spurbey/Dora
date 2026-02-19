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
    this.onAddCity,
    this.onAddRoute,
    this.width = 280,
  });

  final List<Place> places;
  final List<create_route.Route> routes;
  final String? selectedItemId;
  final String? selectedItemType;
  final void Function(String id, String type) onItemTap;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onAddPlace;
  final VoidCallback? onAddCity;
  final VoidCallback? onAddRoute;
  final double width;

  /// Find the route that connects place at [fromIndex] to the next place.
  create_route.Route? _findRouteBetween(int fromIndex, List<Place> sorted) {
    if (fromIndex >= sorted.length - 1) return null;
    if (fromIndex < routes.length) {
      return routes[fromIndex];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlaces = List<Place>.from(places)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final itemCount =
        sortedPlaces.where((p) => p.placeType != 'city').length +
            sortedPlaces.where((p) => p.placeType == 'city').length;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border:
            Border(right: BorderSide(color: AppColors.divider, width: 0.5)),
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
                    '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
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
          // Add button with menu
          Padding(
            padding: AppSpacing.allMd,
            child: SizedBox(
              width: double.infinity,
              child: sortedPlaces.isEmpty
                  ? ElevatedButton.icon(
                      onPressed: onAddCity ?? onAddPlace,
                      icon:
                          const Icon(Icons.add_location_alt, size: 18),
                      label: const Text('Add Your First Destination'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
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
              'Add a city or place to begin\nbuilding your travelogue',
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
    final widgets = <Widget>[];
    int? lastDay;
    int placeNumber = 0;

    for (int i = 0; i < sortedPlaces.length; i++) {
      final place = sortedPlaces[i];
      final isCity = place.placeType == 'city';
      final isFirst = i == 0;
      final isLast = i == sortedPlaces.length - 1;

      if (!isCity) placeNumber++;

      // Day header
      if (place.dayNumber != null && place.dayNumber != lastDay) {
        lastDay = place.dayNumber;
        widgets.add(TimelineDayHeader(dayNumber: place.dayNumber!));
      }

      // Place/city item
      final subtitleParts = <String>[];
      if (place.visitTime != null) {
        subtitleParts.add(_capitalizeFirst(place.visitTime!));
      }
      if (place.address != null && place.address!.isNotEmpty) {
        subtitleParts.add(place.address!);
      }
      final subtitle =
          subtitleParts.isEmpty ? null : subtitleParts.join(' \u00b7 ');

      widgets.add(
        TimelinePlaceItem(
          key: ValueKey('place_${place.id}'),
          orderNumber: isCity ? 0 : placeNumber,
          title: place.name,
          subtitle: subtitle,
          selected:
              selectedItemId == place.id && selectedItemType == 'place',
          onTap: () => onItemTap(place.id, 'place'),
          isFirst: isFirst,
          isLast: isLast && _findRouteBetween(i, sortedPlaces) == null,
          isCity: isCity,
        ),
      );

      // Route connector (between this place and next)
      final route = _findRouteBetween(i, sortedPlaces);
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

/// Popup menu button for adding cities, places, or routes.
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
            Icon(Icons.add, size: 18, color: AppColors.accent),
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
