import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class RouteControlStrip extends StatelessWidget {
  const RouteControlStrip({
    super.key,
    required this.transportMode,
    required this.startName,
    required this.endName,
    this.distanceKm,
    this.durationMins,
    required this.isEditMode,
    required this.waypointCount,
    required this.onToggleEdit,
    required this.onOpenWaypoints,
    required this.onFlip,
    required this.onOpenDetails,
    required this.onDelete,
    required this.onClose,
  });

  final String transportMode;
  final String startName;
  final String endName;
  final double? distanceKm;
  final int? durationMins;
  final bool isEditMode;
  final int waypointCount;
  final VoidCallback onToggleEdit;
  final VoidCallback onOpenWaypoints;
  final VoidCallback onFlip;
  final VoidCallback onOpenDetails;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  IconData get _transportIcon => switch (transportMode) {
        'air' => Icons.flight,
        'foot' || 'walk' || 'walking' => Icons.directions_walk,
        'bike' || 'cycling' => Icons.directions_bike,
        _ => Icons.directions_car,
      };

  String get _distanceText {
    if (distanceKm == null) return '--';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  String get _durationText {
    if (durationMins == null) return '--';
    if (durationMins! < 60) return '${durationMins}m';
    final h = durationMins! ~/ 60;
    final m = durationMins! % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.92),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 24,
                offset: Offset(0, -4),
                color: Colors.black12,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow(context),
                  const SizedBox(height: AppSpacing.sm),
                  _buildActionRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      children: [
        Icon(_transportIcon, size: 20, color: AppColors.accent),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '$startName  \u2192  $endName',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$_distanceText  \u00B7  $_durationText',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _CloseButton(onTap: onClose),
      ],
    );
  }

  Widget _buildActionRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionChip(
            icon: Icons.edit,
            label: 'Edit',
            active: isEditMode,
            onTap: onToggleEdit,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionChip(
            icon: Icons.add_location_alt,
            label: waypointCount > 0
                ? 'Waypoints ($waypointCount)'
                : 'Waypoints',
            onTap: onOpenWaypoints,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionChip(
            icon: Icons.swap_horiz,
            label: 'Flip',
            onTap: onFlip,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionChip(
            icon: Icons.info_outline,
            label: 'Details',
            onTap: onOpenDetails,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionChip(
            icon: Icons.delete_outline,
            label: 'Delete',
            destructive: true,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
        ),
        child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    final Color bg;
    final Color border;

    if (active) {
      fg = Colors.white;
      bg = AppColors.accent;
      border = AppColors.accent;
    } else if (destructive) {
      fg = AppColors.error;
      bg = AppColors.error.withValues(alpha: 0.08);
      border = AppColors.error.withValues(alpha: 0.25);
    } else {
      fg = AppColors.textPrimary;
      bg = AppColors.surface;
      border = AppColors.divider;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
