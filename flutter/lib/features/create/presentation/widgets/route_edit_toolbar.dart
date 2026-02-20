import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';

class RouteEditToolbar extends StatelessWidget {
  const RouteEditToolbar({
    super.key,
    required this.currentMode,
    required this.onToggleEdit,
    required this.onFlip,
    required this.onDelete,
    required this.onClose,
  });

  final EditorMode currentMode;
  final VoidCallback onToggleEdit;
  final VoidCallback onFlip;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  bool get _editActive => currentMode == EditorMode.editRoute;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.borderLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: AppSpacing.sm,
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
              _ToolButton(
                icon: Icons.edit,
                label: 'Edit',
                active: _editActive,
                onTap: onToggleEdit,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolButton(
                icon: Icons.swap_vert,
                label: 'Flip',
                active: false,
                onTap: onFlip,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                active: false,
                activeColor: AppColors.error,
                onTap: onDelete,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolButton(
                icon: Icons.close,
                label: 'Close',
                active: false,
                onTap: onClose,
              ),
              if (_editActive) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: 56,
                  child: Text(
                    'Tap line · Drag to move',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: active
                  ? null
                  : Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: Icon(
              icon,
              size: 20,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: active ? color : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
