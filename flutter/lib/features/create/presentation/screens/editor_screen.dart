import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/editor_state.dart';
import 'package:dora/features/create/domain/map_state.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/create/presentation/providers/map_provider.dart';
import 'package:dora/features/create/presentation/widgets/bottom_detail_panel.dart';
import 'package:dora/features/create/presentation/widgets/city_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/editor_header.dart';
import 'package:dora/features/create/presentation/widgets/map_canvas.dart';
import 'package:dora/features/create/presentation/widgets/place_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/route_creator_form.dart';
import 'package:dora/features/create/presentation/widgets/route_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/route_edit_toolbar.dart';
import 'package:dora/features/create/presentation/widgets/timeline_sidebar.dart';
import 'package:dora/shared/widgets/confirmation_dialog.dart';
import 'package:dora/shared/widgets/error_view.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    final editorAsync = ref.watch(editorControllerProvider(widget.tripId));

    ref.listen(editorControllerProvider(widget.tripId), (prev, next) {
      final prevMode = prev?.valueOrNull?.mode;
      final nextMode = next.valueOrNull?.mode;

      if (nextMode == EditorMode.addPlace &&
          prevMode != EditorMode.addPlace) {
        _openPlaceSearch();
      }

      if (nextMode == EditorMode.addCity &&
          prevMode != EditorMode.addCity) {
        _openCitySearch();
      }
    });

    return editorAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: ErrorView(
          message: 'Failed to load editor',
          onRetry: () =>
              ref.invalidate(editorControllerProvider(widget.tripId)),
        ),
      ),
      data: (editor) {
        final mapState = ref.watch(mapStateProvider(widget.tripId));
        final controller =
            ref.read(editorControllerProvider(widget.tripId).notifier);

        final mediaQuery = MediaQuery.of(context);
        final isWide = mediaQuery.size.width >= 900;
        final initialCenter =
            mapState.center ?? const AppLatLng(latitude: 0, longitude: 0);
        final initialZoom = mapState.zoom ?? 12.0;

        final selectedName = _getSelectedItemName(editor);
        final selectedIcon = _getSelectedItemIcon(editor);

        final showFab = !isWide && !editor.bottomPanelExpanded;

        return WillPopScope(
          onWillPop: () => _handleBack(editor.saving),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  EditorHeader(
                    tripName: editor.trip.name,
                    saving: editor.saving,
                    onBack: () => _handleBack(editor.saving).then((value) {
                      if (value && mounted) {
                        context.go(Routes.trips);
                      }
                    }),
                    onNameChanged: controller.updateTripName,
                    onExport: () {},
                    onMore: () {},
                  ),
                  Expanded(
                    child: isWide
                        ? _buildWideLayout(
                            editor, mapState, controller,
                            initialCenter, initialZoom,
                            selectedName, selectedIcon)
                        : _buildMobileLayout(
                            editor, mapState, controller,
                            initialCenter, initialZoom,
                            selectedName, selectedIcon),
                  ),
                ],
              ),
            ),
            floatingActionButton: showFab
                ? _buildMobileFab(editor, controller)
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
          ),
        );
      },
    );
  }

  Widget _buildMobileFab(EditorState editor, EditorController controller) {
    if (editor.places.isEmpty) {
      return FloatingActionButton.extended(
        onPressed: () => controller.setMode(EditorMode.addCity),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt, size: 20),
        label: const Text('Add Destination'),
      );
    }
    return FloatingActionButton(
      onPressed: () => _showTimelineSheet(editor, controller),
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      child: const Icon(Icons.timeline),
    );
  }

  String? _getSelectedItemName(EditorState editor) {
    if (editor.selectedItemType == 'place' && editor.selectedItemId != null) {
      try {
        final place = editor.places
            .firstWhere((p) => p.id == editor.selectedItemId);
        if (place.placeType == 'city') {
          return '${place.name} (City)';
        }
        return place.name;
      } catch (_) {
        return null;
      }
    }
    if (editor.selectedItemType == 'route' && editor.selectedItemId != null) {
      try {
        final route = editor.routes
            .firstWhere((r) => r.id == editor.selectedItemId);
        return route.name ?? 'Route';
      } catch (_) {
        return 'Route';
      }
    }
    return null;
  }

  IconData? _getSelectedItemIcon(EditorState editor) {
    if (editor.selectedItemType == 'place' && editor.selectedItemId != null) {
      try {
        final place = editor.places
            .firstWhere((p) => p.id == editor.selectedItemId);
        return place.placeType == 'city'
            ? Icons.location_city
            : Icons.place;
      } catch (_) {
        return Icons.place;
      }
    }
    if (editor.selectedItemType == 'route') return Icons.route;
    return null;
  }

  bool _isAnyRouteMode(EditorMode mode) =>
      mode == EditorMode.addRouteAir ||
      mode == EditorMode.addRouteCar ||
      mode == EditorMode.addRouteWalking;

  Widget _buildWideLayout(
    EditorState editor,
    MapState mapState,
    EditorController controller,
    AppLatLng initialCenter,
    double initialZoom,
    String? selectedName,
    IconData? selectedIcon,
  ) {
    final showPanel =
        editor.selectedItemId != null || _isAnyRouteMode(editor.mode);
    return Row(
      children: [
        TimelineSidebar(
          places: editor.places,
          routes: editor.routes,
          selectedItemId: editor.selectedItemId,
          selectedItemType: editor.selectedItemType,
          onItemTap: (id, type) {
            if (type == 'place') {
              controller.handlePlaceTap(id);
            } else {
              controller.selectRoute(id);
            }
          },
          onReorder: controller.reorderPlaces,
          onAddPlace: () => controller.setMode(EditorMode.addPlace),
          onAddCity: () => controller.setMode(EditorMode.addCity),
          onAddRoute: () => controller.startDrawingRoute(),
        ),
        Expanded(
          child: Stack(
            children: [
              MapCanvas(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                markers: mapState.markers,
                routes: mapState.routes,
                mode: editor.mode,
                routeStartItemId: editor.routeStartItemId,
                onModeChanged: controller.setMode,
                onMapCreated: controller.setMapController,
                onMapTap: controller.handleMapTap,
                onRouteTap: controller.selectRoute,
              ),
              if (showPanel)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomDetailPanel(
                    expanded: _isAnyRouteMode(editor.mode)
                        ? true
                        : editor.bottomPanelExpanded,
                    onToggle: controller.toggleBottomPanel,
                    selectedItemName: _isAnyRouteMode(editor.mode)
                        ? _routeModeName(editor.mode)
                        : selectedName,
                    selectedItemIcon: _isAnyRouteMode(editor.mode)
                        ? Icons.route
                        : selectedIcon,
                    child: _buildDetailContent(editor, controller),
                  ),
                ),
              // Route edit toolbar — shown when a route is selected
              if (editor.selectedItemType == 'route' &&
                  editor.selectedItemId != null &&
                  !_isAnyRouteMode(editor.mode))
                Positioned(
                  right: AppSpacing.md,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: RouteEditToolbar(
                      currentMode: editor.mode,
                      onToggleEdit: () =>
                          controller.toggleRouteEditMode(editor.selectedItemId!),
                      onFlip: () => controller.flipRoute(editor.selectedItemId!),
                      onDelete: () =>
                          controller.removeRoute(editor.selectedItemId!),
                      onClose: controller.deselectAll,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    EditorState editor,
    MapState mapState,
    EditorController controller,
    AppLatLng initialCenter,
    double initialZoom,
    String? selectedName,
    IconData? selectedIcon,
  ) {
    final showPanel =
        editor.selectedItemId != null || _isAnyRouteMode(editor.mode);
    return Stack(
      children: [
        MapCanvas(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          markers: mapState.markers,
          routes: mapState.routes,
          mode: editor.mode,
          routeStartItemId: editor.routeStartItemId,
          onModeChanged: controller.setMode,
          onMapCreated: controller.setMapController,
          onMapTap: controller.handleMapTap,
          onRouteTap: controller.selectRoute,
        ),
        if (showPanel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomDetailPanel(
              expanded: _isAnyRouteMode(editor.mode)
                  ? true
                  : editor.bottomPanelExpanded,
              onToggle: controller.toggleBottomPanel,
              selectedItemName: _isAnyRouteMode(editor.mode)
                  ? _routeModeName(editor.mode)
                  : selectedName,
              selectedItemIcon: _isAnyRouteMode(editor.mode)
                  ? Icons.route
                  : selectedIcon,
              child: _buildDetailContent(editor, controller),
            ),
          ),
        // Route edit toolbar — shown when a route is selected
        if (editor.selectedItemType == 'route' &&
            editor.selectedItemId != null &&
            !_isAnyRouteMode(editor.mode))
          Positioned(
            right: AppSpacing.md,
            bottom: 120,
            child: RouteEditToolbar(
              currentMode: editor.mode,
              onToggleEdit: () =>
                  controller.toggleRouteEditMode(editor.selectedItemId!),
              onFlip: () => controller.flipRoute(editor.selectedItemId!),
              onDelete: () => controller.removeRoute(editor.selectedItemId!),
              onClose: controller.deselectAll,
            ),
          ),
      ],
    );
  }

  String _routeModeName(EditorMode mode) => switch (mode) {
        EditorMode.addRouteAir => 'Flight Path',
        EditorMode.addRouteWalking => 'Walking Route',
        _ => 'Driving Route',
      };

  void _showTimelineSheet(
    EditorState editor,
    EditorController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              height: 24,
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: TimelineSidebar(
                width: double.infinity,
                places: editor.places,
                routes: editor.routes,
                selectedItemId: editor.selectedItemId,
                selectedItemType: editor.selectedItemType,
                onItemTap: (id, type) {
                  Navigator.pop(context);
                  if (type == 'place') {
                    controller.handlePlaceTap(id);
                  } else {
                    controller.selectRoute(id);
                  }
                },
                onReorder: controller.reorderPlaces,
                onAddPlace: () {
                  Navigator.pop(context);
                  controller.setMode(EditorMode.addPlace);
                },
                onAddCity: () {
                  Navigator.pop(context);
                  controller.setMode(EditorMode.addCity);
                },
                onAddRoute: () {
                  Navigator.pop(context);
                  controller.startDrawingRoute();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPlaceSearch() async {
    if (!mounted) {
      return;
    }
    await context.push(Routes.placeSearchPath(widget.tripId));
    if (mounted) {
      ref
          .read(editorControllerProvider(widget.tripId).notifier)
          .setMode(EditorMode.view);
    }
  }

  Future<void> _openCitySearch() async {
    if (!mounted) {
      return;
    }
    await context.push(Routes.citySearchPath(widget.tripId));
    if (mounted) {
      ref
          .read(editorControllerProvider(widget.tripId).notifier)
          .setMode(EditorMode.view);
    }
  }

  String? _findPlaceName(List<Place> places, String? id) {
    if (id == null) return null;
    try {
      return places.firstWhere((p) => p.id == id).name;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _handleBack(bool saving) async {
    if (!saving) {
      return true;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Leave editor?',
        message: 'Saving in progress...',
        confirmText: 'Leave',
        cancelText: 'Stay',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    return result ?? false;
  }

  Widget? _buildDetailContent(
    EditorState editor,
    EditorController controller,
  ) {
    // Route creator form takes priority when in any route drawing mode
    if (_isAnyRouteMode(editor.mode)) {
      return RouteCreatorForm(
        mode: editor.mode,
        places: editor.places,
        sourceId: editor.routeStartItemId,
        destinationId: editor.routeEndItemId,
        onSourceChanged: controller.selectRouteSource,
        onDestinationChanged: controller.selectRouteDestination,
        onCreateRoute: () => controller.drawRoute(
          editor.routeStartItemId!,
          editor.routeEndItemId!,
          capturedMode: editor.mode,
        ),
        onCancel: controller.cancelRouteMode,
        isLoading: editor.isGeneratingRoute,
      );
    }

    final type = editor.selectedItemType;
    final id = editor.selectedItemId;
    final places = editor.places;
    final routes = editor.routes;

    if (type == 'place' && id != null) {
      try {
        final place = places.firstWhere((item) => item.id == id);
        if (place.placeType == 'city') {
          return CityDetailForm(
            city: place,
            onSave: controller.updatePlace,
            onDelete: () => controller.removePlace(place.id),
          );
        }
        return PlaceDetailForm(
          place: place,
          onSave: controller.updatePlace,
          onDelete: () => controller.removePlace(place.id),
        );
      } catch (_) {
        return null;
      }
    }

    if (type == 'route' && id != null) {
      try {
        final route = routes.firstWhere((item) => item.id == id);
        final startName = _findPlaceName(places, route.startPlaceId);
        final endName = _findPlaceName(places, route.endPlaceId);
        return RouteDetailForm(
          route: route,
          onSave: controller.updateRoute,
          onDelete: () => controller.removeRoute(route.id),
          startPlaceName: startName,
          endPlaceName: endName,
        );
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}
