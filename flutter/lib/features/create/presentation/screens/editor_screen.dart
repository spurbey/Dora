import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/config/feature_flags.dart';
import 'package:dora/core/config/live_system_v2_gate.dart';
import 'package:dora/features/advisory/advisory_guard.dart';
import 'package:dora/features/advisory/presentation/screens/advisory_debug_screen.dart';
import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/editor_state.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/core/live_tracking/live_tracking_shared_models.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_live_tracking_runtime_provider.dart';
import 'package:dora/features/create/presentation/providers/map_provider.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';
import 'package:dora/features/create/presentation/providers/place_media_provider.dart';
import 'package:dora/features/create/presentation/widgets/bottom_detail_panel.dart';
import 'package:dora/features/create/presentation/widgets/city_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/editor_header.dart';
import 'package:dora/features/create/presentation/widgets/map_canvas.dart';
import 'package:dora/features/create/presentation/widgets/place_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/place_picker_sheet.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/route_control_strip.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/route_creation_strip.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/route_details_sheet.dart';
import 'package:dora/features/create/presentation/widgets/route_studio/waypoint_sheet.dart';
import 'package:dora/features/create/presentation/widgets/timeline_sidebar.dart';
import 'package:dora/features/create/presentation/widgets/media_attachment_viewer.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_inbox_provider.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_review_panel.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_captured_storyline_panel.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';
import 'package:dora/features/trips/presentation/providers/trips_provider.dart';
import 'package:dora/shared/widgets/confirmation_dialog.dart';
import 'package:dora/shared/widgets/error_view.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with WidgetsBindingObserver {
  AppLatLng? _deviceCenter;
  bool _didAutoCenterOnDevice = false;
  AppMarker? _mediaFocusMarker;
  String? _mediaFocusPlaceId;
  final Set<String> _v2ReviewActionsInFlight = <String>{};
  bool _didTriggerV2EditorOpenRecovery = false;
  static const _defaultEditorCenter = AppLatLng(
    latitude: 20.5937,
    longitude: 78.9629,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveDeviceCenter();
      _triggerV2Recovery(source: V2ResolverTriggerSource.editorOpen);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerV2Recovery(source: V2ResolverTriggerSource.resumed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v2GateDecision = ref.read(liveSystemV2RolloutGateProvider).evaluate(
      tripId: widget.tripId,
      surface: LiveSystemV2Surface.editor,
      requiredSubsystems: const {
        LiveSystemV2Subsystem.localCompiler,
        LiveSystemV2Subsystem.liveEditorUiContract,
      },
    );
    final useV2ReviewLane = v2GateDecision.enabled;
    if (useV2ReviewLane) {
      _triggerV2Recovery(source: V2ResolverTriggerSource.editorOpen);
    }
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
        const syncStatusAsync = AsyncValue<EditorSyncStatus>.data(
          EditorSyncStatus(
            kind: EditorSyncStatusKind.localSaved,
            label: 'Saved locally',
            snapshot: EditorSyncSnapshot(
              tripSynced: true,
              unsyncedPlaceCount: 0,
              unsyncedRouteCount: 0,
              pendingMediaCount: 0,
              failedMediaCount: 0,
              blockedMediaCount: 0,
              hasActiveSession: false,
              hasPendingPublish: false,
              uncommittedSessionCount: 0,
            ),
          ),
        );
        final v2TimelineGroupsAsync =
            ref.watch(v2TimelineGroupsProvider(widget.tripId));
        final v2RouteProjectionAsync =
            ref.watch(v2RouteProjectionProvider(widget.tripId));
        final claimedSegmentKeysAsync =
            ref.watch(v2ClaimedRouteSegmentKeysProvider(widget.tripId));
        final trackingRuntimeAsync =
            ref.watch(v2LiveTrackingRuntimeSnapshotProvider(widget.tripId));
        final v2InboxAsync =
            ref.watch(v2UnresolvedInboxProvider(widget.tripId));
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
        final markers = [
          ...mapState.markers,
          if (_mediaFocusMarker != null) _mediaFocusMarker!,
        ];
        final routes = [...mapState.routes];
        final routeSegments = v2RouteProjectionAsync.valueOrNull ??
            const <V2RouteProjectionSegment>[];
        final claimedSegmentKeys =
            claimedSegmentKeysAsync.valueOrNull ?? const <String>{};
        for (final segment in routeSegments) {
          if (segment.geometry.length < 2) {
            continue;
          }
          if (claimedSegmentKeys.contains(segment.segmentKey)) {
            continue;
          }
          routes.add(
            AppRoute(
              id: '_v2_compiled_${segment.segmentKey}',
              coordinates: segment.geometry,
              color: AppColors.accent.withValues(alpha: 0.58),
              width: 3,
              dashed: false,
            ),
          );
        }

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

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              return;
            }
            unawaited(_attemptLeaveEditor(editor.saving));
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  EditorHeader(
                    tripName: editor.trip.name,
                    syncStatusLabel: syncStatusLabel,
                    syncStatusColor: syncStatusColor,
                    onBack: () {
                      unawaited(_attemptLeaveEditor(editor.saving));
                    },
                    onNameChanged: controller.updateTripName,
                    onExport: _openExportStudio,
                    onMore: _openTripActionsMenu,
                  ),
                  if (syncCallout != null) _buildSyncCallout(syncCallout),
                  _buildLiveCaptureEntryCard(
                    trackingRuntimeAsync: trackingRuntimeAsync,
                    syncStatusAsync: syncStatusAsync,
                  ),
                  _buildV2UnresolvedReviewInbox(
                    editor: editor,
                    inboxAsync: v2InboxAsync,
                  ),
                  Expanded(
                    child: isWide
                        ? _buildWideLayout(
                            editor,
                            markers,
                            routes,
                            controller,
                            initialCenter,
                            initialZoom,
                            selectedName,
                            selectedIcon,
                            pendingMediaCount,
                            selectedPlaceId,
                            useV2ReviewLane,
                            v2TimelineGroupsAsync,
                          )
                        : _buildMobileLayout(
                            editor,
                            markers,
                            routes,
                            controller,
                            initialCenter,
                            initialZoom,
                            selectedName,
                            selectedIcon,
                            pendingMediaCount,
                            selectedPlaceId,
                            useV2ReviewLane,
                            v2TimelineGroupsAsync,
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: showFab
                ? _buildMobileFab(
                    editor,
                    controller,
                    useV2ReviewLane,
                    v2TimelineGroupsAsync,
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
          ),
        );
      },
    );
  }

  Widget _buildMobileFab(
    EditorState editor,
    EditorController controller,
    bool useV2Projection,
    AsyncValue<List<V2TimelineDayGroup>>? v2TimelineGroupsAsync,
  ) {
    return FloatingActionButton(
      onPressed: () => _showTimelineSheet(
        editor,
        controller,
        useV2Projection,
        v2TimelineGroupsAsync,
      ),
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
          case EditorSyncStatusKind.activeSession:
            return (status.label, AppColors.accent);
          case EditorSyncStatusKind.publishing:
            return (status.label, AppColors.accent);
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
              message: 'Upload is blocked. Resolve the issue and retry.',
              tint: AppColors.warning,
              actionLabel: 'Retry',
              onAction: () => unawaited(_retrySyncNow()),
            );
          case EditorSyncStatusKind.activeSession:
          case EditorSyncStatusKind.publishing:
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
    final mediaWorker = ref.read(uploadQueueWorkerProvider);
    await mediaWorker.startIfIdle();
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

  Widget _buildLiveCaptureEntryCard({
    required AsyncValue<LiveTrackingRuntimeSnapshot> trackingRuntimeAsync,
    required AsyncValue<EditorSyncStatus> syncStatusAsync,
  }) {
    final subtitle = trackingRuntimeAsync.when(
      data: _liveTrackingSubtitle,
      loading: () => 'Checking tracking state...',
      error: (_, __) =>
          'Tracking state unavailable. Open live capture to retry.',
    );
    final runtimeState = trackingRuntimeAsync.valueOrNull?.state ??
        LiveTrackingRuntimeState.planned;
    final blockedCount =
        syncStatusAsync.valueOrNull?.snapshot.blockedItems ?? 0;

    final stateLabel = switch (runtimeState) {
      LiveTrackingRuntimeState.active => 'Active',
      LiveTrackingRuntimeState.paused => 'Paused',
      LiveTrackingRuntimeState.ended => 'Ended',
      LiveTrackingRuntimeState.planned => 'Ready',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Container(
        key: const ValueKey('editorLiveCaptureEntryCard'),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.12),
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: blockedCount > 0
                ? AppColors.warning.withValues(alpha: 0.45)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Capture',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _buildPillChip(
                        icon: Icons.wifi_tethering,
                        label: stateLabel,
                      ),
                      if (blockedCount > 0)
                        _buildPillChip(
                          icon: Icons.error_outline,
                          label: '$blockedCount blocked',
                          tint: AppColors.warning,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.icon(
              key: const ValueKey('editorOpenLiveCaptureButton'),
              onPressed: () =>
                  context.push(Routes.liveCapturePath(widget.tripId)),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillChip({
    required IconData icon,
    required String label,
    Color? tint,
  }) {
    final chipTint = tint ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: chipTint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: chipTint,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildV2UnresolvedReviewInbox({
    required EditorState editor,
    required AsyncValue<List<V2UnresolvedInboxItem>> inboxAsync,
  }) {
    return inboxAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return V2UnresolvedReviewPanel(
          items: items,
          interactive: true,
          onReviewInEditor: null,
          busyEventIds: _v2ReviewActionsInFlight,
          onAcceptCandidate: (eventId, candidate) => unawaited(
            _runV2ReviewAction(
              eventId: eventId,
              action: () async {
                await ref
                    .read(v2UnresolvedReviewControllerProvider)
                    .acceptCandidate(
                      eventId: eventId,
                      candidate: candidate,
                    );
                return true;
              },
              successMessage: 'Capture bound to place.',
            ),
          ),
          onAddPlace: (eventId) => unawaited(
            _runV2ReviewAction(
              eventId: eventId,
              action: () => _assignV2ManualPlace(
                eventId: eventId,
                editor: editor,
              ),
              successMessage: 'Capture bound to selected place.',
            ),
          ),
          onKeepGeotag: (eventId) => unawaited(
            _runV2ReviewAction(
              eventId: eventId,
              action: () async {
                await ref
                    .read(v2UnresolvedReviewControllerProvider)
                    .keepGeotag(eventId: eventId);
                return true;
              },
              successMessage: 'Capture kept as geotag.',
            ),
          ),
          title: 'Needs review',
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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

  bool _isV2ReviewLaneEnabled() {
    return ref.read(liveSystemV2RolloutGateProvider).evaluate(
      tripId: widget.tripId,
      surface: LiveSystemV2Surface.editor,
      requiredSubsystems: const {
        LiveSystemV2Subsystem.localCompiler,
        LiveSystemV2Subsystem.liveEditorUiContract,
      },
    ).enabled;
  }

  void _triggerV2Recovery({
    required V2ResolverTriggerSource source,
  }) {
    if (!_isV2ReviewLaneEnabled()) {
      return;
    }
    if (source == V2ResolverTriggerSource.editorOpen &&
        _didTriggerV2EditorOpenRecovery) {
      return;
    }
    if (source == V2ResolverTriggerSource.editorOpen) {
      _didTriggerV2EditorOpenRecovery = true;
    }
    unawaited(
      ref.read(v2ResolverOrchestratorProvider).runRecoveryForTrip(
            tripId: widget.tripId,
            source: source,
            limit: 20,
          ),
    );
  }

  Future<void> _runV2ReviewAction({
    required String eventId,
    required Future<bool> Function() action,
    required String successMessage,
  }) async {
    if (!mounted || _v2ReviewActionsInFlight.contains(eventId)) {
      return;
    }
    setState(() {
      _v2ReviewActionsInFlight.add(eventId);
    });
    try {
      final applied = await action();
      if (!applied) {
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to apply review action.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _v2ReviewActionsInFlight.remove(eventId);
        });
      }
    }
  }

  Future<bool> _assignV2ManualPlace({
    required String eventId,
    required EditorState editor,
  }) async {
    final places = editor.places.toList();
    if (places.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No places or cities available. Add one in the editor first.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }

    final selectedPlaceId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            children: [
              const ListTile(
                dense: true,
                title: Text(
                  'Select place',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              for (final place in places)
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(place.name),
                  subtitle: place.address?.trim().isNotEmpty == true
                      ? Text(place.address!.trim())
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(place.id),
                ),
            ],
          ),
        );
      },
    );

    if (selectedPlaceId == null || selectedPlaceId.trim().isEmpty) {
      return false;
    }

    Place? selectedPlace;
    for (final place in places) {
      if (place.id == selectedPlaceId) {
        selectedPlace = place;
        break;
      }
    }
    if (selectedPlace == null) {
      return false;
    }
    await ref.read(v2UnresolvedReviewControllerProvider).assignManualPlace(
          eventId: eventId,
          placeId: selectedPlace.id,
          placeName: selectedPlace.name,
        );
    return true;
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

  Widget? _buildCapturedStorylinePanel({
    required bool useV2Projection,
    required AsyncValue<List<V2TimelineDayGroup>>? v2TimelineGroupsAsync,
  }) {
    if (!useV2Projection || v2TimelineGroupsAsync == null) {
      return null;
    }
    return v2TimelineGroupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return null;
        }
        return V2CapturedStorylinePanel(groups: groups);
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Widget _buildWideLayout(
    EditorState editor,
    List<AppMarker> markers,
    List<AppRoute> routes,
    EditorController controller,
    AppLatLng initialCenter,
    double initialZoom,
    String? selectedName,
    IconData? selectedIcon,
    int pendingMediaCount,
    String? selectedPlaceId,
    bool useV2Projection,
    AsyncValue<List<V2TimelineDayGroup>>? v2TimelineGroupsAsync,
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
            capturedStorylinePanel: _buildCapturedStorylinePanel(
              useV2Projection: useV2Projection,
              v2TimelineGroupsAsync: v2TimelineGroupsAsync,
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              MapCanvas(
                initialCenter: initialCenter,
                initialZoom: initialZoom,
                markers: markers,
                routes: routes,
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
    List<AppMarker> markers,
    List<AppRoute> routes,
    EditorController controller,
    AppLatLng initialCenter,
    double initialZoom,
    String? selectedName,
    IconData? selectedIcon,
    int pendingMediaCount,
    String? selectedPlaceId,
    bool useV2Projection,
    AsyncValue<List<V2TimelineDayGroup>>? v2TimelineGroupsAsync,
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
          routes: routes,
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
    bool useV2Projection,
    AsyncValue<List<V2TimelineDayGroup>>? v2TimelineGroupsAsync,
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
                capturedStorylinePanel: _buildCapturedStorylinePanel(
                  useV2Projection: useV2Projection,
                  v2TimelineGroupsAsync: v2TimelineGroupsAsync,
                ),
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

  Future<void> _attemptLeaveEditor(bool saving) async {
    final shouldLeave = await _handleBack(saving);
    if (!mounted || !shouldLeave) {
      return;
    }
    context.go(Routes.trips);
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

  Future<void> _openTripActionsMenu() async {
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save_outlined),
                title: const Text('Save trip'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_saveTripFromEditor());
                },
              ),
              ListTile(
                leading: const Icon(Icons.publish_outlined),
                title: const Text('Publish trip'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_publishTripFromEditor());
                },
              ),
              if (advisoryEnabled())
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: const Text('Advisory Debug'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdvisoryDebugScreen(
                          tripId: widget.tripId,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveTripFromEditor() async {
    final result = await ref
        .read(tripsControllerProvider.notifier)
        .saveTrip(widget.tripId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }

  Future<void> _publishTripFromEditor() async {
    final result = await ref
        .read(tripsControllerProvider.notifier)
        .publishTrip(widget.tripId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
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
