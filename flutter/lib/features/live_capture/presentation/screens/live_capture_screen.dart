import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/features/capture/domain/capture_models.dart';
import 'package:dora/features/live_capture/map/live_capture_map_widget.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/live_tracking/live_tracking_shared_models.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_action_dock.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_top_bar.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_transient_effects.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_inbox_provider.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_review_panel.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_live_tracking_runtime_provider.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/features/advisory/providers/advisory_providers.dart';
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
  });

  final String tripId;
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
  Timer? _resolverReconcileTimer;

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
    final v2CompilerEnabled = !usePreview;
    final useV2Lane = !usePreview;
    _useV2Lane = useV2Lane;
    if (!usePreview) {
      ref.watch(v2CaptureBootstrapProvider);
    }
    final runtimeAsync = usePreview
        ? null
        : ref.watch(v2LiveTrackingRuntimeSnapshotProvider(widget.tripId));
    final AsyncValue<EditorSyncStatus>? syncStatusAsync = null;
    final mapOverlay = usePreview
        ? null
        : ref.watch(v2LiveTrackingMapOverlayProvider(widget.tripId));
    final v2EventsAsync = usePreview || !useV2Lane
        ? null
        : ref.watch(v2LiveCaptureEventsProvider(widget.tripId));
    final v2RecentProjectionAsync = usePreview || !v2CompilerEnabled
        ? null
        : ref.watch(v2LiveRecentProjectionProvider(widget.tripId));
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
      if (!usePreview && useV2Lane && v2InboxItems.isNotEmpty)
        V2UnresolvedReviewPanel(
          items: v2InboxItems,
          interactive: false,
          onReviewInEditor: _actionInFlight
              ? null
              : () => context.push(Routes.editorPath(widget.tripId)),
          title: 'Needs review',
        ),
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
              child: LiveCaptureMapWidget(
                key: ValueKey('liveCaptureMap-${widget.tripId}'),
                initialCenter: mapInitialCenter,
                initialZoom: 13,
                position: capturePosition,
                pathPoints:
                    mapOverlay?.pathRoute?.coordinates ?? const <AppLatLng>[],
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  _withEntrance(
                    LiveCaptureTopBar(
                      tripName: tripName,
                      state: shellState,
                      syncLabel: syncLabel,
                      syncKind: syncKind,
                      onBack: _handleBack,
                      onOverflow: _showOverflowMenu,
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
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md + 86,
                    child: usePreview
                        ? const _RecentEventsPlaceholder()
                        : v2CompilerEnabled
                            ? v2RecentProjectionAsync!.when(
                                data: (entries) => LiveCaptureRecentEventsStrip(
                                  events: _mapV2ProjectionRecentEvents(entries),
                                  loading: false,
                                ),
                                loading: () =>
                                    const LiveCaptureRecentEventsStrip(
                                  events: <LiveCaptureRecentEventItem>[],
                                  loading: true,
                                ),
                                error: (_, __) =>
                                    const LiveCaptureRecentEventsStrip(
                                  events: <LiveCaptureRecentEventItem>[],
                                  loading: false,
                                ),
                              )
                            : v2EventsAsync!.when(
                                data: (events) => LiveCaptureRecentEventsStrip(
                                  events: _mapV2RecentEvents(events),
                                  loading: false,
                                ),
                                loading: () =>
                                    const LiveCaptureRecentEventsStrip(
                                  events: <LiveCaptureRecentEventItem>[],
                                  loading: true,
                                ),
                                error: (_, __) =>
                                    const LiveCaptureRecentEventsStrip(
                                  events: <LiveCaptureRecentEventItem>[],
                                  loading: false,
                                ),
                              ),
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
                                    hintText: 'Write note for this location...',
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
                                    successMessage: 'Warning captured locally.',
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
          ],
        ),
      ),
    );
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

  List<LiveCaptureRecentEventItem> _mapV2RecentEvents(
    List<EventJournalRow> events,
  ) {
    return events
        .map(
          (event) => LiveCaptureRecentEventItem(
            id: event.eventId,
            eventType: event.eventType,
            note: _extractV2EventNote(event),
            capturedAt: event.capturedAt,
            syncLabel: _resolverLabel(event.resolverState),
          ),
        )
        .toList(growable: false);
  }

  List<LiveCaptureRecentEventItem> _mapV2ProjectionRecentEvents(
    List<V2TimelineProjectionEntry> entries,
  ) {
    return entries
        .map(
          (entry) => LiveCaptureRecentEventItem(
            id: entry.entryId,
            eventType: entry.eventType,
            note: entry.title,
            capturedAt: entry.capturedAt,
            syncLabel: _chipLabel(entry.syncChipState),
          ),
        )
        .toList(growable: false);
  }

  String _chipLabel(String chipState) {
    switch (chipState) {
      case 'commit_pending':
        return 'Saved locally';
      case 'committing':
        return 'Saved locally';
      case 'committed':
        return 'Saved locally';
      case 'commit_failed_retryable':
        return 'Saved locally';
      case 'local_only':
      default:
        return 'Local';
    }
  }

  String _resolverLabel(String resolverState) {
    switch (resolverState) {
      case 'place_bound':
        return 'Bound';
      case 'review_required':
        return 'Needs review';
      case 'geotag_final':
        return 'Geo-tagged';
      case 'geotag_unresolved':
      default:
        return 'Local';
    }
  }

  String? _extractV2EventNote(EventJournalRow event) {
    final payload = event.payloadJson;
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final note = decoded['note'];
      if (note is String && note.trim().isNotEmpty) {
        return note.trim();
      }
    } catch (_) {
      // no-op: notes are optional in payload.
    }
    return null;
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
      _showMessage(
          'Captured locally. Review in editor if a place needs confirmation.');
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
      final destinationMsg = result.destination == CaptureDestination.storyDraft
          ? 'Captured and saved as a story draft.'
          : 'Captured locally.';
      final attachMsg = result.attachedToTrip
          ? ' Attached to ${result.tripName ?? 'active trip'}.'
          : '';
      _showMessage('$destinationMsg$attachMsg');
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
            Text('Trip preferences', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Changes update your advisory recommendations.',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Activity focus', style: AppTypography.h3),
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
            Text('Travel style', style: AppTypography.h3),
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
            Text('Budget', style: AppTypography.h3),
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
                            if (mounted) Navigator.of(context).pop();
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
