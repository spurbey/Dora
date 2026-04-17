import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart' as crypto;
import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora/features/trips/data/trips_api.dart';

const String kTripStatusLiveEditing = 'live_editing';
const String kTripStatusEditing = 'editing';
const String kTripStatusSaved = 'saved';
const String kTripStatusPublished = 'published';

const String kPublishStatePending = 'publish_pending';
const String kPublishStatePublishing = 'publishing';
const String kPublishStateFailedRetryable = 'publish_failed_retryable';
const String kPublishStatePublished = 'published';

const int _v2PublishSchemaVersion = 1;
const int _publishChunkMaxBytes = 128 * 1024;
const int _publishMaxPayloadBytes = 64 * 1024 * 1024;

class TripPublishActionResult {
  const TripPublishActionResult({
    required this.ok,
    required this.message,
    this.requiresSaveFirst = false,
  });

  final bool ok;
  final String message;
  final bool requiresSaveFirst;
}

class TripsRepository {
  TripsRepository(
    this._db,
    this._api,
    this._authService,
    this._liveTrackingApi,
  );

  final AppDatabase _db;
  final TripsApi _api;
  final AuthService _authService;
  final LiveTrackingApi _liveTrackingApi;

  static const int _pageSize = 50;

  Future<List<UserTrip>> getCachedUserTrips() async {
    final userId = _currentUserId();
    if (userId == null) {
      return const <UserTrip>[];
    }
    final cached = await _db.userTripsDao.getTripsForUser(userId);
    return _resolveLifecycleStatuses(cached);
  }

  Future<List<UserTrip>> getUserTrips({bool forceRefresh = false}) async {
    final userId = _currentUserId();
    if (userId == null) {
      return const <UserTrip>[];
    }
    final cached = await _db.userTripsDao.getTripsForUser(userId);

    try {
      // Always try backend first so My Trips stays backend-authoritative.
      final remoteTrips = await _fetchAllRemoteTrips();
      final merged = await _mergeTrips(
        userId: userId,
        localTrips: cached,
        remoteTrips: remoteTrips,
      );
      final resolved = await _resolveLifecycleStatuses(merged);
      await _persistMergedTrips(userId: userId, mergedTrips: resolved);
      return resolved;
    } catch (e) {
      if (cached.isNotEmpty) {
        return _resolveLifecycleStatuses(cached);
      }
      final operation = forceRefresh ? 'refresh' : 'load';
      throw TripsRepositoryException('Failed to $operation trips: $e');
    }
  }

  Future<UserTrip?> getActiveTrip() async {
    final trips = await getUserTrips();
    for (final trip in trips) {
      if (trip.isActive) {
        return trip;
      }
    }
    return null;
  }

  Future<UserTrip> duplicateTrip(String id) async {
    final userId = _requireCurrentUserId();
    try {
      final remoteId = await _resolveRemoteTripIdForUserTripId(
        localTripId: id,
        userId: userId,
      );
      final duplicated = await _api.duplicateTrip(remoteId);
      await _db.userTripsDao.insertTrip(duplicated);
      return duplicated;
    } catch (e) {
      final original = await _db.userTripsDao.getTripByIdForUser(id, userId);
      if (original == null) {
        throw TripsRepositoryException('Trip not found');
      }

      final now = DateTime.now();
      final duplicated = original.copyWith(
        id: const Uuid().v4(),
        name: _copyName(original.name),
        status: 'editing',
        lastEditedAt: now,
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'pending',
        createdAt: now,
      );

      await _db.userTripsDao.insertTrip(duplicated);
      await _markSyncFailed(duplicated.id);
      return duplicated;
    }
  }

  Future<void> deleteTrip(String id) async {
    final userId = _requireCurrentUserId();
    final existing = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (existing == null) {
      return;
    }

    await _db.userTripsDao.deleteTrip(id);

    // Local-only pending trips have no guaranteed backend representation yet.
    if (existing.syncStatus != 'synced') {
      return;
    }

    try {
      final remoteTripId = await _resolveRemoteTripIdForUserTrip(
        trip: existing,
        userId: userId,
      );
      await _api.deleteTrip(remoteTripId);
    } catch (e) {
      final restored = existing.copyWith(
        syncStatus: 'failed',
        localUpdatedAt: DateTime.now(),
      );
      await _db.userTripsDao.insertTrip(restored);
      throw TripsRepositoryException('Failed to delete trip: $e');
    }
  }

  Future<UserTrip> updateVisibility(String id, String visibility) async {
    final userId = _requireCurrentUserId();
    final trip = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (trip == null) {
      throw TripsRepositoryException('Trip not found');
    }

    try {
      final currentSnapshotDigest = await _currentSnapshotDigest(id);
      final publishState = await _db.tripPublishStateDao.getState(id);
      final publishedDigest = publishState?.lastSavedSnapshotDigest;

      if (visibility == 'public' &&
          (currentSnapshotDigest == null ||
              publishedDigest == null ||
              publishedDigest != currentSnapshotDigest)) {
        throw TripsRepositoryException('Publish required before sharing');
      }

      final now = DateTime.now().toUtc();
      final remoteTripId = await _resolveRemoteTripIdForUserTrip(
        trip: trip,
        userId: userId,
      );
      final remote = await _api.updateTripVisibility(remoteTripId, visibility);
      final merged = remote.copyWith(
        id: trip.id,
        userId: trip.userId,
        localUpdatedAt: now,
        syncStatus: 'synced',
      );
      final resolved = await _resolveLifecycleStatus(
        merged.copyWith(
          visibility: visibility,
          localUpdatedAt: now,
          syncStatus: 'synced',
        ),
      );
      await _db.userTripsDao.updateTrip(resolved);
      return resolved;
    } catch (e) {
      await _markSyncFailed(trip.id);
      throw TripsRepositoryException('Failed to update visibility: $e');
    }
  }

  Future<TripPublishActionResult> saveTrip(String id) async {
    final userId = _requireCurrentUserId();
    final trip = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (trip == null) {
      return const TripPublishActionResult(
        ok: false,
        message: 'Trip not found.',
      );
    }

    final hasLiveSession = await _hasActiveOrPausedSession(id);
    if (hasLiveSession) {
      return const TripPublishActionResult(
        ok: false,
        message: 'Stop live tracking before saving.',
      );
    }

    final snapshot = await _buildSnapshotPayload(id);
    if (snapshot.sessions.isEmpty) {
      return const TripPublishActionResult(
        ok: false,
        message: 'No captured session to save yet.',
      );
    }
    if (snapshot.payloadBytes > _publishMaxPayloadBytes) {
      return const TripPublishActionResult(
        ok: false,
        message: 'Trip snapshot is too large to save.',
      );
    }

    late final String remoteTripId;
    try {
      remoteTripId = await _resolveRemoteTripIdForUserTrip(
        trip: trip,
        userId: userId,
      );
    } catch (e) {
      return TripPublishActionResult(
        ok: false,
        message: _humanizeError(e),
      );
    }
    final mediaManifest = await _buildMediaManifest(snapshot.mediaRows);
    final mediaManifestPayload =
        mediaManifest.map((item) => item.toManifestPayload()).toList();
    final mediaManifestDigest = _sha256Hex(
      _canonicalJson(mediaManifestPayload),
    );
    final publishJobId = 'save_${const Uuid().v4()}';
    final now = DateTime.now().toUtc();
    await _upsertTripPublishState(
      id,
      publishState: kPublishStatePublishing,
      publishJobId: publishJobId,
      updatedAt: now,
      lastErrorCode: null,
      lastErrorMessage: null,
    );

    try {
      final startResponse = await _liveTrackingApi.publishStartV2(
        tripId: remoteTripId,
        idempotencyKey:
            'publish:start:$remoteTripId:$publishJobId:${snapshot.snapshotDigest}',
        clientJobId: publishJobId,
        schemaVersion: _v2PublishSchemaVersion,
        publishSummary: {
          'snapshot_hash': snapshot.snapshotDigest,
          'session_count': snapshot.sessions.length,
          'event_count': snapshot.events.length,
          'media_count': snapshot.media.length,
          'point_count': snapshot.routePoints.length,
          'payload_bytes': snapshot.payloadBytes,
          if (snapshot.startedAt != null)
            'started_at': _isoUtc(snapshot.startedAt!),
          if (snapshot.endedAt != null)
            'ended_at': _isoUtc(snapshot.endedAt!),
        },
        mediaManifest: mediaManifestPayload,
        mediaManifestDigest: mediaManifestDigest,
      );

      final publishToken = _stringFromMap(startResponse, 'publish_token');
      if (publishToken == null || publishToken.isEmpty) {
        throw TripsRepositoryException(
          'Save failed: backend did not return publish token.',
        );
      }

      final uploadTargets = _uploadTargetsFromResponse(startResponse);
      final uploadedMediaRefs = await _uploadMediaAndBuildRefs(
        manifest: mediaManifest,
        uploadTargets: uploadTargets,
      );

      await _liveTrackingApi.publishMediaCompleteV2(
        tripId: remoteTripId,
        idempotencyKey:
            'publish:media-complete:$remoteTripId:$publishJobId:$mediaManifestDigest',
        publishToken: publishToken,
        clientJobId: publishJobId,
        schemaVersion: _v2PublishSchemaVersion,
        uploadedMedia: uploadedMediaRefs,
      );

      final chunks = _splitPayloadIntoChunks(
        snapshot.payloadJson,
        maxBytes: _publishChunkMaxBytes,
      );
      final chunkHashes = <String>[];
      for (var index = 0; index < chunks.length; index++) {
        final chunk = chunks[index];
        final chunkHash = _sha256Hex(chunk);
        chunkHashes.add(chunkHash);
        await _liveTrackingApi.publishPayloadChunkV2(
          tripId: remoteTripId,
          idempotencyKey:
              'publish:payload-chunk:$remoteTripId:$publishJobId:$index:$chunkHash',
          publishToken: publishToken,
          clientJobId: publishJobId,
          schemaVersion: _v2PublishSchemaVersion,
          chunkIndex: index,
          totalChunks: chunks.length,
          chunkContentHash: chunkHash,
          chunkJson: chunk,
        );
      }

      final acceptedChunksDigest = _sha256Hex(chunkHashes.join('|'));
      await _liveTrackingApi.publishCommitV2(
        tripId: remoteTripId,
        idempotencyKey:
            'publish:commit:$remoteTripId:$publishJobId:${snapshot.snapshotDigest}:$acceptedChunksDigest',
        publishToken: publishToken,
        clientJobId: publishJobId,
        schemaVersion: _v2PublishSchemaVersion,
      );

      await _upsertTripPublishState(
        id,
        publishState: kPublishStatePending,
        publishJobId: publishJobId,
        lastSavedSnapshotDigest: snapshot.snapshotDigest,
        lastSavedAt: now,
        updatedAt: now,
        lastErrorCode: null,
        lastErrorMessage: null,
      );
      await _refreshTripLifecycleById(id, userId);

      return const TripPublishActionResult(
        ok: true,
        message: 'Trip saved.',
      );
    } catch (e) {
      await _upsertTripPublishState(
        id,
        publishState: kPublishStateFailedRetryable,
        publishJobId: publishJobId,
        updatedAt: DateTime.now().toUtc(),
        lastErrorCode: 'save_failed',
        lastErrorMessage: e.toString(),
      );
      await _refreshTripLifecycleById(id, userId);
      return TripPublishActionResult(
        ok: false,
        message: 'Save failed. ${_humanizeError(e)}',
      );
    }
  }

  Future<TripPublishActionResult> publishTrip(String id) async {
    final userId = _requireCurrentUserId();
    final trip = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (trip == null) {
      return const TripPublishActionResult(
        ok: false,
        message: 'Trip not found.',
      );
    }

    final hasLiveSession = await _hasActiveOrPausedSession(id);
    if (hasLiveSession) {
      return const TripPublishActionResult(
        ok: false,
        message: 'Stop live tracking before publishing.',
      );
    }

    final currentDigest = await _currentSnapshotDigest(id);
    final state = await _db.tripPublishStateDao.getState(id);
    final lastSavedDigest = state?.lastSavedSnapshotDigest;
    if (currentDigest == null ||
        lastSavedDigest == null ||
        lastSavedDigest != currentDigest) {
      return const TripPublishActionResult(
        ok: false,
        message: 'Save required before publishing.',
        requiresSaveFirst: true,
      );
    }

    try {
      final updated = await updateVisibility(id, 'public');
      final now = DateTime.now().toUtc();
      await _upsertTripPublishState(
        id,
        publishState: kPublishStatePublished,
        publishJobId: state?.publishJobId,
        lastSavedSnapshotDigest: lastSavedDigest,
        lastSavedAt: state?.lastSavedAt,
        lastPublishedSnapshotDigest: currentDigest,
        lastPublishedAt: now,
        updatedAt: now,
        lastErrorCode: null,
        lastErrorMessage: null,
      );
      await _db.userTripsDao.updateTrip(updated.copyWith(
        status: kTripStatusPublished,
        syncStatus: 'synced',
      ));
      return const TripPublishActionResult(
        ok: true,
        message: 'Trip published.',
      );
    } catch (e) {
      await _upsertTripPublishState(
        id,
        publishState: kPublishStateFailedRetryable,
        publishJobId: state?.publishJobId,
        updatedAt: DateTime.now().toUtc(),
        lastErrorCode: 'publish_failed',
        lastErrorMessage: e.toString(),
      );
      await _refreshTripLifecycleById(id, userId);
      return TripPublishActionResult(
        ok: false,
        message: 'Publish failed. ${_humanizeError(e)}',
        requiresSaveFirst: false,
      );
    }
  }

  Future<bool> hasPendingChanges() async {
    final userId = _currentUserId();
    if (userId == null) {
      return false;
    }
    final trips = await _db.userTripsDao.getTripsForUser(userId);
    return trips.any((trip) => trip.syncStatus != 'synced');
  }

  Future<void> clearCache() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    final tripIds = (await _db.tripDao.getAllTrips())
        .where((trip) => trip.userId == userId)
        .map((trip) => trip.id)
        .toList();

    await _db.transaction(() async {
      await _db.userTripsDao.clearAllForUser(userId);
      await _db.delete(_db.publicTrips).go();
      if (tripIds.isNotEmpty) {
        await (_db.delete(_db.places)..where((t) => t.tripId.isIn(tripIds)))
            .go();
        await (_db.delete(_db.routes)..where((t) => t.tripId.isIn(tripIds)))
            .go();
        await (_db.delete(_db.media)..where((t) => t.tripId.isIn(tripIds)))
            .go();
      }
      await (_db.delete(_db.trips)..where((t) => t.userId.equals(userId))).go();
    });
  }

  String? _currentUserId() {
    final userId = _authService.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  String _requireCurrentUserId() {
    final userId = _currentUserId();
    if (userId == null) {
      throw TripsRepositoryException('No authenticated user');
    }
    return userId;
  }

  Future<List<UserTrip>> _fetchAllRemoteTrips() async {
    final allTrips = <UserTrip>[];
    const maxPages = 20;
    var page = 1;

    while (page <= maxPages) {
      final pageTrips = await _api.getUserTrips(
        page: page,
        limit: _pageSize,
      );
      if (pageTrips.isEmpty) {
        break;
      }
      allTrips.addAll(pageTrips);
      if (pageTrips.length < _pageSize) {
        break;
      }
      page += 1;
    }

    return allTrips;
  }

  Future<List<UserTrip>> _mergeTrips({
    required String userId,
    required List<UserTrip> localTrips,
    required List<UserTrip> remoteTrips,
  }) async {
    final localServerIds = await _serverTripIdsByLocalId(userId);
    final mergedByIdentity = <String, UserTrip>{};

    for (final remote in remoteTrips.where((trip) => trip.userId == userId)) {
      mergedByIdentity[remote.id] = remote;
    }

    for (final local in localTrips.where((trip) => trip.userId == userId)) {
      final identity = localServerIds[local.id] ?? local.id;
      final remote = mergedByIdentity[identity];
      final hasLocalUnsyncedChanges = local.syncStatus != 'synced';

      if (hasLocalUnsyncedChanges) {
        mergedByIdentity[identity] = _mergeLocalPriorityTrip(
          local: local,
          remote: remote,
        );
        continue;
      }

      if (remote == null) {
        // Remote list is authoritative for synced entities.
        continue;
      }

      mergedByIdentity[identity] = _mergeRemotePriorityTrip(
        local: local,
        remote: remote,
      );
    }

    final merged = mergedByIdentity.values.toList()
      ..sort((a, b) => b.localUpdatedAt.compareTo(a.localUpdatedAt));
    return merged;
  }

  UserTrip _mergeLocalPriorityTrip({
    required UserTrip local,
    required UserTrip? remote,
  }) {
    return local.copyWith(
      coverPhotoUrl: local.coverPhotoUrl ?? remote?.coverPhotoUrl,
      placeCount: local.placeCount > 0
          ? local.placeCount
          : (remote?.placeCount ?? local.placeCount),
      serverUpdatedAt: remote?.serverUpdatedAt ?? local.serverUpdatedAt,
    );
  }

  UserTrip _mergeRemotePriorityTrip({
    required UserTrip local,
    required UserTrip remote,
  }) {
    final latestLocalUpdatedAt =
        local.localUpdatedAt.isAfter(remote.localUpdatedAt)
            ? local.localUpdatedAt
            : remote.localUpdatedAt;
    return remote.copyWith(
      id: local.id,
      userId: local.userId,
      placeCount: remote.placeCount > 0 ? remote.placeCount : local.placeCount,
      localUpdatedAt: latestLocalUpdatedAt,
      syncStatus: 'synced',
    );
  }

  Future<Map<String, String>> _serverTripIdsByLocalId(String userId) async {
    final rows = await _db.tripDao.getAllTrips();
    final mapped = <String, String>{};
    for (final row in rows) {
      final serverTripId = row.serverTripId;
      if (row.userId != userId ||
          serverTripId == null ||
          serverTripId.isEmpty) {
        continue;
      }
      mapped[row.id] = serverTripId;
    }
    return mapped;
  }

  Future<void> _persistMergedTrips({
    required String userId,
    required List<UserTrip> mergedTrips,
  }) async {
    final scopedTrips = mergedTrips
        .map((trip) =>
            trip.userId == userId ? trip : trip.copyWith(userId: userId))
        .toList();
    await _db.userTripsDao.insertTrips(scopedTrips);
    final mergedIds = scopedTrips.map((trip) => trip.id).toList();
    await _db.userTripsDao.deleteSyncedTripsNotInIdsForUser(
      userId: userId,
      ids: mergedIds,
    );
  }

  Future<List<UserTrip>> _resolveLifecycleStatuses(
    List<UserTrip> trips,
  ) async {
    final resolved = <UserTrip>[];
    for (final trip in trips) {
      resolved.add(await _resolveLifecycleStatus(trip));
    }
    return resolved;
  }

  Future<UserTrip> _resolveLifecycleStatus(UserTrip trip) async {
    if (await _hasActiveOrPausedSession(trip.id)) {
      return trip.copyWith(status: kTripStatusLiveEditing);
    }

    final snapshotDigest = await _currentSnapshotDigest(trip.id);
    final publishState = await _db.tripPublishStateDao.getState(trip.id);
    final lastSavedDigest = publishState?.lastSavedSnapshotDigest;
    final lastPublishedDigest = publishState?.lastPublishedSnapshotDigest;

    if (snapshotDigest == null ||
        lastSavedDigest == null ||
        snapshotDigest != lastSavedDigest) {
      return trip.copyWith(status: kTripStatusEditing);
    }

    if (trip.visibility == 'public' &&
        lastPublishedDigest != null &&
        lastPublishedDigest == snapshotDigest) {
      return trip.copyWith(status: kTripStatusPublished);
    }

    return trip.copyWith(status: kTripStatusSaved);
  }

  Future<void> _refreshTripLifecycleById(String tripId, String userId) async {
    final trip = await _db.userTripsDao.getTripByIdForUser(tripId, userId);
    if (trip == null) {
      return;
    }
    final resolved = await _resolveLifecycleStatus(trip);
    await _db.userTripsDao.updateTrip(resolved);
  }

  Future<bool> _hasActiveOrPausedSession(String tripLocalId) async {
    final active = await _db.sessionJournalDao
        .getActiveOrPausedSessionForTrip(tripLocalId);
    return active != null;
  }

  Future<String?> _currentSnapshotDigest(String tripLocalId) async {
    final snapshot = await _buildSnapshotPayload(tripLocalId);
    return snapshot.snapshotDigest;
  }

  Future<_TripSnapshotPayload> _buildSnapshotPayload(String tripLocalId) async {
    final sessions =
        await _db.sessionJournalDao.listSessionsForTrip(tripLocalId);
    final events =
        await _db.eventJournalDao.listEventsForTripChronological(tripLocalId);
    final media = await _db.mediaJournalDao.listMediaForTrip(tripLocalId);
    final routePoints = await _db.routePointJournalDao.listPointsForTrip(
      tripLocalId,
    );
    final tripRow = await _db.tripDao.getTripById(tripLocalId);

    final normalizedSessions = sessions.toList()
      ..sort((a, b) {
        final bySeq = a.sessionSeq.compareTo(b.sessionSeq);
        if (bySeq != 0) {
          return bySeq;
        }
        return a.sessionId.compareTo(b.sessionId);
      });
    final normalizedEvents = events.toList()
      ..sort((a, b) {
        final byCapturedAt = a.capturedAt.compareTo(b.capturedAt);
        if (byCapturedAt != 0) {
          return byCapturedAt;
        }
        final bySeq = a.eventSeq.compareTo(b.eventSeq);
        if (bySeq != 0) {
          return bySeq;
        }
        return a.eventId.compareTo(b.eventId);
      });
    final normalizedMedia = media.toList()
      ..sort((a, b) {
        final byCapturedAt = a.capturedAt.compareTo(b.capturedAt);
        if (byCapturedAt != 0) {
          return byCapturedAt;
        }
        return a.mediaId.compareTo(b.mediaId);
      });
    final normalizedRoutePoints = routePoints.toList()
      ..sort((a, b) {
        final byCapturedAt = a.capturedAt.compareTo(b.capturedAt);
        if (byCapturedAt != 0) {
          return byCapturedAt;
        }
        final bySeq = a.pointSeq.compareTo(b.pointSeq);
        if (bySeq != 0) {
          return bySeq;
        }
        return a.pointId.compareTo(b.pointId);
      });

    final sessionPayload = normalizedSessions
        .map((row) => _sessionPayload(row, tripLocalId))
        .toList(growable: false);
    final eventPayload =
        normalizedEvents.map(_eventPayload).toList(growable: false);
    final mediaPayload =
        normalizedMedia.map(_mediaPayload).toList(growable: false);
    final routePayload =
        normalizedRoutePoints.map(_routePointPayload).toList(growable: false);

    final payload = <String, dynamic>{
      'trip_local_id': tripLocalId,
      'trip_metadata': _tripMetadataPayload(tripRow),
      'sessions': sessionPayload,
      'events': eventPayload,
      'media': mediaPayload,
      'route_points': routePayload,
    };
    final payloadJson = _canonicalJson(payload);

    final startedAt = normalizedSessions
        .map((row) => row.startedAt ?? row.createdAt)
        .cast<DateTime?>()
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (acc, value) =>
              acc == null || value.isBefore(acc) ? value.toUtc() : acc,
        );
    final endedAt = normalizedSessions
        .map((row) => row.endedAt)
        .whereType<DateTime>()
        .fold<DateTime?>(
          null,
          (acc, value) =>
              acc == null || value.isAfter(acc) ? value.toUtc() : acc,
        );

    return _TripSnapshotPayload(
      payloadJson: payloadJson,
      snapshotDigest: _sha256Hex(payloadJson),
      payloadBytes: utf8.encode(payloadJson).length,
      sessions: sessionPayload,
      events: eventPayload,
      media: mediaPayload,
      routePoints: routePayload,
      mediaRows: normalizedMedia,
      startedAt: startedAt,
      endedAt: endedAt,
    );
  }

  Map<String, dynamic> _tripMetadataPayload(TripRow? row) {
    if (row == null) {
      return const <String, dynamic>{};
    }
    return <String, dynamic>{
      'name': row.name,
      'description': row.description,
      'visibility': row.visibility,
      'start_date': _isoUtcNullable(row.startDate),
      'end_date': _isoUtcNullable(row.endDate),
      'tags': row.tags,
      'center_point': row.centerPoint == null
          ? null
          : <String, dynamic>{
              'lat': row.centerPoint!.latitude,
              'lng': row.centerPoint!.longitude,
            },
      'zoom': row.zoom,
    };
  }

  Map<String, dynamic> _sessionPayload(
    SessionJournalRow row,
    String tripLocalId,
  ) {
    final resolvedEndedAt =
        row.endedAt ?? (row.controlState == 'sealed' ? row.updatedAt : null);
    return <String, dynamic>{
      'trip_id': tripLocalId,
      'session_id': row.sessionId,
      'seal_version': math.max(row.sealVersion, 1),
      'control_state': row.controlState,
      'stop_server_pending': row.stopServerPending,
      'started_at': _isoUtc(row.startedAt ?? row.createdAt),
      'ended_at': _isoUtcNullable(resolvedEndedAt),
      'device_id': row.deviceId,
      'stop_client_event_id': row.stopClientEventId,
    };
  }

  Map<String, dynamic> _eventPayload(EventJournalRow row) {
    return <String, dynamic>{
      'event_id': row.eventId,
      'session_id': row.sessionId,
      'event_type': row.eventType,
      'captured_at': _isoUtc(row.capturedAt),
      'latitude': row.latitude,
      'longitude': row.longitude,
      'resolver_state': row.resolverState,
      'decision_source': row.decisionSource,
      'manual_lock': row.manualLock == 1,
      'place_bind_kind': row.placeBindKind,
      'place_bind_id': row.placeBindId,
      'place_bind_name': row.placeBindName,
      'geotag_final_reason': row.geotagFinalReason,
      'payload_json': _decodeEventPayload(row.payloadJson),
      'event_seq': row.eventSeq,
      'captured_while_paused': row.capturedWhilePaused == 1,
      'candidate_set_version': row.candidateSetVersion,
      'resolved_at': _isoUtcNullable(row.resolvedAt),
      'created_at': _isoUtc(row.createdAt),
      'updated_at': _isoUtc(row.updatedAt),
    };
  }

  dynamic _decodeEventPayload(String? payloadJson) {
    if (payloadJson == null || payloadJson.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(payloadJson);
    } catch (_) {
      return payloadJson;
    }
  }

  Map<String, dynamic> _mediaPayload(MediaJournalRow row) {
    return <String, dynamic>{
      'media_id': row.mediaId,
      'event_id': row.eventId,
      'session_id': row.sessionId,
      'captured_at': _isoUtc(row.capturedAt),
      'media_type': row.mediaType,
      'mime_type': row.mimeType,
      'bytes_size': row.bytesSize,
      'width_px': row.widthPx,
      'height_px': row.heightPx,
      'duration_ms': row.durationMs,
      'created_at': _isoUtc(row.createdAt),
      'updated_at': _isoUtc(row.updatedAt),
    };
  }

  Map<String, dynamic> _routePointPayload(RoutePointJournalRow row) {
    return <String, dynamic>{
      'point_id': row.pointId,
      'session_id': row.sessionId,
      'captured_at': _isoUtc(row.capturedAt),
      'latitude': row.latitude,
      'longitude': row.longitude,
      'accuracy_m': row.accuracyM,
      'speed_mps': row.speedMps,
      'bearing_deg': row.bearingDeg,
      'altitude_m': row.altitudeM,
      'source': row.source,
      'point_seq': row.pointSeq,
    };
  }

  Future<List<_MediaManifestItem>> _buildMediaManifest(
    List<MediaJournalRow> mediaRows,
  ) async {
    final manifest = <_MediaManifestItem>[];
    final sortedRows = mediaRows.toList()
      ..sort((a, b) => a.mediaId.compareTo(b.mediaId));
    for (final row in sortedRows) {
      final filePath = _resolveLocalFilePath(row.localUri);
      final file = File(filePath);
      if (!await file.exists()) {
        throw TripsRepositoryException(
          'Missing media file for ${row.mediaId}.',
        );
      }
      final bytes = await file.readAsBytes();
      final mediaHash = crypto.sha256.convert(bytes).toString();
      manifest.add(
        _MediaManifestItem(
          mediaId: row.mediaId,
          mimeType: row.mimeType,
          sizeBytes: row.bytesSize ?? bytes.length,
          mediaContentHash: mediaHash,
          filePath: filePath,
        ),
      );
    }
    return manifest;
  }

  String _resolveLocalFilePath(String uriOrPath) {
    if (uriOrPath.startsWith('file://')) {
      return Uri.parse(uriOrPath).toFilePath(windows: Platform.isWindows);
    }
    return uriOrPath;
  }

  List<Map<String, dynamic>> _uploadTargetsFromResponse(
    Map<String, dynamic> response,
  ) {
    final raw = response['upload_targets'];
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw
        .whereType<Map>()
        .map((item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _uploadMediaAndBuildRefs({
    required List<_MediaManifestItem> manifest,
    required List<Map<String, dynamic>> uploadTargets,
  }) async {
    if (manifest.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    final byMediaId = <String, _MediaManifestItem>{
      for (final item in manifest) item.mediaId: item,
    };
    final uploaded = <Map<String, dynamic>>[];

    for (final target in uploadTargets) {
      final mediaId = _stringFromMap(target, 'client_media_id');
      final storageRef = _stringFromMap(target, 'storage_ref');
      final bucket = _stringFromMap(target, 'bucket');
      final objectKey = _stringFromMap(target, 'object_key');
      if (mediaId == null ||
          storageRef == null ||
          bucket == null ||
          objectKey == null) {
        throw TripsRepositoryException('Invalid upload target from backend.');
      }
      final item = byMediaId.remove(mediaId);
      if (item == null) {
        throw TripsRepositoryException(
          'Missing local media for upload target $mediaId.',
        );
      }
      final file = File(item.filePath);
      if (!await file.exists()) {
        throw TripsRepositoryException('Missing media file for $mediaId.');
      }
      final bytes = await file.readAsBytes();
      await Supabase.instance.client.storage.from(bucket).uploadBinary(
            objectKey,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: item.mimeType ?? 'application/octet-stream',
            ),
          );
      uploaded.add(<String, dynamic>{
        'client_media_id': mediaId,
        'storage_ref': storageRef,
      });
    }

    if (byMediaId.isNotEmpty) {
      throw TripsRepositoryException(
        'Missing upload target for ${byMediaId.length} media item(s).',
      );
    }
    return uploaded;
  }

  List<String> _splitPayloadIntoChunks(
    String payloadJson, {
    required int maxBytes,
  }) {
    if (payloadJson.isEmpty) {
      return const <String>['{}'];
    }
    final chunks = <String>[];
    var start = 0;
    while (start < payloadJson.length) {
      var low = start + 1;
      var high = payloadJson.length;
      var best = -1;

      while (low <= high) {
        final mid = low + ((high - low) ~/ 2);
        final bytes = utf8.encode(payloadJson.substring(start, mid)).length;
        if (bytes <= maxBytes) {
          best = mid;
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }

      if (best <= start) {
        throw TripsRepositoryException('Failed to split payload chunk safely.');
      }
      chunks.add(payloadJson.substring(start, best));
      start = best;
    }
    return chunks;
  }

  String _canonicalJson(Object? value) {
    final canonicalized = _canonicalizeValue(value);
    return jsonEncode(canonicalized);
  }

  dynamic _canonicalizeValue(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()
        ..sort((a, b) => a.compareTo(b));
      final output = <String, dynamic>{};
      for (final key in keys) {
        output[key] = _canonicalizeValue(value[key]);
      }
      return output;
    }
    if (value is List) {
      return value.map(_canonicalizeValue).toList(growable: false);
    }
    if (value is DateTime) {
      return value.toUtc().toIso8601String();
    }
    return value;
  }

  String _sha256Hex(String input) =>
      crypto.sha256.convert(utf8.encode(input)).toString();

  String? _stringFromMap(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  String _isoUtc(DateTime value) => value.toUtc().toIso8601String();

  String? _isoUtcNullable(DateTime? value) =>
      value == null ? null : _isoUtc(value);

  String _humanizeError(Object error) {
    final raw = error.toString();
    if (raw.isEmpty) {
      return 'Please retry.';
    }
    return raw;
  }

  Future<void> _upsertTripPublishState(
    String tripLocalId, {
    required String publishState,
    required DateTime updatedAt,
    String? publishJobId,
    String? lastSavedSnapshotDigest,
    DateTime? lastSavedAt,
    String? lastPublishedSnapshotDigest,
    DateTime? lastPublishedAt,
    String? lastErrorCode,
    String? lastErrorMessage,
  }) {
    return _db.tripPublishStateDao.upsertState(
      TripPublishStateCompanion(
        tripLocalId: Value(tripLocalId),
        publishState: Value(publishState),
        publishJobId: Value(publishJobId),
        lastSavedSnapshotDigest: Value(lastSavedSnapshotDigest),
        lastSavedAt: Value(lastSavedAt?.toUtc()),
        lastPublishedSnapshotDigest: Value(lastPublishedSnapshotDigest),
        lastPublishedAt: Value(lastPublishedAt?.toUtc()),
        lastErrorCode: Value(lastErrorCode),
        lastErrorMessage: Value(lastErrorMessage),
        updatedAt: Value(updatedAt.toUtc()),
      ),
    );
  }

  Future<String> _resolveRemoteTripIdForUserTripId({
    required String localTripId,
    required String userId,
  }) async {
    final trip = await _db.userTripsDao.getTripByIdForUser(localTripId, userId);
    if (trip == null) {
      throw TripsRepositoryException('Trip not found');
    }
    return _resolveRemoteTripIdForUserTrip(trip: trip, userId: userId);
  }

  Future<String> _resolveRemoteTripIdForUserTrip({
    required UserTrip trip,
    required String userId,
  }) async {
    if (trip.userId != userId) {
      throw TripsRepositoryException('Trip does not belong to current user');
    }

    final tripRow = await _db.tripDao.getTripById(trip.id);
    final serverTripId = tripRow?.serverTripId;
    if (serverTripId != null && serverTripId.isNotEmpty) {
      return serverTripId;
    }

    if (trip.syncStatus == 'synced') {
      return trip.id;
    }

    throw TripsRepositoryException(
      'Trip is not synced to backend yet. Please retry after sync completes.',
    );
  }

  Future<void> _markSyncFailed(String id) async {
    final userId = _requireCurrentUserId();
    final trip = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (trip == null) {
      return;
    }
    await _db.userTripsDao.updateTrip(trip.copyWith(syncStatus: 'failed'));
  }

  static String _copyName(String name) {
    const suffix = ' (Copy)';
    const maxLength = 28;
    final trimmed = name.length > maxLength
        ? name.substring(0, maxLength).trimRight()
        : name;
    return '$trimmed$suffix';
  }
}

class _TripSnapshotPayload {
  const _TripSnapshotPayload({
    required this.payloadJson,
    required this.snapshotDigest,
    required this.payloadBytes,
    required this.sessions,
    required this.events,
    required this.media,
    required this.routePoints,
    required this.mediaRows,
    required this.startedAt,
    required this.endedAt,
  });

  final String payloadJson;
  final String snapshotDigest;
  final int payloadBytes;
  final List<Map<String, dynamic>> sessions;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> media;
  final List<Map<String, dynamic>> routePoints;
  final List<MediaJournalRow> mediaRows;
  final DateTime? startedAt;
  final DateTime? endedAt;
}

class _MediaManifestItem {
  const _MediaManifestItem({
    required this.mediaId,
    required this.mimeType,
    required this.sizeBytes,
    required this.mediaContentHash,
    required this.filePath,
  });

  final String mediaId;
  final String? mimeType;
  final int? sizeBytes;
  final String mediaContentHash;
  final String filePath;

  Map<String, dynamic> toManifestPayload() {
    return <String, dynamic>{
      'client_media_id': mediaId,
      'mime_type': mimeType,
      'size_bytes': sizeBytes,
      'media_content_hash': mediaContentHash,
    };
  }
}

class TripsRepositoryException implements Exception {
  TripsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
