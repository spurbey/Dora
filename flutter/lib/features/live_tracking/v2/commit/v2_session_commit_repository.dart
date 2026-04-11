import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/media_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_chunk_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_job_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_media_item_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';

class V2SessionCommitRepository {
  V2SessionCommitRepository({
    required AppDatabase database,
    required SessionJournalDao sessionDao,
    required SessionCommitJobDao jobDao,
    required SessionCommitMediaItemDao mediaItemDao,
    required SessionCommitChunkDao chunkDao,
    required EventJournalDao eventDao,
    required MediaJournalDao mediaDao,
    required RoutePointJournalDao routePointDao,
    DateTime Function()? now,
  })  : _database = database,
        _sessionDao = sessionDao,
        _jobDao = jobDao,
        _mediaItemDao = mediaItemDao,
        _chunkDao = chunkDao,
        _eventDao = eventDao,
        _mediaDao = mediaDao,
        _routePointDao = routePointDao,
        _now = now ?? DateTime.now;

  final AppDatabase _database;
  final SessionJournalDao _sessionDao;
  final SessionCommitJobDao _jobDao;
  final SessionCommitMediaItemDao _mediaItemDao;
  final SessionCommitChunkDao _chunkDao;
  final EventJournalDao _eventDao;
  final MediaJournalDao _mediaDao;
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
      final media = await _mediaDao.listMediaForSession(session.sessionId);
      final points =
          await _routePointDao.listPointsForSession(session.sessionId);
      final now = _now().toUtc();

      final payload = <String, Object?>{
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
                'media_id': item.mediaId,
                'session_id': item.sessionId,
                'event_id': item.eventId,
                'captured_at': item.capturedAt.toIso8601String(),
                'media_type': item.mediaType,
                'local_uri': item.localUri,
                'mime_type': item.mimeType,
                'bytes_size': item.bytesSize,
                'upload_state': item.uploadState,
                'upload_ref': item.uploadRef,
                'created_at': item.createdAt.toIso8601String(),
                'updated_at': item.updatedAt.toIso8601String(),
              },
            )
            .toList(growable: false),
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
              itemId: 'media:$jobId:${item.mediaId}',
              jobId: jobId,
              mediaId: item.mediaId,
              uploadState: 'pending',
              localUri: item.localUri,
              mimeType: Value(item.mimeType),
              bytesSize: Value(item.bytesSize),
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
    const int fnvOffset = 0xcbf29ce484222325;
    const int fnvPrime = 0x100000001b3;
    var hash = fnvOffset;
    final bytes = utf8.encode(value);
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * fnvPrime) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  int? _sealVersionFromJobId(String jobId) {
    final parts = jobId.split(':');
    if (parts.length < 3) {
      return null;
    }
    return int.tryParse(parts.last);
  }
}
