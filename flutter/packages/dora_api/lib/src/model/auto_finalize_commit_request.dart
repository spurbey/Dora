//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_finalize_commit_request.g.dart';

/// AutoFinalizeCommitRequest
///
/// Properties:
/// * [clientEventId] 
/// * [committedAt] 
@BuiltValue()
abstract class AutoFinalizeCommitRequest implements Built<AutoFinalizeCommitRequest, AutoFinalizeCommitRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'committed_at')
  DateTime get committedAt;

  AutoFinalizeCommitRequest._();

  factory AutoFinalizeCommitRequest([void updates(AutoFinalizeCommitRequestBuilder b)]) = _$AutoFinalizeCommitRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoFinalizeCommitRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoFinalizeCommitRequest> get serializer => _$AutoFinalizeCommitRequestSerializer();
}

class _$AutoFinalizeCommitRequestSerializer implements PrimitiveSerializer<AutoFinalizeCommitRequest> {
  @override
  final Iterable<Type> types = const [AutoFinalizeCommitRequest, _$AutoFinalizeCommitRequest];

  @override
  final String wireName = r'AutoFinalizeCommitRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoFinalizeCommitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'committed_at';
    yield serializers.serialize(
      object.committedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoFinalizeCommitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AutoFinalizeCommitRequestBuilder result,
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
        case r'committed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.committedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoFinalizeCommitRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoFinalizeCommitRequestBuilder();
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

