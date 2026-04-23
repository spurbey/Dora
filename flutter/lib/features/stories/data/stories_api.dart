import 'dart:io';

import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/network/api_client.dart';
import 'package:dora/features/stories/data/models/story_models.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class StoriesApi {
  StoriesApi(this._api, this._authService, this._apiClient);

  final openapi.StoriesApi _api;
  final AuthService _authService;
  final ApiClient _apiClient;

  Future<String> _authHeader() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw StoriesApiException('Missing auth token', statusCode: 401);
    }
    return 'Bearer $token';
  }

  Future<StoryPublishResult> publishStory({
    required String clientStoryId,
    required String filePath,
    required StoryMediaType mediaType,
    required double centerLat,
    required double centerLng,
    int? durationMs,
  }) async {
    try {
      final fileName = filePath.split(Platform.pathSeparator).last;
      final multipart =
          await MultipartFile.fromFile(filePath, filename: fileName);
      final response = await _api.publishStoryApiV1StoriesPublishPost(
        authorization: await _authHeader(),
        clientStoryId: clientStoryId,
        mediaType: mediaType.name,
        centerLat: centerLat,
        centerLng: centerLng,
        durationMs: durationMs,
        file: multipart,
      );
      final payload = response.data;
      if (payload == null) {
        throw StoriesApiException('Empty publish response', statusCode: 502);
      }
      return StoryPublishResult.fromApi(payload);
    } on DioException catch (error) {
      throw _wrap(error);
    }
  }

  Future<StoryFeedPage> fetchFeed({
    required StoryRadiusFilter radius,
    double? lat,
    double? lng,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/stories/feed',
        queryParameters: <String, dynamic>{
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          'radius_km': radius.wireValue,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': limit,
        },
        options: Options(
          headers: <String, String>{
            'authorization': await _authHeader(),
          },
        ),
      );
      final payload = response.data;
      if (payload == null) {
        throw StoriesApiException('Empty feed response', statusCode: 502);
      }
      return StoryFeedPage.fromJson(payload);
    } on DioException catch (error) {
      throw _wrap(error);
    }
  }

  Future<StoryFeedItem> getStory(String storyId) async {
    try {
      final response = await _api.getStoryApiV1StoriesStoryIdGet(
        authorization: await _authHeader(),
        storyId: storyId,
      );
      final payload = response.data;
      if (payload == null) {
        throw StoriesApiException('Empty story response', statusCode: 502);
      }
      return StoryFeedItem.fromApi(payload);
    } on DioException catch (error) {
      throw _wrap(error);
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await _api.deleteStoryApiV1StoriesStoryIdDelete(
        authorization: await _authHeader(),
        storyId: storyId,
      );
    } on DioException catch (error) {
      throw _wrap(error);
    }
  }

  Future<void> reportStory({
    required String storyId,
    required String reason,
    String? details,
  }) async {
    try {
      await _api.reportStoryApiV1StoriesStoryIdReportPost(
        authorization: await _authHeader(),
        storyId: storyId,
        storyReportRequest: openapi.StoryReportRequest(
          (b) => b
            ..reason = reason
            ..details =
                details?.trim().isNotEmpty == true ? details!.trim() : null,
        ),
      );
    } on DioException catch (error) {
      throw _wrap(error);
    }
  }

  Future<void> muteAuthor(String authorId) async {
    try {
      await _api.muteStoryAuthorApiV1StoriesAuthorsAuthorIdMutePost(
        authorization: await _authHeader(),
        authorId: authorId,
      );
    } on DioException catch (error) {
      throw _wrap(error);
    }
  }

  Future<StoryFeedItem> recordView(String storyId) async {
    try {
      final response = await _api.markStoryViewedApiV1StoriesStoryIdViewPost(
        authorization: await _authHeader(),
        storyId: storyId,
      );
      final payload = response.data;
      if (payload == null) {
        throw StoriesApiException('Empty view response', statusCode: 502);
      }
      return StoryFeedItem.fromApi(payload);
    } on DioException catch (error) {
      throw _wrap(error);
    }
  }

  StoriesApiException _wrap(DioException error) {
    final statusCode = error.response?.statusCode;
    final payload = error.response?.data;
    String message = error.message ?? 'Stories request failed';
    String? code;
    if (payload is openapi.HTTPValidationError) {
      final detail = payload.detail;
      if (detail != null && detail.isNotEmpty) {
        message = detail.map((item) => item.msg).join(', ');
      }
    } else if (payload is Map) {
      final detail = payload['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        message = detail;
      } else if (detail is List && detail.isNotEmpty) {
        message = detail.map((item) => item.toString()).join(', ');
      } else if (payload['message'] is String) {
        message = payload['message'].toString();
      }
      if (payload['code'] is String) {
        code = payload['code'].toString();
      }
    } else if (payload is String && payload.trim().isNotEmpty) {
      message = payload;
    }
    return StoriesApiException(message, statusCode: statusCode, code: code);
  }
}
