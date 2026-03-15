import 'package:flutter/material.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class WaypointSheet extends StatelessWidget {
  const WaypointSheet({
    super.key,
    required this.waypoints,
    required this.startPlaceName,
    required this.endPlaceName,
    required this.onReorder,
    required this.onRemove,
  });

  final List<AppLatLng> waypoints;
  final String startPlaceName;
  final String endPlaceName;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Text('Waypoints', style: AppTypography.h3),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    '${waypoints.length}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Start endpoint (fixed)
          _EndpointTile(
            icon: Icons.trip_origin,
            color: const Color(0xFF2E7D32),
            label: startPlaceName,
            subtitle: 'Start',
          ),

          // Waypoints list (reorderable)
          if (waypoints.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Text(
                'No waypoints yet. Tap "Edit" and tap the route line to add waypoints.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemCount: waypoints.length,
                onReorder: onReorder,
                itemBuilder: (context, index) {
                  final wp = waypoints[index];
                  return _WaypointTile(
                    key: ValueKey('wp_$index'),
                    index: index,
                    position: wp,
                    onRemove: () => onRemove(index),
                  );
                },
              ),
            ),

          // End endpoint (fixed)
          _EndpointTile(
            icon: Icons.place,
            color: const Color(0xFFC62828),
            label: endPlaceName,
            subtitle: 'End',
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _EndpointTile extends StatelessWidget {
  const _EndpointTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaypointTile extends StatelessWidget {
  const _WaypointTile({
    super.key,
    required this.index,
    required this.position,
    required this.onRemove,
  });

  final int index;
  final AppLatLng position;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF7B1FA2),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waypoint ${index + 1}',
                  style: AppTypography.body.copyWith(fontSize: 14),
                ),
                Text(
                  '${position.latitude.toStringAsFixed(5)}, '
                  '${position.longitude.toStringAsFixed(5)}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.close, size: 16, color: AppColors.error),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child:
                  Icon(Icons.drag_handle, size: 20, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
