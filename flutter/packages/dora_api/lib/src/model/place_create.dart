//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'place_create.g.dart';

/// Place creation schema.  Inherits all fields from PlaceBase and adds trip-specific fields. Used for POST /places endpoint.  Attributes:     trip_id: ID of parent trip (required)     order_in_trip: Position in trip itinerary (optional, auto-set if not provided)  Business Logic:     - trip_id must reference an existing trip     - user_id is automatically set from authenticated user     - location (Geography) is automatically created from lat/lng     - If order_in_trip not provided, set to max + 1
///
/// Properties:
/// * [name] 
/// * [placeType] 
/// * [lat] - Latitude (WGS84)
/// * [lng] - Longitude (WGS84)
/// * [userNotes] 
/// * [userRating] 
/// * [visitDate] 
/// * [tripId] 
/// * [orderInTrip] 
@BuiltValue()
abstract class PlaceCreate implements Built<PlaceCreate, PlaceCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'place_type')
  String? get placeType;

  /// Latitude (WGS84)
  @BuiltValueField(wireName: r'lat')
  num get lat;

  /// Longitude (WGS84)
  @BuiltValueField(wireName: r'lng')
  num get lng;

  @BuiltValueField(wireName: r'user_notes')
  String? get userNotes;

  @BuiltValueField(wireName: r'user_rating')
  int? get userRating;

  @BuiltValueField(wireName: r'visit_date')
  Date? get visitDate;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'order_in_trip')
  int? get orderInTrip;

  PlaceCreate._();

  factory PlaceCreate([void updates(PlaceCreateBuilder b)]) = _$PlaceCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlaceCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlaceCreate> get serializer => _$PlaceCreateSerializer();
}

class _$PlaceCreateSerializer implements PrimitiveSerializer<PlaceCreate> {
  @override
  final Iterable<Type> types = const [PlaceCreate, _$PlaceCreate];

  @override
  final String wireName = r'PlaceCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlaceCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    if (object.orderInTrip != null) {
      yield r'order_in_trip';
      yield serializers.serialize(
        object.orderInTrip,
        specifiedType: const FullType.nullable(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlaceCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlaceCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'order_in_trip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.orderInTrip = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlaceCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlaceCreateBuilder();
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

