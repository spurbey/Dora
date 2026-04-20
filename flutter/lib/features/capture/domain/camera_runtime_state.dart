import 'package:flutter/foundation.dart';

import 'package:dora/features/capture/domain/camera_runtime_config.dart';

enum CameraRuntimePhase {
  idle,
  initializing,
  preview,
  capturingPhoto,
  recordingVideo,
  persisting,
  permissionDenied,
  error,
  disposed,
}

enum CameraRuntimeEvent {
  initStart,
  initSuccess,
  initFail,
  permissionFail,
  captureStart,
  captureDone,
  recordStart,
  recordStop,
  persistDone,
  persistFail,
  errorRetry,
  dispose,
}

@immutable
class CameraRuntimeState {
  const CameraRuntimeState({
    required this.phase,
    required this.generation,
    required this.launchTick,
    this.errorMessage,
    this.queuedDismiss = false,
    this.backgroundSince,
    this.inactiveSince,
    this.coveredByRoute = false,
  });

  const CameraRuntimeState.initial()
      : phase = CameraRuntimePhase.idle,
        generation = 0,
        launchTick = 0,
        errorMessage = null,
        queuedDismiss = false,
        backgroundSince = null,
        inactiveSince = null,
        coveredByRoute = false;

  final CameraRuntimePhase phase;
  final int generation;
  final int launchTick;
  final String? errorMessage;
  final bool queuedDismiss;
  final DateTime? backgroundSince;
  final DateTime? inactiveSince;
  final bool coveredByRoute;

  bool get canCapture => phase == CameraRuntimePhase.preview;
  bool get canFlip => phase == CameraRuntimePhase.preview;
  bool get canSwitchMode => phase == CameraRuntimePhase.preview;
  bool get canBack =>
      phase != CameraRuntimePhase.capturingPhoto &&
      phase != CameraRuntimePhase.persisting &&
      phase != CameraRuntimePhase.recordingVideo;

  bool get showsControls =>
      phase == CameraRuntimePhase.preview ||
      phase == CameraRuntimePhase.capturingPhoto ||
      phase == CameraRuntimePhase.recordingVideo ||
      phase == CameraRuntimePhase.persisting;

  bool get isBusy =>
      phase == CameraRuntimePhase.capturingPhoto ||
      phase == CameraRuntimePhase.recordingVideo ||
      phase == CameraRuntimePhase.persisting ||
      phase == CameraRuntimePhase.initializing;

  bool get shouldTier3FromBackground {
    final since = backgroundSince;
    if (since == null) return false;
    final elapsed = DateTime.now().toUtc().difference(since);
    return elapsed >= kBackgroundTier2Threshold;
  }

  bool get shouldPromoteInactiveToTier2 {
    final since = inactiveSince;
    if (since == null) return false;
    final elapsed = DateTime.now().toUtc().difference(since);
    return elapsed >= kInactivePromotionThreshold;
  }

  CameraRuntimeState copyWith({
    CameraRuntimePhase? phase,
    int? generation,
    int? launchTick,
    String? errorMessage,
    bool clearError = false,
    bool? queuedDismiss,
    DateTime? backgroundSince,
    bool clearBackgroundSince = false,
    DateTime? inactiveSince,
    bool clearInactiveSince = false,
    bool? coveredByRoute,
  }) {
    return CameraRuntimeState(
      phase: phase ?? this.phase,
      generation: generation ?? this.generation,
      launchTick: launchTick ?? this.launchTick,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      queuedDismiss: queuedDismiss ?? this.queuedDismiss,
      backgroundSince: clearBackgroundSince
          ? null
          : (backgroundSince ?? this.backgroundSince),
      inactiveSince:
          clearInactiveSince ? null : (inactiveSince ?? this.inactiveSince),
      coveredByRoute: coveredByRoute ?? this.coveredByRoute,
    );
  }
}
