import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/navigation/navigation_shell.dart';
import 'package:dora/core/navigation/routes.dart';

void main() {
  group('locationToTabIndex', () {
    test('maps shell paths to the 4-tab + center-FAB layout', () {
      // The Camera FAB is NOT a tab — it sits center-docked above the bar.
      // The tab strip is Feed · Live · [FAB] · Trips · Profile, so tab
      // indices are contiguous 0..3 for Feed/Live/Trips/Profile.
      expect(locationToTabIndex(Routes.feed), 0);
      expect(locationToTabIndex(Routes.liveHub), 1);
      expect(locationToTabIndex(Routes.trips), 2);
      expect(locationToTabIndex(Routes.profile), 3);
    });

    test('falls back to feed for unknown paths', () {
      expect(locationToTabIndex('/unknown'), 0);
    });
  });

  group('tabIndexToRoute', () {
    test('returns routes in Feed/Live/Trips/Profile order', () {
      expect(tabIndexToRoute(0), Routes.feed);
      expect(tabIndexToRoute(1), Routes.liveHub);
      expect(tabIndexToRoute(2), Routes.trips);
      expect(tabIndexToRoute(3), Routes.profile);
    });

    test('falls back to feed for invalid indexes', () {
      expect(tabIndexToRoute(-1), Routes.feed);
      expect(tabIndexToRoute(99), Routes.feed);
    });
  });
}
