import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/config/feature_flags.dart';
import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/editor_state.dart';
import 'package:dora/features/create/domain/map_state.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/data/live_tracking_capture_coordinator.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/create/presentation/providers/entity_sync_provider.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_runtime_provider.dart';
import 'package:dora/features/create/presentation/providers/map_provider.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';
import 'package:dora/features/create/presentation/providers/place_media_provider.dart';
import 'package:dora/features/create/presentation/widgets/bottom_detail_panel.dart';
import 'package:dora/features/create/presentation/widgets/city_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/editor_header.dart';
import 'package:dora/features/create/presentation/widgets/live_tracking_control_strip.dart';
import 'package:dora/features/create/presentation/widgets/map_canvas.dart';
import 'package:dora/features/create/presentation/widgets/place_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/place_picker_sheet.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/route_control_strip.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/route_creation_strip.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/route_details_sheet.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/waypoint_sheet.dart';
import 'package:dora/features/create/presentation/widgets/timeline_sidebar.dart';
import 'package:dora/features/create/presentation/widgets/media_attachment_viewer.dart';
import 'package:dora/shared/widgets/confirmation_dialog.dart';
import 'package:dora/shared/widgets/error_view.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  AppLatLng? _deviceCenter;
  bool _didAutoCenterOnDevice = false;
  AppMarker? _mediaFocusMarker;
  String? _mediaFocusPlaceId;
  bool _trackingActionInFlight = false;
  String? _trackingActionLabel;
  static const _defaultEditorCenter = AppLatLng(
    latitude: 20.5937,
    longitude: 78.9629,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveDeviceCenter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorAsync = ref.watch(editorControllerProvider(widget.tripId));

    ref.listen(editorControllerProvider(widget.tripId), (prev, next) {
      final prevMode = prev?.valueOrNull?.mode;
      final nextMode = next.valueOrNull?.mode;

      _maybeCenterMapOnDevice(next.valueOrNull);
      _syncMediaFocusWithSelection(next.valueOrNull);

      if (nextMode == EditorMode.addPlace && prevMode != EditorMode.addPlace) {
        _openPlaceSearch();
      }

      if (nextMode == EditorMode.addCity && prevMode != EditorMode.addCity) {
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
        final syncStatusAsync =
            ref.watch(editorSyncStatusProvider(widget.tripId));
        final trackingRuntimeAsync =
            ref.watch(liveTrackingRuntimeSnapshotProvider(widget.tripId));
        final controller =
            ref.read(editorControllerProvider(widget.tripId).notifier);
        final (syncStatusLabel, syncStatusColor) = _resolveHeaderSyncStatus(
          savingLocally: editor.saving,
          syncStatusAsync: syncStatusAsync,
        );
        final syncCallout = _resolveEditorSyncCallout(
          syncStatusAsync: syncStatusAsync,
          controller: controller,
        );

        final mediaQuery = MediaQuery.of(context);
        final isWide = mediaQuery.size.width >= 900;
        final initialCenter =
            mapState.center ?? _deviceCenter ?? _defaultEditorCenter;
        final initialZoom = mapState.zoom ?? 12.0;
        final markers = _mediaFocusMarker == null
            ? mapState.markers
            : [...mapState.markers, _mediaFocusMarker!];

        final selectedName = _getSelectedItemName(editor);
        final selectedIcon = _getSelectedItemIcon(editor);
        final selectedPlaceId =
            editor.selectedItemType == 'place' ? editor.selectedItemId : null;
        final pendingMediaCount = selectedPlaceId == null
            ? 0
            : ref
                .watch(placePendingUploadCountProvider(selectedPlaceId))
                .maybeWhen(
                  data: (count) => count,
                  orElse: () => 0,
                );

        final showFab = !isWide &&
            !editor.bottomPanelExpanded &&
            !editor.routeStudioActive &&
            !_isAnyRouteMode(editor.mode);

        return WillPopScope(
          onWillPop: () => _handleBack(editor.saving),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  EditorHeader(
                    tripName: editor.trip.name,
                    syncStatusLabel: syncStatusLabel,
                    syncStatusColor: syncStatusColor,
                    onBack: () => _handleBack(editor.saving).then((value) {
                      if (value && mounted) {
                        context.go(Routes.trips);
                      }
                    }),
                    onNameChanged: controller.updateTripName,
                    onExport: _openExportStudio,
                    onMore: () {},
                  ),
                  if (syncCallout != null) _buildSyncCallout(syncCallout),
                  _buildLiveTrackingControlStrip(trackingRuntimeAsync),
                  Expanded(
                    child: isWide
                        ? _buildWideLayout(
                            editor,
                            mapState,
                            markers,
                            controller,
                            initialCenter,
                            initialZoom,
                            selectedName,
                            selectedIcon,
                            pendingMediaCount,
                            selectedPlaceId)
                        : _buildMobileLayout(
                            editor,
                            mapState,
                            markers,
                            controller,
                            initialCenter,
                            initialZoom,
                            selectedName,
                            selectedIcon,
                            pendingMediaCount,
                            selectedPlaceId),
                  ),
                ],
              ),
            ),
            floatingActionButton:
                showFab ? _buildMobileFab(editor, controller) : null,
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
        final place =
            editor.places.firstWhere((p) => p.id == editor.selectedItemId);
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
        final route =
            editor.routes.firstWhere((r) => r.id == editor.selectedItemId);
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
        final place =
            editor.places.firstWhere((p) => p.id == editor.selectedItemId);
        return place.placeType == 'city' ? Icons.location_city : Icons.place;
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

  (String, Color) _resolveHeaderSyncStatus({
    required bool savingLocally,
    required AsyncValue<EditorSyncStatus> syncStatusAsync,
  }) {
    if (savingLocally) {
      return ('Saving locally...', AppColors.textSecondary);
    }

    return syncStatusAsync.when(
      data: (status) {
        switch (status.kind) {
          case EditorSyncStatusKind.localSaved:
            return (status.label, AppColors.textSecondary);
          case EditorSyncStatusKind.syncing:
            return (status.label, AppColors.accent);
          case EditorSyncStatusKind.synced:
            return (status.label, AppColors.success);
          case EditorSyncStatusKind.failed:
            return (status.label, AppColors.error);
          case EditorSyncStatusKind.blocked:
            return (status.label, AppColors.warning);
        }
      },
      loading: () => ('Checking sync...', AppColors.textSecondary),
      error: (_, __) => ('Sync status unavailable', AppColors.warning),
    );
  }

  _EditorSyncCallout? _resolveEditorSyncCallout({
    required AsyncValue<EditorSyncStatus> syncStatusAsync,
    required EditorController controller,
  }) {
    return syncStatusAsync.when(
      data: (status) {
        switch (status.kind) {
          case EditorSyncStatusKind.failed:
            return _EditorSyncCallout(
              message: 'Some changes failed to sync.',
              tint: AppColors.error,
              actionLabel: 'Retry now',
              onAction: () => unawaited(_retrySyncNow()),
            );
          case EditorSyncStatusKind.blocked:
            final snapshot = status.snapshot;
            final blockedMediaPlaceId = snapshot.firstBlockedMediaPlaceId;
            if (blockedMediaPlaceId != null && blockedMediaPlaceId.isNotEmpty) {
              return _EditorSyncCallout(
                message: 'Some media uploads are blocked.',
                tint: AppColors.warning,
                actionLabel: 'Open uploads',
                onAction: () => unawaited(
                  _openBlockedMediaUploads(blockedMediaPlaceId),
                ),
              );
            }
            return _EditorSyncCallout(
              message: snapshot.firstBlockedTaskErrorMessage ??
                  'Sync is blocked. Resolve the issue and retry.',
              tint: AppColors.warning,
              actionLabel: 'Review',
              onAction: () => _focusBlockedEntity(snapshot, controller),
            );
          case EditorSyncStatusKind.localSaved:
          case EditorSyncStatusKind.syncing:
          case EditorSyncStatusKind.synced:
            return null;
        }
      },
      loading: () => null,
      error: (_, __) => _EditorSyncCallout(
        message: 'Sync status unavailable.',
        tint: AppColors.warning,
        actionLabel: 'Retry now',
        onAction: () => unawaited(_retrySyncNow()),
      ),
    );
  }

  Future<void> _retrySyncNow() async {
    final entityWorker = ref.read(entitySyncWorkerProvider);
    final mediaWorker = ref.read(uploadQueueWorkerProvider);
    await Future.wait([
      entityWorker.startIfIdle(),
      mediaWorker.startIfIdle(),
    ]);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying sync now.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openBlockedMediaUploads(String placeId) async {
    if (!mounted) {
      return;
    }
    await context.push(Routes.mediaUploadPath(widget.tripId, placeId));
  }

  void _focusBlockedEntity(
    EditorSyncSnapshot snapshot,
    EditorController controller,
  ) {
    final entityType = snapshot.firstBlockedTaskEntityType;
    final entityId = snapshot.firstBlockedTaskEntityId;
    if (entityType == 'place' && entityId != null) {
      controller.selectPlace(entityId);
    } else if (entityType == 'route' && entityId != null) {
      controller.selectRoute(entityId);
    }

    final message = snapshot.firstBlockedTaskErrorMessage ??
        'Sync is blocked. Resolve the highlighted item and retry.';
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () => unawaited(_retrySyncNow()),
        ),
      ),
    );
  }

  Widget _buildSyncCallout(_EditorSyncCallout callout) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Container(
        padding: AppSpacing.allSm,
        decoration: BoxDecoration(
          color: callout.tint.withValues(alpha: 0.12),
          border: Border.all(color: callout.tint.withValues(alpha: 0.35)),
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                callout.message,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (callout.actionLabel != null && callout.onAction != null)
              TextButton(
                onPressed: callout.onAction,
                child: Text(callout.actionLabel!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTrackingControlStrip(
    AsyncValue<LiveTrackingRuntimeSnapshot> trackingRuntimeAsync,
  ) {
    final hasRuntimeSnapshot = trackingRuntimeAsync.hasValue;
    final snapshot = trackingRuntimeAsync.valueOrNull;
    final runtimeState =
        hasRuntimeSnapshot ? snapshot!.state : LiveTrackingRuntimeState.planned;
    final subtitle = trackingRuntimeAsync.when(
      data: _liveTrackingSubtitle,
      loading: () => 'Checking tracking state...',
      error: (_, __) => 'Tracking state unavailable. Retry once sync recovers.',
    );

    return LiveTrackingControlStrip(
      runtimeState: runtimeState,
      isBusy: _trackingActionInFlight,
      controlsEnabled: hasRuntimeSnapshot,
      busyLabel: _trackingActionLabel,
      subtitle: subtitle,
      onStart: () => unawaited(
        _runLiveTrackingAction(
          busyLabel: 'Starting...',
          successMessage: 'Live tracking started.',
          action: (coordinator) async {
            await coordinator.startTracking(tripId: widget.tripId);
            return true;
          },
        ),
      ),
      onPause: () => unawaited(
        _runLiveTrackingAction(
          busyLabel: 'Pausing...',
          successMessage: 'Live tracking paused.',
          noOpMessage: 'No active tracking session to pause.',
          action: (coordinator) async {
            final paused =
                await coordinator.pauseTracking(tripId: widget.tripId);
            return paused != null;
          },
        ),
      ),
      onResume: () => unawaited(
        _runLiveTrackingAction(
          busyLabel: 'Resuming...',
          successMessage: 'Live tracking resumed.',
          noOpMessage: 'No paused tracking session to resume.',
          action: (coordinator) async {
            final resumed =
                await coordinator.resumeTracking(tripId: widget.tripId);
            return resumed != null;
          },
        ),
      ),
      onStop: () => unawaited(
        _runLiveTrackingAction(
          busyLabel: 'Stopping...',
          successMessage: 'Live tracking stopped.',
          noOpMessage: 'No active or paused session to stop.',
          action: (coordinator) async {
            final stopped =
                await coordinator.stopTracking(tripId: widget.tripId);
            return stopped != null;
          },
        ),
      ),
    );
  }

  String _liveTrackingSubtitle(LiveTrackingRuntimeSnapshot snapshot) {
    final lastPoint = snapshot.lastPointAt;
    switch (snapshot.state) {
      case LiveTrackingRuntimeState.active:
        if (lastPoint != null) {
          return 'Active. Last point at ${_formatTime(lastPoint)}.';
        }
        return 'Active. Waiting for first location sample.';
      case LiveTrackingRuntimeState.paused:
        if (lastPoint != null) {
          return 'Paused. Last point at ${_formatTime(lastPoint)}.';
        }
        return 'Paused. Resume when you continue moving.';
      case LiveTrackingRuntimeState.ended:
        return 'Session ended. Start a new session to continue capture.';
      case LiveTrackingRuntimeState.planned:
        return 'Not started. Start tracking to capture route progress.';
    }
  }

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _runLiveTrackingAction({
    required String busyLabel,
    required String successMessage,
    String? noOpMessage,
    required Future<bool> Function(LiveTrackingCaptureCoordinator coordinator)
        action,
  }) async {
    if (_trackingActionInFlight || !mounted) {
      return;
    }
    setState(() {
      _trackingActionInFlight = true;
      _trackingActionLabel = busyLabel;
    });
    try {
      final coordinator = ref.read(liveTrackingCaptureCoordinatorProvider);
      final didApply = await action(coordinator);
      if (!mounted) {
        return;
      }
      final feedback = didApply
          ? successMessage
          : (noOpMessage ?? 'No tracking state change was required.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(feedback),
        duration: const Duration(seconds: 2),
      ));
    } on LiveTrackingCaptureException catch (error) {
      await _handleLiveTrackingCaptureException(error);
    } catch (_) {
      _showLocationMessage('Live tracking action failed. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _trackingActionInFlight = false;
          _trackingActionLabel = null;
        });
      }
    }
  }

  Future<void> _handleLiveTrackingCaptureException(
    LiveTrackingCaptureException error,
  ) async {
    if (!mounted) {
      return;
    }
    switch (error.code) {
      case 'location_service_disabled':
        await _promptToEnableLocationServices();
        return;
      case 'location_permission_denied_forever':
        await _promptToOpenAppSettings();
        return;
      case 'location_permission_denied':
        _showLocationMessage('Location permission denied.');
        return;
      default:
        _showLocationMessage(error.message);
        return;
    }
  }

  Future<void> _resolveDeviceCenter() async {
    final locationResult = await ref
        .read(locationServiceProvider)
        .getCurrentPositionResult(requestPermission: false);
    final position = locationResult.position;
    if (!mounted || position == null) {
      return;
    }

    final center = AppLatLng(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    setState(() {
      _deviceCenter = center;
    });

    _maybeCenterMapOnDevice(
      ref.read(editorControllerProvider(widget.tripId)).valueOrNull,
    );
  }

  void _maybeCenterMapOnDevice(EditorState? editor) {
    if (_didAutoCenterOnDevice || editor == null) {
      return;
    }
    if (_deviceCenter == null) {
      return;
    }
    final hasTripCenter = editor.trip.centerPoint != null;
    final hasPlaces = editor.places.isNotEmpty;
    if (hasTripCenter || hasPlaces) {
      return;
    }

    final mapController = editor.mapController;
    if (mapController == null) {
      return;
    }
    _didAutoCenterOnDevice = true;
    unawaited(mapController.flyTo(_deviceCenter!, zoom: 13));
  }

  Future<void> _centerMapOnCurrentLocation() async {
    final locationResult =
        await ref.read(locationServiceProvider).getCurrentPositionResult();
    if (!mounted) {
      return;
    }

    if (locationResult.isServiceDisabled) {
      await _promptToEnableLocationServices();
      return;
    }
    if (locationResult.isPermissionDeniedForever) {
      await _promptToOpenAppSettings();
      return;
    }
    if (locationResult.isPermissionDenied) {
      _showLocationMessage('Location permission denied');
      return;
    }

    final position = locationResult.position;
    if (position == null) {
      _showLocationMessage('Could not get current location');
      return;
    }

    final center = AppLatLng(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    setState(() {
      _deviceCenter = center;
    });

    final mapController = ref
        .read(editorControllerProvider(widget.tripId))
        .valueOrNull
        ?.mapController;
    if (mapController != null) {
      await mapController.flyTo(center, zoom: 14);
    }
  }

  void _showLocationMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _promptToEnableLocationServices() async {
    if (!mounted) {
      return;
    }
    final shouldOpenSettings = await _showLocationActionDialog(
      icon: Icons.gps_off_rounded,
      title: 'Turn On Location Services',
      message:
          'Location services are off. Enable them to center the map to your current location.',
      confirmLabel: 'Open settings',
    );
    if (shouldOpenSettings == true) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _promptToOpenAppSettings() async {
    if (!mounted) {
      return;
    }
    final shouldOpenSettings = await _showLocationActionDialog(
      icon: Icons.location_on_outlined,
      title: 'Allow Location Permission',
      message:
          'Location permission is permanently denied. Open app settings and allow location access.',
      confirmLabel: 'Open settings',
    );
    if (shouldOpenSettings == true) {
      await Geolocator.openAppSettings();
    }
  }

  Future<bool?> _showLocationActionDialog({
    required IconData icon,
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.divider),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.accent),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.divider),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                      child: const Text('Not now'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderMd,
                        ),
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncMediaFocusWithSelection(EditorState? editor) {
    final focusPlaceId = _mediaFocusPlaceId;
    if (focusPlaceId == null) {
      return;
    }
    final selectedPlaceId =
        editor?.selectedItemType == 'place' ? editor?.selectedItemId : null;
    if (selectedPlaceId != focusPlaceId) {
      _clearMediaFocus();
    }
  }

  void _clearMediaFocus() {
    if (_mediaFocusMarker == null && _mediaFocusPlaceId == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _mediaFocusMarker = null;
      _mediaFocusPlaceId = null;
    });
  }

  void _openMediaAttachmentViewer({
    required Place place,
    required List<MediaItem> mediaItems,
    required MediaItem initialMedia,
    required EditorController controller,
  }) {
    if (!mounted || mediaItems.isEmpty) {
      return;
    }
    final initialIndex =
        mediaItems.indexWhere((item) => item.id == initialMedia.id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.card,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.92,
        child: MediaAttachmentViewer(
          items: mediaItems,
          initialIndex: initialIndex < 0 ? 0 : initialIndex,
          onShowOnMap: (item) {
            Navigator.of(sheetContext).pop();
            _focusMediaOnMap(
              place: place,
              media: item,
              controller: controller,
            );
          },
          onManageMedia: () {
            Navigator.of(sheetContext).pop();
            if (mounted) {
              context.push(Routes.mediaUploadPath(widget.tripId, place.id));
            }
          },
        ),
      ),
    );
  }

  void _focusMediaOnMap({
    required Place place,
    required MediaItem media,
    required EditorController controller,
  }) {
    final marker = AppMarker(
      id: '_media_focus_${place.id}_${media.id}',
      position: place.coordinates,
      title: '${place.name} media',
      color: const Color(0xFFFF7A18),
      markerType: 'media_focus',
      label: 'M',
    );
    if (mounted) {
      setState(() {
        _mediaFocusMarker = marker;
        _mediaFocusPlaceId = place.id;
      });
    }
    controller.selectPlace(place.id);
    final mapController = ref
        .read(editorControllerProvider(widget.tripId))
        .valueOrNull
        ?.mapController;
    if (mapController != null) {
      unawaited(
        mapController.flyTo(
          place.coordinates,
          zoom: 16,
          duration: const Duration(milliseconds: 700),
        ),
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Highlighted the selected attachment on the map.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildWideLayout(
    EditorState editor,
    MapState mapState,
    List<AppMarker> markers,
    EditorController controller,
    AppLatLng initialCenter,
    double initialZoom,
    String? selectedName,
    IconData? selectedIcon,
    int pendingMediaCount,
    String? selectedPlaceId,
  ) {
    final inRouteStudio = editor.routeStudioActive;
    final inRouteCreation = _isAnyRouteMode(editor.mode);
    final hideTimeline = inRouteStudio || inRouteCreation;
    final showPanel =
        !inRouteStudio && !inRouteCreation && editor.selectedItemId != null;
    return Row(
      children: [
        if (!hideTimeline)
          TimelineSidebar(
            places: editor.places,
            routes: editor.routes,
            selectedItemId: editor.selectedItemId,
            selectedItemType: editor.selectedItemType,
            onItemTap: (id, type) {
              _clearMediaFocus();
              if (type == 'place') {
                controller.handlePlaceTap(id);
              } else {
                controller.selectRoute(id);
              }
            },
            onReorder: controller.reorderPlaces,
            onAddPlace: () {
              _clearMediaFocus();
              controller.setMode(EditorMode.addPlace);
            },
            onAddCity: () {
              _clearMediaFocus();
              controller.setMode(EditorMode.addCity);
            },
            onAddRoute: () {
              _clearMediaFocus();
              controller.startDrawingRoute();
            },
          ),
        Expanded(
          child: Stack(
            children: [
              MapCanvas(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                markers: markers,
                routes: mapState.routes,
                mode: editor.mode,
                routeStartItemId: editor.routeStartItemId,
                onModeChanged: (mode) {
                  _clearMediaFocus();
                  controller.setMode(mode);
                },
                onMapCreated: controller.setMapController,
                onMapTap: (position) {
                  _clearMediaFocus();
                  controller.handleMapTap(position);
                },
                onRouteTap: (routeId) {
                  _clearMediaFocus();
                  controller.selectRoute(routeId);
                },
                onRouteLineTap: controller.handleRouteLineTap,
                onCurrentLocationTap: _centerMapOnCurrentLocation,
                showMediaTool: selectedPlaceId != null,
                onMediaTap: selectedPlaceId == null
                    ? null
                    : () => context.push(
                          Routes.mediaUploadPath(
                              widget.tripId, selectedPlaceId),
                        ),
              ),
              if (showPanel)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomDetailPanel(
                    expanded: editor.bottomPanelExpanded,
                    onToggle: controller.toggleBottomPanel,
                    selectedItemName: selectedName,
                    selectedItemIcon: selectedIcon,
                    statusText: pendingMediaCount > 0
                        ? '$pendingMediaCount upload(s) pending'
                        : null,
                    child: _buildDetailContent(editor, controller),
                  ),
                ),
              // Route creation strip
              if (inRouteCreation)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildRouteCreationStrip(editor, controller),
                ),
              // Route Studio control strip
              if (inRouteStudio && editor.selectedItemId != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildRouteControlStrip(editor, controller),
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
    List<AppMarker> markers,
    EditorController controller,
    AppLatLng initialCenter,
    double initialZoom,
    String? selectedName,
    IconData? selectedIcon,
    int pendingMediaCount,
    String? selectedPlaceId,
  ) {
    final inRouteStudio = editor.routeStudioActive;
    final inRouteCreation = _isAnyRouteMode(editor.mode);
    final showPanel =
        !inRouteStudio && !inRouteCreation && editor.selectedItemId != null;
    return Stack(
      children: [
        MapCanvas(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          markers: markers,
          routes: mapState.routes,
          mode: editor.mode,
          routeStartItemId: editor.routeStartItemId,
          onModeChanged: (mode) {
            _clearMediaFocus();
            controller.setMode(mode);
          },
          onMapCreated: controller.setMapController,
          onMapTap: (position) {
            _clearMediaFocus();
            controller.handleMapTap(position);
          },
          onRouteTap: (routeId) {
            _clearMediaFocus();
            controller.selectRoute(routeId);
          },
          onRouteLineTap: controller.handleRouteLineTap,
          onCurrentLocationTap: _centerMapOnCurrentLocation,
          showMediaTool: selectedPlaceId != null,
          onMediaTap: selectedPlaceId == null
              ? null
              : () => context.push(
                    Routes.mediaUploadPath(widget.tripId, selectedPlaceId),
                  ),
        ),
        if (showPanel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomDetailPanel(
              expanded: editor.bottomPanelExpanded,
              onToggle: controller.toggleBottomPanel,
              selectedItemName: selectedName,
              selectedItemIcon: selectedIcon,
              statusText: pendingMediaCount > 0
                  ? '$pendingMediaCount upload(s) pending'
                  : null,
              child: _buildDetailContent(editor, controller),
            ),
          ),
        // Route creation strip
        if (inRouteCreation)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildRouteCreationStrip(editor, controller),
          ),
        // Route Studio control strip
        if (inRouteStudio && editor.selectedItemId != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildRouteControlStrip(editor, controller),
          ),
      ],
    );
  }

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
                  _clearMediaFocus();
                  if (type == 'place') {
                    controller.handlePlaceTap(id);
                  } else {
                    controller.selectRoute(id);
                  }
                },
                onReorder: controller.reorderPlaces,
                onAddPlace: () {
                  Navigator.pop(context);
                  _clearMediaFocus();
                  controller.setMode(EditorMode.addPlace);
                },
                onAddCity: () {
                  Navigator.pop(context);
                  _clearMediaFocus();
                  controller.setMode(EditorMode.addCity);
                },
                onAddRoute: () {
                  Navigator.pop(context);
                  _clearMediaFocus();
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
    _clearMediaFocus();
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
    _clearMediaFocus();
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

  void _openExportStudio() {
    if (!mounted) {
      return;
    }
    if (!FeatureFlags.enableExport) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export is not enabled yet.')),
      );
      return;
    }
    context.push(Routes.exportStudioPath(widget.tripId));
  }

  Widget? _buildDetailContent(
    EditorState editor,
    EditorController controller,
  ) {
    // Route creation is handled by RouteCreationStrip — not BottomDetailPanel
    final type = editor.selectedItemType;
    final id = editor.selectedItemId;
    final places = editor.places;

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
        final placeMedia = ref.watch(placeMediaProvider(place.id)).maybeWhen(
              data: (items) => items,
              orElse: () => const <MediaItem>[],
            );
        return PlaceDetailForm(
          place: place,
          onSave: controller.updatePlace,
          onDelete: () => controller.removePlace(place.id),
          onManageMedia: () =>
              context.push(Routes.mediaUploadPath(widget.tripId, place.id)),
          onMediaPreviewTap: placeMedia.isEmpty
              ? null
              : (item) => _openMediaAttachmentViewer(
                    place: place,
                    mediaItems: placeMedia,
                    initialMedia: item,
                    controller: controller,
                  ),
          onViewMediaGallery: placeMedia.isEmpty
              ? null
              : () => _openMediaAttachmentViewer(
                    place: place,
                    mediaItems: placeMedia,
                    initialMedia: placeMedia.first,
                    controller: controller,
                  ),
          mediaItems: placeMedia,
        );
      } catch (_) {
        return null;
      }
    }

    // Routes are handled by Route Studio control strip — not BottomDetailPanel
    return null;
  }

  Widget _buildRouteCreationStrip(
    EditorState editor,
    EditorController controller,
  ) {
    final sourceName = _findPlaceName(editor.places, editor.routeStartItemId);
    final destName = _findPlaceName(editor.places, editor.routeEndItemId);

    // Determine eligible places for current mode
    final eligible = editor.mode == EditorMode.addRouteAir
        ? editor.places.where((p) => p.placeType == 'city').toList()
        : editor.places;
    final hasValidSource = editor.routeStartItemId != null &&
        eligible.any((p) => p.id == editor.routeStartItemId);
    final destEligible =
        eligible.where((p) => p.id != editor.routeStartItemId).toList();
    final hasValidDest = editor.routeEndItemId != null &&
        destEligible.any((p) => p.id == editor.routeEndItemId);
    final canCreate =
        hasValidSource && hasValidDest && !editor.isGeneratingRoute;

    return RouteCreationStrip(
      mode: editor.mode,
      sourceName: sourceName,
      destinationName: destName,
      isLoading: editor.isGeneratingRoute,
      canCreate: canCreate,
      onModeChanged: (newMode) {
        _clearMediaFocus();
        controller.setMode(newMode);
      },
      onPickSource: () => _openPlacePicker(
        title: 'Pick starting point',
        places: eligible,
        onPick: controller.selectRouteSource,
      ),
      onPickDestination: () => _openPlacePicker(
        title: 'Pick destination',
        places: destEligible,
        onPick: controller.selectRouteDestination,
        excludeId: editor.routeStartItemId,
      ),
      onCreateRoute: () {
        _clearMediaFocus();
        controller.drawRoute(
          editor.routeStartItemId!,
          editor.routeEndItemId!,
          capturedMode: editor.mode,
        );
      },
      onCancel: () {
        _clearMediaFocus();
        controller.cancelRouteMode();
      },
    );
  }

  void _openPlacePicker({
    required String title,
    required List<Place> places,
    required ValueChanged<String?> onPick,
    String? excludeId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (_) => PlacePickerSheet(
        title: title,
        places: places,
        excludeId: excludeId,
        onPick: (id) => onPick(id),
      ),
    );
  }

  Widget _buildRouteControlStrip(
    EditorState editor,
    EditorController controller,
  ) {
    try {
      final route =
          editor.routes.firstWhere((r) => r.id == editor.selectedItemId);
      final startName =
          _findPlaceName(editor.places, route.startPlaceId) ?? '?';
      final endName = _findPlaceName(editor.places, route.endPlaceId) ?? '?';
      return RouteControlStrip(
        transportMode: route.transportMode,
        startName: startName,
        endName: endName,
        distanceKm: route.distance,
        durationMins: route.duration,
        isEditMode: editor.mode == EditorMode.editRoute,
        waypointCount: route.waypoints.length,
        onToggleEdit: () =>
            controller.toggleRouteEditMode(editor.selectedItemId!),
        onOpenWaypoints: () => _openWaypointSheet(editor, controller, route),
        onFlip: () => controller.flipRoute(editor.selectedItemId!),
        onOpenDetails: () => _openRouteDetailsSheet(editor, controller, route),
        onDelete: () {
          _clearMediaFocus();
          controller.removeRoute(editor.selectedItemId!);
        },
        onClose: () {
          _clearMediaFocus();
          controller.exitRouteStudio();
        },
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  void _openRouteDetailsSheet(
    EditorState editor,
    EditorController controller,
    create_route.Route route,
  ) {
    final startName = _findPlaceName(editor.places, route.startPlaceId);
    final endName = _findPlaceName(editor.places, route.endPlaceId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (_) => RouteDetailsSheet(
        route: route,
        onSave: controller.updateRoute,
        startPlaceName: startName,
        endPlaceName: endName,
      ),
    );
  }

  void _openWaypointSheet(
    EditorState editor,
    EditorController controller,
    create_route.Route route,
  ) {
    final startName = _findPlaceName(editor.places, route.startPlaceId) ?? '?';
    final endName = _findPlaceName(editor.places, route.endPlaceId) ?? '?';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (_) => WaypointSheet(
        waypoints: route.waypoints,
        startPlaceName: startName,
        endPlaceName: endName,
        onReorder: (oldIndex, newIndex) {
          controller.reorderWaypoints(route.id, oldIndex, newIndex);
          Navigator.pop(context);
        },
        onRemove: (index) {
          controller.removeWaypoint(route.id, index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _EditorSyncCallout {
  const _EditorSyncCallout({
    required this.message,
    required this.tint,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final Color tint;
  final String? actionLabel;
  final VoidCallback? onAction;
}
