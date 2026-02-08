// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PublicTripImpl _$$PublicTripImplFromJson(Map<String, dynamic> json) =>
    _$PublicTripImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      userId: json['userId'] as String,
      username: json['username'] as String,
      placeCount: (json['placeCount'] as num).toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      visibility: json['visibility'] as String? ?? 'public',
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      localUpdatedAt: DateTime.parse(json['localUpdatedAt'] as String),
      serverUpdatedAt: DateTime.parse(json['serverUpdatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
    );

Map<String, dynamic> _$$PublicTripImplToJson(_$PublicTripImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'userId': instance.userId,
      'username': instance.username,
      'placeCount': instance.placeCount,
      'duration': instance.duration,
      'tags': instance.tags,
      'visibility': instance.visibility,
      'viewCount': instance.viewCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'localUpdatedAt': instance.localUpdatedAt.toIso8601String(),
      'serverUpdatedAt': instance.serverUpdatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
