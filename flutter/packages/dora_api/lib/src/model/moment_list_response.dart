//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/moment_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_list_response.g.dart';

/// MomentListResponse
///
/// Properties:
/// * [moments] 
/// * [total] 
@BuiltValue()
abstract class MomentListResponse implements Built<MomentListResponse, MomentListResponseBuilder> {
  @BuiltValueField(wireName: r'moments')
  BuiltList<MomentResponse> get moments;

  @BuiltValueField(wireName: r'total')
  int get total;

  MomentListResponse._();

  factory MomentListResponse([void updates(MomentListResponseBuilder b)]) = _$MomentListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentListResponse> get serializer => _$MomentListResponseSerializer();
}

class _$MomentListResponseSerializer implements PrimitiveSerializer<MomentListResponse> {
  @override
  final Iterable<Type> types = const [MomentListResponse, _$MomentListResponse];

  @override
  final String wireName = r'MomentListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'moments';
    yield serializers.serialize(
      object.moments,
      specifiedType: const FullType(BuiltList, [FullType(MomentResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'moments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MomentResponse)]),
          ) as BuiltList<MomentResponse>;
          result.moments.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentListResponseBuilder();
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

