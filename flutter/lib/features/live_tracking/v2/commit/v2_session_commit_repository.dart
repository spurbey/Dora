import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'package:dora/core/storage/daos/media_attachments_dao.dart';
import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_chunk_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_job_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_media_item_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';

class V2SessionMediaItem {
  const V2SessionMediaItem({
    required this.media,
    required this.eventId,
    required this.sessionId,
    required this.tripLocalId,
  });

  final MediaItem media;
  final String eventId;
  final String sessionId;
  final String tripLocalId;
}

class V2SessionCommitRepository {
  V2SessionCommitRepository({
    required AppDatabase database,
    required SessionJournalDao sessionDao,
    required SessionCommitJobDao jobDao,
    required SessionCommitMediaItemDao mediaItemDao,
    required SessionCommitChunkDao chunkDao,
    required EventJournalDao eventDao,
    required MediaDao mediaDao,
    required MediaAttachmentsDao mediaAttachmentsDao,
    required RoutePointJournalDao routePointDao,
    DateTime Function()? now,
  })  : _database = database,
        _sessionDao = sessionDao,
        _jobDao = jobDao,
        _mediaItemDao = mediaItemDao,
        _chunkDao = chunkDao,
        _eventDao = eventDao,
        _mediaDao = mediaDao,
        _mediaAttachmentsDao = mediaAttachmentsDao,
        _routePointDao = routePointDao,
        _now = now ?? DateTime.now;

  final AppDatabase _database;
  final SessionJournalDao _sessionDao;
  final SessionCommitJobDao _jobDao;
  final SessionCommitMediaItemDao _mediaItemDao;
  final SessionCommitChunkDao _chunkDao;
  final EventJournalDao _eventDao;
  final MediaDao _mediaDao;
  final MediaAttachmentsDao _mediaAttachmentsDao;
  final RoutePointJournalDao _routePointDao;
  final DateTime Function() _now;

  Future<SessionCommitJobRow?> ensureJobForSession({
    required String sessionId,
  }) async {
    return _database.transaction(() async {
      final session = await _sessionDao.getSessionById(sessionId);
      if (session == null || session.controlState != 'sealed') {
        return null;
      }
      final jobId = buildJobId(
        sessionId: session.sessionId,
        sealVersion: session.sealVersion,
      );
      final now = _now().toUtc();
      final existingById = await _jobDao.getJobById(jobId);
      if (existingById != null) {
        if (existingById.jobState == v2CommitStateFailedRetryable) {
          await _jobDao.markReusedAsPending(jobId: jobId, now: now);
        }
        return _jobDao.getJobById(jobId);
      }

      final active = await _jobDao.findActiveJobForSession(sessionId);
      if (active != null) {
        if (active.jobId == jobId) {
          return active;
        }
        final activeSealVersion = _sealVersionFromJobId(active.jobId);
        if (activeSealVersion == null ||
            activeSealVersion >= session.sealVersion) {
          return active;
        }
      }

      final row = SessionCommitJobCompanion.insert(
        jobId: jobId,
        sessionId: session.sessionId,
        tripLocalId: session.tripLocalId,
        serverTripId: Value(session.serverTripId),
        jobState: v2CommitStatePending,
        phase: v2CommitPhasePrepare,
        idempotencyKey:
            'commit:${session.tripLocalId}:${session.sessionId}:${session.sealVersion}',
        createdAt: now,
        updatedAt: now,
      );
      await _jobDao.upsertJob(row);
      return _jobDao.getJobById(jobId);
    });
  }

  Future<List<SessionCommitJobRow>> listRunnableJobs({
    required DateTime now,
    int limit = 20,
  }) {
    return _jobDao.listRunnableJobs(now: now.toUtc(), limit: limit);
  }

  Stream<V2CommitSyncSnapshot> watchTripSyncSnapshot(String tripLocalId) {
    return _jobDao.watchJobsForTrip(tripLocalId).map((rows) {
      var pending = 0;
      var committing = 0;
      var failed = 0;
      var committed = 0;
      final now = _now().toUtc();
      for (final row in rows) {
        switch (row.jobState) {
          case v2CommitStatePending:
            pending++;
            break;
          case v2CommitStateCommitting:
            if (_isLeaseFresh(row, now)) {
              committing++;
            } else {
              pending++;
            }
            break;
          case v2CommitStateFailedRetryable:
            failed++;
            break;
          case v2CommitStateCommitted:
            committed++;
            break;
          default:
            pending++;
        }
      }
      return V2CommitSyncSnapshot(
        pendingJobs: pending,
        committingJobs: committing,
        failedJobs: failed,
        committedJobs: committed,
      );
    });
  }

  Future<SessionCommitJobRow?> acquireLease({
    required String jobId,
    required String ownerId,
    required DateTime now,
  }) async {
    final utcNow = now.toUtc();
    return _database.transaction(() async {
      final job = await _jobDao.getJobById(jobId);
      if (job == null) {
        return null;
      }
      final canAcquire = job.isExecuting == 0 ||
          (_isLeaseExpired(job, utcNow) && job.executionOwnerId != ownerId);
      if (!canAcquire) {
        return null;
      }

      await _jobDao.updateJobById(
        jobId,
        SessionCommitJobCompanion(
          isExecuting: const Value(1),
          executionOwnerId: Value(ownerId),
          executionStartedAt: Value(utcNow),
          leaseVersion: Value(job.leaseVersion + 1),
          jobState: const Value(v2CommitStateCommitting),
          updatedAt: Value(utcNow),
        ),
      );
      return _jobDao.getJobById(jobId);
    });
  }

  Future<bool> refreshLease({
    required String jobId,
    required String ownerId,
    required DateTime now,
  }) async {
    final utcNow = now.toUtc();
    final job = await _jobDao.getJobById(jobId);
    if (job == null ||
        job.isExecuting != 1 ||
        job.executionOwnerId != ownerId ||
        _isLeaseExpired(job, utcNow)) {
      return false;
    }
    await _jobDao.updateJobById(
      jobId,
      SessionCommitJobCompanion(
        executionStartedAt: Value(utcNow),
        updatedAt: Value(utcNow),
      ),
    );
    return true;
  }

  Future<void> releaseLease({
    required String jobId,
    required String ownerId,
    required DateTime now,
  }) async {
    final job = await _jobDao.getJobById(jobId);
    if (job == null ||
        job.isExecuting != 1 ||
        job.executionOwnerId != ownerId) {
      return;
    }
    await _jobDao.updateJobById(
      jobId,
      SessionCommitJobCompanion(
        isExecuting: const Value(0),
        executionOwnerId: const Value(null),
        updatedAt: Value(now.toUtc()),
      ),
    );
  }

  Future<void> prepareSnapshotIfMissing({
    required String jobId,
  }) async {
    await _database.transaction(() async {
      final job = await _jobDao.getJobById(jobId);
      if (job == null || job.snapshotHash != null) {
        return;
      }
      final session = await _sessionDao.getSessionById(job.sessionId);
      if (session == null) {
        return;
      }
      final events = await _eventDao.listEventsForSession(session.sessionId);
      final media = await _listSessionMediaItems(
        sessionId: session.sessionId,
        tripLocalId: session.tripLocalId,
      );
      final points =
          await _routePointDao.listPointsForSession(session.sessionId);
      final now = _now().toUtc();
      final mediaManifest = await _buildMediaManifest(media);
      final mediaManifestDigest = _stableHash(_canonicalJson(mediaManifest));

      final payload = <String, Object?>{
        'schema_version': 1,
        'job_id': jobId,
        'trip_local_id': session.tripLocalId,
        'server_trip_id': session.serverTripId,
        'session_id': session.sessionId,
        'seal_version': session.sealVersion,
        'control_state': session.controlState,
        'stop_server_pending': session.stopServerPending,
        'start_ack_at': session.startAckAt?.toIso8601String(),
        'stop_ack_at': session.stopAckAt?.toIso8601String(),
        'started_at': session.startedAt?.toIso8601String(),
        'ended_at': session.endedAt?.toIso8601String(),
        'start_request_seq': session.startRequestSeq,
        'session_seq': session.sessionSeq,
        'device_id': session.deviceId,
        'stop_client_event_id': session.stopClientEventId,
        'events': events
            .map(
              (event) => <String, Object?>{
                'event_id': event.eventId,
                'session_id': event.sessionId,
                'captured_at': event.capturedAt.toIso8601String(),
                'event_type': event.eventType,
                'latitude': event.latitude,
                'longitude': event.longitude,
                'payload_json': event.payloadJson,
                'resolver_state': event.resolverState,
                'decision_source': event.decisionSource,
                'manual_lock': event.manualLock,
                'place_bind_kind': event.placeBindKind,
                'place_bind_id': event.placeBindId,
                'place_bind_name': event.placeBindName,
                'geotag_final_reason': event.geotagFinalReason,
                'captured_while_paused': event.capturedWhilePaused,
                'candidate_set_version': event.candidateSetVersion,
                'resolved_at': event.resolvedAt?.toIso8601String(),
                'event_seq': event.eventSeq,
                'created_at': event.createdAt.toIso8601String(),
                'updated_at': event.updatedAt.toIso8601String(),
              },
            )
            .toList(growable: false),
        'media': media
            .map(
              (item) => <String, Object?>{
                'media_id': item.media.id,
                'session_id': item.sessionId,
                'event_id': item.eventId,
                'captured_at': item.media.capturedAt.toIso8601String(),
                'media_type': item.media.mediaType,
                'local_uri': item.media.localUri,
                'mime_type': item.media.mimeType,
                'bytes_size': item.media.bytesSize,
                'upload_state': item.media.uploadState,
                'upload_ref': item.media.serverId,
                'created_at': item.media.createdAt.toIso8601String(),
                'updated_at': item.media.updatedAt.toIso8601String(),
              },
            )
            .toList(growable: false),
        'media_manifest': mediaManifest,
        'media_manifest_digest': mediaManifestDigest,
        'route_points': points
            .map(
              (point) => <String, Object?>{
                'point_id': point.pointId,
                'session_id': point.sessionId,
                'captured_at': point.capturedAt.toIso8601String(),
                'latitude': point.latitude,
                'longitude': point.longitude,
                'accuracy_m': point.accuracyM,
                'speed_mps': point.speedMps,
                'bearing_deg': point.bearingDeg,
                'altitude_m': point.altitudeM,
                'source': point.source,
                'point_seq': point.pointSeq,
              },
            )
            .toList(growable: false),
        'point_count': points.length,
      };
      final payloadJson = jsonEncode(payload);
      final hash = _stableHash(payloadJson);
      final chunks = _chunkPayloadJson(payloadJson);

      final mediaItems = media
          .map(
            (item) => SessionCommitMediaItemCompanion.insert(
              itemId: 'media:$jobId:${item.media.id}',
              jobId: jobId,
              mediaId: item.media.id,
              uploadState: 'pending',
              localUri: item.media.localUri ?? '',
              mimeType: Value(item.media.mimeType),
              bytesSize: Value(item.media.bytesSize),
              createdAt: now,
              updatedAt: now,
            ),
          )
          .toList(growable: false);

      final chunkRows = <SessionCommitChunkCompanion>[];
      for (var index = 0; index < chunks.length; index++) {
        final chunkPayload = chunks[index];
        chunkRows.add(
          SessionCommitChunkCompanion.insert(
            chunkId: 'chunk:$jobId:$index',
            jobId: jobId,
            chunkIndex: index,
            totalChunks: chunks.length,
            byteSize: utf8.encode(chunkPayload).length,
            contentHash: _stableHash(chunkPayload),
            payloadJson: chunkPayload,
            chunkState: 'pending',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      await _mediaItemDao.replaceItemsForJob(jobId: jobId, rows: mediaItems);
      await _chunkDao.replaceChunksForJob(jobId: jobId, rows: chunkRows);
      await _jobDao.updateJobById(
        jobId,
        SessionCommitJobCompanion(
          snapshotHash: Value(hash),
          snapshotCreatedAt: Value(now),
          snapshotEventCount: Value(events.length),
          snapshotMediaCount: Value(media.length),
          snapshotPointCount: Value(points.length),
          snapshotPayloadBytes: Value(utf8.encode(payloadJson).length),
          phase: const Value(v2CommitPhasePrepare),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<void> markJobPending({
    required String jobId,
    required DateTime now,
  }) {
    return _jobDao.updateJobById(
      jobId,
      SessionCommitJobCompanion(
        jobState: const Value(v2CommitStatePending),
        phase: const Value(v2CommitPhasePrepare),
        nextRetryAt: const Value(null),
        updatedAt: Value(now.toUtc()),
      ),
    );
  }

  Future<void> markJobCommitted({
    required String jobId,
    required DateTime now,
  }) {
    final utcNow = now.toUtc();
    return _jobDao.updateJobById(
      jobId,
      SessionCommitJobCompanion(
        jobState: const Value(v2CommitStateCommitted),
        phase: const Value(v2CommitPhaseDone),
        completedAt: Value(utcNow),
        nextRetryAt: const Value(null),
        lastErrorCode: const Value(null),
        lastErrorMessage: const Value(null),
        updatedAt: Value(utcNow),
      ),
    );
  }

  Future<void> markJobFailedRetryable({
    required String jobId,
    required int nextAttemptCount,
    required DateTime now,
    required String errorCode,
    required String errorMessage,
    DateTime? nextRetryAt,
  }) {
    return _jobDao.updateJobById(
      jobId,
      SessionCommitJobCompanion(
        jobState: const Value(v2CommitStateFailedRetryable),
        attemptCount: Value(nextAttemptCount),
        lastErrorCode: Value(errorCode),
        lastErrorMessage: Value(errorMessage),
        nextRetryAt: Value(nextRetryAt?.toUtc()),
        updatedAt: Value(now.toUtc()),
      ),
    );
  }

  Future<SessionCommitJobRow?> getJobById(String jobId) =>
      _jobDao.getJobById(jobId);

  Future<void> markSessionStopPending({
    required String sessionId,
    required DateTime now,
  }) async {
    final session = await _sessionDao.getSessionById(sessionId);
    if (session == null) {
      return;
    }
    await _sessionDao.upsertSession(
      SessionJournalCompanion(
        sessionId: Value(session.sessionId),
        tripLocalId: Value(session.tripLocalId),
        serverTripId: Value(session.serverTripId),
        controlState: Value(session.controlState),
        stopServerPending: const Value(1),
        startAckAt: Value(session.startAckAt),
        stopAckAt: Value(session.stopAckAt),
        startedAt: Value(session.startedAt),
        endedAt: Value(session.endedAt),
        stopClientEventId: Value(session.stopClientEventId),
        createdAt: Value(session.createdAt),
        updatedAt: Value(now.toUtc()),
        sealVersion: Value(session.sealVersion),
        startRequestSeq: Value(session.startRequestSeq),
        sessionSeq: Value(session.sessionSeq),
        deviceId: Value(session.deviceId),
      ),
    );
  }

  static String buildJobId({
    required String sessionId,
    required int sealVersion,
  }) {
    return 'commit:$sessionId:$sealVersion';
  }

  bool _isLeaseExpired(SessionCommitJobRow row, DateTime now) {
    final heartbeat = row.executionStartedAt;
    if (heartbeat == null) {
      return true;
    }
    return now.difference(heartbeat.toUtc()) > v2CommitLeaseTtl;
  }

  bool _isLeaseFresh(SessionCommitJobRow row, DateTime now) {
    if (row.isExecuting != 1) {
      return false;
    }
    return !_isLeaseExpired(row, now);
  }

  List<String> _chunkPayloadJson(String payloadJson) {
    const chunkBytes = 128 * 1024;
    if (payloadJson.isEmpty) {
      return const <String>['{}'];
    }
    final bytes = utf8.encode(payloadJson);
    if (bytes.length <= chunkBytes) {
      return <String>[payloadJson];
    }
    final chunks = <String>[];
    var offset = 0;
    while (offset < bytes.length) {
      final remaining = bytes.length - offset;
      final length = math.min(chunkBytes, remaining);
      chunks.add(utf8.decode(bytes.sublist(offset, offset + length)));
      offset += length;
    }
    return chunks;
  }

  String _stableHash(String value) {
    return crypto.sha256.convert(utf8.encode(value)).toString();
  }

  int? _sealVersionFromJobId(String jobId) {
    final parts = jobId.split(':');
    if (parts.length < 3) {
      return null;
    }
    return int.tryParse(parts.last);
  }

  Future<List<V2SessionMediaItem>> _listSessionMediaItems({
    required String sessionId,
    required String tripLocalId,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT m.*, ma.target_local_id AS attachment_event_id
      FROM media m
      INNER JOIN media_attachments ma ON ma.media_id = m.id
      INNER JOIN event_journal e ON e.event_id = ma.target_local_id
      WHERE ma.target_kind = 'trip_event'
        AND ma.role = 'capture'
        AND ma.detached_at IS NULL
        AND m.deleted_at IS NULL
        AND e.session_id = ?
      ORDER BY m.captured_at ASC, m.id ASC
      ''',
      variables: [Variable<String>(sessionId)],
      readsFrom: {
        _database.media,
        _database.mediaAttachments,
        _database.eventJournal,
      },
    ).get();

    return rows.map((row) {
      final media = _database.media.map(row.data);
      final eventId = row.read<String>('attachment_event_id');
      return V2SessionMediaItem(
        media: media,
        eventId: eventId,
        sessionId: sessionId,
        tripLocalId: tripLocalId,
      );
    }).toList(growable: false);
  }

  Future<List<Map<String, Object?>>> _buildMediaManifest(
    List<V2SessionMediaItem> media,
  ) async {
    final manifest = <Map<String, Object?>>[];
    for (final item in media) {
      manifest.add(
        <String, Object?>{
          'client_media_id': item.media.id,
          'mime_type': item.media.mimeType,
          'size_bytes': item.media.bytesSize,
          'media_content_hash': await _computeMediaContentHash(item),
        },
      );
    }
    manifest.sort(
      (a, b) => (a['client_media_id'] as String)
          .compareTo(b['client_media_id'] as String),
    );
    return manifest;
  }

  Future<String> _computeMediaContentHash(V2SessionMediaItem item) async {
    final localUri = item.media.localUri;
    if (localUri != null && localUri.isNotEmpty) {
      final file = _fileFromLocalUri(localUri);
      if (file != null && await file.exists()) {
        final digest = await crypto.sha256.bind(file.openRead()).first;
        return digest.toString();
      }
    }
    return _stableHash(
      _canonicalJson(
        <String, Object?>{
          'media_id': item.media.id,
          'event_id': item.eventId,
          'local_uri': item.media.localUri,
          'mime_type': item.media.mimeType,
          'bytes_size': item.media.bytesSize,
          'captured_at': item.media.capturedAt.toIso8601String(),
        },
      ),
    );
  }

  File? _fileFromLocalUri(String localUri) {
    if (localUri.isEmpty) {
      return null;
    }
    final parsed = Uri.tryParse(localUri);
    if (parsed != null && parsed.scheme == 'file') {
      return File.fromUri(parsed);
    }
    if (parsed != null && parsed.hasScheme && parsed.scheme != 'file') {
      return null;
    }
    return File(localUri);
  }

  String _canonicalJson(Object? value) {
    return jsonEncode(value);
  }
}
