import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/media_table.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [Media])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(AppDatabase db) : super(db);

  Future<List<MediaItem>> getMediaForTrip(String tripId) =>
      (select(media)..where((m) => m.tripId.equals(tripId))).get();

  Future<int> insertMedia(MediaCompanion item) => into(media).insert(item);

  Future<bool> updateMedia(MediaCompanion item) =>
      update(media).replace(item);

  Future<int> deleteMedia(String id) =>
      (delete(media)..where((m) => m.id.equals(id))).go();
}
