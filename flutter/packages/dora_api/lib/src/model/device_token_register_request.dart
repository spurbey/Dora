//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_token_register_request.g.dart';

/// DeviceTokenRegisterRequest
///
/// Properties:
/// * [clientEventId] 
/// * [platform] 
/// * [pushToken] 
/// * [deviceId] 
/// * [appVersion] 
/// * [locale] 
/// * [seenAt] 
@BuiltValue()
abstract class DeviceTokenRegisterRequest implements Built<DeviceTokenRegisterRequest, DeviceTokenRegisterRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'platform')
  DeviceTokenRegisterRequestPlatformEnum get platform;
  // enum platformEnum {  ios,  android,  web,  };

  @BuiltValueField(wireName: r'push_token')
  String get pushToken;

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'locale')
  String? get locale;

  @BuiltValueField(wireName: r'seen_at')
  DateTime get seenAt;

  DeviceTokenRegisterRequest._();

  factory DeviceTokenRegisterRequest([void updates(DeviceTokenRegisterRequestBuilder b)]) = _$DeviceTokenRegisterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceTokenRegisterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceTokenRegisterRequest> get serializer => _$DeviceTokenRegisterRequestSerializer();
}

class _$DeviceTokenRegisterRequestSerializer implements PrimitiveSerializer<DeviceTokenRegisterRequest> {
  @override
  final Iterable<Type> types = const [DeviceTokenRegisterRequest, _$DeviceTokenRegisterRequest];

  @override
  final String wireName = r'DeviceTokenRegisterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceTokenRegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(DeviceTokenRegisterRequestPlatformEnum),
    );
    yield r'push_token';
    yield serializers.serialize(
      object.pushToken,
      specifiedType: const FullType(String),
    );
    if (object.deviceId != null) {
      yield r'device_id';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.locale != null) {
      yield r'locale';
      yield serializers.serialize(
        object.locale,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'seen_at';
    yield serializers.serialize(
      object.seenAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceTokenRegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceTokenRegisterRequestBuilder result,
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
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceTokenRegisterRequestPlatformEnum),
          ) as DeviceTokenRegisterRequestPlatformEnum;
          result.platform = valueDes;
          break;
        case r'push_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pushToken = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceId = valueDes;
          break;
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'locale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locale = valueDes;
          break;
        case r'seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.seenAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceTokenRegisterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceTokenRegisterRequestBuilder();
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

class DeviceTokenRegisterRequestPlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ios')
  static const DeviceTokenRegisterRequestPlatformEnum ios = _$deviceTokenRegisterRequestPlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const DeviceTokenRegisterRequestPlatformEnum android = _$deviceTokenRegisterRequestPlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'web')
  static const DeviceTokenRegisterRequestPlatformEnum web = _$deviceTokenRegisterRequestPlatformEnum_web;

  static Serializer<DeviceTokenRegisterRequestPlatformEnum> get serializer => _$deviceTokenRegisterRequestPlatformEnumSerializer;

  const DeviceTokenRegisterRequestPlatformEnum._(String name): super(name);

  static BuiltSet<DeviceTokenRegisterRequestPlatformEnum> get values => _$deviceTokenRegisterRequestPlatformEnumValues;
  static DeviceTokenRegisterRequestPlatformEnum valueOf(String name) => _$deviceTokenRegisterRequestPlatformEnumValueOf(name);
}

