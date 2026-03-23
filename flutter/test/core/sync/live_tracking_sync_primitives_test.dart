import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/sync/live_tracking_sync_primitives.dart';

void main() {
  group('SyncEntityTypes', () {
    test('maps interactive and tracking batch lanes deterministically', () {
      expect(
        SyncEntityTypes.laneForEntityType(SyncEntityTypes.trip),
        SyncLane.interactive,
      );
      expect(
        SyncEntityTypes.laneForEntityType(SyncEntityTypes.place),
        SyncLane.interactive,
      );
      expect(
        SyncEntityTypes.laneForEntityType(SyncEntityTypes.route),
        SyncLane.interactive,
      );
      expect(
        SyncEntityTypes.laneForEntityType(SyncEntityTypes.trackingSession),
        SyncLane.interactive,
      );
      expect(
        SyncEntityTypes.laneForEntityType(SyncEntityTypes.checkinDecision),
        SyncLane.interactive,
      );
      expect(
        SyncEntityTypes.laneForEntityType(SyncEntityTypes.moment),
        SyncLane.interactive,
      );
      expect(
        SyncEntityTypes.laneForEntityType(SyncEntityTypes.trackingPointBatch),
        SyncLane.trackingBatch,
      );
    });

    test('keeps worker-supported entity list explicit', () {
      expect(
        SyncEntityTypes.supportedByEntitySyncWorker,
        containsAll(<String>[
          SyncEntityTypes.trip,
          SyncEntityTypes.place,
          SyncEntityTypes.route,
        ]),
      );
      expect(
        SyncEntityTypes.supportedByEntitySyncWorker,
        isNot(contains(SyncEntityTypes.trackingPointBatch)),
      );
      expect(
        SyncEntityTypes.supportedByTrackingSyncWorker,
        containsAll(<String>[
          SyncEntityTypes.trackingSession,
          SyncEntityTypes.trackingPointBatch,
          SyncEntityTypes.checkinDecision,
          SyncEntityTypes.moment,
        ]),
      );
      expect(
        SyncEntityTypes.supportedByTrackingSyncWorker,
        isNot(contains(SyncEntityTypes.trip)),
      );
    });
  });

  group('AutoEntitySyncPolicy', () {
    test('manual lock blocks auto mutation for locked field only', () {
      final policy = AutoEntitySyncPolicy(
        provenance: SyncEntityProvenance.auto,
      ).withManualLock('name');

      expect(policy.canApplyAutoMutation(fieldName: 'name'), isFalse);
      expect(policy.canApplyAutoMutation(fieldName: 'notes'), isTrue);
    });

    test('tombstone suppresses auto regeneration during cooldown window', () {
      final tombstonedAt = DateTime(2026, 3, 21, 10, 0, 0);
      final policy = AutoEntitySyncPolicy(
        provenance: SyncEntityProvenance.auto,
        tombstoneCooldown: const Duration(hours: 24),
      ).markTombstoned(at: tombstonedAt);

      expect(
        policy.suppressesAutoRegeneration(
          now: tombstonedAt.add(const Duration(hours: 1)),
        ),
        isTrue,
      );
      expect(
        policy.suppressesAutoRegeneration(
          now: tombstonedAt.add(const Duration(hours: 25)),
        ),
        isFalse,
      );
    });

    test('manual lock remains effective even after tombstone is cleared', () {
      final lockedAndTombstoned = AutoEntitySyncPolicy(
        provenance: SyncEntityProvenance.editedAuto,
      ).withManualLock('address').markTombstoned(
            at: DateTime(2026, 3, 21, 9, 0, 0),
          );

      final policy = lockedAndTombstoned.clearTombstone();
      expect(
        policy.suppressesAutoRegeneration(
          now: DateTime(2026, 3, 22, 10, 0, 0),
        ),
        isFalse,
      );
      expect(policy.canApplyAutoMutation(fieldName: 'address'), isFalse);
      expect(policy.canApplyAutoMutation(fieldName: 'notes'), isTrue);
    });
  });
}
