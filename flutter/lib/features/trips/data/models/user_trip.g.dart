// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserTripImpl _$$UserTripImplFromJson(Map<String, dynamic> json) =>
    _$UserTripImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverPhotoUrl: json['coverPhotoUrl'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      visibility: json['visibility'] as String? ?? 'private',
      placeCount: (json['placeCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'editing',
      lastEditedAt: json['lastEditedAt'] == null
          ? null
          : DateTime.parse(json['lastEditedAt'] as String),
      localUpdatedAt: DateTime.parse(json['localUpdatedAt'] as String),
      serverUpdatedAt: DateTime.parse(json['serverUpdatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserTripImplToJson(_$UserTripImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'visibility': instance.visibility,
      'placeCount': instance.placeCount,
      'status': instance.status,
      'lastEditedAt': instance.lastEditedAt?.toIso8601String(),
      'localUpdatedAt': instance.localUpdatedAt.toIso8601String(),
      'serverUpdatedAt': instance.serverUpdatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'createdAt': instance.createdAt.toIso8601String(),
    };
