import 'dart:async';

import 'package:uuid/uuid.dart';

import 'package:dora/core/config/live_system_v2_gate.dart';
import 'package:dora/core/utils/logger.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';

class V2SessionCommitOrchestrator {
  V2SessionCommitOrchestrator({
    required LiveSystemV2Gate gate,
    required V2SessionJournalRepository sessionRepository,
    required V2SessionCommitRepository commitRepository,
    DateTime Function()? now,
    Uuid? uuid,
  })  : _gate = gate,
        _sessionRepository = sessionRepository,
        _commitRepository = commitRepository,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final LiveSystemV2Gate _gate;
  final V2SessionJournalRepository _sessionRepository;
  final V2SessionCommitRepository _commitRepository;
  final DateTime Function() _now;
  final Uuid _uuid;

  final Map<String, Future<void>> _tripRunInFlight = <String, Future<void>>{};
  final Map<String, Future<void>> _jobRunInFlight = <String, Future<void>>{};

  Future<void> onSessionSealed({
    required String tripId,
    required String sessionId,
  }) async {
    if (!_isWorkerEnabledForTrip(tripId)) {
      return;
    }
    await _commitRepository.ensureJobForSession(sessionId: sessionId);
    await runForTrip(tripId: tripId, source: V2CommitTriggerSource.stop);
  }

  Future<void> runForTrip({
    required String tripId,
    required V2CommitTriggerSource source,
    int limit = 20,
  }) {
    final existing = _tripRunInFlight[tripId];
    if (existing != null) {
      return existing;
    }
    final future = _runForTripLocked(
      tripId: tripId,
      source: source,
      limit: limit,
    );
    _tripRunInFlight[tripId] = future;
    return future.whenComplete(() {
      _tripRunInFlight.remove(tripId);
    });
  }

  Future<void> runGlobal({
    required V2CommitTriggerSource source,
    int limit = 20,
  }) async {
    final now = _now().toUtc();
    final runnable = await _commitRepository.listRunnableJobs(
      now: now,
      limit: limit,
    );
    for (final job in runnable) {
      if (!_isWorkerEnabledForTrip(job.tripLocalId)) {
        continue;
      }
      await _runSingleJob(
        jobId: job.jobId,
        source: source,
      );
    }
  }

  Future<void> manualRetry({
    required String tripId,
  }) {
    return runForTrip(
      tripId: tripId,
      source: V2CommitTriggerSource.manualRetry,
    );
  }

  Future<void> _runForTripLocked({
    required String tripId,
    required V2CommitTriggerSource source,
    required int limit,
  }) async {
    if (!_isWorkerEnabledForTrip(tripId)) {
      return;
    }
    final sessions = await _sessionRepository.listSessionsForTrip(tripId);
    for (final session in sessions) {
      if (session.controlState != 'sealed') {
        continue;
      }
      await _commitRepository.ensureJobForSession(sessionId: session.sessionId);
    }
    final now = _now().toUtc();
    final runnable = await _commitRepository.listRunnableJobs(
      now: now,
      limit: limit,
    );
    for (final job in runnable.where((row) => row.tripLocalId == tripId)) {
      await _runSingleJob(jobId: job.jobId, source: source);
    }
  }

  Future<void> _runSingleJob({
    required String jobId,
    required V2CommitTriggerSource source,
  }) {
    final existing = _jobRunInFlight[jobId];
    if (existing != null) {
      return existing;
    }
    final future = _runSingleJobLocked(jobId: jobId, source: source);
    _jobRunInFlight[jobId] = future;
    return future.whenComplete(() {
      _jobRunInFlight.remove(jobId);
    });
  }

  Future<void> _runSingleJobLocked({
    required String jobId,
    required V2CommitTriggerSource source,
  }) async {
    final ownerId = _uuid.v4();
    final now = _now().toUtc();
    final lease = await _commitRepository.acquireLease(
      jobId: jobId,
      ownerId: ownerId,
      now: now,
    );
    if (lease == null) {
      return;
    }

    try {
      await _commitRepository.prepareSnapshotIfMissing(jobId: jobId);
      await _commitRepository.refreshLease(
        jobId: jobId,
        ownerId: ownerId,
        now: _now().toUtc(),
      );

      final current = await _commitRepository.getJobById(jobId);
      if (current == null) {
        return;
      }

      final backendEnabled = _gate.evaluate(
        tripId: current.tripLocalId,
        surface: LiveSystemV2Surface.runtime,
        requiredSubsystems: const {
          LiveSystemV2Subsystem.localJournal,
          LiveSystemV2Subsystem.sessionCommitWorker,
          LiveSystemV2Subsystem.backendIngest,
        },
      ).enabled;

      if (!backendEnabled) {
        await _commitRepository.markJobPending(
            jobId: jobId, now: _now().toUtc());
        Logger.info(
          'v2_commit_backend_deferred',
          <String, Object?>{
            'job_id': jobId,
            'trip_id': current.tripLocalId,
            'source': source.wireValue,
          },
        );
        return;
      }

      await _commitRepository.markJobPending(jobId: jobId, now: _now().toUtc());
      Logger.info(
        'v2_commit_backend_phase_not_implemented',
        <String, Object?>{
          'job_id': jobId,
          'trip_id': current.tripLocalId,
          'source': source.wireValue,
        },
      );
    } catch (error, stackTrace) {
      final row = await _commitRepository.getJobById(jobId);
      final nextAttempt = (row?.attemptCount ?? 0) + 1;
      final nowUtc = _now().toUtc();
      DateTime? nextRetryAt;
      if (nextAttempt <= v2CommitAutoRetryMaxAttempts) {
        nextRetryAt = nowUtc.add(v2CommitRetryBackoff[nextAttempt - 1]);
      }
      await _commitRepository.markJobFailedRetryable(
        jobId: jobId,
        nextAttemptCount: nextAttempt,
        now: nowUtc,
        nextRetryAt: nextRetryAt,
        errorCode: 'commit_prepare_failed',
        errorMessage: error.toString(),
      );
      Logger.error(
        'v2_commit_job_failed',
        error,
        stackTrace,
      );
    } finally {
      await _commitRepository.releaseLease(
        jobId: jobId,
        ownerId: ownerId,
        now: _now().toUtc(),
      );
    }
  }

  bool _isWorkerEnabledForTrip(String tripId) {
    return _gate.evaluate(
      tripId: tripId,
      surface: LiveSystemV2Surface.runtime,
      requiredSubsystems: const {
        LiveSystemV2Subsystem.localJournal,
        LiveSystemV2Subsystem.sessionCommitWorker,
      },
    ).enabled;
  }
}
