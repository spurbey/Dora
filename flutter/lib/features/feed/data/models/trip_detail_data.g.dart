// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_detail_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TripPlaceImpl _$$TripPlaceImplFromJson(Map<String, dynamic> json) =>
    _$TripPlaceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      notes: json['notes'] as String?,
      visitTime: json['visitTime'] as String?,
      dayNumber: (json['dayNumber'] as num?)?.toInt(),
      orderIndex: (json['orderIndex'] as num?)?.toInt(),
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TripPlaceImplToJson(_$TripPlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'notes': instance.notes,
      'visitTime': instance.visitTime,
      'dayNumber': instance.dayNumber,
      'orderIndex': instance.orderIndex,
      'photoUrls': instance.photoUrls,
    };

_$TripRouteImpl _$$TripRouteImplFromJson(Map<String, dynamic> json) =>
    _$TripRouteImpl(
      id: json['id'] as String,
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => TripLatLng.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      transportMode: json['transportMode'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toInt(),
      dayNumber: (json['dayNumber'] as num?)?.toInt(),
      polyline: json['polyline'] as String?,
    );

Map<String, dynamic> _$$TripRouteImplToJson(_$TripRouteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coordinates': instance.coordinates,
      'transportMode': instance.transportMode,
      'distance': instance.distance,
      'duration': instance.duration,
      'dayNumber': instance.dayNumber,
      'polyline': instance.polyline,
    };

_$TripLatLngImpl _$$TripLatLngImplFromJson(Map<String, dynamic> json) =>
    _$TripLatLngImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$$TripLatLngImplToJson(_$TripLatLngImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
