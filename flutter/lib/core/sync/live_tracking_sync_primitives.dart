enum SyncLane {
  interactive,
  trackingBatch,
}

class SyncEntityTypes {
  const SyncEntityTypes._();

  static const String trip = 'trip';
  static const String place = 'place';
  static const String route = 'route';

  static const String trackingSession = 'tracking_session';
  static const String trackingPointBatch = 'tracking_point_batch';
  static const String checkinDecision = 'checkin_decision';
  static const String moment = 'moment';

  static const Set<String> supportedByEntitySyncWorker = {
    trip,
    place,
    route,
  };

  static const Set<String> supportedByTrackingSyncWorker = {
    trackingSession,
    trackingPointBatch,
    checkinDecision,
    moment,
  };

  // Tracking point uploads are high-volume and should never block user-edit
  // entities from being claimed by the sync worker.
  static const Set<String> _trackingBatchTypes = {
    trackingPointBatch,
  };

  static SyncLane laneForEntityType(String entityType) {
    if (_trackingBatchTypes.contains(entityType)) {
      return SyncLane.trackingBatch;
    }
    return SyncLane.interactive;
  }

  static int lanePriorityForEntityType(String entityType) {
    return laneForEntityType(entityType) == SyncLane.interactive ? 0 : 1;
  }
}

enum SyncEntityProvenance {
  manual,
  auto,
  editedAuto,
}

class AutoEntitySyncPolicy {
  AutoEntitySyncPolicy({
    required this.provenance,
    Set<String> manualLockedFields = const <String>{},
    this.tombstonedAt,
    this.tombstoneCooldown = const Duration(hours: 24),
  }) : manualLockedFields = Set.unmodifiable(manualLockedFields);

  final SyncEntityProvenance provenance;

  // Manual locks protect fields from silent auto-overwrite.
  final Set<String> manualLockedFields;

  // Tombstones prevent immediate regeneration of user-deleted auto entities.
  final DateTime? tombstonedAt;
  final Duration tombstoneCooldown;

  bool isFieldLocked(String fieldName) {
    return manualLockedFields.contains(fieldName);
  }

  bool suppressesAutoRegeneration({DateTime? now}) {
    final tombstone = tombstonedAt;
    if (tombstone == null) {
      return false;
    }
    final currentTime = now ?? DateTime.now();
    return currentTime.isBefore(tombstone.add(tombstoneCooldown));
  }

  bool canApplyAutoMutation({
    required String fieldName,
    DateTime? now,
  }) {
    if (suppressesAutoRegeneration(now: now)) {
      return false;
    }
    return !isFieldLocked(fieldName);
  }

  AutoEntitySyncPolicy withManualLock(String fieldName) {
    final nextLocks = <String>{
      ...manualLockedFields,
      fieldName,
    };
    return AutoEntitySyncPolicy(
      provenance: provenance,
      manualLockedFields: nextLocks,
      tombstonedAt: tombstonedAt,
      tombstoneCooldown: tombstoneCooldown,
    );
  }

  AutoEntitySyncPolicy withoutManualLock(String fieldName) {
    final nextLocks = <String>{
      ...manualLockedFields,
    }..remove(fieldName);
    return AutoEntitySyncPolicy(
      provenance: provenance,
      manualLockedFields: nextLocks,
      tombstonedAt: tombstonedAt,
      tombstoneCooldown: tombstoneCooldown,
    );
  }

  AutoEntitySyncPolicy markTombstoned({DateTime? at}) {
    return AutoEntitySyncPolicy(
      provenance: provenance,
      manualLockedFields: manualLockedFields,
      tombstonedAt: at ?? DateTime.now(),
      tombstoneCooldown: tombstoneCooldown,
    );
  }

  AutoEntitySyncPolicy clearTombstone() {
    return AutoEntitySyncPolicy(
      provenance: provenance,
      manualLockedFields: manualLockedFields,
      tombstonedAt: null,
      tombstoneCooldown: tombstoneCooldown,
    );
  }
}
