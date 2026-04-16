//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_upload_target.g.dart';

/// V2UploadTarget
///
/// Properties:
/// * [clientMediaId] 
/// * [storageProvider] 
/// * [storageRef] 
/// * [bucket] 
/// * [objectKey] 
@BuiltValue()
abstract class V2UploadTarget implements Built<V2UploadTarget, V2UploadTargetBuilder> {
  @BuiltValueField(wireName: r'client_media_id')
  String get clientMediaId;

  @BuiltValueField(wireName: r'storage_provider')
  String get storageProvider;

  @BuiltValueField(wireName: r'storage_ref')
  String get storageRef;

  @BuiltValueField(wireName: r'bucket')
  String get bucket;

  @BuiltValueField(wireName: r'object_key')
  String get objectKey;

  V2UploadTarget._();

  factory V2UploadTarget([void updates(V2UploadTargetBuilder b)]) = _$V2UploadTarget;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2UploadTargetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2UploadTarget> get serializer => _$V2UploadTargetSerializer();
}

class _$V2UploadTargetSerializer implements PrimitiveSerializer<V2UploadTarget> {
  @override
  final Iterable<Type> types = const [V2UploadTarget, _$V2UploadTarget];

  @override
  final String wireName = r'V2UploadTarget';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2UploadTarget object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_media_id';
    yield serializers.serialize(
      object.clientMediaId,
      specifiedType: const FullType(String),
    );
    yield r'storage_provider';
    yield serializers.serialize(
      object.storageProvider,
      specifiedType: const FullType(String),
    );
    yield r'storage_ref';
    yield serializers.serialize(
      object.storageRef,
      specifiedType: const FullType(String),
    );
    yield r'bucket';
    yield serializers.serialize(
      object.bucket,
      specifiedType: const FullType(String),
    );
    yield r'object_key';
    yield serializers.serialize(
      object.objectKey,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2UploadTarget object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2UploadTargetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientMediaId = valueDes;
          break;
        case r'storage_provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.storageProvider = valueDes;
          break;
        case r'storage_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.storageRef = valueDes;
          break;
        case r'bucket':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bucket = valueDes;
          break;
        case r'object_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.objectKey = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2UploadTarget deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2UploadTargetBuilder();
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

