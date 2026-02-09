// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bounds.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppLatLngBoundsImpl _$$AppLatLngBoundsImplFromJson(
        Map<String, dynamic> json) =>
    _$AppLatLngBoundsImpl(
      southwest: AppLatLng.fromJson(json['southwest'] as Map<String, dynamic>),
      northeast: AppLatLng.fromJson(json['northeast'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AppLatLngBoundsImplToJson(
        _$AppLatLngBoundsImpl instance) =>
    <String, dynamic>{
      'southwest': instance.southwest,
      'northeast': instance.northeast,
    };
