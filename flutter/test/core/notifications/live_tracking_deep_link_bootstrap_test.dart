import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/navigation/routes.dart';
import 'package:dora/core/notifications/live_tracking_deep_link_bootstrap.dart';

void main() {
  group('LiveTrackingDeepLinkBootstrap', () {
    test('routes advisory payload to live screen with focused side panel',
        () async {
      final opened = StreamController<Map<String, dynamic>>();
      addTearDown(opened.close);
      final routes = <String>[];

      final bootstrap = LiveTrackingDeepLinkBootstrap(
        openedPayloads: opened.stream,
        loadInitialPayload: () async => null,
        resolveLocalTripId: (tripIdentity) async =>
            tripIdentity == 'remote-trip-advisory'
                ? 'local-trip-advisory'
                : null,
        resolveSessionState: (localTripId) async => null,
        navigateToRoute: routes.add,
        advisoryEnabledResolver: () => true,
      );
      bootstrap.start();
      addTearDown(bootstrap.dispose);

      opened.add(<String, dynamic>{
        'type': 'advisory',
        'trip_id': 'remote-trip-advisory',
        'advisory_id': 'adv-123',
        'message_id': 'advisory-message-1',
      });
      await Future<void>.delayed(Duration.zero);

      expect(
        routes,
        <String>[
          '/trips/local-trip-advisory/live?advisoryFocus=adv-123&openSidePanel=1',
        ],
      );
    });

    test('routes advisory payload without advisory_id to live side panel',
        () async {
      final opened = StreamController<Map<String, dynamic>>();
      addTearDown(opened.close);
      final routes = <String>[];

      final bootstrap = LiveTrackingDeepLinkBootstrap(
        openedPayloads: opened.stream,
        loadInitialPayload: () async => null,
        resolveLocalTripId: (tripIdentity) async => 'local-trip-advisory',
        resolveSessionState: (localTripId) async => null,
        navigateToRoute: routes.add,
        advisoryEnabledResolver: () => true,
      );
      bootstrap.start();
      addTearDown(bootstrap.dispose);

      opened.add(<String, dynamic>{
        'type': 'advisory_paused',
        'trip_id': 'remote-trip-advisory',
        'message_id': 'advisory-message-2',
      });
      await Future<void>.delayed(Duration.zero);

      expect(
        routes,
        <String>[
          '/trips/local-trip-advisory/live?openSidePanel=1',
        ],
      );
    });

    test('routes to live for active session payload', () async {
      final opened = StreamController<Map<String, dynamic>>();
      addTearDown(opened.close);
      final routes = <String>[];

      final bootstrap = LiveTrackingDeepLinkBootstrap(
        openedPayloads: opened.stream,
        loadInitialPayload: () async => <String, dynamic>{
          'trip_id': 'remote-trip-1',
          'message_id': 'initial-1',
        },
        resolveLocalTripId: (tripIdentity) async =>
            tripIdentity == 'remote-trip-1' ? 'local-trip-1' : null,
        resolveSessionState: (localTripId) async => 'active',
        navigateToRoute: routes.add,
      );
      bootstrap.start();
      addTearDown(bootstrap.dispose);

      await Future<void>.delayed(Duration.zero);

      expect(routes, <String>[Routes.liveCapturePath('local-trip-1')]);
    });

    test('routes to editor for ended or missing session', () async {
      final opened = StreamController<Map<String, dynamic>>();
      addTearDown(opened.close);
      final routes = <String>[];

      final bootstrap = LiveTrackingDeepLinkBootstrap(
        openedPayloads: opened.stream,
        loadInitialPayload: () async => null,
        resolveLocalTripId: (tripIdentity) async => 'local-trip-2',
        resolveSessionState: (localTripId) async => null,
        navigateToRoute: routes.add,
      );
      bootstrap.start();
      addTearDown(bootstrap.dispose);

      opened.add(<String, dynamic>{
        'trip_id': 'remote-trip-2',
        'message_id': 'opened-1',
      });
      await Future<void>.delayed(Duration.zero);

      expect(routes, <String>[Routes.editorPath('local-trip-2')]);
    });

    test('dedupes repeated payloads using message id', () async {
      final opened = StreamController<Map<String, dynamic>>();
      addTearDown(opened.close);
      final routes = <String>[];

      final bootstrap = LiveTrackingDeepLinkBootstrap(
        openedPayloads: opened.stream,
        loadInitialPayload: () async => null,
        resolveLocalTripId: (tripIdentity) async => 'local-trip-3',
        resolveSessionState: (localTripId) async => 'active',
        navigateToRoute: routes.add,
      );
      bootstrap.start();
      addTearDown(bootstrap.dispose);

      const payload = <String, dynamic>{
        'trip_id': 'remote-trip-3',
        'message_id': 'same-message',
      };
      opened.add(payload);
      opened.add(payload);
      await Future<void>.delayed(Duration.zero);

      expect(routes, <String>[Routes.liveCapturePath('local-trip-3')]);
    });

    test('ignores payload when trip identity cannot be resolved', () async {
      final opened = StreamController<Map<String, dynamic>>();
      addTearDown(opened.close);
      final routes = <String>[];

      final bootstrap = LiveTrackingDeepLinkBootstrap(
        openedPayloads: opened.stream,
        loadInitialPayload: () async => null,
        resolveLocalTripId: (tripIdentity) async => null,
        resolveSessionState: (localTripId) async => 'active',
        navigateToRoute: routes.add,
      );
      bootstrap.start();
      addTearDown(bootstrap.dispose);

      opened.add(<String, dynamic>{'trip_id': 'remote-trip-404'});
      await Future<void>.delayed(Duration.zero);

      expect(routes, isEmpty);
    });
  });

  group('extractTripIdentity', () {
    test('prioritizes local trip id fields', () {
      expect(
        extractTripIdentity(<String, dynamic>{
          'local_trip_id': 'local-1',
          'trip_id': 'remote-1',
        }),
        'local-1',
      );
      expect(
        extractTripIdentity(<String, dynamic>{
          'trip_local_id': 'local-2',
          'trip_id': 'remote-2',
        }),
        'local-2',
      );
    });

    test('falls back to trip_id and server_trip_id', () {
      expect(
        extractTripIdentity(<String, dynamic>{'trip_id': 'remote-3'}),
        'remote-3',
      );
      expect(
        extractTripIdentity(<String, dynamic>{'server_trip_id': 'remote-4'}),
        'remote-4',
      );
    });
  });
}
