import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/media/image_compressor.dart';
import 'package:dora/core/network/api_client.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/stories/data/models/story_models.dart';
import 'package:dora/features/stories/data/stories_api.dart';
import 'package:dora/features/stories/presentation/providers/stories_providers.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class _FakeStoriesApi extends StoriesApi {
  _FakeStoriesApi({
    this.failPublish = false,
  }) : super(
          openapi.StoriesApi(Dio(), openapi.standardSerializers),
          AuthService(
            SupabaseClient(
              'https://example.supabase.co',
              'public-anon-key',
            ),
          ),
          ApiClient(
            baseUrl: 'https://example.com',
            authService: AuthService(
              SupabaseClient(
                'https://example.supabase.co',
                'public-anon-key',
              ),
            ),
          ),
        );

  final bool failPublish;
  int publishCalls = 0;
  String? lastFilePath;

  @override
  Future<StoryPublishResult> publishStory({
    required String clientStoryId,
    required String filePath,
    required StoryMediaType mediaType,
    required double centerLat,
    required double centerLng,
    int? durationMs,
  }) async {
    publishCalls += 1;
    lastFilePath = filePath;
    if (failPublish) {
      throw StoriesApiException('publish failed', statusCode: 500);
    }
    return StoryPublishResult(
      id: clientStoryId,
      serverId: 'server-$clientStoryId',
      publishedAt: DateTime.utc(2026, 4, 27, 0, 0, 0),
      expiresAt: DateTime.utc(2026, 4, 28, 0, 0, 0),
    );
  }
}

class _RecordingCompressor extends ImageCompressor {
  _RecordingCompressor({
    required this.outputPath,
  });

  final String outputPath;
  int calls = 0;

  @override
  Future<CompressedImageResult> compress({
    required String inputPath,
    required String mediaId,
  }) async {
    calls += 1;
    final source = File(inputPath);
    if (!await source.exists()) {
      throw ImageCompressionException(
        'Source file missing for compression: $inputPath',
      );
    }
    final compressed = File(outputPath);
    await compressed.create(recursive: true);
    await compressed.writeAsBytes(await source.readAsBytes(), flush: true);
    return CompressedImageResult(file: compressed, isTemporary: true);
  }
}

Future<void> _insertDraftStory({
  required AppDatabase db,
  required String mediaId,
  required String mediaType,
  required String mediaPath,
  required String storyId,
}) async {
  final now = DateTime.utc(2026, 4, 27, 0, 0, 0);
  await db.mediaDao.insertMedia(
    MediaCompanion.insert(
      id: mediaId,
      ownerUserId: 'user-1',
      originScope: 'vault',
      capturedAt: now,
      localUpdatedAt: now,
      createdAt: now,
      updatedAt: now,
      mediaType: drift.Value(mediaType),
      localUri: drift.Value(mediaPath),
      syncStatus: const drift.Value('pending'),
      uploadState: const drift.Value('local_only'),
    ),
  );
  await db.storiesDao.insertStory(
    StoriesCompanion.insert(
      id: storyId,
      mediaId: mediaId,
      authorUserId: 'user-1',
      centerLat: 27.7172,
      centerLng: 85.3240,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

void main() {
  group('StoryPublishController compression behavior', () {
    test('photo story uses compressed file and cleans up temp file', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final tempDir = await Directory.systemTemp.createTemp('story-photo-');
      final photoPath = '${tempDir.path}/photo.jpg';
      final compressedPath = '${tempDir.path}/photo_compressed.jpg';
      await File(photoPath)
          .writeAsBytes(List<int>.filled(1024, 7), flush: true);
      await _insertDraftStory(
        db: db,
        mediaId: 'media-photo',
        mediaType: 'photo',
        mediaPath: photoPath,
        storyId: 'story-photo',
      );

      final fakeApi = _FakeStoriesApi();
      final fakeCompressor = _RecordingCompressor(outputPath: compressedPath);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          storiesApiProvider.overrideWithValue(fakeApi),
          storyImageCompressorProvider.overrideWithValue(fakeCompressor),
        ],
      );

      await container
          .read(storyPublishControllerProvider.notifier)
          .publishLocalStory('story-photo');

      expect(fakeApi.publishCalls, 1);
      expect(fakeCompressor.calls, 1);
      expect(fakeApi.lastFilePath, compressedPath);
      expect(File(compressedPath).existsSync(), isFalse);

      final story = await db.storiesDao.getById('story-photo');
      expect(story, isNotNull);
      expect(story!.visibility, 'published');
      expect(story.serverId, 'server-story-photo');

      container.dispose();
      await db.close();
      await tempDir.delete(recursive: true);
    });

    test('video story bypasses compressor in p0 path', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final tempDir = await Directory.systemTemp.createTemp('story-video-');
      final videoPath = '${tempDir.path}/clip.mp4';
      await File(videoPath)
          .writeAsBytes(List<int>.filled(2048, 9), flush: true);
      await _insertDraftStory(
        db: db,
        mediaId: 'media-video',
        mediaType: 'video',
        mediaPath: videoPath,
        storyId: 'story-video',
      );

      final fakeApi = _FakeStoriesApi();
      final fakeCompressor = _RecordingCompressor(
        outputPath: '${tempDir.path}/unused.jpg',
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          storiesApiProvider.overrideWithValue(fakeApi),
          storyImageCompressorProvider.overrideWithValue(fakeCompressor),
        ],
      );

      await container
          .read(storyPublishControllerProvider.notifier)
          .publishLocalStory('story-video');

      expect(fakeApi.publishCalls, 1);
      expect(fakeCompressor.calls, 0);
      expect(fakeApi.lastFilePath, videoPath);

      container.dispose();
      await db.close();
      await tempDir.delete(recursive: true);
    });

    test('temporary compressed photo is cleaned up on publish failure',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      final tempDir = await Directory.systemTemp.createTemp('story-fail-');
      final photoPath = '${tempDir.path}/photo.jpg';
      final compressedPath = '${tempDir.path}/photo_compressed.jpg';
      await File(photoPath)
          .writeAsBytes(List<int>.filled(1024, 5), flush: true);
      await _insertDraftStory(
        db: db,
        mediaId: 'media-fail',
        mediaType: 'photo',
        mediaPath: photoPath,
        storyId: 'story-fail',
      );

      final fakeApi = _FakeStoriesApi(failPublish: true);
      final fakeCompressor = _RecordingCompressor(outputPath: compressedPath);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          storiesApiProvider.overrideWithValue(fakeApi),
          storyImageCompressorProvider.overrideWithValue(fakeCompressor),
        ],
      );

      await expectLater(
        container
            .read(storyPublishControllerProvider.notifier)
            .publishLocalStory('story-fail'),
        throwsA(isA<StoriesApiException>()),
      );
      expect(fakeCompressor.calls, 1);
      expect(File(compressedPath).existsSync(), isFalse);

      final story = await db.storiesDao.getById('story-fail');
      expect(story, isNotNull);
      expect(story!.visibility, 'failed');

      container.dispose();
      await db.close();
      await tempDir.delete(recursive: true);
    });
  });
}
