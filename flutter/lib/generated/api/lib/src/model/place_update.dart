//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'place_update.g.dart';

/// Place update schema.  All fields are optional for partial updates.  Attributes:     name: New place name     place_type: New category     lat: New latitude     lng: New longitude     user_notes: New notes     user_rating: New rating (1-5)     visit_date: New visit date     order_in_trip: New position  Business Rules:     - Only owner can update     - If lat/lng updated, Geography column is automatically updated     - Cannot update trip_id or user_id
///
/// Properties:
/// * [name] 
/// * [placeType] 
/// * [lat] 
/// * [lng] 
/// * [userNotes] 
/// * [userRating] 
/// * [visitDate] 
/// * [orderInTrip] 
@BuiltValue()
abstract class PlaceUpdate implements Built<PlaceUpdate, PlaceUpdateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'place_type')
  String? get placeType;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'user_notes')
  String? get userNotes;

  @BuiltValueField(wireName: r'user_rating')
  int? get userRating;

  @BuiltValueField(wireName: r'visit_date')
  Date? get visitDate;

  @BuiltValueField(wireName: r'order_in_trip')
  int? get orderInTrip;

  PlaceUpdate._();

  factory PlaceUpdate([void updates(PlaceUpdateBuilder b)]) = _$PlaceUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlaceUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlaceUpdate> get serializer => _$PlaceUpdateSerializer();
}

class _$PlaceUpdateSerializer implements PrimitiveSerializer<PlaceUpdate> {
  @override
  final Iterable<Type> types = const [PlaceUpdate, _$PlaceUpdate];

  @override
  final String wireName = r'PlaceUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlaceUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.placeType != null) {
      yield r'place_type';
      yield serializers.serialize(
        object.placeType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType.nullable(num),
      );
    }
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
    PlaceUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlaceUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
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
  PlaceUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlaceUpdateBuilder();
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

