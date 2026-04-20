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

  Future<List<StoryRow>> listAllForAuthor(
    String authorUserId, {
    int? limit,
  }) {
    final query = select(stories)
      ..where((r) => r.authorUserId.equals(authorUserId))
      ..orderBy([
        (r) => OrderingTerm(
              expression: r.createdAt,
              mode: OrderingMode.desc,
            ),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Stream<List<StoryRow>> watchAllForAuthor(
    String authorUserId, {
    List<String>? visibilities,
  }) {
    final query = select(stories)
      ..where((r) {
        final base = r.authorUserId.equals(authorUserId);
        if (visibilities == null || visibilities.isEmpty) {
          return base;
        }
        return base & r.visibility.isIn(visibilities);
      })
      ..orderBy([
        (r) => OrderingTerm(
              expression: r.createdAt,
              mode: OrderingMode.desc,
            ),
      ]);
    return query.watch();
  }

  Future<List<StoryRow>> listForAuthor(
    String authorUserId, {
    int? limit,
    String? visibility,
  }) {
    final query = select(stories)
      ..where((r) => r.authorUserId.equals(authorUserId))
      ..orderBy([
        (r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc),
      ]);
    if (visibility != null) {
      query.where((r) => r.visibility.equals(visibility));
    }
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<StoryRow>> listDraftsForAuthor(
    String authorUserId, {
    int? limit,
  }) {
    return listForAuthor(
      authorUserId,
      limit: limit,
      visibility: 'draft',
    );
  }

  Future<List<StoryRow>> listDraftsByMediaId(String mediaId) {
    return (select(stories)
          ..where(
            (r) => r.mediaId.equals(mediaId) & r.visibility.equals('draft'),
          )
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  Stream<List<StoryRow>> watchDraftsForAuthor(String authorUserId) {
    return (select(stories)
          ..where(
            (r) =>
                r.authorUserId.equals(authorUserId) &
                r.visibility.equals('draft'),
          )
          ..orderBy([
            (r) => OrderingTerm(
                  expression: r.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
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
        lastErrorCode: const Value(null),
        lastErrorMessage: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markPublishing(String id) {
    final now = DateTime.now().toUtc();
    return customUpdate(
      '''
      UPDATE stories
      SET
        visibility = 'publishing',
        publish_requested_at = ?,
        last_publish_attempt_at = ?,
        publish_attempt_count = publish_attempt_count + 1,
        last_error_code = NULL,
        last_error_message = NULL,
        updated_at = ?
      WHERE id = ?
      ''',
      variables: [
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<String>(id),
      ],
      updates: {stories},
    );
  }

  Future<int> markFailed(
    String id, {
    String? errorCode,
    String? errorMessage,
  }) {
    final now = DateTime.now().toUtc();
    return (update(stories)..where((r) => r.id.equals(id))).write(
      StoriesCompanion(
        visibility: const Value('failed'),
        lastErrorCode: Value(errorCode),
        lastErrorMessage: Value(errorMessage),
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

  Future<int> markModerationHidden(String id) {
    final now = DateTime.now().toUtc();
    return (update(stories)..where((r) => r.id.equals(id))).write(
      StoriesCompanion(
        visibility: const Value('moderation_hidden'),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> deleteDraftsByMediaId(String mediaId) {
    return (delete(stories)
          ..where(
            (r) => r.mediaId.equals(mediaId) & r.visibility.equals('draft'),
          ))
        .go();
  }

  Future<int> deleteStory(String id) =>
      (delete(stories)..where((r) => r.id.equals(id))).go();
}
