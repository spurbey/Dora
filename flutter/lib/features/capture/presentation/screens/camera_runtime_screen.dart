import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/media/custom_gallery_picker.dart';
import 'package:dora/core/media/media_permissions.dart';
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
import 'package:dora/features/stories/presentation/providers/stories_providers.dart';

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
  int _resumeProbeFailureCount = 0;
  bool _initRetryUsed = false;
  bool _orientationLocked = false;
  bool _cameraPermissionPermanentlyDenied = false;
  String? _frozenPhotoPreviewPath;
  CaptureMode _captureMode = CaptureMode.photo;
  FlashMode _flashMode = FlashMode.auto;

  CameraInitialMode get _initialMode => widget.args.initialMode;

  @override
  void initState() {
    super.initState();
    _captureMode = _initialMode == CameraInitialMode.video
        ? CaptureMode.video
        : CaptureMode.photo;
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
    final permissionState =
        await const MediaPermissions().cameraPermissionStatus(
      requestIfDenied: true,
    );
    _cameraPermissionPermanentlyDenied =
        permissionState == MediaPermissionState.permanentlyDenied;
    if (permissionState != MediaPermissionState.granted) {
      ref.read(cameraRuntimeControllerProvider.notifier).setPermissionDenied(
            message: _cameraPermissionPermanentlyDenied
                ? 'Camera permission permanently denied'
                : 'Camera permission denied',
          );
      return;
    }
    _cameraPermissionPermanentlyDenied = false;
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
    final permissionState =
        await const MediaPermissions().cameraPermissionStatus(
      requestIfDenied: false,
    );
    _cameraPermissionPermanentlyDenied =
        permissionState == MediaPermissionState.permanentlyDenied;
    if (permissionState != MediaPermissionState.granted) {
      ref.read(cameraRuntimeControllerProvider.notifier).setPermissionDenied(
            message: _cameraPermissionPermanentlyDenied
                ? 'Camera permission permanently denied'
                : 'Camera permission denied',
          );
      return;
    }
    _cameraPermissionPermanentlyDenied = false;

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
      if (healthy) {
        _resumeProbeFailureCount = 0;
        return;
      }
      _resumeProbeFailureCount += 1;
      if (_resumeProbeFailureCount < 2) {
        return;
      }
      _resumeProbeFailureCount = 0;
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
    // Web MVP: camerawesome has no web implementation. Route users to the
    // browser file picker (gallery upload) instead of a dead camera.
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Capture')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_camera_outlined, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Live camera is mobile-only in this web preview',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Use Media upload on your trip to add photos and videos '
                  'from this device instead.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final runtime = ref.watch(cameraRuntimeControllerProvider);
    final scopedTripId = widget.args.preferredTripId;
    final activeSession = scopedTripId == null
        ? ref.watch(activeLiveSessionProvider).valueOrNull
        : ref.watch(activeLiveSessionForTripProvider(scopedTripId)).valueOrNull;
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
            if (_isPhotoPreviewFrozen)
              Positioned.fill(
                child: Image.file(
                  File(_frozenPhotoPreviewPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
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
                isVideoMode: _captureMode == CaptureMode.video,
                flashMode: _flashMode,
                onSelectPhotoMode: () => _setCaptureMode(CaptureMode.photo),
                onSelectVideoMode: () => _setCaptureMode(CaptureMode.video),
                onFlip: _flipCamera,
                onFlash: _toggleFlash,
                onGallery: _pickFromGallery,
              ),
            ),
            if (runtime.phase == CameraRuntimePhase.initializing)
              const Center(child: CircularProgressIndicator()),
            if (runtime.phase == CameraRuntimePhase.permissionDenied)
              _PermissionOverlay(
                permanentlyDenied: _cameraPermissionPermanentlyDenied,
                onTryAgain: () => _attemptInit(resetRetry: true),
                onOpenSettings: const MediaPermissions().openSettings,
              ),
            if (runtime.phase == CameraRuntimePhase.error)
              _ErrorOverlay(
                message: runtime.errorMessage ?? 'Camera error',
                onRetry: () async {
                  _clearFrozenPhotoPreview();
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
    final freezePhotoPreview = _isPhotoPreviewFrozen;
    final shouldMountCamera = runtime.phase ==
            CameraRuntimePhase.initializing ||
        runtime.phase == CameraRuntimePhase.preview ||
        runtime.phase == CameraRuntimePhase.capturingPhoto ||
        runtime.phase == CameraRuntimePhase.recordingVideo ||
        (runtime.phase == CameraRuntimePhase.persisting && !freezePhotoPreview);
    if (!shouldMountCamera) {
      _lastCameraState = null;
      return const SizedBox.expand();
    }

    return KeyedSubtree(
      key: ValueKey<int>(runtime.generation),
      child: CameraAwesomeBuilder.custom(
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
      ),
    );
  }

  void _syncRuntimeWithCameraState(
      dynamic cameraState, CameraRuntimeState runtime) {
    final controller = ref.read(cameraRuntimeControllerProvider.notifier);
    cameraState.when(
      onPreparingCamera: (_) {},
      onPhotoMode: (_) {
        _captureMode = CaptureMode.photo;
        if (runtime.phase == CameraRuntimePhase.initializing) {
          _initWatchdog?.cancel();
          _initRetryUsed = false;
          _resumeProbeFailureCount = 0;
          unawaited(controller.dispatch(CameraRuntimeEvent.initSuccess));
        }
      },
      onVideoMode: (_) {
        _captureMode = CaptureMode.video;
        if (runtime.phase == CameraRuntimePhase.initializing) {
          _initWatchdog?.cancel();
          _initRetryUsed = false;
          _resumeProbeFailureCount = 0;
          unawaited(controller.dispatch(CameraRuntimeEvent.initSuccess));
        }
      },
      onVideoRecordingMode: (_) {
        _captureMode = CaptureMode.video;
      },
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
    _clearFrozenPhotoPreview();
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
    _clearFrozenPhotoPreview();
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

  Future<void> _setCaptureMode(CaptureMode target) async {
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (!runtime.canSwitchMode) return;
    final current = await _currentCaptureMode();
    if (current == target) {
      return;
    }
    await _invokeCameraAction((state) => state.setState(target));
    if (!mounted) return;
    setState(() {
      _captureMode = target;
      if (target == CaptureMode.photo) {
        _clearFrozenPhotoPreview();
      }
    });
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
      if (!mounted) return;
      setState(() {
        _flashMode = next;
      });
    });
  }

  Future<void> _pickFromGallery() async {
    _clearFrozenPhotoPreview();
    final runtime = ref.read(cameraRuntimeControllerProvider);
    if (!runtime.canCapture) return;
    final mode = await _currentCaptureMode();
    final isLiveCaptureContext =
        widget.args.context == CameraLaunchContext.liveTracking;
    if (!mounted) return;
    try {
      final request = GalleryPickerRequest(
        allowedMedia: mode == CaptureMode.video
            ? GalleryPickerMediaFilter.videos
            : GalleryPickerMediaFilter.images,
        maxSelection:
            (mode == CaptureMode.photo && isLiveCaptureContext) ? 10 : 1,
        launchContext: isLiveCaptureContext
            ? GalleryPickerLaunchContext.liveTracking
            : GalleryPickerLaunchContext.fab,
      );
      final pickerResult = await const CustomGalleryPicker().pick(
        context: context,
        request: request,
      );
      if (pickerResult == null || pickerResult.assets.isEmpty) {
        return;
      }
      final paths = pickerResult.assets
          .map((asset) => asset.path.trim())
          .where((path) => path.isNotEmpty)
          .toList(growable: false);
      if (paths.isEmpty) {
        return;
      }

      if (mode == CaptureMode.video || !isLiveCaptureContext) {
        if (mode == CaptureMode.photo) {
          _setFrozenPhotoPreview(paths.first);
        }
        await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
              CameraRuntimeEvent.captureStart,
            );
        await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
              CameraRuntimeEvent.captureDone,
            );
        final result = await _persistCaptured(
          path: paths.first,
          kind: mode == CaptureMode.video
              ? CapturedMediaKind.video
              : CapturedMediaKind.photo,
        );
        if (result == null && mode == CaptureMode.photo) {
          _clearFrozenPhotoPreview();
        }
        return;
      }

      CapturePersistResult? firstResult;
      for (final path in paths) {
        if (!mounted) break;
        await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
              CameraRuntimeEvent.captureStart,
            );
        await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
              CameraRuntimeEvent.captureDone,
            );
        final result = await _persistCaptured(
          path: path,
          kind: CapturedMediaKind.photo,
          popOnSuccess: false,
          forcedDestination: CaptureDestination.vault,
        );
        if (result == null) {
          break;
        }
        firstResult ??= result;
      }
      if (mounted && firstResult != null) {
        context.pop<CapturePersistResult>(firstResult);
      }
    } on PlatformException {
      _showMessage('Could not open gallery.');
    }
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
      _setFrozenPhotoPreview(path);
      await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
            CameraRuntimeEvent.captureDone,
          );
    }

    if (kind == CapturedMediaKind.video && _recordingStartedAt != null) {
      _clearFrozenPhotoPreview();
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

  Future<CapturePersistResult?> _persistCaptured({
    required String path,
    required CapturedMediaKind kind,
    bool popOnSuccess = true,
    CaptureDestination? forcedDestination,
  }) async {
    final destination = forcedDestination ?? await _showDestinationChooser();
    final selected = destination ?? CaptureDestination.vault;

    try {
      final activeSession = await _resolveActiveSessionForPersist();
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

      if (selected == CaptureDestination.storyDraft && result.storyId != null) {
        unawaited(
          ref
              .read(storyPublishControllerProvider.notifier)
              .publishLocalStory(result.storyId!, bestEffort: true),
        );
      }

      if (!mounted) return result;
      if (popOnSuccess) {
        context.pop<CapturePersistResult>(result);
      }
      return result;
    } catch (error) {
      await ref.read(cameraRuntimeControllerProvider.notifier).dispatch(
            CameraRuntimeEvent.persistFail,
            message: error.toString(),
          );
      return null;
    }
  }

  Future<ActiveLiveSessionSummary?> _resolveActiveSessionForPersist() async {
    final scopedTripId = widget.args.preferredTripId;
    if (scopedTripId == null) {
      return ref.read(activeLiveSessionProvider.future);
    }
    return ref.read(activeLiveSessionForTripProvider(scopedTripId).future);
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
              title: const Text('Share as Story'),
              subtitle:
                  const Text('Publishes now; retries from Vault on failure.'),
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
      return _captureMode;
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
      final diskSpace = DiskSpacePlus();
      final freeMb = await diskSpace.getFreeDiskSpace;
      if (freeMb == null || freeMb <= 0) {
        return null;
      }
      final bytes = freeMb * 1024 * 1024;
      if (bytes.isNaN || bytes.isInfinite || bytes <= 0) {
        return null;
      }
      return bytes.floor();
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

  bool get _isPhotoPreviewFrozen =>
      _frozenPhotoPreviewPath != null && (_frozenPhotoPreviewPath!.isNotEmpty);

  void _setFrozenPhotoPreview(String path) {
    if (!mounted) {
      _frozenPhotoPreviewPath = path;
      return;
    }
    setState(() {
      _frozenPhotoPreviewPath = path;
    });
  }

  void _clearFrozenPhotoPreview() {
    if (_frozenPhotoPreviewPath == null) {
      return;
    }
    if (!mounted) {
      _frozenPhotoPreviewPath = null;
      return;
    }
    setState(() {
      _frozenPhotoPreviewPath = null;
    });
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
    required this.isVideoMode,
    required this.flashMode,
    required this.onCapture,
    required this.onSelectPhotoMode,
    required this.onSelectVideoMode,
    required this.onFlip,
    required this.onFlash,
    required this.onGallery,
  });

  final CameraRuntimeState runtime;
  final bool isVideoMode;
  final FlashMode flashMode;
  final Future<void> Function() onCapture;
  final Future<void> Function() onSelectPhotoMode;
  final Future<void> Function() onSelectVideoMode;
  final Future<void> Function() onFlip;
  final Future<void> Function() onFlash;
  final Future<void> Function() onGallery;

  @override
  Widget build(BuildContext context) {
    if (!runtime.showsControls) {
      return const SizedBox.shrink();
    }
    final isRecording = runtime.phase == CameraRuntimePhase.recordingVideo;
    final flashIcon = flashMode == FlashMode.auto
        ? Icons.flash_auto
        : flashMode == FlashMode.always
            ? Icons.flash_on
            : Icons.flash_off;

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
              child: SizedBox(
                width: 84,
                height: 84,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: isRecording ? 26 : 56,
                      height: isRecording ? 26 : 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isRecording
                            ? null
                            : Border.all(color: Colors.white, width: 3),
                        color: isRecording ? Colors.red : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed:
                  runtime.phase == CameraRuntimePhase.preview ? onFlash : null,
              icon: Icon(flashIcon, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: runtime.canSwitchMode ? onSelectPhotoMode : null,
              style: FilledButton.styleFrom(
                backgroundColor: isVideoMode
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white,
                foregroundColor: isVideoMode ? Colors.white : Colors.black,
              ),
              child: const Text('Photo'),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.tonal(
              onPressed: runtime.canSwitchMode ? onSelectVideoMode : null,
              style: FilledButton.styleFrom(
                backgroundColor: isVideoMode
                    ? Colors.red.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
              ),
              child: const Text('Video'),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton.icon(
              onPressed: runtime.canCapture ? onGallery : null,
              icon:
                  const Icon(Icons.photo_library_outlined, color: Colors.white),
              label:
                  const Text('Gallery', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}

class _PermissionOverlay extends StatelessWidget {
  const _PermissionOverlay({
    required this.permanentlyDenied,
    required this.onTryAgain,
    required this.onOpenSettings,
  });

  final bool permanentlyDenied;
  final Future<void> Function() onTryAgain;
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
              Text(
                permanentlyDenied
                    ? 'Camera permission is blocked'
                    : 'Camera permission is required',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!permanentlyDenied)
                FilledButton(
                  onPressed: onTryAgain,
                  child: const Text('Try Again'),
                ),
              if (permanentlyDenied)
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
