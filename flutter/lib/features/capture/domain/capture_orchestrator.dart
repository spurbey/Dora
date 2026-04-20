import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:dora/core/live_tracking/live_tracking_shared_models.dart';
import 'package:dora/core/location/location_service.dart';
import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/daos/stories_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/capture/data/media_capture_file_store.dart';
import 'package:dora/features/capture/domain/capture_models.dart';
import 'package:dora/features/capture/presentation/providers/active_live_session_provider.dart';
import 'package:dora/features/live_tracking/v2/data/live_capture_journal_repository.dart';

class CaptureOrchestrator {
  CaptureOrchestrator({
    required MediaDao mediaDao,
    required StoriesDao storiesDao,
    required V2LiveCaptureJournalRepository liveCaptureRepository,
    required MediaCaptureFileStore fileStore,
    required LocationService locationService,
    required String Function() resolveOwnerUserId,
    Uuid? uuid,
    DateTime Function()? now,
  })  : _mediaDao = mediaDao,
        _storiesDao = storiesDao,
        _liveCaptureRepository = liveCaptureRepository,
        _fileStore = fileStore,
        _locationService = locationService,
        _resolveOwnerUserId = resolveOwnerUserId,
        _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  final MediaDao _mediaDao;
  final StoriesDao _storiesDao;
  final V2LiveCaptureJournalRepository _liveCaptureRepository;
  final MediaCaptureFileStore _fileStore;
  final LocationService _locationService;
  final String Function() _resolveOwnerUserId;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<CapturePersistResult> persistCapture({
    required String sourcePath,
    required CapturedMediaKind mediaKind,
    required CaptureDestination destination,
    required CameraLaunchContext launchContext,
    required ActiveLiveSessionSummary? activeSession,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw const CapturePersistException(
        code: CapturePersistFailureCode.missingFile,
        message: 'Captured media file was not found.',
      );
    }

    final managedId = _uuid.v4();
    final managed = await _fileStore.copyCaptureToManaged(
      sourcePath: sourcePath,
      mediaId: managedId,
      mediaKind: mediaKind,
    );
    var mediaPersisted = false;
    try {
      final location = await _locationService.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      final latitude = location?.latitude;
      final longitude = location?.longitude;

      late final String mediaId;
      String? eventId;
      String? tripId;
      String? tripName;
      var attachedToTrip = false;

      if (activeSession != null) {
        if (latitude == null || longitude == null) {
          throw const CapturePersistException(
            code: CapturePersistFailureCode.locationUnavailable,
            message: 'Location is required while live tracking is active.',
          );
        }
        final eventType = mediaKind == CapturedMediaKind.video
            ? LiveTrackingEventType.media
            : LiveTrackingEventType.photo;
        final result = await _liveCaptureRepository.createMediaCaptureNow(
          tripId: activeSession.tripId,
          eventType: eventType,
          mediaKind: mediaKind == CapturedMediaKind.video
              ? V2CapturedMediaKind.video
              : V2CapturedMediaKind.photo,
          localPath: managed.path,
          latitude: latitude,
          longitude: longitude,
          mimeType: _guessMime(managed.path, mediaKind: mediaKind),
          payload: <String, dynamic>{
            'launch_context': launchContext.name,
            'destination': destination.name,
          },
        );
        mediaId = result.mediaId;
        eventId = result.eventId;
        tripId = activeSession.tripId;
        tripName = activeSession.tripName;
        attachedToTrip = true;
        mediaPersisted = true;
      } else {
        final now = _now().toUtc();
        mediaId = managedId;
        await _mediaDao.insertMedia(
          MediaCompanion.insert(
            id: mediaId,
            ownerUserId: _resolveOwnerUserId(),
            originScope: 'vault',
            mediaType: Value(mediaKind.name),
            localUri: Value(managed.path),
            mimeType: Value(_guessMime(managed.path, mediaKind: mediaKind)),
            bytesSize: Value(managed.bytesSize),
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
        mediaPersisted = true;
      }

      String? storyId;
      if (destination == CaptureDestination.storyDraft) {
        if (latitude == null || longitude == null) {
          throw const CapturePersistException(
            code: CapturePersistFailureCode.locationUnavailable,
            message: 'Location is required to create a story draft.',
          );
        }
        final now = _now().toUtc();
        storyId = _uuid.v4();
        await _storiesDao.insertStory(
          StoriesCompanion.insert(
            id: storyId,
            mediaId: mediaId,
            authorUserId: _resolveOwnerUserId(),
            centerLat: latitude,
            centerLng: longitude,
            visibility: const Value('draft'),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (sourcePath != managed.path) {
        await _safeDelete(sourcePath);
      }

      return CapturePersistResult(
        mediaId: mediaId,
        destination: destination,
        kind: mediaKind,
        attachedToTrip: attachedToTrip,
        eventId: eventId,
        storyId: storyId,
        tripId: tripId,
        tripName: tripName,
      );
    } catch (error) {
      if (!mediaPersisted) {
        await _safeDelete(managed.path);
      }
      if (sourcePath != managed.path) {
        await _safeDelete(sourcePath);
      }
      if (error is CapturePersistException) {
        rethrow;
      }
      if (error is V2LiveCaptureWriteException &&
          error.code == 'location_unavailable') {
        throw CapturePersistException(
          code: CapturePersistFailureCode.locationUnavailable,
          message: error.message,
        );
      }
      throw CapturePersistException(
        code: CapturePersistFailureCode.persistFailed,
        message: error.toString(),
      );
    }
  }

  Future<void> _safeDelete(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best effort cleanup only.
    }
  }

  String? _guessMime(
    String path, {
    required CapturedMediaKind mediaKind,
  }) {
    final lower = path.toLowerCase();
    if (mediaKind == CapturedMediaKind.video) {
      if (lower.endsWith('.mov')) return 'video/quicktime';
      if (lower.endsWith('.m4v')) return 'video/x-m4v';
      return 'video/mp4';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
