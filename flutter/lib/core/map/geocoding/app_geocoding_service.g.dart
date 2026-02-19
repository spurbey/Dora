// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_geocoding_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeocodingResultImpl _$$GeocodingResultImplFromJson(
        Map<String, dynamic> json) =>
    _$GeocodingResultImpl(
      name: json['name'] as String,
      country: json['country'] as String?,
      coordinates:
          AppLatLng.fromJson(json['coordinates'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GeocodingResultImplToJson(
        _$GeocodingResultImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'country': instance.country,
      'coordinates': instance.coordinates,
    };
