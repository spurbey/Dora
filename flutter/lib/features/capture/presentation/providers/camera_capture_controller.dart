import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/live_tracking/live_tracking_shared_models.dart'
    show LiveTrackingEventType;
import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/media/media_permissions.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/capture/presentation/providers/active_live_session_provider.dart';
import 'package:dora/features/live_tracking/v2/data/live_capture_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';

/// What the user asked the Camera FAB sheet to do.
enum CaptureKind { photo, video, gallery }

/// Outcome of a capture attempt, surfaced back to the sheet so it can show a
/// snackbar or banner. `kind` discriminates between success paths (vault vs.
/// trip-attached) and failure paths (permission / error / cancellation).
enum CameraCaptureResultKind {
  cancelled,
  savedToVault,
  attachedToTrip,
  permissionDenied,
  error,
}

@immutable
class CameraCaptureResult {
  const CameraCaptureResult({
    required this.kind,
    this.mediaId,
    this.tripId,
    this.tripName,
    this.errorMessage,
  });

  const CameraCaptureResult.cancelled()
      : kind = CameraCaptureResultKind.cancelled,
        mediaId = null,
        tripId = null,
        tripName = null,
        errorMessage = null;

  final CameraCaptureResultKind kind;
  final String? mediaId;
  final String? tripId;
  final String? tripName;
  final String? errorMessage;
}

/// Riverpod notifier that orchestrates the Camera FAB capture pipeline.
/// Permissions → ImagePicker → location → (active-session branch OR
/// vault-scope write).
final cameraCaptureControllerProvider =
    NotifierProvider<CameraCaptureController, AsyncValue<void>>(
  CameraCaptureController.new,
);

class CameraCaptureController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  /// Public entry point from the bottom sheet.
  Future<CameraCaptureResult> captureAndPersist({
    required CaptureKind kind,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _run(kind);
      state = const AsyncValue.data(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return CameraCaptureResult(
        kind: CameraCaptureResultKind.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<CameraCaptureResult> _run(CaptureKind kind) async {
    final permissions = const MediaPermissions();
    final permissionState = kind == CaptureKind.gallery
        ? await permissions.ensureGalleryPermission()
        : await permissions.ensureCameraPermission();
    if (permissionState != MediaPermissionState.granted) {
      return const CameraCaptureResult(
        kind: CameraCaptureResultKind.permissionDenied,
      );
    }

    final picked = await _pickMedia(kind);
    if (picked == null) {
      return const CameraCaptureResult.cancelled();
    }

    final position = await ref
        .read(locationServiceProvider)
        .getCurrentPosition(timeLimit: const Duration(seconds: 10));
    final latitude = position?.latitude;
    final longitude = position?.longitude;

    final activeSession =
        await ref.read(activeLiveSessionProvider.future);

    if (activeSession != null) {
      return _writeTripAttached(
        picked: picked,
        session: activeSession,
        latitude: latitude,
        longitude: longitude,
      );
    }
    return _writeVault(
      picked: picked,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<_PickedMedia?> _pickMedia(CaptureKind kind) async {
    final picker = ImagePicker();
    switch (kind) {
      case CaptureKind.photo:
        final file = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 92,
        );
        return file == null
            ? null
            : _PickedMedia(
                file: File(file.path),
                mediaType: 'photo',
                mimeType: _guessMime(file.path),
              );
      case CaptureKind.video:
        final file = await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 3),
        );
        return file == null
            ? null
            : _PickedMedia(
                file: File(file.path),
                mediaType: 'video',
                mimeType: _guessMime(file.path),
              );
      case CaptureKind.gallery:
        final file = await picker.pickMedia(imageQuality: 92);
        if (file == null) {
          return null;
        }
        final lower = file.path.toLowerCase();
        final isVideo = lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.m4v');
        return _PickedMedia(
          file: File(file.path),
          mediaType: isVideo ? 'video' : 'photo',
          mimeType: _guessMime(file.path),
        );
    }
  }

  Future<CameraCaptureResult> _writeTripAttached({
    required _PickedMedia picked,
    required ActiveLiveSessionSummary session,
    required double? latitude,
    required double? longitude,
  }) async {
    if (latitude == null || longitude == null) {
      return const CameraCaptureResult(
        kind: CameraCaptureResultKind.error,
        errorMessage:
            'Location is required to attach media to the active trip.',
      );
    }
    final repo = ref.read(v2LiveCaptureJournalRepositoryProvider);
    try {
      final result = await repo.createMediaCaptureNow(
        tripId: session.tripId,
        eventType: picked.mediaType == 'video'
            ? LiveTrackingEventType.media
            : LiveTrackingEventType.photo,
        localPath: picked.file.path,
        latitude: latitude,
        longitude: longitude,
        mimeType: picked.mimeType,
      );
      return CameraCaptureResult(
        kind: CameraCaptureResultKind.attachedToTrip,
        mediaId: result.mediaId,
        tripId: session.tripId,
        tripName: session.tripName,
      );
    } on V2LiveCaptureWriteException catch (error) {
      // Session race: the trip ended between our check and the write. Fall
      // back to vault so the capture isn't lost.
      if (error.code == 'no_active_session') {
        return _writeVault(
          picked: picked,
          latitude: latitude,
          longitude: longitude,
        );
      }
      return CameraCaptureResult(
        kind: CameraCaptureResultKind.error,
        errorMessage: error.message,
      );
    }
  }

  Future<CameraCaptureResult> _writeVault({
    required _PickedMedia picked,
    required double? latitude,
    required double? longitude,
  }) async {
    final userId = _resolveOwnerUserId();
    final db = ref.read(appDatabaseProvider);
    final mediaId = const Uuid().v4();
    final now = DateTime.now().toUtc();
    int? bytesSize;
    try {
      bytesSize = await picked.file.length();
    } catch (_) {
      bytesSize = null;
    }

    await db.mediaDao.insertMedia(
      MediaCompanion.insert(
        id: mediaId,
        ownerUserId: userId,
        originScope: 'vault',
        mediaType: Value(picked.mediaType),
        localUri: Value(picked.file.path),
        mimeType: Value(picked.mimeType),
        bytesSize: Value(bytesSize),
        capturedAt: now,
        latitude: Value(latitude),
        longitude: Value(longitude),
        uploadState: const Value('local_only'),
        uploadProgress: const Value(0.0),
        retryCount: const Value(0),
        syncStatus: const Value('pending'),
        localUpdatedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return CameraCaptureResult(
      kind: CameraCaptureResultKind.savedToVault,
      mediaId: mediaId,
    );
  }

  String _resolveOwnerUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? 'unknown';
  }

  String? _guessMime(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.m4v')) return 'video/x-m4v';
    return null;
  }
}

@immutable
class _PickedMedia {
  const _PickedMedia({
    required this.file,
    required this.mediaType,
    required this.mimeType,
  });

  final File file;
  final String mediaType;
  final String? mimeType;
}

