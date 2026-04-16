//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_media_manifest_item.g.dart';

/// V2MediaManifestItem
///
/// Properties:
/// * [clientMediaId] 
/// * [mimeType] 
/// * [sizeBytes] 
/// * [mediaContentHash] 
@BuiltValue()
abstract class V2MediaManifestItem implements Built<V2MediaManifestItem, V2MediaManifestItemBuilder> {
  @BuiltValueField(wireName: r'client_media_id')
  String get clientMediaId;

  @BuiltValueField(wireName: r'mime_type')
  String? get mimeType;

  @BuiltValueField(wireName: r'size_bytes')
  int? get sizeBytes;

  @BuiltValueField(wireName: r'media_content_hash')
  String get mediaContentHash;

  V2MediaManifestItem._();

  factory V2MediaManifestItem([void updates(V2MediaManifestItemBuilder b)]) = _$V2MediaManifestItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2MediaManifestItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2MediaManifestItem> get serializer => _$V2MediaManifestItemSerializer();
}

class _$V2MediaManifestItemSerializer implements PrimitiveSerializer<V2MediaManifestItem> {
  @override
  final Iterable<Type> types = const [V2MediaManifestItem, _$V2MediaManifestItem];

  @override
  final String wireName = r'V2MediaManifestItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2MediaManifestItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_media_id';
    yield serializers.serialize(
      object.clientMediaId,
      specifiedType: const FullType(String),
    );
    if (object.mimeType != null) {
      yield r'mime_type';
      yield serializers.serialize(
        object.mimeType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sizeBytes != null) {
      yield r'size_bytes';
      yield serializers.serialize(
        object.sizeBytes,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'media_content_hash';
    yield serializers.serialize(
      object.mediaContentHash,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2MediaManifestItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2MediaManifestItemBuilder result,
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
        case r'mime_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mimeType = valueDes;
          break;
        case r'size_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sizeBytes = valueDes;
          break;
        case r'media_content_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaContentHash = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2MediaManifestItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2MediaManifestItemBuilder();
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

