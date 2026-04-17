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
  // V1 refresh signal removed — V2 uses local timeline compiler.
  return const Stream<int>.empty();
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

final compiledProjectionViewProvider =
    Provider.autoDispose.family<AsyncValue<CompiledProjectionView>, String>((
  ref,
  tripId,
) {
  final remote = ref.watch(compiledProjectionRemoteProvider(tripId));

  return remote.when(
    data: (snapshot) => AsyncValue.data(
      CompiledProjectionView.merge(
        remote: snapshot,
        localEvents: const [],
      ),
    ),
    loading: () => const AsyncValue.loading(),
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
        localEvents: const [],
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
    List<dynamic> localEvents = const [],
    bool remoteUnavailable = false,
  }) {
    final entries =
        List<CompiledTimelineEntry>.from(remote.timelineEntries)
          ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

    final grouped = _groupEntriesByDay(entries);
    return CompiledProjectionView(
      tripId: remote.tripId,
      stale: remote.stale,
      remoteUnavailable: remoteUnavailable,
      entries: entries,
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
