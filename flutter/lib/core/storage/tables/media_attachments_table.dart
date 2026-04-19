import 'package:drift/drift.dart';

@TableIndex(
  name: 'media_attachments_target_role_idx',
  columns: {#targetKind, #targetLocalId, #role},
)
@TableIndex(
  name: 'media_attachments_media_idx',
  columns: {#mediaId},
)
@DataClassName('MediaAttachmentRow')
class MediaAttachments extends Table {
  @override
  String get tableName => 'media_attachments';

  TextColumn get id => text()();
  TextColumn get mediaId => text()();
  TextColumn get targetKind => text()();
  TextColumn get targetLocalId => text()();
  TextColumn get targetServerId => text().nullable()();
  TextColumn get role => text()();
  TextColumn get source => text().withDefault(const Constant('user'))();
  DateTimeColumn get attachedAt => dateTime()();
  DateTimeColumn get detachedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
