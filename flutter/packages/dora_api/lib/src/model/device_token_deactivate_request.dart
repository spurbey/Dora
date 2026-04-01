//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_token_deactivate_request.g.dart';

/// DeviceTokenDeactivateRequest
///
/// Properties:
/// * [clientEventId] 
/// * [pushToken] 
/// * [deactivatedAt] 
@BuiltValue()
abstract class DeviceTokenDeactivateRequest implements Built<DeviceTokenDeactivateRequest, DeviceTokenDeactivateRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'push_token')
  String get pushToken;

  @BuiltValueField(wireName: r'deactivated_at')
  DateTime get deactivatedAt;

  DeviceTokenDeactivateRequest._();

  factory DeviceTokenDeactivateRequest([void updates(DeviceTokenDeactivateRequestBuilder b)]) = _$DeviceTokenDeactivateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceTokenDeactivateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceTokenDeactivateRequest> get serializer => _$DeviceTokenDeactivateRequestSerializer();
}

class _$DeviceTokenDeactivateRequestSerializer implements PrimitiveSerializer<DeviceTokenDeactivateRequest> {
  @override
  final Iterable<Type> types = const [DeviceTokenDeactivateRequest, _$DeviceTokenDeactivateRequest];

  @override
  final String wireName = r'DeviceTokenDeactivateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceTokenDeactivateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'push_token';
    yield serializers.serialize(
      object.pushToken,
      specifiedType: const FullType(String),
    );
    yield r'deactivated_at';
    yield serializers.serialize(
      object.deactivatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceTokenDeactivateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceTokenDeactivateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientEventId = valueDes;
          break;
        case r'push_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pushToken = valueDes;
          break;
        case r'deactivated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.deactivatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceTokenDeactivateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceTokenDeactivateRequestBuilder();
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

