import 'dart:async';

import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';

enum LiveTrackingCandidateDecisionAction {
  confirm,
  reject,
  snooze;

  String get wireValue {
    switch (this) {
      case LiveTrackingCandidateDecisionAction.confirm:
        return 'confirm';
      case LiveTrackingCandidateDecisionAction.reject:
        return 'reject';
      case LiveTrackingCandidateDecisionAction.snooze:
        return 'snooze';
    }
  }
}

class LiveTrackingCandidateRepository {
  LiveTrackingCandidateRepository({
    required TrackingCandidateDao trackingCandidateDao,
    required SyncTaskDao syncTaskDao,
    DateTime Function()? now,
    Uuid? uuid,
  })  : _trackingCandidateDao = trackingCandidateDao,
        _syncTaskDao = syncTaskDao,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final TrackingCandidateDao _trackingCandidateDao;
  final SyncTaskDao _syncTaskDao;
  final DateTime Function() _now;
  final Uuid _uuid;

  Stream<List<TrackingCandidateRow>> watchInboxCandidates(String tripId) {
    return Stream<List<TrackingCandidateRow>>.multi((controller) {
      Timer? wakeTimer;
      List<TrackingCandidateRow> latestRows = const <TrackingCandidateRow>[];
      late void Function(DateTime now) scheduleWake;

      void emit() {
        if (controller.isClosed) {
          return;
        }
        final now = _now().toUtc();
        controller.add(_filterInboxCandidates(latestRows, now: now));
        scheduleWake(now);
      }

      scheduleWake = (DateTime now) {
        wakeTimer?.cancel();
        DateTime? earliestWake;
        for (final row in latestRows) {
          if (row.status != 'snoozed') {
            continue;
          }
          final snoozedUntil = row.snoozedUntil?.toUtc();
          if (snoozedUntil == null || !snoozedUntil.isAfter(now)) {
            continue;
          }
          if (earliestWake == null || snoozedUntil.isBefore(earliestWake)) {
            earliestWake = snoozedUntil;
          }
        }
        if (earliestWake == null) {
          return;
        }
        wakeTimer = Timer(earliestWake.difference(now), emit);
      };

      final subscription =
          _trackingCandidateDao.watchInboxCandidatesForTrip(tripId).listen(
                (rows) {
                  latestRows = rows;
                  emit();
                },
                onError: controller.addError,
                onDone: () {
                  wakeTimer?.cancel();
                  controller.close();
                },
              );

      controller.onCancel = () async {
        wakeTimer?.cancel();
        await subscription.cancel();
      };
    });
  }

  Future<List<TrackingCandidateRow>> getInboxCandidates(String tripId) async {
    final rows = await _trackingCandidateDao.getInboxCandidatesForTrip(tripId);
    return _filterInboxCandidates(rows, now: _now().toUtc());
  }

  Future<void> queueDecision({
    required String tripId,
    required String candidateId,
    required LiveTrackingCandidateDecisionAction action,
    String? rejectedReason,
    DateTime? snoozedUntil,
  }) async {
    final row = await _trackingCandidateDao.getCandidateById(candidateId);
    if (row == null) {
      throw StateError('Candidate not found: $candidateId');
    }
    if (row.tripId != tripId) {
      throw StateError(
        'Candidate $candidateId does not belong to trip $tripId',
      );
    }

    final queuedAt = _now().toUtc();
    final resolvedRejectedReason =
        action == LiveTrackingCandidateDecisionAction.reject
            ? (rejectedReason ?? 'user_dismissed')
            : null;
    final resolvedSnoozedUntil =
        action == LiveTrackingCandidateDecisionAction.snooze
            ? (snoozedUntil ?? queuedAt.add(const Duration(hours: 1))).toUtc()
            : null;

    await _trackingCandidateDao.markDecisionQueued(
      candidateId: candidateId,
      actionType: action.wireValue,
      clientEventId: _uuid.v4(),
      queuedAt: queuedAt,
      status: action == LiveTrackingCandidateDecisionAction.snooze
          ? 'snoozed'
          : null,
      rejectedReason: resolvedRejectedReason,
      snoozedUntil: resolvedSnoozedUntil,
    );
    await _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.checkinDecision,
      entityId: candidateId,
      operation: action.wireValue,
    );
  }

  static List<TrackingCandidateRow> _filterInboxCandidates(
    List<TrackingCandidateRow> rows, {
    required DateTime now,
  }) {
    return rows.where((row) {
      if (row.actionState == 'queued' || row.actionState == 'failed') {
        return true;
      }
      if (row.status == 'pending') {
        return true;
      }
      if (row.status == 'snoozed') {
        final snoozedUntil = row.snoozedUntil?.toUtc();
        if (snoozedUntil == null) {
          return true;
        }
        return !snoozedUntil.isAfter(now);
      }
      return false;
    }).toList(growable: false);
  }
}
