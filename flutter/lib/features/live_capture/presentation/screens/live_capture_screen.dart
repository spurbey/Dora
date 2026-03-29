import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/data/live_tracking_capture_coordinator.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_moment_provider.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_runtime_provider.dart';
import 'package:dora/features/create/presentation/providers/tracking_sync_provider.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_action_dock.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_map_canvas.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_top_bar.dart';

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

class _LiveCaptureScreenState extends ConsumerState<LiveCaptureScreen> {
  bool _actionInFlight = false;
  String? _actionLabel;

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
    final syncStatusAsync =
        usePreview ? null : ref.watch(editorSyncStatusProvider(widget.tripId));
    final mapOverlay = usePreview
        ? null
        : ref.watch(liveTrackingMapOverlayProvider(widget.tripId));
    final momentsAsync = usePreview
        ? null
        : ref.watch(liveTrackingMomentsProvider(widget.tripId));

    final runtimeState =
        usePreview ? _previewRuntimeState : runtimeAsync?.valueOrNull?.state;
    final shellState = usePreview
        ? widget.previewState!
        : _resolveShellState(
            runtimeState: runtimeState,
            syncStatus: syncStatusAsync?.valueOrNull,
          );
    final syncLabel = _resolveSyncLabel(
      usePreview: usePreview,
      shellState: shellState,
      syncStatus: syncStatusAsync?.valueOrNull,
    );
    final blockedMessage = syncStatusAsync
        ?.valueOrNull?.snapshot.firstBlockedTaskErrorMessage
        ?.trim();
    final capturePosition = mapOverlay?.currentMarker?.position;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: LiveCaptureMapCanvas(),
          ),
          SafeArea(
            child: Stack(
              children: [
                LiveCaptureTopBar(
                  tripName: 'Trip ${widget.tripId}',
                  state: shellState,
                  syncLabel: syncLabel,
                  onBack: () => context.pop(),
                ),
                if (shellState == LiveCaptureShellState.blocked &&
                    blockedMessage != null &&
                    blockedMessage.isNotEmpty)
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: 96,
                    child: _SyncBlockedCallout(
                      message: blockedMessage,
                      onRetry: _actionInFlight ? null : _retrySyncNow,
                    ),
                  ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md + 164,
                  child: usePreview
                      ? const _RecentEventsPlaceholder()
                      : momentsAsync!.when(
                          data: (events) => LiveCaptureRecentEventsStrip(
                            events: events,
                            loading: false,
                          ),
                          loading: () => const LiveCaptureRecentEventsStrip(
                            events: <TrackingMomentRow>[],
                            loading: true,
                          ),
                          error: (_, __) => const LiveCaptureRecentEventsStrip(
                            events: <TrackingMomentRow>[],
                            loading: false,
                          ),
                        ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      132,
                      0,
                      180,
                    ),
                    child: LiveCaptureActionDock(
                      state: shellState,
                      isBusy: _actionInFlight,
                      onPhoto: usePreview
                          ? null
                          : () => _captureQuickMoment(
                                note: 'Photo marker',
                                successMessage:
                                    'Photo marker captured locally.',
                                position: capturePosition,
                              ),
                      onMedia: usePreview
                          ? null
                          : () => _captureQuickMoment(
                                note: 'Media marker',
                                successMessage:
                                    'Media marker captured locally.',
                                position: capturePosition,
                              ),
                      onTag: usePreview
                          ? null
                          : () => _captureQuickMoment(
                                note: 'Checkpoint',
                                successMessage: 'Checkpoint captured locally.',
                                position: capturePosition,
                              ),
                      onNote: usePreview
                          ? null
                          : () => _promptForTextCapture(
                                title: 'Add Quick Note',
                                hintText: 'Write note for this location...',
                                defaultPrefix: '',
                                successMessage: 'Note captured locally.',
                                position: capturePosition,
                              ),
                      onWarn: usePreview
                          ? null
                          : () => _promptForTextCapture(
                                title: 'Add Warning',
                                hintText: 'Write warning for this location...',
                                defaultPrefix: '[Warn] ',
                                successMessage: 'Warning captured locally.',
                                position: capturePosition,
                              ),
                    ),
                  ),
                ),
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
                            noOpMessage: 'No active tracking session to pause.',
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
                              final resumed = await coordinator.resumeTracking(
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
                            noOpMessage: 'No active or paused session to stop.',
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
              ],
            ),
          ),
        ],
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
    required EditorSyncStatus? syncStatus,
  }) {
    if (runtimeState == null) {
      return widget.previewState ?? LiveCaptureShellState.planned;
    }
    if (syncStatus?.kind == EditorSyncStatusKind.blocked) {
      return LiveCaptureShellState.blocked;
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

  Future<void> _captureQuickMoment({
    required String note,
    required String successMessage,
    required AppLatLng? position,
  }) async {
    if (_actionInFlight || !mounted) {
      return;
    }
    setState(() {
      _actionInFlight = true;
      _actionLabel = 'Saving...';
    });
    try {
      final repository = ref.read(liveTrackingMomentRepositoryProvider);
      await repository.createMomentNow(
        tripId: widget.tripId,
        note: note,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      if (!mounted) {
        return;
      }
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
    required String successMessage,
    required AppLatLng? position,
  }) async {
    if (!mounted || _actionInFlight) {
      return;
    }
    final controller = TextEditingController(text: defaultPrefix);
    final submitted = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: InputDecoration(hintText: hintText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    final note = submitted?.trim();
    if (note == null || note.isEmpty) {
      return;
    }
    await _captureQuickMoment(
      note: note,
      successMessage: successMessage,
      position: position,
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
      default:
        _showMessage(error.message);
        return;
    }
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

class _RecentEventsPlaceholder extends StatelessWidget {
  const _RecentEventsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        key: const ValueKey('liveCaptureRecentEventsPlaceholder'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.bolt, size: 16),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Recent captures will appear here in the next slice.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.09),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
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
