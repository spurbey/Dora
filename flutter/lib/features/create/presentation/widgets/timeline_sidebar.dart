import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/presentation/widgets/timeline_item.dart';
import 'package:dora/shared/widgets/draggable_list.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(right: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          Expanded(
            child: DraggableList(
              itemCount: places.length,
              onReorder: onReorder,
              padding: AppSpacing.allMd,
              itemBuilder: (context, index) {
                final place = places[index];
                final subtitleParts = <String>[];
                if (place.dayNumber != null) {
                  subtitleParts.add('Day ${place.dayNumber}');
                }
                if (place.visitTime != null) {
                  subtitleParts.add(place.visitTime!);
                }
                final subtitle =
                    subtitleParts.isEmpty ? null : subtitleParts.join(' · ');
                return Padding(
                  key: ValueKey(place.id),
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: TimelineItem(
                    title: place.name,
                    subtitle: subtitle,
                    icon: Icons.place,
                    selected: selectedItemId == place.id &&
                        selectedItemType == 'place',
                    onTap: () => onItemTap(place.id, 'place'),
                  ),
                );
              },
            ),
          ),
          if (routes.isNotEmpty)
            Padding(
              padding: AppSpacing.horizontalMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Routes', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.sm),
                  for (final route in routes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: TimelineItem(
                        title:
                            '${route.distance?.toStringAsFixed(1) ?? '--'} km',
                        subtitle:
                            route.duration != null ? '${route.duration} min' : null,
                        icon: Icons.route,
                        selected: selectedItemId == route.id &&
                            selectedItemType == 'route',
                        onTap: () => onItemTap(route.id, 'route'),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: AppSpacing.allMd,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAddPlace,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                  foregroundColor: AppColors.accent,
                ),
                child: const Text('+ Add'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
