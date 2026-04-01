import 'package:drift/drift.dart' show Variable;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/navigation/app_router.dart';
import 'package:dora/core/notifications/live_tracking_deep_link_bootstrap.dart';
import 'package:dora/core/storage/database_provider.dart';

final liveTrackingDeepLinkBootstrapProvider = Provider<void>((ref) {
  FirebaseMessaging messaging;
  try {
    messaging = FirebaseMessaging.instance;
  } catch (_) {
    return;
  }

  final db = ref.watch(appDatabaseProvider);
  final router = ref.watch(appRouterProvider);
  final trackingSessionDao = ref.watch(trackingSessionDaoProvider);

  final bootstrap = LiveTrackingDeepLinkBootstrap(
    openedPayloads: FirebaseMessaging.onMessageOpenedApp
        .map(_remoteMessagePayload)
        .where((payload) => payload.isNotEmpty),
    loadInitialPayload: () async {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage == null) {
        return null;
      }
      final payload = _remoteMessagePayload(initialMessage);
      if (payload.isEmpty) {
        return null;
      }
      return payload;
    },
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
      final activeSession =
          await trackingSessionDao.getActiveOrPausedSessionForTrip(localTripId);
      return activeSession?.state;
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

Map<String, dynamic> _remoteMessagePayload(RemoteMessage message) {
  final payload = Map<String, dynamic>.from(message.data);
  final messageId = message.messageId;
  if (messageId != null && messageId.isNotEmpty) {
    payload.putIfAbsent('message_id', () => messageId);
  }
  return payload;
}
