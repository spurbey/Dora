//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/v2_route_segment_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_route_response.g.dart';

/// V2RouteResponse
///
/// Properties:
/// * [segments] 
/// * [hasMore] 
/// * [nextCursor] 
/// * [compiledAt] 
/// * [compilerVersion] 
@BuiltValue()
abstract class V2RouteResponse implements Built<V2RouteResponse, V2RouteResponseBuilder> {
  @BuiltValueField(wireName: r'segments')
  BuiltList<V2RouteSegmentResponse>? get segments;

  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  @BuiltValueField(wireName: r'compiled_at')
  DateTime? get compiledAt;

  @BuiltValueField(wireName: r'compiler_version')
  int get compilerVersion;

  V2RouteResponse._();

  factory V2RouteResponse([void updates(V2RouteResponseBuilder b)]) = _$V2RouteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2RouteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2RouteResponse> get serializer => _$V2RouteResponseSerializer();
}

class _$V2RouteResponseSerializer implements PrimitiveSerializer<V2RouteResponse> {
  @override
  final Iterable<Type> types = const [V2RouteResponse, _$V2RouteResponse];

  @override
  final String wireName = r'V2RouteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2RouteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.segments != null) {
      yield r'segments';
      yield serializers.serialize(
        object.segments,
        specifiedType: const FullType(BuiltList, [FullType(V2RouteSegmentResponse)]),
      );
    }
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
    if (object.nextCursor != null) {
      yield r'next_cursor';
      yield serializers.serialize(
        object.nextCursor,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    V2RouteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2RouteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'segments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(V2RouteSegmentResponse)]),
          ) as BuiltList<V2RouteSegmentResponse>;
          result.segments.replace(valueDes);
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
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
  V2RouteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2RouteResponseBuilder();
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

