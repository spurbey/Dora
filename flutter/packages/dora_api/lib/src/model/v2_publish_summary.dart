//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_summary.g.dart';

/// V2PublishSummary
///
/// Properties:
/// * [snapshotHash] 
/// * [sessionCount] 
/// * [eventCount] 
/// * [mediaCount] 
/// * [pointCount] 
/// * [payloadBytes] 
/// * [startedAt] 
/// * [endedAt] 
@BuiltValue()
abstract class V2PublishSummary implements Built<V2PublishSummary, V2PublishSummaryBuilder> {
  @BuiltValueField(wireName: r'snapshot_hash')
  String get snapshotHash;

  @BuiltValueField(wireName: r'session_count')
  int? get sessionCount;

  @BuiltValueField(wireName: r'event_count')
  int get eventCount;

  @BuiltValueField(wireName: r'media_count')
  int get mediaCount;

  @BuiltValueField(wireName: r'point_count')
  int get pointCount;

  @BuiltValueField(wireName: r'payload_bytes')
  int get payloadBytes;

  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  V2PublishSummary._();

  factory V2PublishSummary([void updates(V2PublishSummaryBuilder b)]) = _$V2PublishSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishSummaryBuilder b) => b
      ..sessionCount = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishSummary> get serializer => _$V2PublishSummarySerializer();
}

class _$V2PublishSummarySerializer implements PrimitiveSerializer<V2PublishSummary> {
  @override
  final Iterable<Type> types = const [V2PublishSummary, _$V2PublishSummary];

  @override
  final String wireName = r'V2PublishSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'snapshot_hash';
    yield serializers.serialize(
      object.snapshotHash,
      specifiedType: const FullType(String),
    );
    if (object.sessionCount != null) {
      yield r'session_count';
      yield serializers.serialize(
        object.sessionCount,
        specifiedType: const FullType(int),
      );
    }
    yield r'event_count';
    yield serializers.serialize(
      object.eventCount,
      specifiedType: const FullType(int),
    );
    yield r'media_count';
    yield serializers.serialize(
      object.mediaCount,
      specifiedType: const FullType(int),
    );
    yield r'point_count';
    yield serializers.serialize(
      object.pointCount,
      specifiedType: const FullType(int),
    );
    yield r'payload_bytes';
    yield serializers.serialize(
      object.payloadBytes,
      specifiedType: const FullType(int),
    );
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.endedAt != null) {
      yield r'ended_at';
      yield serializers.serialize(
        object.endedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'snapshot_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.snapshotHash = valueDes;
          break;
        case r'session_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sessionCount = valueDes;
          break;
        case r'event_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.eventCount = valueDes;
          break;
        case r'media_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.mediaCount = valueDes;
          break;
        case r'point_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pointCount = valueDes;
          break;
        case r'payload_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.payloadBytes = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishSummaryBuilder();
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

