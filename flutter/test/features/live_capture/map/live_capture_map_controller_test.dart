import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/features/live_capture/map/live_capture_map_controller.dart';

void main() {
  group('LiveCaptureMapController', () {
    test('methods on uninitialized controller do not throw', () async {
      final ctrl = LiveCaptureMapController();

      // All public methods must be safe to call before initialize().
      await expectLater(
        ctrl.updatePosition(const AppLatLng(latitude: 27.7, longitude: 85.3)),
        completes,
      );
      await expectLater(
        ctrl.updateLivePath(const [
          AppLatLng(latitude: 27.7, longitude: 85.3),
          AppLatLng(latitude: 27.71, longitude: 85.31),
        ]),
        completes,
      );
      await expectLater(ctrl.recenterToPosition(), completes);

      ctrl.dispose();
    });

    test('setFollowMode toggles followMode property', () {
      final ctrl = LiveCaptureMapController();

      expect(ctrl.followMode, isTrue, reason: 'default is follow=true');

      ctrl.setFollowMode(false);
      expect(ctrl.followMode, isFalse);

      ctrl.setFollowMode(true);
      expect(ctrl.followMode, isTrue);

      ctrl.dispose();
    });

    test('updateLivePath with empty list does not throw', () async {
      final ctrl = LiveCaptureMapController();

      await expectLater(
        ctrl.updateLivePath(const <AppLatLng>[]),
        completes,
      );

      ctrl.dispose();
    });
  });
}
