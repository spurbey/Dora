import 'dart:async';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/config/feature_flags.dart';
import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/features/capture/domain/capture_models.dart';
import 'package:dora/features/live_capture/map/live_capture_map_widget.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/core/live_tracking/live_tracking_shared_models.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_action_dock.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_top_bar.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_transient_effects.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_inbox_provider.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_live_tracking_runtime_provider.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/features/advisory/providers/advisory_providers.dart';
import 'package:dora/features/live_capture/map/live_capture_map_controller.dart'
    show AdvisoryMapMarker, MapDimensionalMode, V3MapTap, V3MapTapKind;
import 'package:dora/features/live_capture/presentation/widgets/advisory_active_card.dart';
import 'package:dora/features/live_capture/presentation/widgets/advisory_side_panel.dart';
import 'package:dora/features/live_capture/presentation/widgets/dimensional_mode_toggle.dart';
import 'package:dora/features/live_capture/presentation/widgets/dora_bubble_stack.dart';
import 'package:dora/features/live_capture/presentation/widgets/dora_top_left_pill.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_bottom_detail_sheet.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_bottom_sheet_v3.dart';
import 'package:dora/features/live_capture/presentation/widgets/map_callout_overlay.dart';
import 'package:dora/features/live_capture/providers/bottom_sheet_state_provider.dart';
import 'package:dora/features/live_capture/providers/dora_bubble_triggers.dart';
import 'package:dora/features/live_capture/providers/trip_captured_media_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';
import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora_api/dora_api.dart' as openapi;

final liveCaptureTripNameProvider =
    StreamProvider.autoDispose.family<String, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT name
    FROM trips
    WHERE id = ?
    LIMIT 1
    ''',
    variables: [Variable<String>(tripId)],
    readsFrom: {db.trips},
  );
  return query.watchSingleOrNull().map((row) {
    final name = row?.read<String>('name').trim();
    if (name == null || name.isEmpty) {
      final shortId = tripId.length > 8 ? tripId.substring(0, 8) : tripId;
      return 'Trip $shortId';
    }
    return name;
  });
});

class LiveCaptureScreen extends ConsumerStatefulWidget {
  const LiveCaptureScreen({
    super.key,
    required this.tripId,
    this.previewState,
    this.advisoryFocusId,
    this.openSidePanel = false,
  });

  final String tripId;
  final String? advisoryFocusId;
  final bool openSidePanel;
  final LiveCaptureShellState? previewState;

  @override
  ConsumerState<LiveCaptureScreen> createState() => _LiveCaptureScreenState();
}

class _LiveCaptureScreenState extends ConsumerState<LiveCaptureScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final Set<String> _dismissedReviewPromptEventIds = <String>{};
  static const AppLatLng _defaultLiveCenter = AppLatLng(
    latitude: 20.5937,
    longitude: 78.9629,
  );
  bool _useV2Lane = false;
  bool _didTriggerV2LiveOpenRecovery = false;
  bool _actionInFlight = false;
  String? _actionLabel;
  bool _sidePanelOpen = false;
  String? _focusedAdvisoryId;
  BottomSheetContent? _bottomSheetContent;
  Timer? _resolverReconcileTimer;

  // ── V3 state ───────────────────────────────────────────────────────────────
  // Map widget GlobalKey so the screen can drive flyTo from timeline-row taps
  // and project map coords for the callout overlay.
  final GlobalKey<LiveCaptureMapWidgetState> _v3MapKey =
      GlobalKey<LiveCaptureMapWidgetState>();
  // Camera-change pump — Mapbox calls onCameraChanged on every pan/zoom/rotate;
  // the callout overlay subscribes to this stream to re-anchor.
  final StreamController<void> _v3CameraChanges =
      StreamController<void>.broadcast();
  MapDimensionalMode _v3DimensionalMode = MapDimensionalMode.standard;
  MapCalloutData? _v3Callout;

  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final Animation<double> _topBarAnim;
  late final Animation<double> _dockAnim;
  late final Animation<double> _panelAnim;

  // Transient burst effects (photo / warn capture feedback)
  late final StreamController<TransientEffect> _effectController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: AnimationTokens.slow,
    );
    _topBarAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _dockAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    );
    _panelAnim = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _effectController = StreamController<TransientEffect>.broadcast();
    // Honor deep-link extras: open side panel / focus a specific advisory.
    if (widget.openSidePanel) {
      _sidePanelOpen = true;
    }
    if (widget.advisoryFocusId != null && widget.advisoryFocusId!.isNotEmpty) {
      _focusedAdvisoryId = widget.advisoryFocusId;
      _sidePanelOpen = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entranceCtrl.forward();
      if (widget.previewState == null) {
        if (_isV2LaneEnabled()) {
          _triggerV2Recovery(source: V2ResolverTriggerSource.liveOpen);
        } else {
          _triggerResolverReconcile();
        }
      }
      if (widget.previewState == null && !_isV2LaneEnabled()) {
        _resolverReconcileTimer = Timer.periodic(
          const Duration(seconds: 45),
          (_) => _triggerResolverReconcile(),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entranceCtrl.dispose();
    _effectController.close();
    _resolverReconcileTimer?.cancel();
    _v3CameraChanges.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.previewState == null &&
        _isV2LaneEnabled()) {
      _triggerV2Recovery(source: V2ResolverTriggerSource.resumed);
    }
  }

  void _emitEffect(TransientEffectType type) {
    if (!_effectController.isClosed) {
      _effectController.add(TransientEffect(type));
    }
  }

  Widget _withEntrance(
    Widget child,
    Animation<double> anim, {
    double slideX = 0,
    double slideY = 0,
  }) {
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (context, child) {
        if (MediaQuery.of(context).disableAnimations) return child!;
        final t = anim.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(slideX * (1.0 - t), slideY * (1.0 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usePreview = widget.previewState != null;
    final enableV3 = !usePreview && FeatureFlags.enableLiveScreenV3;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final useV2Lane = !usePreview;
    _useV2Lane = useV2Lane;
    if (!usePreview) {
      ref.watch(v2CaptureBootstrapProvider);
    }
    final runtimeAsync = usePreview
        ? null
        : ref.watch(v2LiveTrackingRuntimeSnapshotProvider(widget.tripId));
    const AsyncValue<EditorSyncStatus>? syncStatusAsync = null;
    final mapOverlay = usePreview
        ? null
        : ref.watch(v2LiveTrackingMapOverlayProvider(widget.tripId));
    // The recent-events strip is gone (replaced by the V3 timeline
    // bottom sheet) so we no longer subscribe to v2LiveCaptureEventsProvider
    // / v2LiveRecentProjectionProvider here. The unified timeline
    // provider does its own subscriptions inside the sheet.
    final v2InboxAsync = usePreview || !useV2Lane
        ? null
        : ref.watch(v2UnresolvedInboxProvider(widget.tripId));
    final tripName = usePreview
        ? 'Live preview'
        : ref.watch(liveCaptureTripNameProvider(widget.tripId)).valueOrNull ??
            (widget.tripId.length > 8
                ? 'Trip ${widget.tripId.substring(0, 8)}'
                : 'Trip ${widget.tripId}');
    // V1 unresolved summary provider removed — V2 uses inbox-based review.
    // Always return an empty summary; V2 inbox items are used instead.
    const unresolvedSummary = LiveTrackingUnresolvedSummary(
      reviewRequiredCount: 0,
      onRouteCount: 0,
      latestReviewRequired: null,
      reviewHints: <LiveTrackingPlaceHint>[],
    );

    final runtimeState =
        usePreview ? _previewRuntimeState : runtimeAsync?.valueOrNull?.state;
    final syncStatus = syncStatusAsync?.valueOrNull;
    final shellState = usePreview
        ? widget.previewState!
        : _resolveShellState(runtimeState: runtimeState);
    final syncKind =
        useV2Lane ? EditorSyncStatusKind.localSaved : syncStatus?.kind;
    final syncLabel = _resolveSyncLabel(
      usePreview: usePreview,
      useV2Lane: useV2Lane,
      shellState: shellState,
      syncStatus: syncStatusAsync?.valueOrNull,
    );
    // V2: blockedMediaCount > 0 indicates media upload is blocked.
    final hasBlockedMedia = (syncStatus?.snapshot.blockedMediaCount ?? 0) > 0;
    final capturePosition = mapOverlay?.currentMarker?.position;
    final mapInitialCenter = capturePosition ??
        (mapOverlay?.pathRoute?.coordinates.isNotEmpty == true
            ? mapOverlay!.pathRoute!.coordinates.first
            : _defaultLiveCenter);
    final reviewEvent = unresolvedSummary.latestReviewRequired;
    final reviewHints = unresolvedSummary.reviewHints;
    final v2InboxItems =
        v2InboxAsync?.valueOrNull ?? const <V2UnresolvedInboxItem>[];
    final v3SheetState =
        enableV3 ? ref.watch(bottomSheetStateProvider(widget.tripId)) : null;
    final v3SheetVisible =
        v3SheetState != null && v3SheetState is! BottomSheetHidden;
    final showReviewPrompt = !usePreview &&
        reviewEvent != null &&
        reviewHints.isNotEmpty &&
        !_dismissedReviewPromptEventIds.contains(reviewEvent.id);
    final topNotices = <Widget>[
      if (!usePreview &&
          !useV2Lane &&
          syncStatus?.kind == EditorSyncStatusKind.blocked &&
          hasBlockedMedia)
        _SyncBlockedCallout(
          message: 'Media upload blocked',
          onRetry: _actionInFlight ? null : _retrySyncNow,
        ),
      if (!usePreview && !useV2Lane && unresolvedSummary.hasReviewRequired)
        _UnresolvedCaptureBanner(
          unresolvedCount: unresolvedSummary.reviewRequiredCount,
          latestNote: unresolvedSummary.latestReviewRequired?.note?.trim(),
          onReview: _actionInFlight
              ? null
              : () => context.push(Routes.editorPath(widget.tripId)),
        ),
      // V2 unresolved review panel replaced by compact badge on top bar.
      if (!useV2Lane && showReviewPrompt)
        _ProbablePlacePromptCard(
          hints: reviewHints,
          onConfirmHint: _actionInFlight
              ? null
              : (hint) => _confirmProbablePlace(
                    eventId: reviewEvent.id,
                    hint: hint,
                  ),
          onKeepOnRoute:
              _actionInFlight ? null : () => _keepEventOnRoute(reviewEvent.id),
          onAddPlace: _actionInFlight
              ? null
              : () => _openEditorForManualPlace(reviewEvent.id),
        ),
    ];

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBack(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Consumer(
                builder: (context, innerRef, _) {
                  final insightsAsync = usePreview
                      ? null
                      : innerRef.watch(
                          advisoryInsightsProvider(widget.tripId),
                        );
                  final markers = usePreview
                      ? const <AdvisoryMapMarker>[]
                      : _mapInsightsToMarkers(
                          insightsAsync?.asData?.value,
                        );

                  // V3 providers only subscribe when the feature flag is on.
                  final memoryMarkers = enableV3
                      ? (innerRef
                              .watch(tripCapturedMediaProvider(widget.tripId))
                              .valueOrNull ??
                          const <TripCapturedMediaMarker>[])
                      : const <TripCapturedMediaMarker>[];
                  final eventMarkers = enableV3
                      ? (innerRef
                              .watch(tripEventsMapProvider(widget.tripId))
                              .valueOrNull ??
                          const <TripEventMapMarker>[])
                      : const <TripEventMapMarker>[];

                  return LiveCaptureMapWidget(
                    key: _v3MapKey,
                    initialCenter: mapInitialCenter,
                    initialZoom: 13,
                    position: capturePosition,
                    pathPoints: mapOverlay?.pathRoute?.coordinates ??
                        const <AppLatLng>[],
                    advisoryMarkers: markers,
                    onAdvisoryMarkerTap: (advisoryId) {
                      final list = insightsAsync?.asData?.value.insights;
                      if (list == null) return;
                      final found =
                          list.where((i) => i.id == advisoryId).toList();
                      if (found.isEmpty) return;
                      if (enableV3) {
                        setState(() {
                          _sidePanelOpen = true;
                          _focusedAdvisoryId = advisoryId;
                        });
                        return;
                      }
                      setState(() {
                        _bottomSheetContent = AdvisoryPoiDetail(found.first);
                      });
                    },
                    enableV3: enableV3,
                    memoryMarkers: memoryMarkers,
                    eventMarkers: eventMarkers,
                    dimensionalMode: _v3DimensionalMode,
                    onCameraChanged: enableV3
                        ? () {
                            if (!_v3CameraChanges.isClosed) {
                              _v3CameraChanges.add(null);
                            }
                          }
                        : null,
                    onV3MapTap: enableV3 ? _handleV3MapTap : null,
                  );
                },
              ),
            ),
            if (!enableV3)
              SafeArea(
                child: Stack(
                  children: [
                    _withEntrance(
                      Consumer(
                        builder: (context, innerRef, _) {
                          final pendingAdvisoryCount = innerRef
                                  .watch(
                                      advisoryInsightsProvider(widget.tripId))
                                  .asData
                                  ?.value
                                  .insights
                                  .where((i) => i.status.name == 'pending')
                                  .length ??
                              0;
                          return LiveCaptureTopBar(
                            tripName: tripName,
                            state: shellState,
                            syncLabel: syncLabel,
                            syncKind: syncKind,
                            onBack: _handleBack,
                            onOverflow: _showOverflowMenu,
                            resolverBadgeCount: v2InboxItems.length,
                            onResolverTap: v2InboxItems.isNotEmpty
                                ? () => context.push(
                                      Routes.editorPath(widget.tripId),
                                    )
                                : null,
                            advisoryUnreadCount: pendingAdvisoryCount,
                            onAdvisoryTap: () => _toggleSidePanel(),
                          );
                        },
                      ),
                      _topBarAnim,
                      slideY: -8,
                    ),
                    if (topNotices.isNotEmpty)
                      Positioned(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        top: 74,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < topNotices.length; i++) ...[
                              if (i > 0) const SizedBox(height: 6),
                              topNotices[i],
                            ],
                          ],
                        ),
                      ),
                    // (Recent-events strip removed — the V3 timeline
                    // bottom sheet is the canonical surface for "what
                    // I just captured" in chronological order.)
                    // The preview shell still uses _RecentEventsPlaceholder
                    // so widget tests don't crash on missing live data.
                    if (usePreview)
                      const Positioned(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: AppSpacing.md + 86,
                        child: _RecentEventsPlaceholder(),
                      ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 98, 0, 100),
                        child: _withEntrance(
                          LiveCaptureActionDock(
                            state: shellState,
                            isBusy: _actionInFlight,
                            onPhoto: usePreview
                                ? null
                                : () => _openCameraCapture(
                                      initialMode: CameraInitialMode.photo,
                                    ),
                            onMedia: usePreview
                                ? null
                                : () => _openCameraCapture(
                                      initialMode: CameraInitialMode.video,
                                    ),
                            onTag: usePreview
                                ? null
                                : () => _captureQuickEvent(
                                      eventType: LiveTrackingEventType.tag,
                                      note: 'Checkpoint',
                                      successMessage:
                                          'Checkpoint captured locally.',
                                      position: capturePosition,
                                    ),
                            onNote: usePreview
                                ? null
                                : () => _promptForTextCapture(
                                      title: 'Add Quick Note',
                                      hintText:
                                          'Write note for this location...',
                                      defaultPrefix: '',
                                      eventType: LiveTrackingEventType.note,
                                      successMessage: 'Note captured locally.',
                                      position: capturePosition,
                                    ),
                            onWarn: usePreview
                                ? null
                                : () => _promptForTextCapture(
                                      title: 'Add Warning',
                                      hintText:
                                          'Write warning for this location...',
                                      defaultPrefix: '[Warn] ',
                                      eventType: LiveTrackingEventType.warn,
                                      successMessage:
                                          'Warning captured locally.',
                                      position: capturePosition,
                                    ),
                          ),
                          _dockAnim,
                          slideX: 24,
                        ),
                      ),
                    ),
                    _withEntrance(
                      LiveCaptureBottomPanel(
                        state: shellState,
                        isBusy: _actionInFlight,
                        busyLabel: _actionLabel,
                        onStart: usePreview
                            ? null
                            : () => _runLiveTrackingAction(
                                  busyLabel: 'Starting...',
                                  successMessage: 'Live tracking started.',
                                  action: () async {
                                    await ref
                                        .read(v2CaptureCoordinatorProvider)
                                        .startTracking(tripId: widget.tripId);
                                    return true;
                                  },
                                ),
                        onPause: usePreview
                            ? null
                            : () => _runLiveTrackingAction(
                                  busyLabel: 'Pausing...',
                                  successMessage: 'Live tracking paused.',
                                  noOpMessage:
                                      'No active tracking session to pause.',
                                  action: () async {
                                    final paused = await ref
                                        .read(v2CaptureCoordinatorProvider)
                                        .pauseTracking(tripId: widget.tripId);
                                    return paused != null;
                                  },
                                ),
                        onResume: usePreview
                            ? null
                            : () => _runLiveTrackingAction(
                                  busyLabel: 'Resuming...',
                                  successMessage: 'Live tracking resumed.',
                                  noOpMessage:
                                      'No paused tracking session to resume.',
                                  action: () async {
                                    final resumed = await ref
                                        .read(v2CaptureCoordinatorProvider)
                                        .resumeTracking(tripId: widget.tripId);
                                    return resumed != null;
                                  },
                                ),
                        onStop: usePreview
                            ? null
                            : () => _runLiveTrackingAction(
                                  busyLabel: 'Stopping...',
                                  successMessage: 'Live tracking stopped.',
                                  noOpMessage:
                                      'No active or paused session to stop.',
                                  action: () async {
                                    final stopped = await ref
                                        .read(v2CaptureCoordinatorProvider)
                                        .stopTracking(tripId: widget.tripId);
                                    return stopped != null;
                                  },
                                ),
                        onRetrySync: usePreview || useV2Lane || _actionInFlight
                            ? null
                            : _retrySyncNow,
                        onOpenEditor: usePreview
                            ? null
                            : () =>
                                context.push(Routes.editorPath(widget.tripId)),
                      ),
                      _panelAnim,
                      slideY: 24,
                    ),
                    // Advisory active card — floats just above the bottom panel
                    if (!usePreview)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 120,
                        child: Consumer(
                          builder: (context, innerRef, _) {
                            final async = innerRef.watch(
                              activeAdvisoryProvider(widget.tripId),
                            );
                            final advisory = async.asData?.value;
                            if (advisory == null) {
                              return const SizedBox.shrink();
                            }
                            return AdvisoryActiveCard(
                              key: ValueKey(
                                'active_advisory_${advisory.id}',
                              ),
                              localTripId: widget.tripId,
                              advisory: advisory,
                              onShowOnMap: advisory.placeLat != null &&
                                      advisory.placeLng != null
                                  ? (lat, lng) {
                                      _v3MapKey.currentState?.flyTo(lat, lng);
                                    }
                                  : null,
                              onOpenDetail: () {
                                setState(() {
                                  _sidePanelOpen = true;
                                  _focusedAdvisoryId = advisory.id;
                                });
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            // Transient burst effects — above HUD, pointer-transparent
            Positioned.fill(
              child: LiveCaptureTransientEffects(
                key: const ValueKey('liveCaptureTransientEffects'),
                stream: _effectController.stream,
                cancelAll: syncStatus?.kind == EditorSyncStatusKind.blocked,
              ),
            ),
            // Advisory side panel — full-screen overlay, slides from right
            if (!usePreview)
              Positioned.fill(
                child: AdvisorySidePanel(
                  localTripId: widget.tripId,
                  isOpen: _sidePanelOpen,
                  onClose: _toggleSidePanel,
                  focusedAdvisoryId: _focusedAdvisoryId,
                  onOpenAdvisoryDetail: (adv) {
                    if (enableV3) {
                      setState(() {
                        _sidePanelOpen = true;
                        _focusedAdvisoryId = adv.id;
                      });
                      return;
                    }
                    setState(() {
                      _bottomSheetContent = AdvisoryPoiDetail(adv);
                    });
                  },
                ),
              ),
            // Bottom detail sheet — POI / photo / place detail
            if (!usePreview && !enableV3 && _bottomSheetContent != null)
              Positioned.fill(
                child: LiveCaptureBottomDetailSheet(
                  localTripId: widget.tripId,
                  content: _bottomSheetContent!,
                  onDismiss: () => setState(() => _bottomSheetContent = null),
                  onShowOnMap: (lat, lng) {
                    _v3MapKey.currentState?.flyTo(lat, lng);
                  },
                ),
              ),

            // ── V3 chrome — the live-screen experience. ───────────────
            if (enableV3) ...[
              // Map callout overlay — pointer-transparent except where the
              // bubble itself sits.
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: _v3Callout == null,
                  child: Consumer(
                    builder: (context, innerRef, _) {
                      // Resolve mapboxMap from the controller through the
                      // map widget's state. The widget exposes flyTo via
                      // its key; the callout overlay needs the underlying
                      // MapboxMap instance — we expose that via a getter.
                      return MapCalloutOverlay(
                        data: _v3Callout,
                        mapboxMap: _v3MapKey.currentState?.mapboxMap,
                        cameraChangeStream: _v3CameraChanges.stream,
                        onTap: _onCalloutTap,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      child: _LiveCaptureV3TopChrome(
                        tripName: tripName,
                        state: shellState,
                        syncLabel: syncLabel,
                        onBack: _handleBack,
                        onOverflow: _showOverflowMenu,
                        doraPill: DoraTopLeftPill(
                          tripId: widget.tripId,
                          size: 52,
                          onTap: _toggleSidePanel,
                        ),
                        dimensionalToggle: DimensionalModeToggle(
                          mode: _v3DimensionalMode,
                          size: 52,
                          onChanged: (mode) =>
                              setState(() => _v3DimensionalMode = mode),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom-left Dora speech bubble stack
              Positioned(
                left: 0,
                right: 0,
                bottom: (v3SheetVisible ? 200 : 132) + bottomSafe,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: DoraBubbleStack(
                    tripId: widget.tripId,
                    onAdvisoryTap: (advisoryId) {
                      setState(() {
                        _sidePanelOpen = true;
                        _focusedAdvisoryId = advisoryId;
                      });
                    },
                  ),
                ),
              ),
              // Bottom sheet host
              if (v3SheetVisible)
                Positioned.fill(
                  child: LiveCaptureBottomSheetV3(
                    tripId: widget.tripId,
                    onUnresolvedTap: () =>
                        context.push(Routes.editorPath(widget.tripId)),
                    onCameraFly: (lat, lng) {
                      _v3MapKey.currentState?.flyTo(lat, lng);
                    },
                  ),
                ),
              if (!v3SheetVisible)
                Positioned(
                  right: 16,
                  bottom: 28 + bottomSafe,
                  child: _LiveCaptureV3TimelineHandle(
                    tripId: widget.tripId,
                    onTap: () => ref
                        .read(bottomSheetStateProvider(widget.tripId).notifier)
                        .openTimeline(),
                  ),
                ),
              if (!v3SheetVisible)
                Positioned(
                  left: 16,
                  bottom: 28 + bottomSafe,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: _LiveCaptureV3TrackingControls(
                      state: shellState,
                      isBusy: _actionInFlight,
                      onStart: () => _runLiveTrackingAction(
                        busyLabel: 'Starting...',
                        successMessage: 'Live tracking started.',
                        action: () async {
                          await ref
                              .read(v2CaptureCoordinatorProvider)
                              .startTracking(tripId: widget.tripId);
                          return true;
                        },
                      ),
                      onPause: () => _runLiveTrackingAction(
                        busyLabel: 'Pausing...',
                        successMessage: 'Live tracking paused.',
                        noOpMessage: 'No active tracking session to pause.',
                        action: () async {
                          final paused = await ref
                              .read(v2CaptureCoordinatorProvider)
                              .pauseTracking(tripId: widget.tripId);
                          return paused != null;
                        },
                      ),
                      onResume: () => _runLiveTrackingAction(
                        busyLabel: 'Resuming...',
                        successMessage: 'Live tracking resumed.',
                        noOpMessage: 'No paused tracking session to resume.',
                        action: () async {
                          final resumed = await ref
                              .read(v2CaptureCoordinatorProvider)
                              .resumeTracking(tripId: widget.tripId);
                          return resumed != null;
                        },
                      ),
                      onStop: () => _runLiveTrackingAction(
                        busyLabel: 'Stopping...',
                        successMessage: 'Live tracking stopped.',
                        noOpMessage: 'No active or paused session to stop.',
                        action: () async {
                          final stopped = await ref
                              .read(v2CaptureCoordinatorProvider)
                              .stopTracking(tripId: widget.tripId);
                          return stopped != null;
                        },
                      ),
                      onOpenEditor: () =>
                          context.push(Routes.editorPath(widget.tripId)),
                    ),
                  ),
                ),
              if (!v3SheetVisible)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24 + bottomSafe,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: _LiveCaptureV3CaptureControl(
                      state: shellState,
                      isBusy: _actionInFlight,
                      onPhoto: () => _openCameraCapture(
                        initialMode: CameraInitialMode.photo,
                      ),
                      onVideo: () => _openCameraCapture(
                        initialMode: CameraInitialMode.video,
                      ),
                      onMedia: () => _openCameraCapture(
                        initialMode: CameraInitialMode.video,
                      ),
                      onTag: () => _captureQuickEvent(
                        eventType: LiveTrackingEventType.tag,
                        note: 'Checkpoint',
                        successMessage: 'Checkpoint captured locally.',
                        position: capturePosition,
                      ),
                      onNote: () => _promptForTextCapture(
                        title: 'Add Quick Note',
                        hintText: 'Write note for this location...',
                        defaultPrefix: '',
                        eventType: LiveTrackingEventType.note,
                        successMessage: 'Note captured locally.',
                        position: capturePosition,
                      ),
                      onWarn: () => _promptForTextCapture(
                        title: 'Add Warning',
                        hintText: 'Write warning for this location...',
                        defaultPrefix: '[Warn] ',
                        eventType: LiveTrackingEventType.warn,
                        successMessage: 'Warning captured locally.',
                        position: capturePosition,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handles a V3 map tap. Surfaces a callout above the hit pin; the
  /// callout's onTap then opens the bottom-sheet detail.
  void _handleV3MapTap(V3MapTap? hit) {
    if (hit == null) {
      setState(() => _v3Callout = null);
      return;
    }
    final item = _timelineItemForHit(hit);
    final mediaItem = item is TimelineMediaItem ? item : null;
    setState(() {
      _v3Callout = MapCalloutData(
        id: hit.id,
        kind: _calloutKindFor(hit.kind),
        latitude: hit.latitude,
        longitude: hit.longitude,
        title: _calloutTitleFor(hit, item),
        clusterCount: hit.clusterCount,
        thumbnailLocalPath: mediaItem == null
            ? null
            : _firstNonEmptyString([
                mediaItem.thumbnailLocalPath,
                mediaItem.localUri,
              ]),
        thumbnailUrl: mediaItem == null
            ? null
            : _firstNonEmptyString([
                mediaItem.thumbnailRemoteUrl,
                mediaItem.remoteUrl,
              ]),
      );
    });
  }

  void _onCalloutTap() {
    final callout = _v3Callout;
    if (callout == null) return;
    // Map the callout id back to a TimelineItem and open detail.
    // Read the unified timeline once to find the matching item.
    final timelineAsync = ref.read(tripUnifiedTimelineProvider(widget.tripId));
    final items = timelineAsync.valueOrNull ?? const [];
    final match = items
        .where((it) =>
            it.id == 'media:${callout.id}' || it.id == 'event:${callout.id}')
        .toList();
    if (match.isEmpty) return;
    ref
        .read(bottomSheetStateProvider(widget.tripId).notifier)
        .openDetail(match.first);
    setState(() => _v3Callout = null);
  }

  TimelineItem? _timelineItemForHit(V3MapTap hit) {
    final items =
        ref.read(tripUnifiedTimelineProvider(widget.tripId)).valueOrNull ??
            const <TimelineItem>[];
    final prefix = hit.kind == V3MapTapKind.memory ? 'media:' : 'event:';
    for (final item in items) {
      if (item.id == '$prefix${hit.id}') return item;
    }
    return null;
  }

  static MapCalloutKind _calloutKindFor(V3MapTapKind kind) {
    switch (kind) {
      case V3MapTapKind.memory:
        return MapCalloutKind.memory;
      case V3MapTapKind.memoryCluster:
        return MapCalloutKind.cluster;
      case V3MapTapKind.note:
        return MapCalloutKind.note;
      case V3MapTapKind.warn:
        return MapCalloutKind.warn;
      case V3MapTapKind.geotag:
        return MapCalloutKind.geotag;
    }
  }

  static String _calloutTitleFor(V3MapTap hit, TimelineItem? item) {
    if (item is TimelineEventItem && item.body.trim().isNotEmpty) {
      return item.body.trim();
    }
    switch (hit.kind) {
      case V3MapTapKind.memory:
        return 'Photo';
      case V3MapTapKind.memoryCluster:
        return '${hit.clusterCount ?? 0} memories here';
      case V3MapTapKind.note:
        return 'Note';
      case V3MapTapKind.warn:
        return 'Warning';
      case V3MapTapKind.geotag:
        return 'Geotag';
    }
  }

  static String? _firstNonEmptyString(Iterable<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  LiveTrackingRuntimeState get _previewRuntimeState {
    switch (widget.previewState!) {
      case LiveCaptureShellState.active:
        return LiveTrackingRuntimeState.active;
      case LiveCaptureShellState.paused:
        return LiveTrackingRuntimeState.paused;
      case LiveCaptureShellState.ended:
      case LiveCaptureShellState.blocked:
        return LiveTrackingRuntimeState.ended;
      case LiveCaptureShellState.planned:
        return LiveTrackingRuntimeState.planned;
    }
  }

  LiveCaptureShellState _resolveShellState({
    required LiveTrackingRuntimeState? runtimeState,
  }) {
    if (runtimeState == null) {
      return widget.previewState ?? LiveCaptureShellState.planned;
    }
    switch (runtimeState) {
      case LiveTrackingRuntimeState.active:
        return LiveCaptureShellState.active;
      case LiveTrackingRuntimeState.paused:
        return LiveCaptureShellState.paused;
      case LiveTrackingRuntimeState.ended:
        return LiveCaptureShellState.ended;
      case LiveTrackingRuntimeState.planned:
        return LiveCaptureShellState.planned;
    }
  }

  String _resolveSyncLabel({
    required bool usePreview,
    required bool useV2Lane,
    required LiveCaptureShellState shellState,
    required EditorSyncStatus? syncStatus,
  }) {
    if (usePreview) {
      return _previewSyncLabel(shellState);
    }
    if (useV2Lane) {
      return 'Saved locally';
    }
    switch (syncStatus?.kind) {
      case EditorSyncStatusKind.blocked:
        return 'Upload blocked';
      case EditorSyncStatusKind.failed:
        return 'Upload failed';
      case EditorSyncStatusKind.syncing:
        return 'Uploading...';
      case EditorSyncStatusKind.localSaved:
        return 'Saved locally';
      case EditorSyncStatusKind.synced:
        return 'Synced';
      case EditorSyncStatusKind.activeSession:
        return 'Live session active';
      case EditorSyncStatusKind.publishing:
        return 'Publishing...';
      case null:
        return 'Syncing...';
    }
  }

  String _previewSyncLabel(LiveCaptureShellState value) {
    switch (value) {
      case LiveCaptureShellState.active:
        return 'Syncing';
      case LiveCaptureShellState.blocked:
        return 'Sync blocked';
      case LiveCaptureShellState.paused:
        return 'Up to date';
      case LiveCaptureShellState.ended:
        return 'Synced';
      case LiveCaptureShellState.planned:
        return 'Ready';
    }
  }

  bool _isV2LaneEnabled() {
    if (widget.previewState != null) {
      return false;
    }
    return _useV2Lane;
  }

  void _toggleSidePanel() {
    setState(() {
      _sidePanelOpen = !_sidePanelOpen;
      if (!_sidePanelOpen) {
        _focusedAdvisoryId = null;
      }
    });
  }

  static const Map<String, (String, Color)> _advisoryMarkerStyle = {
    'safety_warning': ('⚠️', Color(0xFFF59E0B)),
    'scam_alert': ('🚨', Color(0xFFDC2626)),
    'food_tip': ('🍜', Color(0xFFEA580C)),
    'photo_spot': ('📸', Color(0xFF7C3AED)),
    'transport_tip': ('🚌', Color(0xFF2563EB)),
    'accommodation': ('🏨', Color(0xFF0891B2)),
    'cultural_etiquette': ('🙏', Color(0xFF7C3AED)),
    'must_do': ('🎯', Color(0xFF059669)),
    'avoid': ('🚫', Color(0xFFDC2626)),
    'general_tip': ('💡', AppColors.accent),
  };

  List<AdvisoryMapMarker> _mapInsightsToMarkers(
    openapi.AdvisoryInsightListResponse? list,
  ) {
    if (list == null) return const <AdvisoryMapMarker>[];
    final out = <AdvisoryMapMarker>[];
    for (final ins in list.insights) {
      final lat = ins.placeLat?.toDouble();
      final lng = ins.placeLng?.toDouble();
      if (lat == null || lng == null) continue;
      final style = _advisoryMarkerStyle[ins.category.name] ??
          _advisoryMarkerStyle['general_tip']!;
      // "pending" = suggested (Dora recommendation, not yet acted on)
      // any other delivery status → treat as accepted (saved / acted on)
      final accepted = ins.status.name != 'pending';
      out.add(
        AdvisoryMapMarker(
          advisoryId: ins.id,
          lat: lat,
          lng: lng,
          categoryEmoji: style.$1,
          tint: style.$2,
          accepted: accepted,
        ),
      );
      if (out.length >= 15) break;
    }
    return out;
  }

  void _handleBack() {
    if (!mounted) {
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Routes.liveHubPath());
  }

  Future<void> _showOverflowMenu() async {
    if (!mounted) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Trip preferences'),
              subtitle: const Text('Edit activity focus, style, budget'),
              onTap: () => Navigator.of(ctx).pop('metadata'),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Debug diagnostics'),
              onTap: () => Navigator.of(ctx).pop('debug'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'metadata':
        _showTripMetadataEditor();
        break;
      case 'debug':
        _showMessage('Debug diagnostics: V2 active, no V1 sync state.');
        break;
    }
  }

  Future<void> _showTripMetadataEditor() async {
    if (!mounted) return;
    try {
      final authService = ref.read(authServiceProvider);
      final token = await authService.getAccessToken();
      if (token == null || token.isEmpty) return;
      final auth = 'Bearer $token';
      final serverTripId =
          await ref.read(serverTripIdProvider(widget.tripId).future);
      final metaApi = ref.read(metadataApiProvider);

      openapi.TripMetadataResponse? current;
      try {
        final resp = await metaApi.getTripMetadataApiV1TripsTripIdMetadataGet(
          tripId: serverTripId,
          authorization: auth,
        );
        current = resp.data;
      } catch (_) {}

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _TripMetadataEditSheet(
          currentActivityFocus: current?.activityFocus?.toList() ?? [],
          currentTravelStyle: current?.travelStyle?.toList() ?? [],
          currentBudgetCategory: current?.budgetCategory,
          onSave: (activityFocus, travelStyle, budgetCategory) async {
            try {
              final payload = openapi.TripMetadataUpdate((b) {
                b.activityFocus.replace(activityFocus);
                b.travelStyle.replace(travelStyle);
                b.budgetCategory = budgetCategory;
              });
              await metaApi.updateTripMetadataApiV1TripsTripIdMetadataPatch(
                tripId: serverTripId,
                authorization: auth,
                tripMetadataUpdate: payload,
              );
              if (mounted) _showMessage('Preferences updated');
            } catch (e) {
              if (mounted) _showMessage('Could not save: $e');
            }
          },
        ),
      );
    } catch (e) {
      if (mounted) _showMessage('Could not load metadata: $e');
    }
  }

  Future<void> _runLiveTrackingAction({
    required String busyLabel,
    required String successMessage,
    String? noOpMessage,
    required Future<bool> Function() action,
  }) async {
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = busyLabel;
    });
    try {
      final didApply = await action();
      if (!mounted) {
        return;
      }
      final feedback = didApply
          ? successMessage
          : (noOpMessage ?? 'No tracking state change required.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedback),
          duration: const Duration(seconds: 2),
        ),
      );
    } on LiveTrackingCaptureException catch (error) {
      await _handleLiveTrackingCaptureException(error);
    } catch (_) {
      _showMessage('Live tracking action failed. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _actionInFlight = false;
          _actionLabel = null;
        });
      }
    }
  }

  Future<void> _retrySyncNow() async {
    if (_isV2LaneEnabled()) {
      _showMessage(
          'V2 lane is local-only in this phase. No sync retry needed.');
      return;
    }
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = 'Retrying...';
    });
    try {
      final mediaWorker = ref.read(uploadQueueWorkerProvider);
      await mediaWorker.startIfIdle();
      if (!mounted) {
        return;
      }
      _triggerResolverReconcile();
      _showMessage('Sync retry queued.');
    } catch (_) {
      _showMessage('Failed to trigger sync retry.');
    } finally {
      if (mounted) {
        setState(() {
          _actionInFlight = false;
          _actionLabel = null;
        });
      }
    }
  }

  void _triggerResolverReconcile() {
    // V1 reconciliation removed — V2 resolver handles this.
  }

  void _triggerV2Recovery({
    required V2ResolverTriggerSource source,
  }) {
    if (!mounted || widget.previewState != null || !_isV2LaneEnabled()) {
      return;
    }
    if (source == V2ResolverTriggerSource.liveOpen &&
        _didTriggerV2LiveOpenRecovery) {
      return;
    }
    if (source == V2ResolverTriggerSource.liveOpen) {
      _didTriggerV2LiveOpenRecovery = true;
    }
    unawaited(
      ref.read(v2ResolverOrchestratorProvider).runRecoveryForTrip(
            tripId: widget.tripId,
            source: source,
            limit: 20,
          ),
    );
  }

  Future<void> _captureQuickEvent({
    required LiveTrackingEventType eventType,
    required String note,
    required String successMessage,
    required AppLatLng? position,
    VoidCallback? onSuccess,
  }) async {
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = 'Saving...';
    });
    try {
      if (position == null) {
        _showMessage('Location required to capture this event.');
        return;
      }
      final v2EventId =
          await ref.read(v2LiveCaptureJournalRepositoryProvider).createEventNow(
        tripId: widget.tripId,
        eventType: eventType,
        note: note,
        latitude: position.latitude,
        longitude: position.longitude,
        payload: <String, dynamic>{'note': note},
      );
      unawaited(
        ref.read(v2ResolverOrchestratorProvider).resolveCaptureCreated(
              tripId: widget.tripId,
              eventId: v2EventId,
            ),
      );
      if (!mounted) {
        return;
      }
      onSuccess?.call();
      // The V3 acknowledgement bubble is the user-facing message for
      // event captures. No separate snackbar — single message per event.
      DoraBubbleTriggers.acknowledgeEventAdd(
        ref,
        widget.tripId,
        kind: switch (eventType) {
          LiveTrackingEventType.warn => 'warn',
          LiveTrackingEventType.tag => 'geotag',
          _ => 'note',
        },
      );
    } catch (_) {
      _showMessage('Failed to capture item. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _actionInFlight = false;
          _actionLabel = null;
        });
      }
    }
  }

  Future<void> _promptForTextCapture({
    required String title,
    required String hintText,
    required String defaultPrefix,
    required LiveTrackingEventType eventType,
    required String successMessage,
    required AppLatLng? position,
  }) async {
    if (!mounted || _actionInFlight) {
      return;
    }
    final submitted = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => _TextCaptureDialog(
        title: title,
        hintText: hintText,
        initialValue: defaultPrefix,
      ),
    );
    final note = submitted?.trim();
    if (note == null || note.isEmpty) {
      return;
    }
    await _captureQuickEvent(
      eventType: eventType,
      note: note,
      successMessage: successMessage,
      position: position,
      onSuccess: eventType == LiveTrackingEventType.warn
          ? () => _emitEffect(TransientEffectType.warnCaptured)
          : null,
    );
  }

  Future<void> _openCameraCapture({
    required CameraInitialMode initialMode,
  }) async {
    if (_actionInFlight || !mounted) {
      return;
    }

    setState(() {
      _actionInFlight = true;
      _actionLabel = 'Opening camera...';
    });
    try {
      final result = await context.push<CapturePersistResult>(
        Routes.cameraPath(),
        extra: CameraLaunchArgs(
          context: CameraLaunchContext.liveTracking,
          initialMode: initialMode,
          preferredTripId: widget.tripId,
        ),
      );
      if (!mounted || result == null) {
        return;
      }
      if (result.eventId != null) {
        _dismissedReviewPromptEventIds.remove(result.eventId!);
      }
      if (result.kind == CapturedMediaKind.photo) {
        _emitEffect(TransientEffectType.photoCaptured);
      }
      // Trip-attached captures: Dora bubble is the user-facing message.
      // Vault-only captures (no trip attachment) keep the system
      // snackbar — Dora has nothing to say about non-trip media.
      if (result.attachedToTrip) {
        DoraBubbleTriggers.acknowledgeMemoryCapture(ref, widget.tripId);
      } else {
        final destinationMsg =
            result.destination == CaptureDestination.storyDraft
                ? 'Captured; story draft saved and publish queued.'
                : 'Captured locally.';
        _showMessage(destinationMsg);
      }
    } catch (_) {
      _showMessage('Failed to capture media. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _actionInFlight = false;
          _actionLabel = null;
        });
      }
    }
  }

  Future<void> _confirmProbablePlace({
    required String eventId,
    required LiveTrackingPlaceHint hint,
  }) async {
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = 'Confirming place...';
    });
    try {
      // V1 place confirmation removed — V2 resolver handles place binding.
      _showMessage('Place confirmation handled in editor review.');
    } catch (_) {
      _showMessage('Failed to confirm place. Try again.');
    } finally {
      if (mounted) {
        setState(() {
          _actionInFlight = false;
          _actionLabel = null;
        });
      }
    }
  }

  Future<void> _keepEventOnRoute(String eventId) async {
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = 'Keeping on route...';
    });
    try {
      // V1 route-keep removed — V2 resolver handles this.
      _dismissedReviewPromptEventIds.add(eventId);
      _showMessage('Capture kept on route.');
    } catch (_) {
      _showMessage('Failed to keep capture on route.');
    } finally {
      if (mounted) {
        setState(() {
          _actionInFlight = false;
          _actionLabel = null;
        });
      }
    }
  }

  void _openEditorForManualPlace(String eventId) {
    _dismissedReviewPromptEventIds.add(eventId);
    context.push(Routes.editorPath(widget.tripId));
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
        _showMessage('Location permission denied.');
        return;
      case 'tracking_trip_identity_missing':
      case 'tracking_trip_identity_stale':
        _showSyncRecoveryMessage(error.message);
        return;
      default:
        _showMessage(error.message);
        return;
    }
  }

  void _showSyncRecoveryMessage(String message) {
    if (!mounted) {
      return;
    }
    final isV2Lane = _isV2LaneEnabled();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: isV2Lane
            ? null
            : SnackBarAction(
                label: 'Retry sync',
                onPressed: _retrySyncNow,
              ),
      ),
    );
  }

  void _showMessage(String message) {
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
      message: 'Location services are off. Enable them to start live tracking.',
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
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: AppColors.divider),
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
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
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
}

class _LiveCaptureV3TopChrome extends StatelessWidget {
  const _LiveCaptureV3TopChrome({
    required this.tripName,
    required this.state,
    required this.syncLabel,
    required this.onBack,
    required this.onOverflow,
    required this.doraPill,
    required this.dimensionalToggle,
  });

  final String tripName;
  final LiveCaptureShellState state;
  final String syncLabel;
  final VoidCallback onBack;
  final VoidCallback onOverflow;
  final Widget doraPill;
  final Widget dimensionalToggle;

  @override
  Widget build(BuildContext context) {
    final label = _stateLabel(state);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        doraPill,
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: DoraColors.surfaceWhite.withValues(alpha: 0.78),
              borderRadius: DoraRadius.chipAll,
              border: Border.all(
                color: DoraColors.inkPrimary.withValues(alpha: 0.08),
              ),
              boxShadow: DoraShadow.tight,
            ),
            child: ClipRect(
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onBack,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: DoraColors.inkPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: tripName,
                              style: DoraTypography.callout.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                                color: DoraColors.inkPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '  $label - $syncLabel',
                              style: DoraTypography.caption.copyWith(
                                fontSize: 11,
                                height: 1.0,
                                color: DoraColors.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                        textScaler: const TextScaler.linear(1.0),
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onOverflow,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 20,
                          color: DoraColors.inkSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        dimensionalToggle,
      ],
    );
  }

  static String _stateLabel(LiveCaptureShellState state) {
    switch (state) {
      case LiveCaptureShellState.active:
        return 'Active';
      case LiveCaptureShellState.paused:
        return 'Paused';
      case LiveCaptureShellState.ended:
        return 'Ended';
      case LiveCaptureShellState.blocked:
        return 'Blocked';
      case LiveCaptureShellState.planned:
        return 'Ready';
    }
  }
}

class _LiveCaptureV3TimelineHandle extends ConsumerWidget {
  const _LiveCaptureV3TimelineHandle({
    required this.tripId,
    required this.onTap,
  });

  final String tripId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineCount =
        ref.watch(tripUnifiedTimelineProvider(tripId)).valueOrNull?.length ?? 0;
    final unresolvedCount =
        ref.watch(v2UnresolvedInboxProvider(tripId)).valueOrNull?.length ?? 0;
    final label = timelineCount == 0 ? 'Timeline' : '$timelineCount items';

    return Semantics(
      button: true,
      label: 'Open trip timeline',
      child: Material(
        color: DoraColors.surfaceWhite.withValues(alpha: 0.9),
        borderRadius: DoraRadius.pillAll,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: DoraRadius.pillAll,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: DoraRadius.pillAll,
              border: Border.all(
                color: DoraColors.inkPrimary.withValues(alpha: 0.08),
              ),
              boxShadow: DoraShadow.tight,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.auto_stories_outlined,
                      size: 20,
                      color: DoraColors.brandPrimary,
                    ),
                    if (unresolvedCount > 0)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: DoraColors.warn,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  textScaler: const TextScaler.linear(1.0),
                  style: DoraTypography.caption.copyWith(
                    color: DoraColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveCaptureV3TrackingControls extends StatelessWidget {
  const _LiveCaptureV3TrackingControls({
    required this.state,
    required this.isBusy,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onOpenEditor,
  });

  final LiveCaptureShellState state;
  final bool isBusy;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onOpenEditor;

  @override
  Widget build(BuildContext context) {
    final enabled = !isBusy;
    final actions = switch (state) {
      LiveCaptureShellState.planned => [
          _V3ControlAction(
            icon: Icons.play_arrow_rounded,
            label: 'Start',
            onTap: enabled ? onStart : null,
          ),
        ],
      LiveCaptureShellState.active => [
          _V3ControlAction(
            icon: Icons.pause_rounded,
            label: 'Pause',
            onTap: enabled ? onPause : null,
          ),
          _V3ControlAction(
            icon: Icons.stop_rounded,
            label: 'Stop',
            onTap: enabled ? onStop : null,
            tint: DoraColors.warn,
          ),
        ],
      LiveCaptureShellState.paused => [
          _V3ControlAction(
            icon: Icons.play_arrow_rounded,
            label: 'Resume',
            onTap: enabled ? onResume : null,
          ),
          _V3ControlAction(
            icon: Icons.stop_rounded,
            label: 'Stop',
            onTap: enabled ? onStop : null,
            tint: DoraColors.warn,
          ),
        ],
      LiveCaptureShellState.ended => [
          _V3ControlAction(
            icon: Icons.play_arrow_rounded,
            label: 'Start New',
            onTap: enabled ? onStart : null,
          ),
          _V3ControlAction(
            icon: Icons.edit_outlined,
            label: 'Review',
            onTap: enabled ? onOpenEditor : null,
          ),
        ],
      LiveCaptureShellState.blocked => [
          _V3ControlAction(
            icon: Icons.rule_folder_outlined,
            label: 'Review',
            onTap: enabled ? onOpenEditor : null,
            tint: DoraColors.warn,
          ),
        ],
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DoraColors.surfaceWhite.withValues(alpha: 0.86),
        borderRadius: DoraRadius.pillAll,
        border: Border.all(
          color: DoraColors.inkPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: DoraShadow.tight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions) _V3ControlButton(action: action),
        ],
      ),
    );
  }
}

class _LiveCaptureV3CaptureControl extends StatefulWidget {
  const _LiveCaptureV3CaptureControl({
    required this.state,
    required this.isBusy,
    required this.onPhoto,
    required this.onVideo,
    required this.onNote,
    required this.onWarn,
    required this.onTag,
    required this.onMedia,
  });

  final LiveCaptureShellState state;
  final bool isBusy;
  final VoidCallback onPhoto;
  final VoidCallback onVideo;
  final VoidCallback onNote;
  final VoidCallback onWarn;
  final VoidCallback onTag;
  final VoidCallback onMedia;

  @override
  State<_LiveCaptureV3CaptureControl> createState() =>
      _LiveCaptureV3CaptureControlState();
}

class _LiveCaptureV3CaptureControlState
    extends State<_LiveCaptureV3CaptureControl> {
  bool _expanded = false;

  bool get _canShow {
    return widget.state == LiveCaptureShellState.active ||
        widget.state == LiveCaptureShellState.paused;
  }

  bool get _canPrimary {
    return _canShow && !widget.isBusy;
  }

  @override
  Widget build(BuildContext context) {
    if (!_canShow) return const SizedBox.shrink();
    final paused = widget.state == LiveCaptureShellState.paused;
    final actions = paused
        ? [
            _V3ControlAction(
              icon: Icons.note_add_outlined,
              label: 'Note',
              onTap: _canPrimary ? widget.onNote : null,
            ),
          ]
        : [
            _V3ControlAction(
              icon: Icons.note_add_outlined,
              label: 'Note',
              onTap: _canPrimary ? widget.onNote : null,
            ),
            _V3ControlAction(
              icon: Icons.warning_amber_rounded,
              label: 'Warn',
              tint: DoraColors.warn,
              onTap: _canPrimary ? widget.onWarn : null,
            ),
            _V3ControlAction(
              icon: Icons.place_outlined,
              label: 'Tag',
              onTap: _canPrimary ? widget.onTag : null,
            ),
            _V3ControlAction(
              icon: Icons.videocam_outlined,
              label: 'Media',
              onTap: _canPrimary ? widget.onMedia : null,
            ),
          ];

    return IgnorePointer(
      ignoring: widget.isBusy,
      child: AnimatedOpacity(
        opacity: widget.isBusy ? 0.65 : 1,
        duration: DoraMotion.dismiss,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: DoraMotion.reveal,
              switchInCurve: DoraMotion.revealCurve,
              switchOutCurve: DoraMotion.dismissCurve,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: _expanded
                  ? Container(
                      key: const ValueKey('v3CaptureMenu'),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: DoraColors.surfaceWhite.withValues(alpha: 0.92),
                        borderRadius: DoraRadius.pillAll,
                        border: Border.all(
                          color: DoraColors.inkPrimary.withValues(alpha: 0.08),
                        ),
                        boxShadow: DoraShadow.tight,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final action in actions)
                            _V3ControlButton(
                              action: action,
                              onAfterTap: () =>
                                  setState(() => _expanded = false),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            GestureDetector(
              onTap: _canPrimary
                  ? (paused ? widget.onNote : widget.onPhoto)
                  : null,
              onLongPress: _canPrimary && !paused ? widget.onVideo : null,
              onVerticalDragEnd: (details) {
                final dy = details.primaryVelocity ?? 0;
                if (dy < 0) setState(() => _expanded = true);
                if (dy > 0) setState(() => _expanded = false);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.25, -0.3),
                        colors: [
                          DoraColors.brandAccent,
                          DoraColors.brandPrimary,
                        ],
                      ),
                      border: Border.all(
                        color: DoraColors.surfaceWhite,
                        width: 3,
                      ),
                      boxShadow: DoraShadow.soft,
                    ),
                    child: Icon(
                      paused
                          ? Icons.note_add_outlined
                          : Icons.photo_camera_outlined,
                      color: DoraColors.surfaceWhite,
                      size: 30,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Material(
                      color: DoraColors.surfaceWhite,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _canPrimary
                            ? () => setState(() => _expanded = !_expanded)
                            : null,
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Icon(
                            _expanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: 20,
                            color: DoraColors.brandPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _V3ControlAction {
  const _V3ControlAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint = DoraColors.brandPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color tint;
}

class _V3ControlButton extends StatelessWidget {
  const _V3ControlButton({
    required this.action,
    this.onAfterTap,
  });

  final _V3ControlAction action;
  final VoidCallback? onAfterTap;

  @override
  Widget build(BuildContext context) {
    final enabled = action.onTap != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        label: action.label,
        child: Material(
          color: enabled
              ? action.tint.withValues(alpha: 0.10)
              : DoraColors.inkTertiary.withValues(alpha: 0.10),
          borderRadius: DoraRadius.pillAll,
          child: InkWell(
            onTap: enabled
                ? () {
                    action.onTap!();
                    onAfterTap?.call();
                  }
                : null,
            borderRadius: DoraRadius.pillAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action.icon,
                      color: enabled ? action.tint : DoraColors.inkTertiary,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      action.label,
                      textScaler: const TextScaler.linear(1.0),
                      style: DoraTypography.caption.copyWith(
                        color: enabled ? action.tint : DoraColors.inkTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextCaptureDialog extends StatefulWidget {
  const _TextCaptureDialog({
    required this.title,
    required this.hintText,
    required this.initialValue,
  });

  final String title;
  final String hintText;
  final String initialValue;

  @override
  State<_TextCaptureDialog> createState() => _TextCaptureDialogState();
}

class _TextCaptureDialogState extends State<_TextCaptureDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        decoration: InputDecoration(hintText: widget.hintText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _RecentEventsPlaceholder extends StatelessWidget {
  const _RecentEventsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        key: const ValueKey('liveCaptureRecentEventsPlaceholder'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.65)),
        ),
        child: const Row(
          children: [
            Icon(Icons.bolt, size: 14),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Recent captures appear here',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncBlockedCallout extends StatelessWidget {
  const _SyncBlockedCallout({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('liveCaptureBlockedCallout'),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _UnresolvedCaptureBanner extends StatelessWidget {
  const _UnresolvedCaptureBanner({
    required this.unresolvedCount,
    required this.latestNote,
    required this.onReview,
  });

  final int unresolvedCount;
  final String? latestNote;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final headline = unresolvedCount == 1
        ? '1 capture needs place confirmation'
        : '$unresolvedCount captures need place confirmation';
    final latest =
        latestNote != null && latestNote!.isNotEmpty ? latestNote! : '';
    return Container(
      key: const ValueKey('liveCaptureUnresolvedBanner'),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.place_outlined,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                if (latest.isNotEmpty)
                  Text(
                    latest,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onReview,
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}

class _ProbablePlacePromptCard extends StatelessWidget {
  const _ProbablePlacePromptCard({
    required this.hints,
    required this.onConfirmHint,
    required this.onKeepOnRoute,
    required this.onAddPlace,
  });

  final List<LiveTrackingPlaceHint> hints;
  final ValueChanged<LiveTrackingPlaceHint>? onConfirmHint;
  final VoidCallback? onKeepOnRoute;
  final VoidCallback? onAddPlace;

  @override
  Widget build(BuildContext context) {
    final visibleHints = hints.take(3).toList(growable: false);
    return Container(
      key: const ValueKey('liveCaptureProbablePlacePrompt'),
      padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.accentSoft.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Probable place detected',
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < visibleHints.length; i++)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${visibleHints[i].name} (${(visibleHints[i].confidence * 100).round()}%)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onConfirmHint == null
                      ? null
                      : () => onConfirmHint!(visibleHints[i]),
                  child: Text(i == 0 ? 'Confirm' : 'Use'),
                ),
              ],
            ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: 0,
            children: [
              TextButton(
                onPressed: onKeepOnRoute,
                child: const Text('Keep on route'),
              ),
              OutlinedButton(
                onPressed: onAddPlace,
                child: const Text('Add place'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TripMetadataEditSheet extends StatefulWidget {
  const _TripMetadataEditSheet({
    required this.currentActivityFocus,
    required this.currentTravelStyle,
    required this.currentBudgetCategory,
    required this.onSave,
  });

  final List<String> currentActivityFocus;
  final List<String> currentTravelStyle;
  final String? currentBudgetCategory;
  final Future<void> Function(
    List<String> activityFocus,
    List<String> travelStyle,
    String? budgetCategory,
  ) onSave;

  @override
  State<_TripMetadataEditSheet> createState() => _TripMetadataEditSheetState();
}

class _TripMetadataEditSheetState extends State<_TripMetadataEditSheet> {
  late List<String> _activityFocus;
  late List<String> _travelStyle;
  String? _budgetCategory;
  bool _saving = false;

  static const _activityOptions = [
    'hiking',
    'food',
    'photography',
    'nightlife',
    'beaches',
    'cultural',
    'adventure',
    'relaxation',
  ];

  static const _styleOptions = [
    'adventure',
    'luxury',
    'budget',
    'cultural',
    'relaxed',
  ];

  static const _budgetOptions = ['budget', 'mid-range', 'luxury'];

  @override
  void initState() {
    super.initState();
    _activityFocus = List<String>.from(widget.currentActivityFocus);
    _travelStyle = List<String>.from(widget.currentTravelStyle);
    _budgetCategory = widget.currentBudgetCategory;
  }

  String _displayLabel(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trip preferences', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Changes update your advisory recommendations.',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Activity focus', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _activityOptions.map((opt) {
                final selected = _activityFocus.contains(opt);
                return FilterChip(
                  label: Text(_displayLabel(opt)),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      val
                          ? _activityFocus.add(opt)
                          : _activityFocus.remove(opt);
                    });
                  },
                  selectedColor: AppColors.accentSoft,
                  checkmarkColor: AppColors.accent,
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Travel style', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _styleOptions.map((opt) {
                final selected = _travelStyle.contains(opt);
                return FilterChip(
                  label: Text(_displayLabel(opt)),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      val ? _travelStyle.add(opt) : _travelStyle.remove(opt);
                    });
                  },
                  selectedColor: AppColors.accentSoft,
                  checkmarkColor: AppColors.accent,
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Budget', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _budgetOptions.map((opt) {
                final selected = _budgetCategory == opt;
                return ChoiceChip(
                  label: Text(_displayLabel(opt)),
                  selected: selected,
                  onSelected: (val) {
                    setState(() => _budgetCategory = val ? opt : null);
                  },
                  selectedColor: AppColors.accentSoft,
                  checkmarkColor: AppColors.accent,
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            await widget.onSave(
                              _activityFocus,
                              _travelStyle,
                              _budgetCategory,
                            );
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                    child: Text(_saving ? 'Saving...' : 'Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
