import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/trips/presentation/sync_status_ui.dart';

void main() {
  group('resolveTripSyncBadgeUi', () {
    test('maps pending to local saved', () {
      final badge = resolveTripSyncBadgeUi('pending');

      expect(badge.kind, TripSyncUiKind.localSaved);
      expect(badge.label, 'Saved locally');
    });

    test('maps blocked to blocked label', () {
      final badge = resolveTripSyncBadgeUi('blocked');

      expect(badge.kind, TripSyncUiKind.blocked);
      expect(badge.label, 'Sync blocked');
    });

    test('maps in_progress to syncing label', () {
      final badge = resolveTripSyncBadgeUi('in_progress');

      expect(badge.kind, TripSyncUiKind.syncing);
      expect(badge.label, 'Syncing...');
    });
  });

  group('resolveTripsSyncBannerUi', () {
    test('prefers refresh-failed banner', () {
      final banner = resolveTripsSyncBannerUi(
        rawStatuses: const ['failed', 'pending'],
        refreshFailed: true,
      );

      expect(banner, isNotNull);
      expect(banner!.showRetryAction, isTrue);
      expect(
        banner.message,
        'Could not refresh trips. Showing cached data.',
      );
    });

    test('prioritizes blocked over failed and pending', () {
      final banner = resolveTripsSyncBannerUi(
        rawStatuses: const ['pending', 'failed', 'blocked'],
        refreshFailed: false,
      );

      expect(banner, isNotNull);
      expect(banner!.showRetryAction, isFalse);
      expect(
        banner.message,
        'Some trips are sync blocked. Open the trip to resolve issues.',
      );
    });

    test('returns null when all trips are synced', () {
      final banner = resolveTripsSyncBannerUi(
        rawStatuses: const ['synced', 'synced'],
        refreshFailed: false,
      );

      expect(banner, isNull);
    });
  });
}
