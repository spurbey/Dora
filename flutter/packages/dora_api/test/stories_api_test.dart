import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for StoriesApi
void main() {
  final instance = DoraApi().getStoriesApi();

  group(StoriesApi, () {
    // Delete Story
    //
    //Future<StoryResponse> deleteStoryApiV1StoriesStoryIdDelete(String storyId, String authorization) async
    test('test deleteStoryApiV1StoriesStoryIdDelete', () async {
      // TODO
    });

    // Get Story
    //
    //Future<StoryResponse> getStoryApiV1StoriesStoryIdGet(String storyId, String authorization) async
    test('test getStoryApiV1StoriesStoryIdGet', () async {
      // TODO
    });

    // Get Story Feed
    //
    //Future<StoryFeedResponse> getStoryFeedApiV1StoriesFeedGet(String authorization, { num lat, num lng, String radiusKm, String cursor, int limit }) async
    test('test getStoryFeedApiV1StoriesFeedGet', () async {
      // TODO
    });

    // Mark Story Viewed
    //
    //Future<StoryResponse> markStoryViewedApiV1StoriesStoryIdViewPost(String storyId, String authorization) async
    test('test markStoryViewedApiV1StoriesStoryIdViewPost', () async {
      // TODO
    });

    // Moderation Hide Story
    //
    //Future<StoryModerationResponse> moderationHideStoryApiV1StoriesStoryIdModerationHidePost(String storyId, String authorization) async
    test('test moderationHideStoryApiV1StoriesStoryIdModerationHidePost', () async {
      // TODO
    });

    // Mute Story Author
    //
    //Future<StoryMuteResponse> muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost(String authorId, String authorization) async
    test('test muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost', () async {
      // TODO
    });

    // Publish Story
    //
    //Future<StoryResponse> publishStoryApiV1StoriesPublishPost(String authorization, String clientStoryId, String mediaType, num centerLat, num centerLng, MultipartFile file, { int durationMs }) async
    test('test publishStoryApiV1StoriesPublishPost', () async {
      // TODO
    });

    // Report Story
    //
    //Future<JsonObject> reportStoryApiV1StoriesStoryIdReportPost(String storyId, String authorization, StoryReportRequest storyReportRequest) async
    test('test reportStoryApiV1StoriesStoryIdReportPost', () async {
      // TODO
    });

  });
}
