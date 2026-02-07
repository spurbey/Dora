//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/date.dart';
import 'package:dora_api/src/model/media_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'place_response.g.dart';

/// Place response schema.  Attributes:     id: Place UUID     trip_id: Parent trip ID     user_id: Owner user ID     name: Place name     place_type: Category     lat: Latitude     lng: Longitude     user_notes: Personal notes     user_rating: Rating 1-5     visit_date: Date of visit     photos: Array of photo metadata or media objects     videos: Array of video metadata     external_data: Cached API data     order_in_trip: Position in itinerary     created_at: Creation timestamp     updated_at: Last update timestamp  Config:     from_attributes: Enable ORM mode for SQLAlchemy models
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [userId] 
/// * [name] 
/// * [placeType] 
/// * [lat] 
/// * [lng] 
/// * [userNotes] 
/// * [userRating] 
/// * [visitDate] 
/// * [photos] 
/// * [videos] 
/// * [externalData] 
/// * [orderInTrip] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class PlaceResponse implements Built<PlaceResponse, PlaceResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'place_type')
  String? get placeType;

  @BuiltValueField(wireName: r'lat')
  num get lat;

  @BuiltValueField(wireName: r'lng')
  num get lng;

  @BuiltValueField(wireName: r'user_notes')
  String? get userNotes;

  @BuiltValueField(wireName: r'user_rating')
  int? get userRating;

  @BuiltValueField(wireName: r'visit_date')
  Date? get visitDate;

  @BuiltValueField(wireName: r'photos')
  BuiltList<MediaResponse>? get photos;

  @BuiltValueField(wireName: r'videos')
  BuiltList<JsonObject>? get videos;

  @BuiltValueField(wireName: r'external_data')
  JsonObject? get externalData;

  @BuiltValueField(wireName: r'order_in_trip')
  int? get orderInTrip;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  PlaceResponse._();

  factory PlaceResponse([void updates(PlaceResponseBuilder b)]) = _$PlaceResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlaceResponseBuilder b) => b
      ..photos = ListBuilder()
      ..videos = ListBuilder();

  @BuiltValueSerializer(custom: true)
  static Serializer<PlaceResponse> get serializer => _$PlaceResponseSerializer();
}

class _$PlaceResponseSerializer implements PrimitiveSerializer<PlaceResponse> {
  @override
  final Iterable<Type> types = const [PlaceResponse, _$PlaceResponse];

  @override
  final String wireName = r'PlaceResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlaceResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.placeType != null) {
      yield r'place_type';
      yield serializers.serialize(
        object.placeType,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'lat';
    yield serializers.serialize(
      object.lat,
      specifiedType: const FullType(num),
    );
    yield r'lng';
    yield serializers.serialize(
      object.lng,
      specifiedType: const FullType(num),
    );
    if (object.userNotes != null) {
      yield r'user_notes';
      yield serializers.serialize(
        object.userNotes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.userRating != null) {
      yield r'user_rating';
      yield serializers.serialize(
        object.userRating,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.visitDate != null) {
      yield r'visit_date';
      yield serializers.serialize(
        object.visitDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.photos != null) {
      yield r'photos';
      yield serializers.serialize(
        object.photos,
        specifiedType: const FullType(BuiltList, [FullType(MediaResponse)]),
      );
    }
    if (object.videos != null) {
      yield r'videos';
      yield serializers.serialize(
        object.videos,
        specifiedType: const FullType(BuiltList, [FullType(JsonObject)]),
      );
    }
    if (object.externalData != null) {
      yield r'external_data';
      yield serializers.serialize(
        object.externalData,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.orderInTrip != null) {
      yield r'order_in_trip';
      yield serializers.serialize(
        object.orderInTrip,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PlaceResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlaceResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'place_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.placeType = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lng = valueDes;
          break;
        case r'user_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userNotes = valueDes;
          break;
        case r'user_rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.userRating = valueDes;
          break;
        case r'visit_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.visitDate = valueDes;
          break;
        case r'photos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MediaResponse)]),
          ) as BuiltList<MediaResponse>;
          result.photos.replace(valueDes);
          break;
        case r'videos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(JsonObject)]),
          ) as BuiltList<JsonObject>;
          result.videos.replace(valueDes);
          break;
        case r'external_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.externalData = valueDes;
          break;
        case r'order_in_trip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.orderInTrip = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlaceResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlaceResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

