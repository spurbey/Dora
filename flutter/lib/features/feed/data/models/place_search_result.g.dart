// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceSearchResultImpl _$$PlaceSearchResultImplFromJson(
        Map<String, dynamic> json) =>
    _$PlaceSearchResultImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      priceLevel: json['priceLevel'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$$PlaceSearchResultImplToJson(
        _$PlaceSearchResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'priceLevel': instance.priceLevel,
      'photoUrl': instance.photoUrl,
    };
