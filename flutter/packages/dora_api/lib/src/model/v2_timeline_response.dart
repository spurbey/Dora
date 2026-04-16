//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/v2_timeline_entry_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_timeline_response.g.dart';

/// V2TimelineResponse
///
/// Properties:
/// * [entries] 
/// * [nextCursor] 
/// * [hasMore] 
/// * [compiledAt] 
/// * [compilerVersion] 
@BuiltValue()
abstract class V2TimelineResponse implements Built<V2TimelineResponse, V2TimelineResponseBuilder> {
  @BuiltValueField(wireName: r'entries')
  BuiltList<V2TimelineEntryResponse>? get entries;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  @BuiltValueField(wireName: r'compiled_at')
  DateTime? get compiledAt;

  @BuiltValueField(wireName: r'compiler_version')
  int get compilerVersion;

  V2TimelineResponse._();

  factory V2TimelineResponse([void updates(V2TimelineResponseBuilder b)]) = _$V2TimelineResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2TimelineResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2TimelineResponse> get serializer => _$V2TimelineResponseSerializer();
}

class _$V2TimelineResponseSerializer implements PrimitiveSerializer<V2TimelineResponse> {
  @override
  final Iterable<Type> types = const [V2TimelineResponse, _$V2TimelineResponse];

  @override
  final String wireName = r'V2TimelineResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2TimelineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.entries != null) {
      yield r'entries';
      yield serializers.serialize(
        object.entries,
        specifiedType: const FullType(BuiltList, [FullType(V2TimelineEntryResponse)]),
      );
    }
    if (object.nextCursor != null) {
      yield r'next_cursor';
      yield serializers.serialize(
        object.nextCursor,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
    if (object.compiledAt != null) {
      yield r'compiled_at';
      yield serializers.serialize(
        object.compiledAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'compiler_version';
    yield serializers.serialize(
      object.compilerVersion,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2TimelineResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2TimelineResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(V2TimelineEntryResponse)]),
          ) as BuiltList<V2TimelineEntryResponse>;
          result.entries.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        case r'compiled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.compiledAt = valueDes;
          break;
        case r'compiler_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.compilerVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2TimelineResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2TimelineResponseBuilder();
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

