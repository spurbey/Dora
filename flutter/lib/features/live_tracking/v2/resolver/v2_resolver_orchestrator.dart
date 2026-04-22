import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/media_attachments_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/network/network_probe.dart';
import 'package:dora/core/utils/logger.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/resolver_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_client.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_decision_reducer.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';

class V2ResolverOrchestrator {
  V2ResolverOrchestrator({
    required AppDatabase database,
    required V2EventJournalRepository eventRepository,
    required V2ResolverJournalRepository resolverRepository,
    required V2ResolverClient resolverClient,
    MediaAttachmentsDao? mediaAttachmentsDao,
    V2ResolverDecisionReducer reducer = const V2ResolverDecisionReducer(),
    Uuid? uuid,
    DateTime Function()? now,
  })  : _eventRepository = eventRepository,
        _database = database,
        _resolverRepository = resolverRepository,
        _resolverClient = resolverClient,
        _mediaAttachmentsDao = mediaAttachmentsDao,
        _reducer = reducer,
        _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  final V2EventJournalRepository _eventRepository;
  final AppDatabase _database;
  final V2ResolverJournalRepository _resolverRepository;
  final V2ResolverClient _resolverClient;
  final MediaAttachmentsDao? _mediaAttachmentsDao;
  final V2ResolverDecisionReducer _reducer;
  final Uuid _uuid;
  final DateTime Function() _now;

  final Map<String, Future<void>> _recoveryInFlightByTrip =
      <String, Future<void>>{};
  final Set<String> _eventInFlight = <String>{};

  Future<void> resolveCaptureCreated({
    required String tripId,
    required String eventId,
  }) async {
    final event = await _eventRepository.getEventById(eventId);
    if (event == null || event.tripLocalId != tripId) {
      return;
    }
    if (!_isUnresolvedState(event.resolverState)) {
      return;
    }
    await _resolveEvent(
      event: event,
      source: V2ResolverTriggerSource.captureCreated,
      isRecovery: false,
    );
  }

  Future<void> runRecoveryForTrip({
    required String tripId,
    required V2ResolverTriggerSource source,
    int limit = 20,
  }) {
    final existing = _recoveryInFlightByTrip[tripId];
    if (existing != null) {
      return existing;
    }
    final future = _runRecoveryLocked(
      tripId: tripId,
      source: source,
      limit: limit,
    );
    _recoveryInFlightByTrip[tripId] = future;
    return future.whenComplete(() {
      _recoveryInFlightByTrip.remove(tripId);
    });
  }

  Future<void> acceptCandidate({
    required String eventId,
    required V2ResolverCandidate candidate,
  }) async {
    final event = await _eventRepository.getEventById(eventId);
    if (event == null) {
      return;
    }
    final now = _now().toUtc();
    final canonicalBinding = await _canonicalizeProviderPoiBinding(
      event: event,
      providerPlaceId: candidate.providerPlaceId,
      providerPlaceName: candidate.name,
      now: now,
    );
    await _eventRepository.updateResolverOutcome(
      eventId: eventId,
      resolverState: 'place_bound',
      decisionSource: 'user_accept_candidate',
      manualLock: 1,
      placeBindKind: canonicalBinding.bindKind,
      placeBindId: canonicalBinding.bindId,
      placeBindName: canonicalBinding.bindName,
      geotagFinalReason: null,
      resolvedAt: now,
      updatedAt: now,
    );
    if (_shouldMirrorPlaceAttachment(
      placeBindKind: canonicalBinding.bindKind,
      placeBindId: canonicalBinding.bindId,
    )) {
      await _mirrorPlaceAttachmentForEvent(
        eventId: eventId,
        placeLocalId: canonicalBinding.bindId!,
        now: now,
      );
    }
    Logger.info(
      'resolver_state_transition',
      <String, Object?>{
        'event_id': eventId,
        'trip_id': event.tripLocalId,
        'from_state': event.resolverState,
        'to_state': 'place_bound',
        'source': 'user_accept_candidate',
      },
    );
  }

  Future<void> assignManualPlace({
    required String eventId,
    required String placeId,
    required String placeName,
  }) async {
    final event = await _eventRepository.getEventById(eventId);
    if (event == null) {
      return;
    }
    final now = _now().toUtc();
    final trimmedPlaceId = placeId.trim();
    await _eventRepository.updateResolverOutcome(
      eventId: eventId,
      resolverState: 'place_bound',
      decisionSource: 'user_manual_place',
      manualLock: 1,
      placeBindKind: 'trip_place_local',
      placeBindId: trimmedPlaceId,
      placeBindName: placeName.trim(),
      geotagFinalReason: null,
      resolvedAt: now,
      updatedAt: now,
    );
    if (_shouldMirrorPlaceAttachment(
      placeBindKind: 'trip_place_local',
      placeBindId: trimmedPlaceId,
    )) {
      await _mirrorPlaceAttachmentForEvent(
        eventId: eventId,
        placeLocalId: trimmedPlaceId,
        now: now,
      );
    }
    Logger.info(
      'resolver_state_transition',
      <String, Object?>{
        'event_id': eventId,
        'trip_id': event.tripLocalId,
        'from_state': event.resolverState,
        'to_state': 'place_bound',
        'source': 'user_manual_place',
      },
    );
  }

  Future<void> keepGeotag({
    required String eventId,
    String reason = 'user_keep_geotag',
  }) async {
    final event = await _eventRepository.getEventById(eventId);
    if (event == null) {
      return;
    }
    final now = _now().toUtc();
    await _eventRepository.updateResolverOutcome(
      eventId: eventId,
      resolverState: 'geotag_final',
      decisionSource: 'user_keep_geotag',
      manualLock: 1,
      placeBindKind: null,
      placeBindId: null,
      placeBindName: null,
      geotagFinalReason: reason,
      resolvedAt: now,
      updatedAt: now,
    );
    Logger.info(
      'resolver_state_transition',
      <String, Object?>{
        'event_id': eventId,
        'trip_id': event.tripLocalId,
        'from_state': event.resolverState,
        'to_state': 'geotag_final',
        'source': reason,
      },
    );
  }

  Future<void> _runRecoveryLocked({
    required String tripId,
    required V2ResolverTriggerSource source,
    required int limit,
  }) async {
    final online = await isNetworkAvailable();
    if (!online) {
      Logger.info(
        'resolver_recovery_skipped_offline',
        <String, Object>{
          'trip_id': tripId,
          'source': source.name,
        },
      );
      return;
    }
    Logger.info(
      'resolver_recovery_triggered',
      <String, Object>{
        'trip_id': tripId,
        'source': source.name,
      },
    );
    final events = await _eventRepository.listUnresolvedEventsForTrip(
      tripId,
      limit: limit,
    );
    var attempted = 0;
    for (final event in events) {
      final didResolve = await _resolveEvent(
        event: event,
        source: source,
        isRecovery: true,
      );
      if (didResolve) {
        attempted++;
      }
    }
    Logger.info(
      'resolver_recovery_completed',
      <String, Object>{
        'trip_id': tripId,
        'source': source.name,
        'attempted_count': attempted,
      },
    );
  }

  Future<bool> _resolveEvent({
    required EventJournalRow event,
    required V2ResolverTriggerSource source,
    required bool isRecovery,
  }) async {
    if (!_eventInFlight.add(event.eventId)) {
      return false;
    }
    try {
      final latestEvent = await _eventRepository.getEventById(event.eventId);
      if (latestEvent == null) {
        return false;
      }
      final attempts =
          await _resolverRepository.listAttemptsForEvent(latestEvent.eventId);
      if (latestEvent.manualLock == 1) {
        await _recordAttempt(
          event: latestEvent,
          attempts: attempts,
          source: source,
          resultKind: V2ResolverAttemptResult.skippedLocked,
          startedAt: _now().toUtc(),
          finishedAt: _now().toUtc(),
        );
        Logger.info(
          'resolver_skipped_locked',
          <String, Object>{
            'event_id': latestEvent.eventId,
            'trip_id': latestEvent.tripLocalId,
          },
        );
        return false;
      }
      if (isRecovery &&
          !_isRecoveryEligible(event: latestEvent, attempts: attempts)) {
        Logger.info(
          'resolver_recovery_skipped_not_eligible',
          <String, Object>{
            'event_id': latestEvent.eventId,
            'trip_id': latestEvent.tripLocalId,
            'source': source.name,
          },
        );
        return false;
      }
      if (!isRecovery && attempts.isNotEmpty) {
        return false;
      }

      final startedAt = _now().toUtc();
      Logger.info(
        'resolver_attempt_started',
        <String, Object>{
          'event_id': latestEvent.eventId,
          'trip_id': latestEvent.tripLocalId,
          'source': source.name,
        },
      );

      List<V2ResolverCandidate> candidates;
      try {
        candidates = await _resolverClient.fetchReverseCandidates(
          location: AppLatLng(
            latitude: latestEvent.latitude,
            longitude: latestEvent.longitude,
          ),
        );
      } on V2ResolverProviderException catch (error) {
        await _recordAttempt(
          event: latestEvent,
          attempts: attempts,
          source: source,
          resultKind: V2ResolverAttemptResult.providerError,
          startedAt: startedAt,
          finishedAt: _now().toUtc(),
          errorCode: error.code,
          errorMessage: error.message,
        );
        Logger.warning(
          'resolver_attempt_completed',
          <String, Object?>{
            'event_id': latestEvent.eventId,
            'trip_id': latestEvent.tripLocalId,
            'result': V2ResolverAttemptResult.providerError.wireValue,
            'error_code': error.code,
          },
        );
        return true;
      } catch (error) {
        await _recordAttempt(
          event: latestEvent,
          attempts: attempts,
          source: source,
          resultKind: V2ResolverAttemptResult.providerError,
          startedAt: startedAt,
          finishedAt: _now().toUtc(),
          errorCode: 'resolver_exception',
          errorMessage: error.toString(),
        );
        Logger.warning(
          'resolver_attempt_completed',
          <String, Object?>{
            'event_id': latestEvent.eventId,
            'trip_id': latestEvent.tripLocalId,
            'result': V2ResolverAttemptResult.providerError.wireValue,
            'error_code': 'resolver_exception',
          },
        );
        return true;
      }

      final refreshed =
          await _eventRepository.getEventById(latestEvent.eventId);
      if (refreshed == null) {
        return false;
      }
      if (refreshed.manualLock == 1) {
        await _recordAttempt(
          event: refreshed,
          attempts: attempts,
          source: source,
          resultKind: V2ResolverAttemptResult.skippedLocked,
          startedAt: startedAt,
          finishedAt: _now().toUtc(),
        );
        Logger.info(
          'resolver_skipped_locked',
          <String, Object>{
            'event_id': refreshed.eventId,
            'trip_id': refreshed.tripLocalId,
          },
        );
        return false;
      }

      final decision = _reducer.reduce(candidates);
      final candidateVersion = refreshed.candidateSetVersion + 1;
      await _persistCandidates(
        eventId: refreshed.eventId,
        candidateVersion: candidateVersion,
        candidates: candidates,
      );
      final now = _now().toUtc();
      final canonicalBinding = await _canonicalizeProviderPoiBinding(
        event: refreshed,
        providerPlaceId: decision.placeBindKind == 'provider_poi'
            ? decision.placeBindId
            : null,
        providerPlaceName: decision.placeBindName,
        now: now,
      );
      await _eventRepository.updateResolverOutcome(
        eventId: refreshed.eventId,
        resolverState: decision.resolverState,
        decisionSource: decision.decisionSource,
        placeBindKind: canonicalBinding.bindKind,
        placeBindId: canonicalBinding.bindId,
        placeBindName: canonicalBinding.bindName,
        geotagFinalReason: decision.geotagFinalReason,
        candidateSetVersion: candidateVersion,
        resolvedAt: decision.resolverState == 'place_bound' ? now : null,
        updatedAt: now,
      );
      if (_shouldMirrorPlaceAttachment(
        placeBindKind: canonicalBinding.bindKind,
        placeBindId: canonicalBinding.bindId,
      )) {
        await _mirrorPlaceAttachmentForEvent(
          eventId: refreshed.eventId,
          placeLocalId: canonicalBinding.bindId!,
          now: now,
        );
      }
      await _recordAttempt(
        event: refreshed,
        attempts: attempts,
        source: source,
        resultKind: decision.resultKind,
        startedAt: startedAt,
        finishedAt: now,
      );
      Logger.info(
        'resolver_attempt_completed',
        <String, Object>{
          'event_id': refreshed.eventId,
          'trip_id': refreshed.tripLocalId,
          'result': decision.resultKind.wireValue,
          'resolver_state': decision.resolverState,
        },
      );
      Logger.info(
        'resolver_state_transition',
        <String, Object?>{
          'event_id': refreshed.eventId,
          'trip_id': refreshed.tripLocalId,
          'from_state': refreshed.resolverState,
          'to_state': decision.resolverState,
          'source': source.wireValue,
        },
      );
      return true;
    } finally {
      _eventInFlight.remove(event.eventId);
    }
  }

  bool _isRecoveryEligible({
    required EventJournalRow event,
    required List<ResolverAttemptJournalRow> attempts,
  }) {
    if (event.manualLock == 1 || !_isUnresolvedState(event.resolverState)) {
      return false;
    }
    if (attempts.length != 1) {
      return false;
    }
    return attempts.first.resultKind ==
        V2ResolverAttemptResult.providerError.wireValue;
  }

  bool _isUnresolvedState(String resolverState) {
    return resolverState == 'geotag_unresolved' ||
        resolverState == 'review_required';
  }

  Future<_CanonicalPlaceBinding> _canonicalizeProviderPoiBinding({
    required EventJournalRow event,
    required String? providerPlaceId,
    required String? providerPlaceName,
    required DateTime now,
  }) async {
    if (providerPlaceId == null || providerPlaceId.trim().isEmpty) {
      return _CanonicalPlaceBinding(
        bindKind: null,
        bindId: null,
        bindName: providerPlaceName,
      );
    }
    final normalizedProviderPlaceId = providerPlaceId.trim();

    final existingLocalBinding = await _findExistingTripPlaceBindingForProvider(
      tripLocalId: event.tripLocalId,
      providerPlaceId: normalizedProviderPlaceId,
    );
    if (existingLocalBinding != null) {
      return _CanonicalPlaceBinding(
        bindKind: 'trip_place_local',
        bindId: existingLocalBinding.placeLocalId,
        bindName: existingLocalBinding.placeName ?? providerPlaceName,
      );
    }

    final displayOrder = await _displayOrderForEvent(
      tripLocalId: event.tripLocalId,
      eventId: event.eventId,
      fallbackCapturedAt: event.capturedAt,
    );
    final orderIndex = await _countTimelineEntriesBeforeDisplayOrder(
      tripLocalId: event.tripLocalId,
      displayOrder: displayOrder,
    );
    final placeLocalId = _uuid.v4();
    final trimmedName = providerPlaceName?.trim();
    final placeName = (trimmedName == null || trimmedName.isEmpty)
        ? 'Captured place'
        : trimmedName;

    await _database.into(_database.places).insertOnConflictUpdate(
          PlacesCompanion.insert(
            id: placeLocalId,
            tripId: event.tripLocalId,
            name: placeName,
            coordinates: AppLatLng(
              latitude: event.latitude,
              longitude: event.longitude,
            ),
            orderIndex: orderIndex,
            dayNumber: Value((orderIndex ~/ 5) + 1),
            placeType: const Value('place'),
            localUpdatedAt: now,
            serverUpdatedAt: now,
            syncStatus: 'pending',
          ),
        );
    return _CanonicalPlaceBinding(
      bindKind: 'trip_place_local',
      bindId: placeLocalId,
      bindName: placeName,
    );
  }

  Future<_ExistingTripPlaceBinding?> _findExistingTripPlaceBindingForProvider({
    required String tripLocalId,
    required String providerPlaceId,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT e.place_bind_id AS place_local_id, p.name AS place_name
      FROM event_journal e
      INNER JOIN resolver_candidate_journal c ON c.event_id = e.event_id
      INNER JOIN places p
        ON p.id = e.place_bind_id
       AND p.trip_id = e.trip_local_id
      WHERE e.trip_local_id = ?
        AND e.place_bind_kind = 'trip_place_local'
        AND e.place_bind_id IS NOT NULL
        AND c.provider_place_id = ?
      ORDER BY COALESCE(e.resolved_at, e.updated_at) DESC
      LIMIT 1
      ''',
      variables: <Variable<Object>>[
        Variable<String>(tripLocalId),
        Variable<String>(providerPlaceId),
      ],
      readsFrom: {
        _database.eventJournal,
        _database.resolverCandidateJournal,
        _database.places,
      },
    ).get();
    if (rows.isEmpty) {
      return null;
    }
    final placeLocalId = rows.first.read<String?>('place_local_id');
    if (placeLocalId == null || placeLocalId.isEmpty) {
      return null;
    }
    return _ExistingTripPlaceBinding(
      placeLocalId: placeLocalId,
      placeName: rows.first.read<String?>('place_name'),
    );
  }

  Future<double> _displayOrderForEvent({
    required String tripLocalId,
    required String eventId,
    required DateTime fallbackCapturedAt,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT display_order
      FROM timeline_projection_local
      WHERE trip_local_id = ?
        AND entry_id = ?
      LIMIT 1
      ''',
      variables: <Variable<Object>>[
        Variable<String>(tripLocalId),
        Variable<String>('event:$eventId'),
      ],
      readsFrom: {
        _database.timelineProjectionLocal,
      },
    ).get();
    final existing =
        rows.isEmpty ? null : rows.first.read<double?>('display_order');
    if (existing != null) {
      return existing;
    }
    return fallbackCapturedAt.toUtc().millisecondsSinceEpoch.toDouble();
  }

  Future<int> _countTimelineEntriesBeforeDisplayOrder({
    required String tripLocalId,
    required double displayOrder,
  }) async {
    final row = await _database.customSelect(
      '''
      SELECT COUNT(1) AS count_before
      FROM timeline_projection_local
      WHERE trip_local_id = ?
        AND COALESCE(
          display_order,
          CAST(strftime('%s', captured_at) AS REAL) * 1000.0
        ) < ?
      ''',
      variables: <Variable<Object>>[
        Variable<String>(tripLocalId),
        Variable<double>(displayOrder),
      ],
      readsFrom: {
        _database.timelineProjectionLocal,
      },
    ).getSingle();
    return row.read<int>('count_before');
  }

  bool _shouldMirrorPlaceAttachment({
    required String? placeBindKind,
    required String? placeBindId,
  }) {
    // Only local place bindings are valid attachment ids for the
    // place-bound media upload lane.
    return placeBindKind == 'trip_place_local' &&
        placeBindId != null &&
        placeBindId.isNotEmpty;
  }

  Future<void> _persistCandidates({
    required String eventId,
    required int candidateVersion,
    required List<V2ResolverCandidate> candidates,
  }) async {
    if (candidates.isEmpty) {
      return;
    }
    final topScore = candidates.first.confidenceScore;
    for (var index = 0; index < math.min(candidates.length, 5); index++) {
      final candidate = candidates[index];
      final isTopTied =
          (candidate.confidenceScore - topScore).abs() <= _reducer.tieEpsilon
              ? 1
              : 0;
      await _resolverRepository.upsertCandidate(
        candidateId: _uuid.v4(),
        eventId: eventId,
        candidateVersion: candidateVersion,
        provider: 'ors',
        providerPlaceId: candidate.providerPlaceId,
        name: candidate.name,
        label: candidate.label,
        latitude: candidate.coordinates.latitude,
        longitude: candidate.coordinates.longitude,
        confidenceScore: candidate.confidenceScore,
        distanceM: candidate.distanceM,
        rankIndex: index,
        isTopTied: isTopTied,
        rawJson: jsonEncode(candidate.rawJson),
        createdAt: _now().toUtc(),
      );
    }
  }

  Future<void> _mirrorPlaceAttachmentForEvent({
    required String eventId,
    required String placeLocalId,
    required DateTime now,
  }) async {
    final dao = _mediaAttachmentsDao;
    if (dao == null) {
      return;
    }
    if (placeLocalId.isEmpty) {
      return;
    }
    final eventAttachments = await dao.listForTarget(
      targetKind: 'trip_event',
      targetLocalId: eventId,
      role: 'capture',
    );
    for (final attachment in eventAttachments) {
      await dao.insertAttachment(
        MediaAttachmentsCompanion.insert(
          id: _uuid.v4(),
          mediaId: attachment.mediaId,
          targetKind: 'place',
          targetLocalId: placeLocalId,
          role: 'review',
          source: const Value('place_resolution'),
          attachedAt: now,
        ),
      );
    }
  }

  Future<void> _recordAttempt({
    required EventJournalRow event,
    required List<ResolverAttemptJournalRow> attempts,
    required V2ResolverTriggerSource source,
    required V2ResolverAttemptResult resultKind,
    required DateTime startedAt,
    required DateTime finishedAt,
    String? errorCode,
    String? errorMessage,
  }) async {
    final nextAttemptNo = attempts.isEmpty ? 1 : (attempts.first.attemptNo + 1);
    await _resolverRepository.upsertAttempt(
      attemptId: _uuid.v4(),
      eventId: event.eventId,
      attemptNo: nextAttemptNo,
      triggerReason: source.wireValue,
      startedAt: startedAt,
      finishedAt: finishedAt,
      resultKind: resultKind.wireValue,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }
}

class _CanonicalPlaceBinding {
  const _CanonicalPlaceBinding({
    required this.bindKind,
    required this.bindId,
    required this.bindName,
  });

  final String? bindKind;
  final String? bindId;
  final String? bindName;
}

class _ExistingTripPlaceBinding {
  const _ExistingTripPlaceBinding({
    required this.placeLocalId,
    required this.placeName,
  });

  final String placeLocalId;
  final String? placeName;
}
