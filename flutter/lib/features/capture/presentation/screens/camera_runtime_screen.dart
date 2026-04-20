import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:dora/core/navigation/navigation_observers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/features/capture/domain/camera_runtime_config.dart';
import 'package:dora/features/capture/domain/camera_runtime_state.dart';
import 'package:dora/features/capture/domain/capture_models.dart';
import 'package:dora/features/capture/presentation/providers/active_live_session_provider.dart';
import 'package:dora/features/capture/presentation/providers/camera_runtime_controller.dart';
import 'package:dora/features/capture/presentation/providers/capture_orchestrator_provider.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';

class CameraRuntimeScreen extends ConsumerStatefulWidget {
  const CameraRuntimeScreen({
    super.key,
    required this.args,
  });

  final CameraLaunchArgs args;

  @override
  ConsumerState<CameraRuntimeScreen> createState() =>
      _CameraRuntimeScreenState();
}

class _CameraRuntimeScreenState extends ConsumerState<CameraRuntimeScreen>
    with WidgetsBindingObserver, RouteAware {
  dynamic _lastCameraState;
  bool _routeSubscribed = false;
  Timer? _initWatchdog;
  Timer? _inactivePromotionTimer;
  Timer? _recordingMaxTimer;
  Timer? _recordingStorageTimer;
  DateTime? _recordingStartedAt;
  StreamSubscription<AudioInterruptionEvent>? _audioInterruptionSub;
  bool _resumeProbeInFlight = false;
  bool _initRetryUsed = false;
  bool _orientationLocked = false;

  CameraInitialMode get _initialMode => widget.args.initialMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_bootstrap());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeSubscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      ref.read(appRouteObserverProvider).subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_routeSubscribed) {
      ref.read(appRouteObserverProvider).unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    _initWatchdog?.cancel();
    _inactivePromotionTimer?.cancel();
    _recordingMaxTimer?.cancel();
    _recordingStorageTimer?.cancel();
    _audioInterruptionSub?.cancel();
    unawaited(_unlockRecordingOrientation());
    unawaited(
      ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
            CameraRuntimeEvent.dispose,
          ),
    );
    super.dispose();
  }

  Future<void> _bootstrap() async {
    unawaited(_runJanitor());
    await _configureAudioInterruptionHandling();
    await _attemptInit(resetRetry: true);
  }

  Future<void> _runJanitor() async {
    final fileStore = ref.read(mediaCaptureFileStoreProvider);
    final db = ref.read(appDatabaseProvider);
    await fileStore.cleanupTempCaptureFiles();
    await fileStore.cleanupOrphanManagedFiles(db);
  }

  Future<void> _configureAudioInterruptionHandling() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _audioInterruptionSub = session.interruptionEventStream.listen(
        (event) {
          if (!mounted) return;
          if (!event.begin) return;
          final runtime = ref.read(cameraRuntimeControllerProvider);
          if (runtime.phase == CameraRuntimePhase.recordingVideo) {
            unawaited(_stopRecording(interrupted: true));
          }
        },
      );
    } catch (_) {
      // Audio interruptions are best-effort.
    }
  }

  void _startInitWatchdog() {
    _initWatchdog?.cancel();
    _initWatchdog = Timer(kCameraInitTimeout, () async {
      if (!mounted) return;
      final runtime = ref.read(cameraRuntimeControllerProvider);
      if (runtime.phase == CameraRuntimePhase.initializing) {
        if (!_initRetryUsed) {
          _initRetryUsed = true;
          await ref
              .read(cameraRuntimeControllerProvider.notifier)
              .forceTier3Reset(
                reason: 'init_watchdog_retry',
              );
          if (!mounted) return;
          await Future<void>.delayed(kCameraInitRetryDelay);
          if (!mounted) return;
          await _attemptInit(resetRetry: false);
          return;
        }
        await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
              CameraRuntimeEvent.initFail,
              message: 'Camera initialization timed out',
            );
      }
    });
  }

  Future<void> _attemptInit({required bool resetRetry}) async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      ref
          .read(cameraRuntimeControllerProvider.notifier)
          .setPermissionDenied(message: 'Camera permission denied');
      return;
    }
    if (resetRetry) {
      _initRetryUsed = false;
    }
    await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
          CameraRuntimeEvent.initStart,
        );
    _startInitWatchdog();
  }

  @override
  void didPushNext() {
    ref.read(cameraRuntimeControllerProvider.notifier).markRouteCovered(true);
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (runtime.phase == CameraRuntimePhase.recordingVideo) {
      unawaited(_stopRecording(interrupted: true));
    }
  }

  @override
  void didPopNext() {
    ref.read(cameraRuntimeControllerProvider.notifier).markRouteCovered(false);
    unawaited(_probeFastResume());
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    unawaited(
      ref.read(cameraRuntimeControllerProvider.notifier).forceTier3Reset(
            reason: 'memory_pressure',
          ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final runtimeController =
        ref.read(cameraRuntimeControllerProvider.notifier);
    final now = DateTime.now().toUtc();
    switch (state) {
      case AppLifecycleState.inactive:
        runtimeController.markInactive(now);
        _inactivePromotionTimer?.cancel();
        _inactivePromotionTimer = Timer(kInactivePromotionThreshold, () {
          if (!mounted) return;
          final runtime = ref.read(cameraRuntimeControllerProvider);
          if (runtime.inactiveSince != null) {
            runtimeController.markBackground(runtime.inactiveSince!);
          }
        });
        break;
      case AppLifecycleState.paused:
        runtimeController.markBackground(now);
        break;
      case AppLifecycleState.resumed:
        runtimeController.clearInactive();
        _inactivePromotionTimer?.cancel();
        unawaited(_handleResumed());
        break;
      case AppLifecycleState.detached:
        unawaited(
          runtimeController.forceTier3Reset(reason: 'detached'),
        );
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _handleResumed() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      ref
          .read(cameraRuntimeControllerProvider.notifier)
          .setPermissionDenied(message: 'Camera permission denied');
      return;
    }

    final runtime = ref.read(cameraRuntimeControllerProvider);
    final backgroundSince = runtime.backgroundSince;
    final tier3 = backgroundSince != null &&
        DateTime.now().toUtc().difference(backgroundSince) >=
            kBackgroundTier2Threshold;
    if (tier3) {
      await ref.read(cameraRuntimeControllerProvider.notifier).forceTier3Reset(
            reason: 'background>=${kBackgroundTier2Threshold.inSeconds}s',
          );
      if (!mounted) return;
      await _attemptInit(resetRetry: true);
      return;
    }

    ref.read(cameraRuntimeControllerProvider.notifier).clearBackground();
    await _probeFastResume();
  }

  Future<void> _probeFastResume() async {
    if (_resumeProbeInFlight) return;
    _resumeProbeInFlight = true;
    try {
      await Future<void>.delayed(kResumeFastPathProbeTimeout);
      if (!mounted) return;
      final runtime = ref.read(cameraRuntimeControllerProvider);
      final healthyPhase = runtime.phase == CameraRuntimePhase.preview ||
          runtime.phase == CameraRuntimePhase.recordingVideo ||
          runtime.phase == CameraRuntimePhase.persisting;
      final requiresLiveCamera = runtime.phase == CameraRuntimePhase.preview ||
          runtime.phase == CameraRuntimePhase.recordingVideo;
      final responsive = !requiresLiveCamera || await _isCameraResponsive();
      final healthy = healthyPhase && responsive;
      if (!healthy) {
        await ref
            .read(cameraRuntimeControllerProvider.notifier)
            .forceTier3Reset(
              reason: 'resume_probe_failed',
            );
        if (!mounted) return;
        await _attemptInit(resetRetry: true);
      }
    } finally {
      _resumeProbeInFlight = false;
    }
  }

  Future<bool> _isCameraResponsive() async {
    final state = _lastCameraState;
    if (state == null) return false;
    try {
      await state.previewSize(0).timeout(kResumeFastPathProbeTimeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final runtime = ref.watch(cameraRuntimeControllerProvider);
    final activeSession = ref.watch(activeLiveSessionProvider).valueOrNull;
    _maybeHandleQueuedDismiss(runtime);

    return PopScope<void>(
      canPop: runtime.canBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(cameraRuntimeControllerProvider.notifier).queueDismiss();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildCamera(runtime),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: _TopBar(
                runtime: runtime,
                activeTripName: activeSession?.tripName,
                onBack: () {
                  if (runtime.canBack) {
                    context.pop();
                  } else {
                    ref
                        .read(cameraRuntimeControllerProvider.notifier)
                        .queueDismiss();
                  }
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
              child: _BottomControls(
                runtime: runtime,
                onCapture: _onCaptureTap,
                onToggleMode: _toggleMode,
                onFlip: _flipCamera,
                onFlash: _toggleFlash,
                onGallery: _pickFromGallery,
              ),
            ),
            if (runtime.phase == CameraRuntimePhase.initializing)
              const Center(child: CircularProgressIndicator()),
            if (runtime.phase == CameraRuntimePhase.permissionDenied)
              _PermissionOverlay(onOpenSettings: openAppSettings),
            if (runtime.phase == CameraRuntimePhase.error)
              _ErrorOverlay(
                message: runtime.errorMessage ?? 'Camera error',
                onRetry: () async {
                  await ref
                      .read(cameraRuntimeControllerProvider.notifier)
                      .forceTier3Reset(reason: 'retry_pressed');
                  if (!mounted) return;
                  await _attemptInit(resetRetry: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _maybeHandleQueuedDismiss(CameraRuntimeState runtime) {
    if (!runtime.queuedDismiss || !runtime.canBack) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final latest = ref.read(cameraRuntimeControllerProvider);
      if (!latest.queuedDismiss || !latest.canBack) {
        return;
      }
      ref.read(cameraRuntimeControllerProvider.notifier).clearQueuedDismiss();
      if (Navigator.of(context).canPop()) {
        context.pop();
      }
    });
  }

  Widget _buildCamera(CameraRuntimeState runtime) {
    return CameraAwesomeBuilder.custom(
      saveConfig: SaveConfig.photoAndVideo(
        initialCaptureMode: _initialMode == CameraInitialMode.video
            ? CaptureMode.video
            : CaptureMode.photo,
        photoPathBuilder: (sensors) async {
          final path = await ref
              .read(mediaCaptureFileStoreProvider)
              .buildTempCapturePath(
                mediaKind: CapturedMediaKind.photo,
              );
          return SingleCaptureRequest(path, sensors.first);
        },
        videoPathBuilder: (sensors) async {
          final path = await ref
              .read(mediaCaptureFileStoreProvider)
              .buildTempCapturePath(
                mediaKind: CapturedMediaKind.video,
              );
          return SingleCaptureRequest(path, sensors.first);
        },
        videoOptions: VideoOptions(enableAudio: true),
      ),
      sensorConfig: SensorConfig.single(
        sensor: Sensor.position(SensorPosition.back),
        flashMode: FlashMode.auto,
      ),
      onMediaCaptureEvent: (dynamic event) {
        unawaited(_onMediaCaptureEvent(event));
      },
      builder: (cameraState, _) {
        _lastCameraState = cameraState;
        _syncRuntimeWithCameraState(cameraState, runtime);
        return const SizedBox.expand();
      },
    );
  }

  void _syncRuntimeWithCameraState(
      dynamic cameraState, CameraRuntimeState runtime) {
    final controller = ref.read(cameraRuntimeControllerProvider.notifier);
    cameraState.when(
      onPreparingCamera: (_) {},
      onPhotoMode: (_) {
        if (runtime.phase == CameraRuntimePhase.initializing) {
          _initWatchdog?.cancel();
          _initRetryUsed = false;
          unawaited(controller.dispatch(CameraRuntimeEvent.initSuccess));
        }
      },
      onVideoMode: (_) {
        if (runtime.phase == CameraRuntimePhase.initializing) {
          _initWatchdog?.cancel();
          _initRetryUsed = false;
          unawaited(controller.dispatch(CameraRuntimeEvent.initSuccess));
        }
      },
      onVideoRecordingMode: (_) {},
      onPreviewMode: (_) {},
      onAnalysisOnlyMode: (_) {},
    );
  }

  Future<void> _onCaptureTap() async {
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (runtime.phase == CameraRuntimePhase.recordingVideo) {
      await _stopRecording(interrupted: false);
      return;
    }
    if (!runtime.canCapture) return;

    final mode = await _currentCaptureMode();
    if (mode == CaptureMode.video) {
      await _startRecording();
      return;
    }
    await _takePhoto();
  }

  Future<void> _takePhoto() async {
    await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
          CameraRuntimeEvent.captureStart,
        );
    try {
      await _invokeCameraAction((state) => state.when(
            onPhotoMode: (photoState) => photoState.takePhoto(),
            onVideoMode: (videoState) => videoState.setState(CaptureMode.photo),
            onVideoRecordingMode: (_) {},
            onPreparingCamera: (_) {},
            onPreviewMode: (_) {},
            onAnalysisOnlyMode: (_) {},
          ));
    } catch (error) {
      ref
          .read(cameraRuntimeControllerProvider.notifier)
          .setError(error.toString());
    }
  }

  Future<void> _startRecording() async {
    final bytesAvailable = await _estimateFreeStorageBytes();
    if (bytesAvailable != null &&
        bytesAvailable < kMinimumRecordingStorageBytes) {
      _showMessage('Low storage: at least 100MB required to record video.');
      return;
    }
    await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
          CameraRuntimeEvent.recordStart,
        );
    await _lockRecordingOrientation();
    _recordingStartedAt = DateTime.now().toUtc();
    _recordingMaxTimer?.cancel();
    _recordingMaxTimer = Timer(kDefaultRecordingMaxDuration, () {
      unawaited(_stopRecording(interrupted: false));
    });
    _recordingStorageTimer?.cancel();
    _recordingStorageTimer = Timer.periodic(
      kRecordingStoragePollInterval,
      (_) async {
        final free = await _estimateFreeStorageBytes();
        if (free != null && free < kMinimumRecordingStorageBytes) {
          _showMessage('Storage limit reached, stopping recording.');
          await _stopRecording(interrupted: false);
        }
      },
    );
    try {
      await _runWithTimeout(
        kStartRecordingTimeout,
        () => _invokeCameraAction((state) => state.when(
              onVideoMode: (videoState) => videoState.startRecording(),
              onPhotoMode: (photoState) =>
                  photoState.setState(CaptureMode.video),
              onVideoRecordingMode: (_) {},
              onPreparingCamera: (_) {},
              onPreviewMode: (_) {},
              onAnalysisOnlyMode: (_) {},
            )),
      );
    } catch (error) {
      _recordingStorageTimer?.cancel();
      _recordingMaxTimer?.cancel();
      await _unlockRecordingOrientation();
      ref
          .read(cameraRuntimeControllerProvider.notifier)
          .setError('Failed to start recording: $error');
    }
  }

  Future<void> _stopRecording({required bool interrupted}) async {
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (runtime.phase != CameraRuntimePhase.recordingVideo) return;
    await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
          CameraRuntimeEvent.recordStop,
        );
    _recordingStorageTimer?.cancel();
    _recordingMaxTimer?.cancel();
    try {
      await _runWithTimeout(
        kStopRecordingTimeout,
        () => _invokeCameraAction((state) => state.when(
              onVideoRecordingMode: (recordingState) =>
                  recordingState.stopRecording(),
              onVideoMode: (_) {},
              onPhotoMode: (_) {},
              onPreparingCamera: (_) {},
              onPreviewMode: (_) {},
              onAnalysisOnlyMode: (_) {},
            )),
      );
      if (interrupted) {
        _showMessage('Recording interrupted and finalized.');
      }
    } catch (error) {
      ref
          .read(cameraRuntimeControllerProvider.notifier)
          .setError('Failed to stop recording: $error');
    } finally {
      await _unlockRecordingOrientation();
    }
  }

  Future<void> _lockRecordingOrientation() async {
    if (_orientationLocked || !mounted) {
      return;
    }
    final orientation = MediaQuery.of(context).orientation;
    final preferred = orientation == Orientation.portrait
        ? const <DeviceOrientation>[
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]
        : const <DeviceOrientation>[
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ];
    await SystemChrome.setPreferredOrientations(preferred);
    _orientationLocked = true;
  }

  Future<void> _unlockRecordingOrientation() async {
    if (!_orientationLocked) {
      return;
    }
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[]);
    _orientationLocked = false;
  }

  Future<void> _toggleMode() async {
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (!runtime.canSwitchMode) return;
    final current = await _currentCaptureMode();
    final target =
        current == CaptureMode.photo ? CaptureMode.video : CaptureMode.photo;
    await _invokeCameraAction((state) => state.setState(target));
  }

  Future<void> _flipCamera() async {
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (!runtime.canFlip) return;
    await _invokeCameraAction((state) => state.switchCameraSensor());
  }

  Future<void> _toggleFlash() async {
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (runtime.phase != CameraRuntimePhase.preview) return;
    await _invokeCameraAction((state) async {
      final current = await state.sensorConfig.flashMode;
      final next = current == FlashMode.auto
          ? FlashMode.none
          : current == FlashMode.none
              ? FlashMode.always
              : FlashMode.auto;
      await state.sensorConfig.setFlashMode(next);
    });
  }

  Future<void> _pickFromGallery() async {
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (!runtime.canCapture) return;
    final permission = await Permission.photos.request();
    if (!permission.isGranted && !permission.isLimited) {
      _showMessage('Gallery permission is required.');
      return;
    }
    final picked = await ImagePicker().pickMedia();
    if (picked == null || picked.path.trim().isEmpty) {
      return;
    }
    final lower = picked.path.toLowerCase();
    final kind = lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.m4v')
        ? CapturedMediaKind.video
        : CapturedMediaKind.photo;
    await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
          CameraRuntimeEvent.captureStart,
        );
    await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
          CameraRuntimeEvent.captureDone,
        );
    await _persistCaptured(
      path: picked.path,
      kind: kind,
    );
  }

  Future<void> _onMediaCaptureEvent(dynamic event) async {
    final status = event.status;
    if (status != MediaCaptureStatus.success) {
      if (status == MediaCaptureStatus.failure) {
        ref
            .read(cameraRuntimeControllerProvider.notifier)
            .setError('${event.exception ?? 'Capture failed'}');
      }
      return;
    }

    final kind = event.isVideo == true
        ? CapturedMediaKind.video
        : CapturedMediaKind.photo;
    final path = _resolvePathFromCaptureEvent(event);
    if (path == null || path.isEmpty) {
      ref
          .read(cameraRuntimeControllerProvider.notifier)
          .setError('Could not resolve captured file path.');
      return;
    }

    if (kind == CapturedMediaKind.photo) {
      await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
            CameraRuntimeEvent.captureDone,
          );
    }

    if (kind == CapturedMediaKind.video && _recordingStartedAt != null) {
      final elapsed = DateTime.now().toUtc().difference(_recordingStartedAt!);
      if (elapsed < kMinimumRecordingDuration) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
        await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
              CameraRuntimeEvent.persistDone,
            );
        _showMessage('Recording was too short and was discarded.');
        return;
      }
    }

    await _persistCaptured(path: path, kind: kind);
  }

  Future<void> _persistCaptured({
    required String path,
    required CapturedMediaKind kind,
  }) async {
    final destination = await _showDestinationChooser();
    final selected = destination ?? CaptureDestination.vault;

    try {
      final activeSession = await ref.read(activeLiveSessionProvider.future);
      final result = await _runWithTimeout(
        kPersistTimeout,
        () => ref.read(captureOrchestratorProvider).persistCapture(
              sourcePath: path,
              mediaKind: kind,
              destination: selected,
              launchContext: widget.args.context,
              activeSession: activeSession,
            ),
      );

      if (result.eventId != null && result.tripId != null) {
        unawaited(
          ref.read(v2ResolverOrchestratorProvider).resolveCaptureCreated(
                tripId: result.tripId!,
                eventId: result.eventId!,
              ),
        );
      }

      await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
            CameraRuntimeEvent.persistDone,
          );

      if (!mounted) return;
      context.pop<CapturePersistResult>(result);
    } catch (error) {
      await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
            CameraRuntimeEvent.persistFail,
            message: error.toString(),
          );
    }
  }

  Future<CaptureDestination?> _showDestinationChooser() {
    return showModalBottomSheet<CaptureDestination>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Save to Vault'),
              onTap: () => Navigator.of(context).pop(CaptureDestination.vault),
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: const Text('Share as Story (Draft)'),
              subtitle: const Text(
                  'Story stays local draft until publish flow ships.'),
              onTap: () =>
                  Navigator.of(context).pop(CaptureDestination.storyDraft),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _invokeCameraAction(
    FutureOr<void> Function(dynamic state) action,
  ) async {
    final state = _lastCameraState;
    if (state == null) {
      throw StateError('Camera state unavailable.');
    }
    await action(state);
  }

  Future<T> _runWithTimeout<T>(
    Duration timeout,
    Future<T> Function() task,
  ) {
    return task().timeout(timeout);
  }

  Future<CaptureMode> _currentCaptureMode() async {
    final state = _lastCameraState;
    if (state == null) {
      return _initialMode == CameraInitialMode.video
          ? CaptureMode.video
          : CaptureMode.photo;
    }
    return state.when(
      onPhotoMode: (_) => CaptureMode.photo,
      onVideoMode: (_) => CaptureMode.video,
      onVideoRecordingMode: (_) => CaptureMode.video,
      onPreparingCamera: (_) => _initialMode == CameraInitialMode.video
          ? CaptureMode.video
          : CaptureMode.photo,
      onPreviewMode: (_) => _initialMode == CameraInitialMode.video
          ? CaptureMode.video
          : CaptureMode.photo,
      onAnalysisOnlyMode: (_) => CaptureMode.photo,
    );
  }

  Future<int?> _estimateFreeStorageBytes() async {
    try {
      final dir = await Directory.systemTemp.createTemp('dora_storage_probe');
      await dir.delete(recursive: true);
      // The app does not have a cross-platform direct free-space API in this
      // codebase yet; return null to skip hard failure on unsupported devices.
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _resolvePathFromCaptureEvent(dynamic event) {
    try {
      String? path;
      event.captureRequest.when(
        single: (single) {
          path = single.file?.path;
        },
        multiple: (multiple) {
          final map = multiple.fileBySensor as Map<dynamic, dynamic>;
          if (map.isNotEmpty) {
            path = map.values.first?.path as String?;
          }
        },
      );
      return path;
    } catch (_) {
      return null;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.runtime,
    required this.activeTripName,
    required this.onBack,
  });

  final CameraRuntimeState runtime;
  final String? activeTripName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const Spacer(),
          ],
        ),
        if (activeTripName != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              'Auto-attaching to $activeTripName',
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.runtime,
    required this.onCapture,
    required this.onToggleMode,
    required this.onFlip,
    required this.onFlash,
    required this.onGallery,
  });

  final CameraRuntimeState runtime;
  final Future<void> Function() onCapture;
  final Future<void> Function() onToggleMode;
  final Future<void> Function() onFlip;
  final Future<void> Function() onFlash;
  final Future<void> Function() onGallery;

  @override
  Widget build(BuildContext context) {
    if (!runtime.showsControls) {
      return const SizedBox.shrink();
    }
    final isRecording = runtime.phase == CameraRuntimePhase.recordingVideo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: runtime.canFlip ? onFlip : null,
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => onCapture(),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: isRecording ? Colors.red : Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed:
                  runtime.phase == CameraRuntimePhase.preview ? onFlash : null,
              icon: const Icon(Icons.flash_on, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: runtime.canSwitchMode ? onToggleMode : null,
              child: Text(
                'Toggle Mode',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            TextButton(
              onPressed: runtime.canCapture ? onGallery : null,
              child: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PermissionOverlay extends StatelessWidget {
  const _PermissionOverlay({required this.onOpenSettings});

  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  size: 32, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.sm),
              const Text('Camera permission is required'),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () async {
                  await onOpenSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 32, color: AppColors.error),
              const SizedBox(height: AppSpacing.sm),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry Camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
