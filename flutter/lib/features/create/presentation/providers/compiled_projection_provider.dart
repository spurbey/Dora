import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drift/drift.dart' show Variable;

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

final compiledProjectionRemoteProvider =
    FutureProvider.autoDispose.family<CompiledProjectionSnapshot, String>((
  ref,
  tripId,
) {
  final repository = ref.watch(compiledProjectionRepositoryProvider);
  return repository.fetchProjection(tripId: tripId);
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
      // When remote projection is available and healthy, skip synced locals
      // (they already exist in the remote data — including them would duplicate).
      // When remote is unavailable, include synced locals so the editor isn't empty.
      if (!remoteUnavailable && _isSynced(row.syncStatus)) {
        continue;
      }
      final clientEventId = _normalizedClientEventId(row);
      if (remoteSourceIds.contains(row.id) ||
          (clientEventId != null &&
              remoteClientEventIds.contains(clientEventId))) {
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
          subtitle: _subtitleForLocalRow(row),
          payload: _decodeJsonMap(row.payloadJson),
          clientEventId: clientEventId,
          isLocalPending: true,
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
