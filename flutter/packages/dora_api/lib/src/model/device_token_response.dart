//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'device_token_response.g.dart';

/// DeviceTokenResponse
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [platform] 
/// * [deviceId] 
/// * [appVersion] 
/// * [locale] 
/// * [tokenHint] 
/// * [isActive] 
/// * [failureCount] 
/// * [lastSeenAt] 
/// * [lastSentAt] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class DeviceTokenResponse implements Built<DeviceTokenResponse, DeviceTokenResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'platform')
  DeviceTokenResponsePlatformEnum get platform;
  // enum platformEnum {  ios,  android,  web,  };

  @BuiltValueField(wireName: r'device_id')
  String? get deviceId;

  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'locale')
  String? get locale;

  @BuiltValueField(wireName: r'token_hint')
  String? get tokenHint;

  @BuiltValueField(wireName: r'is_active')
  bool get isActive;

  @BuiltValueField(wireName: r'failure_count')
  int get failureCount;

  @BuiltValueField(wireName: r'last_seen_at')
  DateTime get lastSeenAt;

  @BuiltValueField(wireName: r'last_sent_at')
  DateTime? get lastSentAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  DeviceTokenResponse._();

  factory DeviceTokenResponse([void updates(DeviceTokenResponseBuilder b)]) = _$DeviceTokenResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeviceTokenResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeviceTokenResponse> get serializer => _$DeviceTokenResponseSerializer();
}

class _$DeviceTokenResponseSerializer implements PrimitiveSerializer<DeviceTokenResponse> {
  @override
  final Iterable<Type> types = const [DeviceTokenResponse, _$DeviceTokenResponse];

  @override
  final String wireName = r'DeviceTokenResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeviceTokenResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(DeviceTokenResponsePlatformEnum),
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
    if (object.tokenHint != null) {
      yield r'token_hint';
      yield serializers.serialize(
        object.tokenHint,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'is_active';
    yield serializers.serialize(
      object.isActive,
      specifiedType: const FullType(bool),
    );
    yield r'failure_count';
    yield serializers.serialize(
      object.failureCount,
      specifiedType: const FullType(int),
    );
    yield r'last_seen_at';
    yield serializers.serialize(
      object.lastSeenAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.lastSentAt != null) {
      yield r'last_sent_at';
      yield serializers.serialize(
        object.lastSentAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeviceTokenResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeviceTokenResponseBuilder result,
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
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeviceTokenResponsePlatformEnum),
          ) as DeviceTokenResponsePlatformEnum;
          result.platform = valueDes;
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
        case r'token_hint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tokenHint = valueDes;
          break;
        case r'is_active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
          break;
        case r'failure_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.failureCount = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastSeenAt = valueDes;
          break;
        case r'last_sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastSentAt = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeviceTokenResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeviceTokenResponseBuilder();
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

class DeviceTokenResponsePlatformEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ios')
  static const DeviceTokenResponsePlatformEnum ios = _$deviceTokenResponsePlatformEnum_ios;
  @BuiltValueEnumConst(wireName: r'android')
  static const DeviceTokenResponsePlatformEnum android = _$deviceTokenResponsePlatformEnum_android;
  @BuiltValueEnumConst(wireName: r'web')
  static const DeviceTokenResponsePlatformEnum web = _$deviceTokenResponsePlatformEnum_web;

  static Serializer<DeviceTokenResponsePlatformEnum> get serializer => _$deviceTokenResponsePlatformEnumSerializer;

  const DeviceTokenResponsePlatformEnum._(String name): super(name);

  static BuiltSet<DeviceTokenResponsePlatformEnum> get values => _$deviceTokenResponsePlatformEnumValues;
  static DeviceTokenResponsePlatformEnum valueOf(String name) => _$deviceTokenResponsePlatformEnumValueOf(name);
}

