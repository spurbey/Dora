import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

/// A place item in the visual timeline with a numbered circle badge,
/// connector line, place name, and optional subtitle.
class TimelinePlaceItem extends StatelessWidget {
  const TimelinePlaceItem({
    super.key,
    required this.orderNumber,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.isCity = false,
  });

  final int orderNumber;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;
  final bool isCity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.transparent,
          borderRadius: AppRadius.borderMd,
          border: selected
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            // Number badge with connector line
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  // Top connector line
                  if (!isFirst)
                    Container(
                      width: 2,
                      height: 8,
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  // Circle number badge
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: selected
                          ? (isCity ? AppColors.primary : AppColors.accent)
                          : (isCity ? AppColors.primary : AppColors.accent)
                              .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isCity ? 'C' : '$orderNumber',
                      style: AppTypography.caption.copyWith(
                        color: selected
                            ? Colors.white
                            : (isCity ? AppColors.primary : AppColors.accent),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Bottom connector line
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 8,
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Place/City icon
            Icon(
              isCity ? Icons.location_city : Icons.place,
              size: 18,
              color: selected
                  ? (isCity ? AppColors.primary : AppColors.accent)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Drag handle
            Icon(
              Icons.drag_handle,
              size: 18,
              color: AppColors.divider,
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact route connector shown between two place items in the timeline.
class TimelineRouteConnector extends StatelessWidget {
  const TimelineRouteConnector({
    super.key,
    required this.transportMode,
    this.distance,
    this.duration,
    this.waypointCount = 0,
    required this.selected,
    required this.onTap,
  });

  final String transportMode;
  final double? distance;
  final int? duration;
  final int waypointCount;
  final bool selected;
  final VoidCallback onTap;

  IconData get _transportIcon {
    switch (transportMode) {
      case 'bike':
        return Icons.directions_bike;
      case 'foot':
      case 'walk':
        return Icons.directions_walk;
      case 'air':
        return Icons.flight;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final distanceStr =
        distance != null ? '${distance!.toStringAsFixed(1)} km' : '';
    final durationStr = duration != null ? '${duration} min' : '';
    final waypointStr = waypointCount > 0 ? '$waypointCount wp' : '';
    final label = [distanceStr, durationStr, waypointStr]
        .where((s) => s.isNotEmpty)
        .join(' - ');

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            // Connector area - dashed vertical line
            SizedBox(
              width: 32,
              height: 28,
              child: Center(
                child: CustomPaint(
                  size: const Size(2, 28),
                  painter: _DashedLinePainter(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Route info
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentSoft
                      : AppColors.surface,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _transportIcon,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    if (label.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          label,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Day header shown above a group of timeline items.
class TimelineDayHeader extends StatelessWidget {
  const TimelineDayHeader({
    super.key,
    required this.dayNumber,
  });

  final int dayNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        'Day $dayNumber',
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Paints a dashed vertical line.
class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const gapHeight = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dashHeight).clamp(0, size.height)),
        paint,
      );
      y += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color;
}
