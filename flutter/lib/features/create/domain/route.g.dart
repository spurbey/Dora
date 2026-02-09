// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouteImpl _$$RouteImplFromJson(Map<String, dynamic> json) => _$RouteImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => AppLatLng.fromJson(e as Map<String, dynamic>))
          .toList(),
      transportMode: json['transportMode'] as String? ?? 'car',
      distance: (json['distance'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toInt(),
      dayNumber: (json['dayNumber'] as num?)?.toInt(),
      localUpdatedAt: DateTime.parse(json['localUpdatedAt'] as String),
      serverUpdatedAt: DateTime.parse(json['serverUpdatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$RouteImplToJson(_$RouteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'coordinates': instance.coordinates,
      'transportMode': instance.transportMode,
      'distance': instance.distance,
      'duration': instance.duration,
      'dayNumber': instance.dayNumber,
      'localUpdatedAt': instance.localUpdatedAt.toIso8601String(),
      'serverUpdatedAt': instance.serverUpdatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
