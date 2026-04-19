import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/media_attachments_table.dart';

part 'media_attachments_dao.g.dart';

@DriftAccessor(tables: [MediaAttachments])
class MediaAttachmentsDao extends DatabaseAccessor<AppDatabase>
    with _$MediaAttachmentsDaoMixin {
  MediaAttachmentsDao(AppDatabase db) : super(db);

  Future<int> insertAttachment(MediaAttachmentsCompanion row) =>
      into(mediaAttachments).insert(
        row,
        mode: InsertMode.insertOrIgnore,
      );

  Future<MediaAttachmentRow?> getById(String id) =>
      (select(mediaAttachments)..where((r) => r.id.equals(id)))
          .getSingleOrNull();

  Future<List<MediaAttachmentRow>> listForMedia(
    String mediaId, {
    bool includeDetached = false,
  }) {
    final query = select(mediaAttachments)
      ..where((r) => r.mediaId.equals(mediaId));
    if (!includeDetached) {
      query.where((r) => r.detachedAt.isNull());
    }
    query.orderBy([
      (r) => OrderingTerm(expression: r.attachedAt, mode: OrderingMode.asc),
    ]);
    return query.get();
  }

  Stream<List<MediaAttachmentRow>> watchForMedia(String mediaId) {
    return (select(mediaAttachments)
          ..where(
            (r) => r.mediaId.equals(mediaId) & r.detachedAt.isNull(),
          )
          ..orderBy([
            (r) =>
                OrderingTerm(expression: r.attachedAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<List<MediaAttachmentRow>> listForTarget({
    required String targetKind,
    required String targetLocalId,
    String? role,
    bool includeDetached = false,
  }) {
    final query = select(mediaAttachments)
      ..where(
        (r) =>
            r.targetKind.equals(targetKind) &
            r.targetLocalId.equals(targetLocalId),
      );
    if (role != null) {
      query.where((r) => r.role.equals(role));
    }
    if (!includeDetached) {
      query.where((r) => r.detachedAt.isNull());
    }
    query.orderBy([
      (r) => OrderingTerm(expression: r.attachedAt, mode: OrderingMode.asc),
    ]);
    return query.get();
  }

  Stream<List<MediaAttachmentRow>> watchForTarget({
    required String targetKind,
    required String targetLocalId,
    String? role,
  }) {
    final query = select(mediaAttachments)
      ..where(
        (r) =>
            r.targetKind.equals(targetKind) &
            r.targetLocalId.equals(targetLocalId) &
            r.detachedAt.isNull(),
      );
    if (role != null) {
      query.where((r) => r.role.equals(role));
    }
    query.orderBy([
      (r) => OrderingTerm(expression: r.attachedAt, mode: OrderingMode.asc),
    ]);
    return query.watch();
  }

  Future<List<String>> listMediaIdsForTarget({
    required String targetKind,
    required String targetLocalId,
    String? role,
  }) async {
    final rows = await listForTarget(
      targetKind: targetKind,
      targetLocalId: targetLocalId,
      role: role,
    );
    return rows.map((r) => r.mediaId).toList(growable: false);
  }

  Future<int> setTargetServerId({
    required String targetKind,
    required String targetLocalId,
    required String targetServerId,
  }) {
    return (update(mediaAttachments)
          ..where(
            (r) =>
                r.targetKind.equals(targetKind) &
                r.targetLocalId.equals(targetLocalId) &
                r.detachedAt.isNull(),
          ))
        .write(
      MediaAttachmentsCompanion(
        targetServerId: Value(targetServerId),
      ),
    );
  }

  Future<int> detach({
    required String mediaId,
    required String targetKind,
    required String targetLocalId,
    String? role,
    DateTime? detachedAt,
  }) {
    final when = (detachedAt ?? DateTime.now()).toUtc();
    final query = update(mediaAttachments)
      ..where(
        (r) =>
            r.mediaId.equals(mediaId) &
            r.targetKind.equals(targetKind) &
            r.targetLocalId.equals(targetLocalId) &
            r.detachedAt.isNull(),
      );
    if (role != null) {
      query.where((r) => r.role.equals(role));
    }
    return query.write(
      MediaAttachmentsCompanion(
        detachedAt: Value(when),
      ),
    );
  }

  Future<int> detachById(String id, {DateTime? detachedAt}) {
    final when = (detachedAt ?? DateTime.now()).toUtc();
    return (update(mediaAttachments)
          ..where((r) => r.id.equals(id) & r.detachedAt.isNull()))
        .write(
      MediaAttachmentsCompanion(detachedAt: Value(when)),
    );
  }

  Future<int> countActiveForTarget({
    required String targetKind,
    required String targetLocalId,
    String? role,
  }) async {
    final countExp = mediaAttachments.id.count();
    final query = selectOnly(mediaAttachments)
      ..addColumns([countExp])
      ..where(
        mediaAttachments.targetKind.equals(targetKind) &
            mediaAttachments.targetLocalId.equals(targetLocalId) &
            mediaAttachments.detachedAt.isNull(),
      );
    if (role != null) {
      query.where(mediaAttachments.role.equals(role));
    }
    final row = await query.getSingleOrNull();
    return row?.read(countExp) ?? 0;
  }
}
