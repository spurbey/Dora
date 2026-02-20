import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/place.dart';

class RouteCreatorForm extends StatelessWidget {
  const RouteCreatorForm({
    super.key,
    required this.mode,
    required this.places,
    required this.sourceId,
    required this.destinationId,
    required this.onSourceChanged,
    required this.onDestinationChanged,
    required this.onCreateRoute,
    required this.onCancel,
    required this.isLoading,
  });

  final EditorMode mode;
  final List<Place> places;
  final String? sourceId;
  final String? destinationId;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<String?> onDestinationChanged;
  final VoidCallback onCreateRoute;
  final VoidCallback onCancel;
  final bool isLoading;

  List<Place> get _filteredPlaces {
    // Air routes only between cities
    if (mode == EditorMode.addRouteAir) {
      return places.where((p) => p.placeType == 'city').toList();
    }
    return places;
  }

  @override
  Widget build(BuildContext context) {
    final eligible = _filteredPlaces;
    final destEligible =
        eligible.where((p) => p.id != sourceId).toList();

    final hasValidSource = sourceId != null && eligible.any((p) => p.id == sourceId);
    final hasValidDestination =
        destinationId != null && destEligible.any((p) => p.id == destinationId);
    final canCreate =
        hasValidSource && hasValidDestination && !isLoading;

    return SingleChildScrollView(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transport badge
          _TransportBadge(mode: mode),
          const SizedBox(height: AppSpacing.md),

          // From dropdown
          Text('From', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          _PlaceDropdown(
            value: sourceId,
            places: eligible,
            hint: 'Select starting point',
            onChanged: onSourceChanged,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Arrow separator
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Icon(
                Icons.arrow_downward,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // To dropdown
          Text('To', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          _PlaceDropdown(
            value: destinationId,
            places: destEligible,
            hint: 'Select destination',
            onChanged: onDestinationChanged,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Map tap hint
          Row(
            children: [
              Icon(
                Icons.touch_app,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Or tap a marker on the map',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Loading indicator
          if (isLoading)
            const LinearProgressIndicator()
          else
            const SizedBox.shrink(),
          const SizedBox(height: AppSpacing.md),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: isLoading ? null : onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: canCreate ? onCreateRoute : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  disabledBackgroundColor:
                      AppColors.accent.withValues(alpha: 0.4),
                ),
                child: const Text('Create Route'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransportBadge extends StatelessWidget {
  const _TransportBadge({required this.mode});

  final EditorMode mode;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (mode) {
      EditorMode.addRouteAir => (
          Icons.flight,
          'Flight',
          const Color(0xFF4F46E5)
        ),
      EditorMode.addRouteWalking => (
          Icons.directions_walk,
          'Walking',
          const Color(0xFFB96B2B)
        ),
      _ => (Icons.directions_car, 'Driving', AppColors.accent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceDropdown extends StatelessWidget {
  const _PlaceDropdown({
    required this.value,
    required this.places,
    required this.hint,
    required this.onChanged,
  });

  final String? value;
  final List<Place> places;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Ensure value is valid in the current list (avoid DropdownButton assertion)
    final validValue = places.any((p) => p.id == value) ? value : null;

    return DropdownButtonFormField<String>(
      value: validValue,
      hint: Text(hint, style: AppTypography.caption),
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
        isDense: true,
      ),
      items: places
          .map(
            (p) => DropdownMenuItem<String>(
              value: p.id,
              child: Text(
                p.name,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
