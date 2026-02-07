//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/trip_component_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_component_list_response.g.dart';

/// Response for GET /trips/{trip_id}/components.
///
/// Properties:
/// * [components] 
/// * [total] 
/// * [tripId] 
@BuiltValue()
abstract class TripComponentListResponse implements Built<TripComponentListResponse, TripComponentListResponseBuilder> {
  @BuiltValueField(wireName: r'components')
  BuiltList<TripComponentResponse> get components;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  TripComponentListResponse._();

  factory TripComponentListResponse([void updates(TripComponentListResponseBuilder b)]) = _$TripComponentListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripComponentListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripComponentListResponse> get serializer => _$TripComponentListResponseSerializer();
}

class _$TripComponentListResponseSerializer implements PrimitiveSerializer<TripComponentListResponse> {
  @override
  final Iterable<Type> types = const [TripComponentListResponse, _$TripComponentListResponse];

  @override
  final String wireName = r'TripComponentListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripComponentListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'components';
    yield serializers.serialize(
      object.components,
      specifiedType: const FullType(BuiltList, [FullType(TripComponentResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripComponentListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripComponentListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'components':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TripComponentResponse)]),
          ) as BuiltList<TripComponentResponse>;
          result.components.replace(valueDes);
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
            specifiedType: const FullType(String),
          ) as String;
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
  TripComponentListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripComponentListResponseBuilder();
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

