import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dora_api/dora_api.dart' as openapi;

enum StoryMediaType { photo, video }

enum StoryRadiusFilter {
  oneKm,
  fiveKm,
  twentyFiveKm,
  all,
}

extension StoryRadiusFilterWire on StoryRadiusFilter {
  String get wireValue {
    switch (this) {
      case StoryRadiusFilter.oneKm:
        return '1';
      case StoryRadiusFilter.fiveKm:
        return '5';
      case StoryRadiusFilter.twentyFiveKm:
        return '25';
      case StoryRadiusFilter.all:
        return 'all';
    }
  }

  String get label {
    switch (this) {
      case StoryRadiusFilter.oneKm:
        return '1km';
      case StoryRadiusFilter.fiveKm:
        return '5km';
      case StoryRadiusFilter.twentyFiveKm:
        return '25km';
      case StoryRadiusFilter.all:
        return 'All';
    }
  }
}

@immutable
class StoryFeedItem {
  const StoryFeedItem({
    required this.id,
    required this.clientStoryId,
    required this.authorUserId,
    required this.mediaType,
    required this.centerLat,
    required this.centerLng,
    required this.status,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.mediaUrl,
    this.thumbnailUrl,
    this.durationMs,
    this.publishedAt,
    this.expiresAt,
    this.distanceKm,
    this.isOwn = false,
  });

  final String id;
  final String clientStoryId;
  final String authorUserId;
  final StoryMediaType mediaType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? durationMs;
  final double centerLat;
  final double centerLng;
  final String status;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distanceKm;
  final bool isOwn;

  factory StoryFeedItem.fromJson(Map<String, dynamic> json) {
    final mediaTypeRaw = (json['media_type'] ?? 'photo').toString();
    final mediaType = mediaTypeRaw.toLowerCase() == 'video'
        ? StoryMediaType.video
        : StoryMediaType.photo;
    return StoryFeedItem(
      id: json['id'].toString(),
      clientStoryId: json['client_story_id']?.toString() ?? '',
      authorUserId: json['author_user_id'].toString(),
      mediaType: mediaType,
      mediaUrl: json['media_url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      durationMs: _toInt(json['duration_ms']),
      centerLat: _toDouble(json['center_lat']) ?? 0,
      centerLng: _toDouble(json['center_lng']) ?? 0,
      status: json['status']?.toString() ?? 'draft',
      publishedAt: _toDateTime(json['published_at']),
      expiresAt: _toDateTime(json['expires_at']),
      viewCount: _toInt(json['view_count']) ?? 0,
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: _toDateTime(json['updated_at']) ?? DateTime.now().toUtc(),
      distanceKm: _toDouble(json['distance_km']),
      isOwn: json['is_own'] == true,
    );
  }

  factory StoryFeedItem.fromApi(openapi.StoryResponse story) {
    final mediaType = story.mediaType.toLowerCase() == 'video'
        ? StoryMediaType.video
        : StoryMediaType.photo;
    return StoryFeedItem(
      id: story.id,
      clientStoryId: story.clientStoryId,
      authorUserId: story.authorUserId,
      mediaType: mediaType,
      mediaUrl: story.mediaUrl,
      thumbnailUrl: story.thumbnailUrl,
      durationMs: story.durationMs,
      centerLat: story.centerLat.toDouble(),
      centerLng: story.centerLng.toDouble(),
      status: story.status,
      publishedAt: story.publishedAt?.toUtc(),
      expiresAt: story.expiresAt?.toUtc(),
      viewCount: story.viewCount ?? 0,
      createdAt: story.createdAt.toUtc(),
      updatedAt: story.updatedAt.toUtc(),
      distanceKm: story.distanceKm?.toDouble(),
      isOwn: story.isOwn ?? false,
    );
  }
}

@immutable
class StoryFeedPage {
  const StoryFeedPage({
    required this.items,
    required this.nextCursor,
  });

  final List<StoryFeedItem> items;
  final String? nextCursor;

  factory StoryFeedPage.fromJson(Map<String, dynamic> json) {
    final stories = json['stories'];
    final List<StoryFeedItem> items;
    if (stories is List) {
      items = stories
          .whereType<Map>()
          .map((raw) => StoryFeedItem.fromJson(
                raw.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .toList(growable: false);
    } else {
      items = const <StoryFeedItem>[];
    }
    return StoryFeedPage(
      items: items,
      nextCursor: json['next_cursor']?.toString(),
    );
  }

  factory StoryFeedPage.fromApi(openapi.StoryFeedResponse response) {
    return StoryFeedPage(
      items:
          response.stories.map(StoryFeedItem.fromApi).toList(growable: false),
      nextCursor: response.nextCursor,
    );
  }
}

@immutable
class StoryPublishResult {
  const StoryPublishResult({
    required this.id,
    required this.publishedAt,
    required this.expiresAt,
    this.serverId,
  });

  final String id;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final String? serverId;

  factory StoryPublishResult.fromJson(Map<String, dynamic> json) {
    return StoryPublishResult(
      id: json['id'].toString(),
      serverId: json['id']?.toString(),
      publishedAt: _toDateTime(json['published_at']),
      expiresAt: _toDateTime(json['expires_at']),
    );
  }

  factory StoryPublishResult.fromApi(openapi.StoryResponse story) {
    return StoryPublishResult(
      id: story.clientStoryId,
      serverId: story.id,
      publishedAt: story.publishedAt?.toUtc(),
      expiresAt: story.expiresAt?.toUtc(),
    );
  }
}

class StoriesApiException implements Exception {
  StoriesApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() {
    final codePart = code == null ? '' : ' code=$code';
    return 'StoriesApiException($statusCode$codePart): $message';
  }
}

DateTime? _toDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value.toUtc();
  final parsed = DateTime.tryParse(value.toString());
  return parsed?.toUtc();
}

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _toDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

Map<String, dynamic> decodeJsonMap(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) {
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}
