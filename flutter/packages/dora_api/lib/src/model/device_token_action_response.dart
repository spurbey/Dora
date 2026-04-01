//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/device_token_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_token_action_response.g.dart';

/// DeviceTokenActionResponse
///
/// Properties:
/// * [token] 
/// * [idempotencyReplayed] 
@BuiltValue()
abstract class DeviceTokenActionResponse implements Built<DeviceTokenActionResponse, DeviceTokenActionResponseBuilder> {
  @BuiltValueField(wireName: r'token')
  DeviceTokenResponse get token;

  @BuiltValueField(wireName: r'idempotency_replayed')
  bool get idempotencyReplayed;

  DeviceTokenActionResponse._();

  factory DeviceTokenActionResponse([void updates(DeviceTokenActionResponseBuilder b)]) = _$DeviceTokenActionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceTokenActionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceTokenActionResponse> get serializer => _$DeviceTokenActionResponseSerializer();
}

class _$DeviceTokenActionResponseSerializer implements PrimitiveSerializer<DeviceTokenActionResponse> {
  @override
  final Iterable<Type> types = const [DeviceTokenActionResponse, _$DeviceTokenActionResponse];

  @override
  final String wireName = r'DeviceTokenActionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceTokenActionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(DeviceTokenResponse),
    );
    yield r'idempotency_replayed';
    yield serializers.serialize(
      object.idempotencyReplayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceTokenActionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceTokenActionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceTokenResponse),
          ) as DeviceTokenResponse;
          result.token.replace(valueDes);
          break;
        case r'idempotency_replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.idempotencyReplayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceTokenActionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceTokenActionResponseBuilder();
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

