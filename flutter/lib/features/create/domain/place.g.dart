// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      coordinates:
          AppLatLng.fromJson(json['coordinates'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      visitTime: json['visitTime'] as String?,
      dayNumber: (json['dayNumber'] as num?)?.toInt(),
      orderIndex: (json['orderIndex'] as num).toInt(),
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      localUpdatedAt: DateTime.parse(json['localUpdatedAt'] as String),
      serverUpdatedAt: DateTime.parse(json['serverUpdatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'name': instance.name,
      'address': instance.address,
      'coordinates': instance.coordinates,
      'notes': instance.notes,
      'visitTime': instance.visitTime,
      'dayNumber': instance.dayNumber,
      'orderIndex': instance.orderIndex,
      'photoUrls': instance.photoUrls,
      'localUpdatedAt': instance.localUpdatedAt.toIso8601String(),
      'serverUpdatedAt': instance.serverUpdatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
