//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/user_action_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_action_response.g.dart';

/// AdvisoryActionResponse
///
/// Properties:
/// * [id] 
/// * [action] 
/// * [createdAt] 
@BuiltValue()
abstract class AdvisoryActionResponse implements Built<AdvisoryActionResponse, AdvisoryActionResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'action')
  UserActionType get action;
  // enum actionEnum {  dismissed,  liked,  saved,  acted_on,  converted_to_place,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  AdvisoryActionResponse._();

  factory AdvisoryActionResponse([void updates(AdvisoryActionResponseBuilder b)]) = _$AdvisoryActionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryActionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryActionResponse> get serializer => _$AdvisoryActionResponseSerializer();
}

class _$AdvisoryActionResponseSerializer implements PrimitiveSerializer<AdvisoryActionResponse> {
  @override
  final Iterable<Type> types = const [AdvisoryActionResponse, _$AdvisoryActionResponse];

  @override
  final String wireName = r'AdvisoryActionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryActionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(UserActionType),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdvisoryActionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryActionResponseBuilder result,
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
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserActionType),
          ) as UserActionType;
          result.action = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdvisoryActionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryActionResponseBuilder();
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

