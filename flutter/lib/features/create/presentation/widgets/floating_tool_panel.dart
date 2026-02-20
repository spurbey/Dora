import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';

class FloatingToolPanel extends StatefulWidget {
  const FloatingToolPanel({
    super.key,
    required this.currentMode,
    required this.onToolSelected,
  });

  final EditorMode currentMode;
  final ValueChanged<EditorMode> onToolSelected;

  @override
  State<FloatingToolPanel> createState() => _FloatingToolPanelState();
}

class _FloatingToolPanelState extends State<FloatingToolPanel> {
  bool _routeMenuOpen = false;

  bool get _isRouteActive =>
      widget.currentMode == EditorMode.addRouteCar ||
      widget.currentMode == EditorMode.addRouteAir ||
      widget.currentMode == EditorMode.addRouteWalking;

  @override
  void didUpdateWidget(FloatingToolPanel old) {
    super.didUpdateWidget(old);
    final wasRoute = _isRouteMode(old.currentMode);
    final isRoute = _isRouteMode(widget.currentMode);
    // Auto-open sub-menu when entering route mode (e.g. from timeline "Draw Route")
    if (!wasRoute && isRoute) {
      setState(() => _routeMenuOpen = true);
    }
    // Auto-close when leaving route mode
    if (wasRoute && !isRoute) {
      setState(() => _routeMenuOpen = false);
    }
  }

  void _handleRouteTap() {
    if (_isRouteActive) {
      // Cancel route mode
      widget.onToolSelected(EditorMode.view);
    } else {
      setState(() => _routeMenuOpen = !_routeMenuOpen);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                active: widget.currentMode == EditorMode.addCity,
                onTap: () => widget.onToolSelected(EditorMode.addCity),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolIcon(
                icon: Icons.add_location_alt,
                label: 'Place',
                active: widget.currentMode == EditorMode.addPlace,
                onTap: () => widget.onToolSelected(EditorMode.addPlace),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Route button + expandable sub-menu
              _ToolIcon(
                icon: Icons.route,
                label: 'Route',
                active: _isRouteActive,
                onTap: _handleRouteTap,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: _routeMenuOpen || _isRouteActive
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: AppSpacing.xs),
                          _SubToolIcon(
                            icon: Icons.flight,
                            label: 'Air',
                            active: widget.currentMode == EditorMode.addRouteAir,
                            onTap: () => widget.onToolSelected(EditorMode.addRouteAir),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _SubToolIcon(
                            icon: Icons.directions_car,
                            label: 'Car',
                            active: widget.currentMode == EditorMode.addRouteCar,
                            onTap: () => widget.onToolSelected(EditorMode.addRouteCar),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          _SubToolIcon(
                            icon: Icons.directions_walk,
                            label: 'Walk',
                            active:
                                widget.currentMode == EditorMode.addRouteWalking,
                            onTap: () =>
                                widget.onToolSelected(EditorMode.addRouteWalking),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ToolIcon(
                icon: Icons.explore_outlined,
                label: 'View',
                active: widget.currentMode == EditorMode.view,
                onTap: () => widget.onToolSelected(EditorMode.view),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isRouteMode(EditorMode mode) =>
    mode == EditorMode.addRouteCar ||
    mode == EditorMode.addRouteAir ||
    mode == EditorMode.addRouteWalking;

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

/// Smaller sub-tool icon for the route type sub-menu.
class _SubToolIcon extends StatelessWidget {
  const _SubToolIcon({
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.accent : AppColors.divider,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: active ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
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
