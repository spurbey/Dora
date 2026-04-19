import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/stories_table.dart';

part 'stories_dao.g.dart';

@DriftAccessor(tables: [Stories])
class StoriesDao extends DatabaseAccessor<AppDatabase> with _$StoriesDaoMixin {
  StoriesDao(AppDatabase db) : super(db);

  Future<int> insertStory(StoriesCompanion row) => into(stories).insert(row);

  Future<StoryRow?> getById(String id) =>
      (select(stories)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<List<StoryRow>> listForAuthor(
    String authorUserId, {
    int? limit,
  }) {
    final query = select(stories)
      ..where((r) => r.authorUserId.equals(authorUserId))
      ..orderBy([
        (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<int> markPublished({
    required String id,
    required DateTime publishedAt,
    required DateTime expiresAt,
    String? serverId,
  }) {
    final now = DateTime.now().toUtc();
    return (update(stories)..where((r) => r.id.equals(id))).write(
      StoriesCompanion(
        visibility: const Value('published'),
        publishedAt: Value(publishedAt.toUtc()),
        expiresAt: Value(expiresAt.toUtc()),
        serverId: serverId == null ? const Value.absent() : Value(serverId),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markDeleted(String id) {
    final now = DateTime.now().toUtc();
    return (update(stories)..where((r) => r.id.equals(id))).write(
      StoriesCompanion(
        visibility: const Value('deleted'),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markExpired(String id) {
    final now = DateTime.now().toUtc();
    return (update(stories)..where((r) => r.id.equals(id))).write(
      StoriesCompanion(
        visibility: const Value('expired'),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> deleteStory(String id) =>
      (delete(stories)..where((r) => r.id.equals(id))).go();
}
