import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/features/capture/domain/camera_runtime_state.dart';

final cameraRuntimeControllerProvider =
    NotifierProvider.autoDispose<CameraRuntimeController, CameraRuntimeState>(
  CameraRuntimeController.new,
);

class CameraRuntimeController extends AutoDisposeNotifier<CameraRuntimeState> {
  Future<void> _transitionLock = Future<void>.value();

  @override
  CameraRuntimeState build() => const CameraRuntimeState.initial();

  Future<void> dispatch(
    CameraRuntimeEvent event, {
    String? message,
  }) {
    _transitionLock = _transitionLock.then((_) async {
      final current = state;
      final next = _reduce(current, event, message: message);
      if (next != null) {
        state = next;
      } else {
        debugPrint(
          '[camera-runtime] rejected event=${event.name} phase=${current.phase.name}',
        );
      }
    });
    return _transitionLock;
  }

  void markRouteCovered(bool covered) {
    state = state.copyWith(coveredByRoute: covered);
  }

  void markInactive(DateTime nowUtc) {
    state = state.copyWith(inactiveSince: nowUtc);
  }

  void clearInactive() {
    state = state.copyWith(clearInactiveSince: true);
  }

  void markBackground(DateTime nowUtc) {
    state = state.copyWith(backgroundSince: nowUtc);
  }

  void clearBackground() {
    state = state.copyWith(clearBackgroundSince: true);
  }

  void queueDismiss() {
    state = state.copyWith(queuedDismiss: true);
  }

  void clearQueuedDismiss() {
    state = state.copyWith(queuedDismiss: false);
  }

  void setPermissionDenied({String? message}) {
    state = state.copyWith(
      phase: CameraRuntimePhase.permissionDenied,
      errorMessage: message ?? 'Camera permission denied',
    );
  }

  void setError(String message) {
    state = state.copyWith(
      phase: CameraRuntimePhase.error,
      errorMessage: message,
    );
  }

  /// Tier-3 reset: release current camera runtime and request a full re-init.
  Future<void> forceTier3Reset({String? reason}) async {
    debugPrint('[camera-runtime] force tier3 reset reason=$reason');
    await dispatch(CameraRuntimeEvent.dispose);
    state = state.copyWith(
      phase: CameraRuntimePhase.idle,
      generation: state.generation + 1,
      launchTick: state.launchTick + 1,
      clearError: true,
      clearBackgroundSince: true,
      clearInactiveSince: true,
    );
  }

  CameraRuntimeState? _reduce(
    CameraRuntimeState current,
    CameraRuntimeEvent event, {
    String? message,
  }) {
    switch (event) {
      case CameraRuntimeEvent.initStart:
        if (current.phase != CameraRuntimePhase.idle) return null;
        return current.copyWith(
          phase: CameraRuntimePhase.initializing,
          clearError: true,
          launchTick: current.launchTick + 1,
        );
      case CameraRuntimeEvent.initSuccess:
        if (current.phase != CameraRuntimePhase.initializing) return null;
        return current.copyWith(
          phase: CameraRuntimePhase.preview,
          clearError: true,
        );
      case CameraRuntimeEvent.initFail:
        if (current.phase != CameraRuntimePhase.initializing) return null;
        return current.copyWith(
          phase: CameraRuntimePhase.error,
          errorMessage: message ?? 'Camera failed to initialize',
        );
      case CameraRuntimeEvent.permissionFail:
        if (current.phase != CameraRuntimePhase.initializing) return null;
        return current.copyWith(
          phase: CameraRuntimePhase.permissionDenied,
          errorMessage: message ?? 'Camera permission denied',
        );
      case CameraRuntimeEvent.captureStart:
        if (current.phase != CameraRuntimePhase.preview) return null;
        return current.copyWith(phase: CameraRuntimePhase.capturingPhoto);
      case CameraRuntimeEvent.captureDone:
        if (current.phase != CameraRuntimePhase.capturingPhoto) return null;
        return current.copyWith(phase: CameraRuntimePhase.persisting);
      case CameraRuntimeEvent.recordStart:
        if (current.phase != CameraRuntimePhase.preview) return null;
        return current.copyWith(phase: CameraRuntimePhase.recordingVideo);
      case CameraRuntimeEvent.recordStop:
        if (current.phase != CameraRuntimePhase.recordingVideo) return null;
        return current.copyWith(phase: CameraRuntimePhase.persisting);
      case CameraRuntimeEvent.persistDone:
        if (current.phase != CameraRuntimePhase.persisting) return null;
        return current.copyWith(
          phase: CameraRuntimePhase.preview,
          clearError: true,
        );
      case CameraRuntimeEvent.persistFail:
        if (current.phase != CameraRuntimePhase.persisting) return null;
        return current.copyWith(
          phase: CameraRuntimePhase.error,
          errorMessage: message ?? 'Failed to persist capture',
        );
      case CameraRuntimeEvent.errorRetry:
        if (current.phase != CameraRuntimePhase.error) return null;
        return current.copyWith(
          phase: CameraRuntimePhase.initializing,
          clearError: true,
        );
      case CameraRuntimeEvent.dispose:
        return current.copyWith(
          phase: CameraRuntimePhase.disposed,
          clearError: true,
        );
    }
  }
}
