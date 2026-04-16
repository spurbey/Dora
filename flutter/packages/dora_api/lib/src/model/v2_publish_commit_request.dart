//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_commit_request.g.dart';

/// V2PublishCommitRequest
///
/// Properties:
/// * [publishToken] 
/// * [clientJobId] 
/// * [schemaVersion] 
@BuiltValue()
abstract class V2PublishCommitRequest implements Built<V2PublishCommitRequest, V2PublishCommitRequestBuilder> {
  @BuiltValueField(wireName: r'publish_token')
  String get publishToken;

  @BuiltValueField(wireName: r'client_job_id')
  String get clientJobId;

  @BuiltValueField(wireName: r'schema_version')
  int get schemaVersion;

  V2PublishCommitRequest._();

  factory V2PublishCommitRequest([void updates(V2PublishCommitRequestBuilder b)]) = _$V2PublishCommitRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishCommitRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishCommitRequest> get serializer => _$V2PublishCommitRequestSerializer();
}

class _$V2PublishCommitRequestSerializer implements PrimitiveSerializer<V2PublishCommitRequest> {
  @override
  final Iterable<Type> types = const [V2PublishCommitRequest, _$V2PublishCommitRequest];

  @override
  final String wireName = r'V2PublishCommitRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishCommitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'publish_token';
    yield serializers.serialize(
      object.publishToken,
      specifiedType: const FullType(String),
    );
    yield r'client_job_id';
    yield serializers.serialize(
      object.clientJobId,
      specifiedType: const FullType(String),
    );
    yield r'schema_version';
    yield serializers.serialize(
      object.schemaVersion,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishCommitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishCommitRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'publish_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publishToken = valueDes;
          break;
        case r'client_job_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientJobId = valueDes;
          break;
        case r'schema_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.schemaVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishCommitRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishCommitRequestBuilder();
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

