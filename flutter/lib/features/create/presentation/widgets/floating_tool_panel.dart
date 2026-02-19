import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';

class FloatingToolPanel extends StatelessWidget {
  const FloatingToolPanel({
    super.key,
    required this.currentMode,
    required this.onToolSelected,
  });

  final EditorMode currentMode;
  final ValueChanged<EditorMode> onToolSelected;

  @override
  Widget build(BuildContext context) {
    final isRouteActive = currentMode == EditorMode.addRouteCar ||
        currentMode == EditorMode.addRouteAir ||
        currentMode == EditorMode.addRouteWalking;

    return ClipRRect(
      borderRadius: AppRadius.borderLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.85),
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.divider),
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 6),
                color: Colors.black26,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToolIcon(
                icon: Icons.location_city,
                label: 'City',
                active: currentMode == EditorMode.addCity,
                onTap: () => onToolSelected(EditorMode.addCity),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolIcon(
                icon: Icons.add_location_alt,
                label: 'Place',
                active: currentMode == EditorMode.addPlace,
                onTap: () => onToolSelected(EditorMode.addPlace),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolIcon(
                icon: Icons.route,
                label: 'Route',
                active: isRouteActive,
                onTap: () => onToolSelected(EditorMode.addRouteCar),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolIcon(
                icon: Icons.explore_outlined,
                label: 'View',
                active: currentMode == EditorMode.view,
                onTap: () => onToolSelected(EditorMode.view),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? AppColors.accent : Colors.transparent,
              shape: BoxShape.circle,
              border: active
                  ? null
                  : Border.all(
                      color: AppColors.divider,
                      width: 1.5,
                    ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: active ? AppColors.accent : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
