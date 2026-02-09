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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
        Container(
          color: Colors.black.withOpacity(0.1),
        ),
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: FloatingToolPanel(
            currentMode: mode,
            onToolSelected: onModeChanged,
          ),
        ),
        if (mode == EditorMode.drawRoute)
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.9),
                borderRadius: AppRadius.borderMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tap places to connect', style: AppTypography.body),
                  TextButton(
                    onPressed: () => onModeChanged(EditorMode.view),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
