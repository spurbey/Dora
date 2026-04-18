//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/user_action_type.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_action_request.g.dart';

/// AdvisoryActionRequest
///
/// Properties:
/// * [action] 
/// * [actionMetadata] 
@BuiltValue()
abstract class AdvisoryActionRequest implements Built<AdvisoryActionRequest, AdvisoryActionRequestBuilder> {
  @BuiltValueField(wireName: r'action')
  UserActionType get action;
  // enum actionEnum {  dismissed,  liked,  saved,  acted_on,  converted_to_place,  };

  @BuiltValueField(wireName: r'action_metadata')
  JsonObject? get actionMetadata;

  AdvisoryActionRequest._();

  factory AdvisoryActionRequest([void updates(AdvisoryActionRequestBuilder b)]) = _$AdvisoryActionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryActionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryActionRequest> get serializer => _$AdvisoryActionRequestSerializer();
}

class _$AdvisoryActionRequestSerializer implements PrimitiveSerializer<AdvisoryActionRequest> {
  @override
  final Iterable<Type> types = const [AdvisoryActionRequest, _$AdvisoryActionRequest];

  @override
  final String wireName = r'AdvisoryActionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryActionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(UserActionType),
    );
    if (object.actionMetadata != null) {
      yield r'action_metadata';
      yield serializers.serialize(
        object.actionMetadata,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdvisoryActionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryActionRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserActionType),
          ) as UserActionType;
          result.action = valueDes;
          break;
        case r'action_metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.actionMetadata = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdvisoryActionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryActionRequestBuilder();
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

