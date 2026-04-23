import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/daos/stories_dao.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/stories/data/models/story_models.dart';
import 'package:dora/features/stories/data/story_hide_store.dart';
import 'package:dora/features/stories/data/stories_api.dart';

final storiesApiProvider = Provider<StoriesApi>((ref) {
  final openApi = ref.watch(openApiStoriesApiProvider);
  final authService = ref.watch(authServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return StoriesApi(openApi, authService, apiClient);
});

final storyHideStoreProvider = Provider<StoryHideStore>((ref) {
  return StoryHideStore();
});

@immutable
class StoryFeedState {
  const StoryFeedState({
    required this.items,
    required this.radius,
    required this.hiddenIds,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<StoryFeedItem> items;
  final StoryRadiusFilter radius;
  final Set<String> hiddenIds;
  final String? nextCursor;
  final bool isLoadingMore;

  StoryFeedState copyWith({
    List<StoryFeedItem>? items,
    StoryRadiusFilter? radius,
    Set<String>? hiddenIds,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return StoryFeedState(
      items: items ?? this.items,
      radius: radius ?? this.radius,
      hiddenIds: hiddenIds ?? this.hiddenIds,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final storyFeedControllerProvider =
    AsyncNotifierProvider<StoryFeedController, StoryFeedState>(
  StoryFeedController.new,
);

class StoryFeedController extends AsyncNotifier<StoryFeedState> {
  static const int _pageSize = 20;
  static const StoryRadiusFilter _defaultRadius = StoryRadiusFilter.all;

  StoriesApi get _api => ref.read(storiesApiProvider);
  StoryHideStore get _hideStore => ref.read(storyHideStoreProvider);

  @override
  Future<StoryFeedState> build() async {
    final hiddenIds = await _hideStore.loadHiddenStoryIds();
    final page = await _fetchPage(
      radius: _defaultRadius,
      hiddenIds: hiddenIds,
      cursor: null,
    );
    return StoryFeedState(
      items: page.items,
      radius: _defaultRadius,
      hiddenIds: hiddenIds,
      nextCursor: page.nextCursor,
      isLoadingMore: false,
    );
  }

  Future<void> setRadius(StoryRadiusFilter radius) async {
    final current = state.valueOrNull;
    if (current != null && current.radius == radius) {
      return;
    }
    final hiddenIds =
        current?.hiddenIds ?? await _hideStore.loadHiddenStoryIds();
    if (current == null) {
      state = const AsyncLoading();
    }
    try {
      final page = await _fetchPage(
        radius: radius,
        hiddenIds: hiddenIds,
        cursor: null,
      );
      state = AsyncData(
        StoryFeedState(
          items: page.items,
          radius: radius,
          hiddenIds: hiddenIds,
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error, stack) {
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(error, stack);
      }
    }
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final radius = current?.radius ?? _defaultRadius;
    final hiddenIds =
        current?.hiddenIds ?? await _hideStore.loadHiddenStoryIds();
    if (current == null) {
      state = const AsyncLoading();
    }
    try {
      final page = await _fetchPage(
        radius: radius,
        hiddenIds: hiddenIds,
        cursor: null,
      );
      state = AsyncData(
        StoryFeedState(
          items: page.items,
          radius: radius,
          hiddenIds: hiddenIds,
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error, stack) {
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(error, stack);
      }
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        current.isLoadingMore ||
        current.nextCursor == null ||
        current.nextCursor!.isEmpty) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await _fetchPage(
        radius: current.radius,
        hiddenIds: current.hiddenIds,
        cursor: current.nextCursor,
      );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> hideStory(String storyId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _hideStore.hideStory(storyId);
    final nextHidden = {...current.hiddenIds, storyId};
    state = AsyncData(
      current.copyWith(
        hiddenIds: nextHidden,
        items: current.items.where((item) => item.id != storyId).toList(),
      ),
    );
  }

  Future<void> muteAuthor(String authorId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _api.muteAuthor(authorId);
    state = AsyncData(
      current.copyWith(
        items: current.items
            .where((item) => item.authorUserId != authorId)
            .toList(),
      ),
    );
  }

  Future<void> reportStory({
    required String storyId,
    required String reason,
    String? details,
  }) {
    return _api.reportStory(
      storyId: storyId,
      reason: reason,
      details: details,
    );
  }

  Future<void> markViewed(String storyId) async {
    try {
      await _api.recordView(storyId);
    } catch (_) {
      // non-fatal UX path
    }
  }

  Future<StoryFeedPage> _fetchPage({
    required StoryRadiusFilter radius,
    required Set<String> hiddenIds,
    required String? cursor,
  }) async {
    double? lat;
    double? lng;
    if (radius != StoryRadiusFilter.all) {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentPosition(timeLimit: const Duration(seconds: 8));
      lat = position?.latitude;
      lng = position?.longitude;
    }
    final page = await _api.fetchFeed(
      radius: radius,
      lat: lat,
      lng: lng,
      cursor: cursor,
      limit: _pageSize,
    );
    final filtered = page.items
        .where((item) => !hiddenIds.contains(item.id))
        .toList(growable: false);
    return StoryFeedPage(
      items: filtered,
      nextCursor: page.nextCursor,
    );
  }
}

final storyPublishControllerProvider =
    NotifierProvider<StoryPublishController, AsyncValue<void>>(
  StoryPublishController.new,
);

class StoryPublishController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  StoriesApi get _api => ref.read(storiesApiProvider);
  StoriesDao get _storiesDao => ref.read(storiesDaoProvider);
  MediaDao get _mediaDao => ref.read(mediaDaoProvider);

  Future<void> publishLocalStory(
    String storyId, {
    bool bestEffort = false,
  }) async {
    if (!bestEffort) {
      state = const AsyncLoading();
    }
    try {
      await _publishLocalStoryInternal(storyId);
      if (!bestEffort) {
        state = const AsyncData(null);
      }
    } catch (error, stack) {
      if (!bestEffort) {
        state = AsyncError(error, stack);
      }
      if (!bestEffort) {
        rethrow;
      }
    }
  }

  Future<void> _publishLocalStoryInternal(String storyId) async {
    final story = await _storiesDao.getById(storyId);
    if (story == null) {
      return;
    }
    final media = await _mediaDao.getMediaById(story.mediaId);
    if (media == null || media.localUri == null || media.localUri!.isEmpty) {
      await _storiesDao.markFailed(
        storyId,
        errorCode: 'missing_media',
        errorMessage: 'Local media file is missing.',
      );
      return;
    }

    await _storiesDao.markPublishing(storyId);
    try {
      final mediaType = media.mediaType.toLowerCase() == 'video'
          ? StoryMediaType.video
          : StoryMediaType.photo;
      final result = await _api.publishStory(
        clientStoryId: story.id,
        filePath: media.localUri!,
        mediaType: mediaType,
        centerLat: story.centerLat,
        centerLng: story.centerLng,
        durationMs: media.durationMs,
      );
      await _storiesDao.markPublished(
        id: story.id,
        publishedAt: result.publishedAt ?? DateTime.now().toUtc(),
        expiresAt: result.expiresAt ??
            DateTime.now().toUtc().add(const Duration(hours: 24)),
        serverId: result.serverId,
      );
    } on StoriesApiException catch (error) {
      await _storiesDao.markFailed(
        story.id,
        errorCode: '${error.statusCode ?? 'unknown'}',
        errorMessage: error.message,
      );
      rethrow;
    } catch (error) {
      await _storiesDao.markFailed(
        story.id,
        errorCode: 'publish_error',
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteStory(VaultStoryItem item) async {
    final status = item.story.visibility.toLowerCase();
    final hasRemote =
        item.story.serverId != null && item.story.serverId!.isNotEmpty;
    if (hasRemote &&
        (status == 'published' ||
            status == 'expired' ||
            status == 'moderation_hidden' ||
            status == 'deleted')) {
      await _api.deleteStory(item.story.serverId!);
      await _storiesDao.markDeleted(item.story.id);
      return;
    }
    await _storiesDao.deleteStory(item.story.id);
  }
}

@immutable
class VaultStoryItem {
  const VaultStoryItem({
    required this.story,
    this.media,
  });

  final StoryRow story;
  final MediaItem? media;
}

final vaultStoryItemsProvider =
    StreamProvider.autoDispose<List<VaultStoryItem>>((ref) async* {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    yield const <VaultStoryItem>[];
    return;
  }
  final storiesDao = ref.watch(storiesDaoProvider);
  final mediaDao = ref.watch(mediaDaoProvider);

  await for (final stories in storiesDao.watchAllForAuthor(
    userId,
    visibilities: const [
      'draft',
      'publishing',
      'failed',
      'published',
      'expired'
    ],
  )) {
    final mediaIds = stories.map((row) => row.mediaId).toSet();
    final mediaRows = await mediaDao.listByIds(mediaIds);
    final mediaById = {for (final row in mediaRows) row.id: row};
    final items = stories
        .map((row) => VaultStoryItem(
              story: row,
              media: mediaById[row.mediaId],
            ))
        .toList(growable: false);
    yield items;
  }
});

String storyStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'draft':
      return 'Draft';
    case 'publishing':
      return 'Publishing';
    case 'failed':
      return 'Failed';
    case 'published':
      return 'Published';
    case 'expired':
      return 'Expired';
    case 'moderation_hidden':
      return 'Hidden';
    case 'deleted':
      return 'Deleted';
    default:
      return status;
  }
}
