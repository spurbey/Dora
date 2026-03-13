import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';

/// Bottom strip shown during route creation in Route Studio.
/// Transport mode pills + place chip selectors for start/end.
class RouteCreationStrip extends StatelessWidget {
  const RouteCreationStrip({
    super.key,
    required this.mode,
    required this.sourceName,
    required this.destinationName,
    required this.isLoading,
    required this.canCreate,
    required this.onModeChanged,
    required this.onPickSource,
    required this.onPickDestination,
    required this.onCreateRoute,
    required this.onCancel,
  });

  final EditorMode mode;
  final String? sourceName;
  final String? destinationName;
  final bool isLoading;
  final bool canCreate;
  final ValueChanged<EditorMode> onModeChanged;
  final VoidCallback onPickSource;
  final VoidCallback onPickDestination;
  final VoidCallback onCreateRoute;
  final VoidCallback onCancel;

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
                  _buildTransportRow(),
                  const SizedBox(height: AppSpacing.md),
                  _buildPlaceRow(),
                  if (isLoading) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _buildActionRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransportRow() {
    return Row(
      children: [
        Text(
          'New Route',
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _TransportPill(
          icon: Icons.directions_car,
          label: 'Drive',
          selected: mode == EditorMode.addRouteCar,
          onTap: () => onModeChanged(EditorMode.addRouteCar),
        ),
        const SizedBox(width: AppSpacing.xs),
        _TransportPill(
          icon: Icons.directions_walk,
          label: 'Walk',
          selected: mode == EditorMode.addRouteWalking,
          onTap: () => onModeChanged(EditorMode.addRouteWalking),
        ),
        const SizedBox(width: AppSpacing.xs),
        _TransportPill(
          icon: Icons.flight,
          label: 'Fly',
          selected: mode == EditorMode.addRouteAir,
          onTap: () => onModeChanged(EditorMode.addRouteAir),
        ),
      ],
    );
  }

  Widget _buildPlaceRow() {
    return Row(
      children: [
        Expanded(
          child: _PlaceChip(
            label: sourceName ?? 'Pick start',
            hasValue: sourceName != null,
            icon: Icons.trip_origin,
            color: const Color(0xFF2E7D32),
            onTap: onPickSource,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(
            Icons.arrow_forward,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: _PlaceChip(
            label: destinationName ?? 'Pick end',
            hasValue: destinationName != null,
            icon: Icons.place,
            color: const Color(0xFFC62828),
            onTap: onPickDestination,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Or tap markers on map',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: canCreate && !isLoading ? onCreateRoute : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
            ),
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _TransportPill extends StatelessWidget {
  const _TransportPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({
    required this.label,
    required this.hasValue,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool hasValue;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: hasValue
              ? color.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: hasValue
                ? color.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: hasValue ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
