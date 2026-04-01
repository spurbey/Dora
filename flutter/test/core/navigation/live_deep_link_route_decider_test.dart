import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/navigation/live_deep_link_route_decider.dart';
import 'package:dora/core/navigation/routes.dart';

void main() {
  group('deepLinkTargetForSessionState', () {
    test('routes active and paused sessions to live', () {
      expect(
        deepLinkTargetForSessionState('active'),
        DeepLinkTarget.live,
      );
      expect(
        deepLinkTargetForSessionState('paused'),
        DeepLinkTarget.live,
      );
    });

    test('routes ended or missing sessions to editor', () {
      expect(
        deepLinkTargetForSessionState('ended'),
        DeepLinkTarget.editor,
      );
      expect(
        deepLinkTargetForSessionState(null),
        DeepLinkTarget.editor,
      );
    });
  });

  group('deepLinkRouteForTrip', () {
    test('builds live capture route for active session', () {
      expect(
        deepLinkRouteForTrip(tripId: 'trip-1', sessionState: 'active'),
        Routes.liveCapturePath('trip-1'),
      );
    });

    test('builds editor route when no active session', () {
      expect(
        deepLinkRouteForTrip(tripId: 'trip-1', sessionState: 'ended'),
        Routes.editorPath('trip-1'),
      );
      expect(
        deepLinkRouteForTrip(tripId: 'trip-1', sessionState: null),
        Routes.editorPath('trip-1'),
      );
    });
  });
}
