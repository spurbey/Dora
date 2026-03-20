class EntitySyncReceipt {
  const EntitySyncReceipt({
    required this.entityType,
    required this.localEntityId,
    required this.remoteEntityId,
    required this.serverUpdatedAt,
  });

  final String entityType;
  final String localEntityId;
  final String remoteEntityId;
  final DateTime serverUpdatedAt;
}
