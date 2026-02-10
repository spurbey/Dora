import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/app_map_view.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/presentation/widgets/floating_tool_panel.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({
    super.key,
    required this.initialCenter,
    required this.initialZoom,
    required this.markers,
    required this.routes,
    required this.mode,
    required this.onModeChanged,
    required this.onMapCreated,
    required this.onMapTap,
    this.onRouteTap,
    this.routeStartPlaceId,
  });

  final AppLatLng initialCenter;
  final double initialZoom;
  final List<AppMarker> markers;
  final List<AppRoute> routes;
  final EditorMode mode;
  final ValueChanged<EditorMode> onModeChanged;
  final ValueChanged<AppMapController> onMapCreated;
  final ValueChanged<AppLatLng> onMapTap;
  final ValueChanged<String>? onRouteTap;
  final String? routeStartPlaceId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map base
        AppMapView(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          markers: markers,
          routes: routes,
          onMapCreated: onMapCreated,
          onMapTap: onMapTap,
          onRouteTap: onRouteTap,
          showUserLocation: true,
        ),
        // Floating tool panel — top right
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: FloatingToolPanel(
            currentMode: mode,
            onToolSelected: onModeChanged,
          ),
        ),
        // Route drawing instruction — bottom center (doesn't overlap tools)
        if (mode == EditorMode.drawRoute)
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Center(
              child: ClipRRect(
                borderRadius: AppRadius.borderMd,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card.withValues(alpha: 0.9),
                      borderRadius: AppRadius.borderMd,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 12,
                          offset: Offset(0, 4),
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          routeStartPlaceId != null
                              ? Icons.flag
                              : Icons.touch_app,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            routeStartPlaceId != null
                                ? 'Great! Now tap the destination'
                                : 'Tap a place to start the route',
                            style: AppTypography.body.copyWith(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        TextButton(
                          onPressed: () => onModeChanged(EditorMode.view),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
