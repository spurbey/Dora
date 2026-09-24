import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/navigation/app_router.dart';
import 'package:dora/core/notifications/deep_link_messaging.dart';
import 'package:dora/core/notifications/live_tracking_deep_link_bootstrap.dart';
import 'package:dora/core/storage/database_provider.dart';

final liveTrackingDeepLinkBootstrapProvider = Provider<void>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final router = ref.watch(appRouterProvider);
  final sessionJournalDao = ref.watch(v2SessionJournalDaoProvider);

  final bootstrap = LiveTrackingDeepLinkBootstrap(
    openedPayloads: openedMessagePayloads(),
    loadInitialPayload: initialMessagePayload,
    resolveLocalTripId: (tripIdentity) async {
      final normalized = tripIdentity.trim();
      if (normalized.isEmpty) {
        return null;
      }

      final localTrip = await db.customSelect(
        '''
        SELECT id
        FROM trips
        WHERE id = ?
        LIMIT 1
        ''',
        variables: [Variable<String>(normalized)],
        readsFrom: {db.trips},
      ).getSingleOrNull();
      if (localTrip != null) {
        return localTrip.read<String>('id');
      }

      final remoteTrip = await db.customSelect(
        '''
        SELECT id
        FROM trips
        WHERE server_trip_id = ?
        LIMIT 1
        ''',
        variables: [Variable<String>(normalized)],
        readsFrom: {db.trips},
      ).getSingleOrNull();
      return remoteTrip?.read<String>('id');
    },
    resolveSessionState: (localTripId) async {
      // V2: use session_journal instead of V1 tracking_sessions.
      final activeSession =
          await sessionJournalDao.getActiveOrPausedSessionForTrip(localTripId);
      return activeSession?.controlState;
    },
    navigateToRoute: (route) {
      final current = router.routeInformationProvider.value.uri.path;
      if (current == route) {
        return;
      }
      router.go(route);
    },
  );

  bootstrap.start();
  ref.onDispose(bootstrap.dispose);
});
