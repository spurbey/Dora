//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/place_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'place_list_response.g.dart';

/// List of places (typically for a single trip).  Attributes:     places: List of places     total: Total number of places     trip_id: Parent trip ID (for context), None for nearby queries  Used for GET /places?trip_id={trip_id} and GET /places/nearby endpoints.
///
/// Properties:
/// * [places] 
/// * [total] 
/// * [tripId] 
@BuiltValue()
abstract class PlaceListResponse implements Built<PlaceListResponse, PlaceListResponseBuilder> {
  @BuiltValueField(wireName: r'places')
  BuiltList<PlaceResponse> get places;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'trip_id')
  String? get tripId;

  PlaceListResponse._();

  factory PlaceListResponse([void updates(PlaceListResponseBuilder b)]) = _$PlaceListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlaceListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlaceListResponse> get serializer => _$PlaceListResponseSerializer();
}

class _$PlaceListResponseSerializer implements PrimitiveSerializer<PlaceListResponse> {
  @override
  final Iterable<Type> types = const [PlaceListResponse, _$PlaceListResponse];

  @override
  final String wireName = r'PlaceListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlaceListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'places';
    yield serializers.serialize(
      object.places,
      specifiedType: const FullType(BuiltList, [FullType(PlaceResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    if (object.tripId != null) {
      yield r'trip_id';
      yield serializers.serialize(
        object.tripId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlaceListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlaceListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'places':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(PlaceResponse)]),
          ) as BuiltList<PlaceResponse>;
          result.places.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tripId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlaceListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlaceListResponseBuilder();
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

