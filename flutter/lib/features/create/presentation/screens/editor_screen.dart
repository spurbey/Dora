import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/create/presentation/providers/map_provider.dart';
import 'package:dora/features/create/presentation/widgets/bottom_detail_panel.dart';
import 'package:dora/features/create/presentation/widgets/editor_header.dart';
import 'package:dora/features/create/presentation/widgets/map_canvas.dart';
import 'package:dora/features/create/presentation/widgets/place_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/route_detail_form.dart';
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

        final isWide = MediaQuery.of(context).size.width >= 900;
        final initialCenter =
            mapState.center ?? const AppLatLng(latitude: 0, longitude: 0);
        final initialZoom = mapState.zoom ?? 12.0;

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
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            if (isWide)
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
                                onAddPlace: () =>
                                    controller.setMode(EditorMode.addPlace),
                              ),
                            Expanded(
                              child: MapCanvas(
                                initialCenter: initialCenter,
                                initialZoom: initialZoom,
                                markers: mapState.markers,
                                routes: mapState.routes,
                                mode: editor.mode,
                                onModeChanged: controller.setMode,
                                onMapCreated: controller.setMapController,
                                onMapTap: (_) => controller.deselectAll(),
                                onRouteTap: controller.selectRoute,
                              ),
                            ),
                          ],
                        ),
                        if (!isWide)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 72,
                            child: TimelineSidebar(
                              width: MediaQuery.of(context).size.width,
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
                              onAddPlace: () =>
                                  controller.setMode(EditorMode.addPlace),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: BottomDetailPanel(
                            expanded: editor.bottomPanelExpanded,
                            onToggle: controller.toggleBottomPanel,
                            child: _buildDetailContent(
                              editor.selectedItemType,
                              editor.selectedItemId,
                              editor.places,
                              editor.routes,
                              controller,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    String? type,
    String? id,
    List<Place> places,
    List<create_route.Route> routes,
    EditorController controller,
  ) {
    if (type == 'place' && id != null) {
      final place = places.firstWhere((item) => item.id == id);
      return PlaceDetailForm(
        place: place,
        onSave: controller.updatePlace,
        onDelete: () => controller.removePlace(place.id),
      );
    }

    if (type == 'route' && id != null) {
      final route = routes.firstWhere((item) => item.id == id);
      return RouteDetailForm(
        route: route,
        onSave: controller.updateRoute,
        onDelete: () => controller.removeRoute(route.id),
      );
    }

    return null;
  }
}
