import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dora/core/media/media_permissions.dart';
import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/features/live_capture/map/live_capture_map_widget.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/data/compiled_projection_repository.dart';
import 'package:dora/features/create/data/live_tracking_capture_coordinator.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/providers/compiled_projection_provider.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_runtime_provider.dart';
import 'package:dora/features/create/presentation/providers/tracking_sync_provider.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_repository.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/providers/live_tracking_event_provider.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_action_dock.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_top_bar.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_transient_effects.dart';

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
    with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();
  final Set<String> _dismissedReviewPromptEventIds = <String>{};
  static const AppLatLng _defaultLiveCenter = AppLatLng(
    latitude: 20.5937,
    longitude: 78.9629,
  );
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
        _triggerResolverReconcile();
      }
    });
    if (widget.previewState == null) {
      _resolverReconcileTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) => _triggerResolverReconcile(),
      );
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _effectController.close();
    _resolverReconcileTimer?.cancel();
    super.dispose();
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
    if (!usePreview) {
      ref.watch(liveTrackingCaptureBootstrapProvider);
      ref.watch(trackingSyncBootstrapProvider);
    }
    final runtimeAsync = usePreview
        ? null
        : ref.watch(liveTrackingRuntimeSnapshotProvider(widget.tripId));
    final syncStatusAsync = usePreview
        ? null
        : ref.watch(liveTrackingSyncStatusProvider(widget.tripId));
    final mapOverlay = usePreview
        ? null
        : ref.watch(liveTrackingMapOverlayProvider(widget.tripId));
    final eventsAsync = usePreview
        ? null
        : ref.watch(liveTrackingEventsProvider(widget.tripId));
    final tripName = usePreview
        ? 'Live preview'
        : ref.watch(liveCaptureTripNameProvider(widget.tripId)).valueOrNull ??
            (widget.tripId.length > 8
                ? 'Trip ${widget.tripId.substring(0, 8)}'
                : 'Trip ${widget.tripId}');
    final unresolvedSummary = usePreview
        ? const LiveTrackingUnresolvedSummary(
            unresolvedCount: 0,
            latestUnresolved: null,
            latestReviewRequired: null,
            reviewHints: <LiveTrackingPlaceHint>[],
          )
        : ref.watch(liveTrackingUnresolvedSummaryProvider(widget.tripId));

    final runtimeState =
        usePreview ? _previewRuntimeState : runtimeAsync?.valueOrNull?.state;
    final syncStatus = syncStatusAsync?.valueOrNull;
    final shellState = usePreview
        ? widget.previewState!
        : _resolveShellState(runtimeState: runtimeState);
    final syncKind = syncStatus?.kind;
    final syncLabel = _resolveSyncLabel(
      usePreview: usePreview,
      shellState: shellState,
      syncStatus: syncStatusAsync?.valueOrNull,
    );
    final blockedMessage =
        syncStatus?.snapshot.firstBlockedTaskErrorMessage?.trim();
    final capturePosition = mapOverlay?.currentMarker?.position;
    final mapInitialCenter = capturePosition ??
        (mapOverlay?.pathRoute?.coordinates.isNotEmpty == true
            ? mapOverlay!.pathRoute!.coordinates.first
            : _defaultLiveCenter);
    final reviewEvent = unresolvedSummary.latestReviewRequired;
    final reviewHints = unresolvedSummary.reviewHints;
    final showReviewPrompt = !usePreview &&
        reviewEvent != null &&
        reviewHints.isNotEmpty &&
        !_dismissedReviewPromptEventIds.contains(reviewEvent.id);
    final topNotices = <Widget>[
      if (!usePreview &&
          syncStatus?.kind == EditorSyncStatusKind.blocked &&
          blockedMessage != null &&
          blockedMessage.isNotEmpty)
        _SyncBlockedCallout(
          message: blockedMessage,
          onRetry: _actionInFlight ? null : _retrySyncNow,
        ),
      if (!usePreview && unresolvedSummary.hasUnresolved)
        _UnresolvedCaptureBanner(
          unresolvedCount: unresolvedSummary.unresolvedCount,
          latestNote: unresolvedSummary.latestUnresolved?.note?.trim(),
          onReview: _actionInFlight
              ? null
              : () => context.push(Routes.editorPath(widget.tripId)),
        ),
      if (showReviewPrompt)
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
                pathPoints: mapOverlay?.pathRoute?.coordinates ?? const <AppLatLng>[],
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
                        : eventsAsync!.when(
                            data: (events) => LiveCaptureRecentEventsStrip(
                              events: events,
                              loading: false,
                            ),
                            loading: () => const LiveCaptureRecentEventsStrip(
                              events: <TrackingEventRow>[],
                              loading: true,
                            ),
                            error: (_, __) =>
                                const LiveCaptureRecentEventsStrip(
                              events: <TrackingEventRow>[],
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
                            : () => _captureMedia(
                                  eventType: LiveTrackingEventType.photo,
                                  fromCamera: true,
                                  position: capturePosition,
                                ),
                        onMedia: usePreview
                            ? null
                            : () => _captureMedia(
                                  eventType: LiveTrackingEventType.media,
                                  fromCamera: false,
                                  position: capturePosition,
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
                              action: (coordinator) async {
                                await coordinator.startTracking(
                                    tripId: widget.tripId);
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
                              action: (coordinator) async {
                                final paused = await coordinator.pauseTracking(
                                  tripId: widget.tripId,
                                );
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
                              action: (coordinator) async {
                                final resumed =
                                    await coordinator.resumeTracking(
                                  tripId: widget.tripId,
                                );
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
                              action: (coordinator) async {
                                final stopped = await coordinator.stopTracking(
                                  tripId: widget.tripId,
                                );
                                return stopped != null;
                              },
                            ),
                    onRetrySync:
                        usePreview || _actionInFlight ? null : _retrySyncNow,
                    onOpenEditor: usePreview
                        ? null
                        : () => context.push(Routes.editorPath(widget.tripId)),
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
    required LiveCaptureShellState shellState,
    required EditorSyncStatus? syncStatus,
  }) {
    if (usePreview) {
      return _previewSyncLabel(shellState);
    }
    switch (syncStatus?.kind) {
      case EditorSyncStatusKind.blocked:
        return 'Sync blocked';
      case EditorSyncStatusKind.failed:
        return 'Sync failed';
      case EditorSyncStatusKind.syncing:
        return 'Syncing...';
      case EditorSyncStatusKind.localSaved:
        return 'Saved locally';
      case EditorSyncStatusKind.synced:
        return 'Synced';
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

  Future<void> _runLiveTrackingAction({
    required String busyLabel,
    required String successMessage,
    String? noOpMessage,
    required Future<bool> Function(LiveTrackingCaptureCoordinator coordinator)
        action,
  }) async {
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = busyLabel;
    });
    try {
      final coordinator = ref.read(liveTrackingCaptureCoordinatorProvider);
      final didApply = await action(coordinator);
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
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = 'Retrying...';
    });
    try {
      await ref.read(trackingSyncWorkerProvider).startIfIdle();
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
    if (!mounted || widget.previewState != null) {
      return;
    }
    unawaited(
      ref
          .read(liveTrackingEventRepositoryProvider)
          .reconcileUnresolved(widget.tripId, limit: 20),
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
      final repository = ref.read(liveTrackingEventRepositoryProvider);
      await repository.createEventNow(
        tripId: widget.tripId,
        eventType: eventType,
        note: note,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      if (!mounted) {
        return;
      }
      onSuccess?.call();
      _showMessage(successMessage);
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

  Future<void> _captureMedia({
    required LiveTrackingEventType eventType,
    required bool fromCamera,
    required AppLatLng? position,
  }) async {
    if (_actionInFlight || !mounted) {
      return;
    }

    const permissions = MediaPermissions();
    final permissionState = fromCamera
        ? await permissions.ensureCameraPermission()
        : await permissions.ensureGalleryPermission();
    if (permissionState != MediaPermissionState.granted) {
      await _promptToOpenMediaSettings(permissions);
      return;
    }

    final picked = fromCamera
        ? await _imagePicker.pickImage(source: ImageSource.camera)
        : await _imagePicker.pickMedia();
    if (picked == null || picked.path.trim().isEmpty) {
      return;
    }
    if (!File(picked.path).existsSync()) {
      _showMessage('Captured file is unavailable. Please try again.');
      return;
    }
    if (position == null) {
      _showMessage('Waiting for GPS fix. Try again in a few seconds.');
      return;
    }

    setState(() {
      _actionInFlight = true;
      _actionLabel =
          'Saving ${eventType == LiveTrackingEventType.photo ? 'photo' : 'media'}...';
    });
    try {
      final repository = ref.read(liveTrackingEventRepositoryProvider);
      final result = await repository.createMediaCaptureNow(
        tripId: widget.tripId,
        eventType: eventType,
        localPath: picked.path,
        latitude: position.latitude,
        longitude: position.longitude,
        mimeType: picked.mimeType,
        payload: <String, dynamic>{
          'file_name': picked.name,
          'capture_source': fromCamera ? 'camera' : 'gallery',
        },
      );
      if (!mounted) {
        return;
      }
      _dismissedReviewPromptEventIds.remove(result.eventId);
      if (eventType == LiveTrackingEventType.photo) {
        _emitEffect(TransientEffectType.photoCaptured);
      }
      if (result.decision.state == 'resolved') {
        _showMessage('Captured and auto-bound to nearby place.');
      } else if (result.decision.state == 'review_required') {
        _showMessage('Captured. Review probable places when ready.');
      } else {
        _showMessage('Captured and saved on route.');
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
      final repository = ref.read(liveTrackingEventRepositoryProvider);
      final result = await repository.confirmPlaceForReviewEvent(
        eventId: eventId,
        hint: hint,
      );
      if (result == null) {
        _showMessage('Could not confirm place for this capture.');
        return;
      }
      if (result.syncedRouteMediaIds.isNotEmpty) {
        final projectionRepository =
            ref.read(compiledProjectionRepositoryProvider);
        for (final mediaId in result.syncedRouteMediaIds) {
          try {
            await projectionRepository.rebind(
              tripId: widget.tripId,
              sourceKind: 'tracking_event_media',
              sourceMediaId: mediaId,
              action: CompiledRebindAction.bind,
              tripPlaceId: result.placeId,
            );
          } catch (_) {
            // Local bind is already persisted; remote projection will catch up on next rebind.
          }
        }
      }
      _dismissedReviewPromptEventIds.add(eventId);
      _showMessage('Capture attached to place.');
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
      await ref
          .read(liveTrackingEventRepositoryProvider)
          .keepReviewEventOnRoute(eventId);
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

  Future<void> _promptToOpenMediaSettings(MediaPermissions permissions) async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission required'),
        content: const Text(
          'Camera or gallery permission is required for media capture. Open app settings to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await permissions.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
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
        ? '1 capture needs place selection'
        : '$unresolvedCount captures need place selection';
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
    final topHint = hints.first;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  '${topHint.name} (${(topHint.confidence * 100).round()}%)',
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
                    : () => onConfirmHint!(topHint),
                child: const Text('Confirm'),
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
