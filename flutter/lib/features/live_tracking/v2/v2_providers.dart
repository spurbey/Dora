import 'dart:async';

import 'package:dora/core/config/live_system_v2_gate.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_projection_repository.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_timeline_compiler.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_route_segment_claim_projector.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_route_segment_claim_repository.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_orchestrator.dart';
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_repository.dart';
import 'package:dora/features/live_tracking/v2/data/live_capture_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
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
    mediaDao: ref.watch(mediaDaoProvider),
    mediaAttachmentsDao: ref.watch(mediaAttachmentsDaoProvider),
    resolveOwnerUserId: () =>
        Supabase.instance.client.auth.currentUser?.id ?? 'unknown',
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
    database: ref.watch(appDatabaseProvider),
    eventRepository: ref.watch(v2EventJournalRepositoryProvider),
    resolverRepository: ref.watch(v2ResolverJournalRepositoryProvider),
    resolverClient: ref.watch(v2ResolverClientProvider),
    mediaAttachmentsDao: ref.watch(mediaAttachmentsDaoProvider),
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

final v2RouteSegmentClaimRepositoryProvider =
    Provider<V2RouteSegmentClaimRepository>((ref) {
  return V2RouteSegmentClaimRepository(
    claimDao: ref.watch(v2RouteSegmentClaimLocalDaoProvider),
  );
});

final v2RouteSegmentClaimProjectorProvider =
    Provider<V2RouteSegmentClaimProjector>((ref) {
  return V2RouteSegmentClaimProjector(
    database: ref.watch(appDatabaseProvider),
    projectionRepository: ref.watch(v2LocalProjectionRepositoryProvider),
    claimRepository: ref.watch(v2RouteSegmentClaimRepositoryProvider),
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
    mediaDao: ref.watch(mediaDaoProvider),
    mediaAttachmentsDao: ref.watch(mediaAttachmentsDaoProvider),
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
       FROM event_journal
       WHERE trip_local_id = ?) AS max_event_updated_at,
      (SELECT COUNT(1)
       FROM event_journal
       WHERE trip_local_id = ?) AS event_count,
      (SELECT MAX(updated_at)
       FROM session_journal
       WHERE trip_local_id = ?) AS max_session_updated_at,
      (SELECT COUNT(1)
       FROM session_journal
       WHERE trip_local_id = ?) AS session_count,
      (SELECT MAX(captured_at)
       FROM route_point_journal
       WHERE trip_local_id = ?) AS max_point_captured_at,
      (SELECT COUNT(1)
       FROM route_point_journal
       WHERE trip_local_id = ?) AS point_count,
      (SELECT MAX(m.updated_at)
       FROM media m
       INNER JOIN media_attachments ma ON ma.media_id = m.id
       INNER JOIN event_journal e ON e.event_id = ma.target_local_id
       WHERE ma.target_kind = 'trip_event'
         AND ma.role = 'capture'
         AND ma.detached_at IS NULL
         AND m.deleted_at IS NULL
         AND e.trip_local_id = ?) AS max_media_updated_at,
      (SELECT COUNT(1)
       FROM media m
       INNER JOIN media_attachments ma ON ma.media_id = m.id
       INNER JOIN event_journal e ON e.event_id = ma.target_local_id
       WHERE ma.target_kind = 'trip_event'
         AND ma.role = 'capture'
          AND ma.detached_at IS NULL
          AND m.deleted_at IS NULL
          AND e.trip_local_id = ?) AS media_count,
      (SELECT MAX(rc.created_at)
       FROM resolver_candidate_journal rc
       INNER JOIN event_journal e ON e.event_id = rc.event_id
       WHERE e.trip_local_id = ?) AS max_resolver_candidate_created_at,
      (SELECT COUNT(1)
       FROM resolver_candidate_journal rc
       INNER JOIN event_journal e ON e.event_id = rc.event_id
       WHERE e.trip_local_id = ?) AS resolver_candidate_count,
      (SELECT MAX(COALESCE(ra.finished_at, ra.started_at))
       FROM resolver_attempt_journal ra
       INNER JOIN event_journal e ON e.event_id = ra.event_id
       WHERE e.trip_local_id = ?) AS max_resolver_attempt_updated_at,
      (SELECT COUNT(1)
       FROM resolver_attempt_journal ra
       INNER JOIN event_journal e ON e.event_id = ra.event_id
       WHERE e.trip_local_id = ?) AS resolver_attempt_count
    ''',
    variables: [
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
    ],
    readsFrom: {
      db.eventJournal,
      db.sessionJournal,
      db.routePointJournal,
      db.media,
      db.mediaAttachments,
      db.resolverCandidateJournal,
      db.resolverAttemptJournal,
    },
  );

  return query
      .watchSingle()
      .map((row) {
        final maxEventUpdatedAt =
            row.data['max_event_updated_at']?.toString() ?? '';
        final eventCount = row.data['event_count']?.toString() ?? '0';
        final maxSessionUpdatedAt =
            row.data['max_session_updated_at']?.toString() ?? '';
        final sessionCount = row.data['session_count']?.toString() ?? '0';
        final maxPointCapturedAt =
            row.data['max_point_captured_at']?.toString() ?? '';
        final pointCount = row.data['point_count']?.toString() ?? '0';
        final maxMediaUpdatedAt =
            row.data['max_media_updated_at']?.toString() ?? '';
        final mediaCount = row.data['media_count']?.toString() ?? '0';
        final maxResolverCandidateCreatedAt =
            row.data['max_resolver_candidate_created_at']?.toString() ?? '';
        final resolverCandidateCount =
            row.data['resolver_candidate_count']?.toString() ?? '0';
        final maxResolverAttemptUpdatedAt =
            row.data['max_resolver_attempt_updated_at']?.toString() ?? '';
        final resolverAttemptCount =
            row.data['resolver_attempt_count']?.toString() ?? '0';
        if (maxEventUpdatedAt.isEmpty &&
            maxSessionUpdatedAt.isEmpty &&
            maxPointCapturedAt.isEmpty &&
            maxMediaUpdatedAt.isEmpty &&
            maxResolverCandidateCreatedAt.isEmpty &&
            maxResolverAttemptUpdatedAt.isEmpty &&
            eventCount == '0' &&
            sessionCount == '0' &&
            pointCount == '0' &&
            mediaCount == '0' &&
            resolverCandidateCount == '0' &&
            resolverAttemptCount == '0') {
          return 0;
        }
        return Object.hash(
          maxEventUpdatedAt,
          eventCount,
          maxSessionUpdatedAt,
          sessionCount,
          maxPointCapturedAt,
          pointCount,
          maxMediaUpdatedAt,
          mediaCount,
          maxResolverCandidateCreatedAt,
          resolverCandidateCount,
          maxResolverAttemptUpdatedAt,
          resolverAttemptCount,
        );
      })
      .distinct()
      .transform(
        const _TrailingDebounceStreamTransformer<int>(
          Duration(milliseconds: 1500),
        ),
      );
});

final v2ProjectionCompileDriverProvider =
    Provider.autoDispose.family<void, String>((ref, tripId) {
  final compiler = ref.watch(v2LocalTimelineCompilerProvider);
  final refreshStream = ref.watch(v2ProjectionRefreshSignalProvider(tripId));
  var disposed = false;
  var compileInFlight = false;
  var compileQueued = false;

  Future<void> runCompile({String? reason}) async {
    if (disposed) {
      return;
    }
    if (compileInFlight) {
      compileQueued = true;
      return;
    }
    compileInFlight = true;
    var nextReason = reason;
    try {
      do {
        compileQueued = false;
        try {
          await compiler.compileTrip(tripId: tripId, reason: nextReason);
        } catch (_) {
          // Keep projection watchers alive even if one compile run fails.
        }
        nextReason = 'local_source_refresh';
      } while (!disposed && compileQueued);
    } finally {
      compileInFlight = false;
    }
  }

  final sub = refreshStream.listen(
    (signal) {
      if (signal == 0) {
        return;
      }
      unawaited(runCompile(reason: 'local_source_refresh'));
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

final v2RouteSegmentClaimRefreshSignalProvider =
    Provider.autoDispose.family<Stream<int>, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT
      (SELECT MAX(local_updated_at)
       FROM routes
       WHERE trip_id = ?) AS max_route_updated_at,
      (SELECT COUNT(1)
       FROM routes
       WHERE trip_id = ?) AS route_count,
      (SELECT MAX(updated_at)
       FROM route_projection_local
       WHERE trip_local_id = ?) AS max_segment_updated_at,
      (SELECT COUNT(1)
       FROM route_projection_local
       WHERE trip_local_id = ?) AS segment_count
    ''',
    variables: [
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
    ],
    readsFrom: {
      db.routes,
      db.routeProjectionLocal,
    },
  );

  return query
      .watchSingle()
      .map((row) {
        final maxRouteUpdatedAt =
            row.data['max_route_updated_at']?.toString() ?? '';
        final routeCount = row.data['route_count']?.toString() ?? '0';
        final maxSegmentUpdatedAt =
            row.data['max_segment_updated_at']?.toString() ?? '';
        final segmentCount = row.data['segment_count']?.toString() ?? '0';
        if (maxRouteUpdatedAt.isEmpty &&
            maxSegmentUpdatedAt.isEmpty &&
            routeCount == '0' &&
            segmentCount == '0') {
          return 0;
        }
        return Object.hash(
          maxRouteUpdatedAt,
          routeCount,
          maxSegmentUpdatedAt,
          segmentCount,
        );
      })
      .distinct()
      .transform(
        const _TrailingDebounceStreamTransformer<int>(
          Duration(milliseconds: 600),
        ),
      );
});

final v2RouteSegmentClaimCompileDriverProvider =
    Provider.autoDispose.family<void, String>((ref, tripId) {
  final projector = ref.watch(v2RouteSegmentClaimProjectorProvider);
  final refreshStream =
      ref.watch(v2RouteSegmentClaimRefreshSignalProvider(tripId));
  var disposed = false;

  Future<void> runProjector() async {
    if (disposed) {
      return;
    }
    try {
      await projector.projectTripClaims(tripId);
    } catch (_) {
      // Keep claim projection best-effort to avoid interrupting map/timeline.
    }
  }

  final sub = refreshStream.listen(
    (signal) {
      if (signal == 0) {
        return;
      }
      unawaited(runProjector());
    },
    onError: (_, __) {},
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

final v2ClaimedRouteSegmentKeysProvider =
    StreamProvider.autoDispose.family<Set<String>, String>((ref, tripId) {
  ref.watch(v2RouteSegmentClaimCompileDriverProvider(tripId));
  final repository = ref.watch(v2RouteSegmentClaimRepositoryProvider);
  return repository.watchClaimedSegmentKeys(tripId);
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
        (a, b) => b.displayOrder.compareTo(a.displayOrder),
      );
    final bySession = <String, List<V2TimelineProjectionEntry>>{};
    for (final entry in dayEntries) {
      bySession
          .putIfAbsent(entry.sessionId, () => <V2TimelineProjectionEntry>[])
          .add(entry);
    }
    final sortedSessionIds = bySession.keys.toList()
      ..sort((a, b) {
        final bTop = bySession[b]!.first.capturedAt;
        final aTop = bySession[a]!.first.capturedAt;
        final byOrder = bySession[b]!
            .first
            .displayOrder
            .compareTo(bySession[a]!.first.displayOrder);
        if (byOrder != 0) {
          return byOrder;
        }
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
