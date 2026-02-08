// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripStatsImpl _$$TripStatsImplFromJson(Map<String, dynamic> json) =>
    _$TripStatsImpl(
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      totalPlaces: (json['totalPlaces'] as num?)?.toInt() ?? 0,
      totalVideos: (json['totalVideos'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TripStatsImplToJson(_$TripStatsImpl instance) =>
    <String, dynamic>{
      'totalTrips': instance.totalTrips,
      'totalPlaces': instance.totalPlaces,
      'totalVideos': instance.totalVideos,
      'totalViews': instance.totalViews,
    };
