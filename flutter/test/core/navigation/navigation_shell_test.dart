import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/navigation/navigation_shell.dart';
import 'package:dora/core/navigation/routes.dart';

void main() {
  group('locationToTabIndex', () {
    test('maps shell paths to five-tab layout', () {
      expect(locationToTabIndex(Routes.feed), 0);
      expect(locationToTabIndex(Routes.create), 1);
      expect(locationToTabIndex(Routes.liveHub), 2);
      expect(locationToTabIndex(Routes.trips), 3);
      expect(locationToTabIndex(Routes.profile), 4);
    });

    test('falls back to feed for unknown paths', () {
      expect(locationToTabIndex('/unknown'), 0);
    });
  });

  group('tabIndexToRoute', () {
    test('returns routes in Feed/Create/Live/Trips/Profile order', () {
      expect(tabIndexToRoute(0), Routes.feed);
      expect(tabIndexToRoute(1), Routes.create);
      expect(tabIndexToRoute(2), Routes.liveHub);
      expect(tabIndexToRoute(3), Routes.trips);
      expect(tabIndexToRoute(4), Routes.profile);
    });

    test('falls back to feed for invalid indexes', () {
      expect(tabIndexToRoute(-1), Routes.feed);
      expect(tabIndexToRoute(99), Routes.feed);
    });
  });
}
