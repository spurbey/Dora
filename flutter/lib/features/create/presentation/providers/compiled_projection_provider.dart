import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/compiled_projection_repository.dart';
import 'package:dora/features/create/domain/compiled_projection.dart';

final compiledProjectionRepositoryProvider =
    Provider<CompiledProjectionRepository>((ref) {
  final api = ref.watch(liveTrackingApiProvider);
  final db = ref.watch(appDatabaseProvider);
  return CompiledProjectionRepository(
    liveTrackingApi: api,
    resolveServerTripId: (localTripId) async {
      final row = await db.customSelect(
        'SELECT server_trip_id FROM trips WHERE id = ? LIMIT 1',
        variables: [Variable<String>(localTripId)],
        readsFrom: {db.trips},
      ).getSingleOrNull();
      final id = row?.read<String?>('server_trip_id')?.trim();
      return (id != null && id.isNotEmpty) ? id : null;
    },
    resolveServerPlaceId: (localPlaceId) async {
      final row = await db.customSelect(
        'SELECT server_place_id FROM places WHERE id = ? LIMIT 1',
        variables: [Variable<String>(localPlaceId)],
        readsFrom: {db.places},
      ).getSingleOrNull();
      final id = row?.read<String?>('server_place_id')?.trim();
      return (id != null && id.isNotEmpty) ? id : null;
    },
  );
});

final compiledProjectionRefreshSignalProvider =
    Provider.autoDispose.family<Stream<int>, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT MAX(t.updated_at) AS refresh_tick
    FROM sync_tasks AS t
    WHERE t.status = 'completed'
      AND (
        (t.entity_type = 'tracking_event' AND t.entity_id IN (
          SELECT e.id FROM tracking_events AS e WHERE e.trip_id = ?
        ))
        OR (t.entity_type = 'tracking_event_media' AND t.entity_id IN (
          SELECT em.id FROM tracking_event_media AS em WHERE em.trip_id = ?
        ))
        OR (t.entity_type = 'checkin_decision' AND t.entity_id IN (
          SELECT c.id FROM tracking_candidates AS c WHERE c.trip_id = ?
        ))
        OR (
          t.entity_type = 'tracking_session'
          AND t.operation IN ('start', 'stop')
          AND t.entity_id IN (
            SELECT s.id FROM tracking_sessions AS s WHERE s.trip_id = ?
          )
        )
      )
    ''',
    variables: [
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
    ],
    readsFrom: {
      db.syncTasks,
      db.trackingEvents,
      db.trackingEventMedia,
      db.trackingCandidates,
      db.trackingSessions,
    },
  );

  return query
      .watchSingle()
      .map((row) => _coerceRefreshTickMillis(row.data['refresh_tick']))
      .where((tick) => tick > 0)
      .distinct()
      .transform(
        const _TrailingDebounceStreamTransformer<int>(Duration(seconds: 2)),
      );
});

/// Fetches compiled projection with one shared fetch path:
/// - immediate fetch on subscribe
/// - debounced refresh triggers from completed sync tasks
/// - 90-second fallback poll while editor is visible
final compiledProjectionRemoteProvider =
    StreamProvider.autoDispose.family<CompiledProjectionSnapshot, String>((
  ref,
  tripId,
) {
  final repository = ref.watch(compiledProjectionRepositoryProvider);
  final refreshSignals =
      ref.watch(compiledProjectionRefreshSignalProvider(tripId));

  // Keep this provider warm briefly across route rebuilds.
  final keepAliveLink = ref.keepAlive();
  Timer? disposeGraceTimer;
  ref.onCancel(() {
    disposeGraceTimer?.cancel();
    disposeGraceTimer = Timer(
      const Duration(seconds: 20),
      keepAliveLink.close,
    );
  });
  ref.onResume(() {
    disposeGraceTimer?.cancel();
    disposeGraceTimer = null;
  });

  final controller = StreamController<CompiledProjectionSnapshot>();
  var disposed = false;

  Future<void> emitFetch() async {
    if (disposed || controller.isClosed) {
      return;
    }
    try {
      final snapshot = await repository.fetchProjection(tripId: tripId);
      if (!disposed && !controller.isClosed) {
        controller.add(snapshot);
      }
    } catch (error, stackTrace) {
      if (!disposed && !controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    }
  }

  final refreshSub = refreshSignals.listen(
    (_) => unawaited(emitFetch()),
    onError: (Object error, StackTrace stackTrace) {
      if (!disposed && !controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    },
  );

  final pollTimer = Timer.periodic(
    const Duration(seconds: 90),
    (_) => unawaited(emitFetch()),
  );

  unawaited(emitFetch());

  ref.onDispose(() {
    disposed = true;
    disposeGraceTimer?.cancel();
    pollTimer.cancel();
    unawaited(refreshSub.cancel());
    unawaited(controller.close());
  });

  return controller.stream;
});

final _trackingEventsForTripProvider =
    StreamProvider.autoDispose.family<List<TrackingEventRow>, String>((
  ref,
  tripId,
) {
  final trackingEventDao = ref.watch(trackingEventDaoProvider);
  return trackingEventDao.watchEventsForTrip(tripId);
});

final compiledProjectionViewProvider =
    Provider.autoDispose.family<AsyncValue<CompiledProjectionView>, String>((
  ref,
  tripId,
) {
  final remote = ref.watch(compiledProjectionRemoteProvider(tripId));
  final localEvents = ref.watch(_trackingEventsForTripProvider(tripId)).value ??
      const <TrackingEventRow>[];

  return remote.when(
    data: (snapshot) => AsyncValue.data(
      CompiledProjectionView.merge(
        remote: snapshot,
        localEvents: localEvents,
      ),
    ),
    loading: () {
      final fallback = CompiledProjectionView.merge(
        remote: const CompiledProjectionSnapshot(
          tripId: '',
          compilerVersion: 1,
          stale: false,
          timelineEntries: <CompiledTimelineEntry>[],
          timelineGroups: <CompiledTimelineDayGroup>[],
          routeSegments: <CompiledRouteSegment>[],
        ),
        localEvents: localEvents,
        remoteUnavailable: false,
      );
      return localEvents.isEmpty
          ? const AsyncValue.loading()
          : AsyncValue.data(fallback);
    },
    error: (error, stackTrace) => AsyncValue.data(
      CompiledProjectionView.merge(
        remote: const CompiledProjectionSnapshot(
          tripId: '',
          compilerVersion: 1,
          stale: true,
          timelineEntries: <CompiledTimelineEntry>[],
          timelineGroups: <CompiledTimelineDayGroup>[],
          routeSegments: <CompiledRouteSegment>[],
        ),
        localEvents: localEvents,
        remoteUnavailable: true,
      ),
    ),
  );
});

class CompiledProjectionView {
  const CompiledProjectionView({
    required this.tripId,
    required this.stale,
    required this.remoteUnavailable,
    required this.entries,
    required this.dayGroups,
    required this.routeSegments,
  });

  final String tripId;
  final bool stale;
  final bool remoteUnavailable;
  final List<CompiledTimelineEntry> entries;
  final List<CompiledProjectionDayGroup> dayGroups;
  final List<CompiledRouteSegment> routeSegments;

  bool get hasEntries => entries.isNotEmpty;

  factory CompiledProjectionView.merge({
    required CompiledProjectionSnapshot remote,
    required List<TrackingEventRow> localEvents,
    bool remoteUnavailable = false,
  }) {
    final remoteEntries =
        List<CompiledTimelineEntry>.from(remote.timelineEntries);
    final remoteSourceIds = remoteEntries
        .where((entry) => entry.sourceKind == 'tracking_event')
        .map((entry) => entry.sourceId)
        .where((sourceId) => sourceId.isNotEmpty)
        .toSet();
    final remoteClientEventIds = remoteEntries
        .map((entry) => entry.clientEventId?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();

    final overlayEntries = <CompiledTimelineEntry>[];
    for (final row in localEvents) {
      if (!_isStorylineEventType(row.eventType)) {
        continue;
      }
      final clientEventId = _normalizedClientEventId(row);
      if ((clientEventId != null &&
              remoteClientEventIds.contains(clientEventId)) ||
          remoteSourceIds.contains(row.id)) {
        continue;
      }
      overlayEntries.add(
        CompiledTimelineEntry(
          entryId: 'local_tracking_event:${row.id}',
          sourceKind: 'tracking_event_local',
          sourceId: row.id,
          eventType: row.eventType,
          capturedAt: row.createdAt.toUtc(),
          bucketType:
              (row.resolvedPlaceId != null && row.resolvedPlaceId!.isNotEmpty)
                  ? 'place'
                  : 'on_route',
          placeId: row.resolvedPlaceId,
          placeName: null,
          bindSource: 'none',
          bindConfidence: row.bindConfidence,
          reasonCode: row.resolverReasonCode,
          title: _titleForLocalRow(row),
          subtitle: _isSynced(row.syncStatus)
              ? _subtitleForSyncedLocalRow(row)
              : _subtitleForLocalRow(row),
          payload: _payloadForLocalRow(row),
          clientEventId: clientEventId,
          isLocalPending: !_isSynced(row.syncStatus),
        ),
      );
    }

    final merged = <CompiledTimelineEntry>[
      ...remoteEntries,
      ...overlayEntries,
    ]..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

    final grouped = _groupEntriesByDay(merged);
    return CompiledProjectionView(
      tripId: remote.tripId,
      stale: remote.stale,
      remoteUnavailable: remoteUnavailable,
      entries: merged,
      dayGroups: grouped,
      routeSegments: remote.routeSegments,
    );
  }
}

class CompiledProjectionDayGroup {
  const CompiledProjectionDayGroup({
    required this.day,
    required this.entries,
  });

  final DateTime day;
  final List<CompiledTimelineEntry> entries;
}

List<CompiledProjectionDayGroup> _groupEntriesByDay(
  List<CompiledTimelineEntry> entries,
) {
  final byDay = <DateTime, List<CompiledTimelineEntry>>{};
  for (final entry in entries) {
    final day = DateTime(
      entry.capturedAt.toLocal().year,
      entry.capturedAt.toLocal().month,
      entry.capturedAt.toLocal().day,
    );
    byDay.putIfAbsent(day, () => <CompiledTimelineEntry>[]).add(entry);
  }
  final sortedDays = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return sortedDays
      .map(
        (day) => CompiledProjectionDayGroup(
          day: day,
          entries: byDay[day]!
            ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt)),
        ),
      )
      .toList(growable: false);
}

bool _isStorylineEventType(String eventType) =>
    eventType == 'note' ||
    eventType == 'warn' ||
    eventType == 'tag' ||
    eventType == 'photo' ||
    eventType == 'media';

bool _isSynced(String syncStatus) => syncStatus.toLowerCase() == 'synced';

String? _normalizedClientEventId(TrackingEventRow row) {
  final value = row.clientEventId?.trim();
  if (value == null || value.isEmpty) {
    return row.id;
  }
  return value;
}

String _titleForLocalRow(TrackingEventRow row) {
  final note = row.note?.trim();
  if (note != null && note.isNotEmpty) {
    return note;
  }
  switch (row.eventType) {
    case 'warn':
      return 'Warning captured';
    case 'tag':
      return 'Tag captured';
    default:
      return 'Note captured';
  }
}

String _subtitleForLocalRow(TrackingEventRow row) {
  final status = row.syncStatus.trim().isEmpty ? 'pending' : row.syncStatus;
  return 'Pending sync ($status)';
}

String _subtitleForSyncedLocalRow(TrackingEventRow row) {
  final resolverState = row.resolverState.trim();
  if (resolverState == 'resolved') return 'Synced';
  if (resolverState == 'review_required') {
    return 'Synced - needs place confirmation';
  }
  return 'Synced - on route';
}

Map<String, dynamic> _payloadForLocalRow(TrackingEventRow row) {
  final payload = _decodeJsonMap(row.payloadJson);
  final clientEventId = row.clientEventId?.trim();
  if (clientEventId != null && clientEventId.isNotEmpty) {
    payload.putIfAbsent('client_event_id', () => clientEventId);
  }
  final resolverState = row.resolverState.trim();
  if (resolverState.isNotEmpty) {
    payload['resolver_state'] = resolverState;
  }
  final hintJson = row.resolutionHintJson?.trim() ?? '';
  if (hintJson.isNotEmpty) {
    payload['resolution_hint_json'] = hintJson;
    final parsedHints = _decodeJsonList(hintJson);
    if (parsedHints != null) {
      payload.putIfAbsent('resolver_hints', () => parsedHints);
    }
  }
  return payload;
}

Map<String, dynamic> _decodeJsonMap(String raw) {
  if (raw.trim().isEmpty) {
    return <String, dynamic>{};
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  } catch (_) {
    // Ignore malformed payloads and fall back to empty map.
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>>? _decodeJsonList(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return null;
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  } catch (_) {
    return null;
  }
}

int _coerceRefreshTickMillis(dynamic raw) {
  if (raw is DateTime) {
    return raw.millisecondsSinceEpoch;
  }
  if (raw is int) {
    return raw;
  }
  if (raw is String) {
    final parsedInt = int.tryParse(raw);
    if (parsedInt != null) {
      return parsedInt;
    }
    final parsedDate = DateTime.tryParse(raw);
    if (parsedDate != null) {
      return parsedDate.millisecondsSinceEpoch;
    }
  }
  return 0;
}

class _TrailingDebounceStreamTransformer<T>
    extends StreamTransformerBase<T, T> {
  const _TrailingDebounceStreamTransformer(this.duration);

  final Duration duration;

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    T? latest;
    var hasLatest = false;

    void emitLatest() {
      if (!hasLatest) {
        return;
      }
      controller.add(latest as T);
      hasLatest = false;
      latest = null;
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen(
          (event) {
            latest = event;
            hasLatest = true;
            timer?.cancel();
            timer = Timer(duration, emitLatest);
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            emitLatest();
            unawaited(controller.close());
          },
          cancelOnError: false,
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        timer?.cancel();
        await subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
