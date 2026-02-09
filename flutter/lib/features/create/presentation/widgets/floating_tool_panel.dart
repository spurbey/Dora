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
    return Container(
      padding: AppSpacing.allSm,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.95),
        borderRadius: AppRadius.borderLg,
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        children: [
          _ToolButton(
            label: 'Add',
            icon: Icons.add,
            selected: currentMode == EditorMode.addPlace,
            onTap: () => onToolSelected(EditorMode.addPlace),
          ),
          _ToolButton(
            label: 'Edit',
            icon: Icons.edit,
            selected: currentMode == EditorMode.editItem,
            onTap: () => onToolSelected(EditorMode.editItem),
          ),
          _ToolButton(
            label: 'Places',
            icon: Icons.place,
            selected: currentMode == EditorMode.addPlace,
            onTap: () => onToolSelected(EditorMode.addPlace),
          ),
          _ToolButton(
            label: 'Routes',
            icon: Icons.route,
            selected: currentMode == EditorMode.drawRoute,
            onTap: () => onToolSelected(EditorMode.drawRoute),
          ),
          _ToolButton(
            label: 'Media',
            icon: Icons.photo_camera,
            selected: false,
            onTap: () {},
            disabled: true,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: disabled ? AppColors.divider : color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: disabled ? AppColors.divider : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
