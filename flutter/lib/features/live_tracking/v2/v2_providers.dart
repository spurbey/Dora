import 'dart:async';

import 'package:dora/core/config/live_system_v2_gate.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_projection_repository.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_timeline_compiler.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_orchestrator.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_repository.dart';
import 'package:dora/features/live_tracking/v2/data/live_capture_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/media_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/resolver_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/route_point_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_client.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_decision_reducer.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_orchestrator.dart';

final v2SessionJournalRepositoryProvider =
    Provider<V2SessionJournalRepository>((ref) {
  final dao = ref.watch(v2SessionJournalDaoProvider);
  return V2SessionJournalRepository(dao);
});

final v2RoutePointJournalRepositoryProvider =
    Provider<V2RoutePointJournalRepository>((ref) {
  final dao = ref.watch(v2RoutePointJournalDaoProvider);
  return V2RoutePointJournalRepository(dao);
});

final v2EventJournalRepositoryProvider = Provider<V2EventJournalRepository>(
  (ref) {
    final dao = ref.watch(v2EventJournalDaoProvider);
    return V2EventJournalRepository(dao);
  },
);

final v2MediaJournalRepositoryProvider = Provider<V2MediaJournalRepository>(
  (ref) {
    final dao = ref.watch(v2MediaJournalDaoProvider);
    return V2MediaJournalRepository(dao);
  },
);

final v2ResolverJournalRepositoryProvider =
    Provider<V2ResolverJournalRepository>((ref) {
  final candidateDao = ref.watch(v2ResolverCandidateJournalDaoProvider);
  final attemptDao = ref.watch(v2ResolverAttemptJournalDaoProvider);
  return V2ResolverJournalRepository(
    resolverCandidateDao: candidateDao,
    resolverAttemptDao: attemptDao,
  );
});

final v2LiveCaptureJournalRepositoryProvider =
    Provider<V2LiveCaptureJournalRepository>((ref) {
  return V2LiveCaptureJournalRepository(
    sessionRepository: ref.watch(v2SessionJournalRepositoryProvider),
    eventRepository: ref.watch(v2EventJournalRepositoryProvider),
    mediaRepository: ref.watch(v2MediaJournalRepositoryProvider),
  );
});

final v2ResolverClientProvider = Provider<V2ResolverClient>((ref) {
  return V2ResolverClient();
});

final v2ResolverDecisionReducerProvider =
    Provider<V2ResolverDecisionReducer>((ref) {
  return const V2ResolverDecisionReducer();
});

final v2ResolverOrchestratorProvider = Provider<V2ResolverOrchestrator>((ref) {
  return V2ResolverOrchestrator(
    eventRepository: ref.watch(v2EventJournalRepositoryProvider),
    resolverRepository: ref.watch(v2ResolverJournalRepositoryProvider),
    resolverClient: ref.watch(v2ResolverClientProvider),
    reducer: ref.watch(v2ResolverDecisionReducerProvider),
  );
});

final v2LocalProjectionRepositoryProvider =
    Provider<V2LocalProjectionRepository>((ref) {
  return V2LocalProjectionRepository(
    timelineDao: ref.watch(v2TimelineProjectionLocalDaoProvider),
    routeDao: ref.watch(v2RouteProjectionLocalDaoProvider),
    cursorDao: ref.watch(v2TimelineCompileCursorDaoProvider),
  );
});

final v2SessionCommitRepositoryProvider =
    Provider<V2SessionCommitRepository>((ref) {
  return V2SessionCommitRepository(
    database: ref.watch(appDatabaseProvider),
    sessionDao: ref.watch(v2SessionJournalDaoProvider),
    jobDao: ref.watch(v2SessionCommitJobDaoProvider),
    mediaItemDao: ref.watch(v2SessionCommitMediaItemDaoProvider),
    chunkDao: ref.watch(v2SessionCommitChunkDaoProvider),
    eventDao: ref.watch(v2EventJournalDaoProvider),
    mediaDao: ref.watch(v2MediaJournalDaoProvider),
    routePointDao: ref.watch(v2RoutePointJournalDaoProvider),
  );
});

final v2SessionCommitOrchestratorProvider =
    Provider<V2SessionCommitOrchestrator>((ref) {
  return V2SessionCommitOrchestrator(
    gate: ref.watch(liveSystemV2RolloutGateProvider),
    sessionRepository: ref.watch(v2SessionJournalRepositoryProvider),
    commitRepository: ref.watch(v2SessionCommitRepositoryProvider),
  );
});

final v2CommitSyncSnapshotProvider =
    StreamProvider.autoDispose.family<V2CommitSyncSnapshot, String>((
  ref,
  tripId,
) {
  final repository = ref.watch(v2SessionCommitRepositoryProvider);
  return repository.watchTripSyncSnapshot(tripId);
});

final v2LocalTimelineCompilerProvider =
    Provider<V2LocalTimelineCompiler>((ref) {
  return V2LocalTimelineCompiler(
    database: ref.watch(appDatabaseProvider),
    projectionRepository: ref.watch(v2LocalProjectionRepositoryProvider),
    sessionRepository: ref.watch(v2SessionJournalRepositoryProvider),
    eventRepository: ref.watch(v2EventJournalRepositoryProvider),
    mediaRepository: ref.watch(v2MediaJournalRepositoryProvider),
    routePointRepository: ref.watch(v2RoutePointJournalRepositoryProvider),
  );
});

final v2ProjectionRefreshSignalProvider =
    Provider.autoDispose.family<Stream<int>, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT
      (SELECT MAX(updated_at)
       FROM session_journal
       WHERE trip_local_id = ?
         AND control_state = 'sealed') AS max_sealed_session_updated_at,
      (SELECT GROUP_CONCAT(session_id, '|')
       FROM session_journal
       WHERE trip_local_id = ?
         AND control_state = 'sealed') AS sealed_session_ids
    ''',
    variables: [
      Variable<String>(tripId),
      Variable<String>(tripId),
    ],
    readsFrom: {
      db.sessionJournal,
    },
  );

  return query
      .watchSingle()
      .map((row) {
        final maxSealedUpdatedAt =
            row.data['max_sealed_session_updated_at']?.toString() ?? '';
        final sealedSessionIds =
            row.data['sealed_session_ids']?.toString() ?? '';
        if (maxSealedUpdatedAt.isEmpty && sealedSessionIds.isEmpty) {
          return 0;
        }
        return Object.hash(maxSealedUpdatedAt, sealedSessionIds);
      })
      .distinct()
      .transform(
        const _TrailingDebounceStreamTransformer<int>(
          Duration(milliseconds: 300),
        ),
      );
});

final v2ProjectionCompileDriverProvider =
    Provider.autoDispose.family<void, String>((ref, tripId) {
  final compiler = ref.watch(v2LocalTimelineCompilerProvider);
  final refreshStream = ref.watch(v2ProjectionRefreshSignalProvider(tripId));
  var disposed = false;

  Future<void> runCompile({String? reason}) async {
    if (disposed) {
      return;
    }
    try {
      await compiler.compileTrip(tripId: tripId, reason: reason);
    } catch (_) {
      // Keep projection watchers alive even if one compile run fails.
    }
  }

  final sub = refreshStream.listen(
    (signal) {
      if (signal == 0) {
        return;
      }
      unawaited(runCompile(reason: 'sealed_session_refresh'));
    },
    onError: (_, __) {
      // No-op: compile remains best-effort for provider consumers.
    },
  );
  ref.onDispose(() async {
    disposed = true;
    await sub.cancel();
  });
});

final v2TimelineProjectionProvider =
    StreamProvider.autoDispose.family<List<V2TimelineProjectionEntry>, String>((
  ref,
  tripId,
) {
  ref.watch(v2ProjectionCompileDriverProvider(tripId));
  final repository = ref.watch(v2LocalProjectionRepositoryProvider);
  return repository.watchTimelineEntries(tripId);
});

final v2RouteProjectionProvider =
    StreamProvider.autoDispose.family<List<V2RouteProjectionSegment>, String>((
  ref,
  tripId,
) {
  ref.watch(v2ProjectionCompileDriverProvider(tripId));
  final repository = ref.watch(v2LocalProjectionRepositoryProvider);
  return repository.watchRouteSegments(tripId);
});

final v2TimelineGroupsProvider = Provider.autoDispose
    .family<AsyncValue<List<V2TimelineDayGroup>>, String>((ref, tripId) {
  final entriesAsync = ref.watch(v2TimelineProjectionProvider(tripId));
  return entriesAsync.when(
    data: (entries) => AsyncValue.data(_groupTimelineByDayAndSession(entries)),
    loading: AsyncValue.loading,
    error: AsyncValue.error,
  );
});

final v2LiveRecentProjectionProvider = Provider.autoDispose
    .family<AsyncValue<List<V2TimelineProjectionEntry>>, String>((ref, tripId) {
  final entriesAsync = ref.watch(v2TimelineProjectionProvider(tripId));
  return entriesAsync.when(
    data: (entries) => AsyncValue.data(
      entries.take(12).toList(growable: false),
    ),
    loading: AsyncValue.loading,
    error: AsyncValue.error,
  );
});

List<V2TimelineDayGroup> _groupTimelineByDayAndSession(
  List<V2TimelineProjectionEntry> entries,
) {
  final byDay = <DateTime, List<V2TimelineProjectionEntry>>{};
  for (final entry in entries) {
    final local = entry.capturedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    byDay.putIfAbsent(day, () => <V2TimelineProjectionEntry>[]).add(entry);
  }
  final sortedDays = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

  final groups = <V2TimelineDayGroup>[];
  for (final day in sortedDays) {
    final dayEntries = byDay[day]!
      ..sort(
        (a, b) => b.capturedAt.compareTo(a.capturedAt),
      );
    final bySession = <String, List<V2TimelineProjectionEntry>>{};
    for (final entry in dayEntries) {
      bySession
          .putIfAbsent(entry.sessionId, () => <V2TimelineProjectionEntry>[])
          .add(entry);
    }
    final sortedSessionIds = bySession.keys.toList()
      ..sort((a, b) {
        final aTop = bySession[a]!.first.capturedAt;
        final bTop = bySession[b]!.first.capturedAt;
        return bTop.compareTo(aTop);
      });
    final sessions = sortedSessionIds
        .map(
          (sessionId) => V2TimelineSessionGroup(
            sessionId: sessionId,
            entries: bySession[sessionId]!,
          ),
        )
        .toList(growable: false);
    groups.add(
      V2TimelineDayGroup(
        day: day,
        sessions: sessions,
      ),
    );
  }
  return groups;
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
    T? pending;

    void flushPending() {
      if (pending == null || controller.isClosed) {
        return;
      }
      controller.add(pending as T);
      pending = null;
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen(
          (event) {
            pending = event;
            timer?.cancel();
            timer = Timer(duration, flushPending);
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            flushPending();
            controller.close();
          },
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        timer?.cancel();
        pending = null;
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }
}
