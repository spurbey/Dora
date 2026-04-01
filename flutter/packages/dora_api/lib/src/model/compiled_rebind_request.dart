//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'compiled_rebind_request.g.dart';

/// CompiledRebindRequest
///
/// Properties:
/// * [sourceEventId] 
/// * [sourceMediaId] 
/// * [sourceKind] 
/// * [action] 
/// * [tripPlaceId] 
@BuiltValue()
abstract class CompiledRebindRequest implements Built<CompiledRebindRequest, CompiledRebindRequestBuilder> {
  @BuiltValueField(wireName: r'source_event_id')
  String? get sourceEventId;

  @BuiltValueField(wireName: r'source_media_id')
  String? get sourceMediaId;

  @BuiltValueField(wireName: r'source_kind')
  String? get sourceKind;

  @BuiltValueField(wireName: r'action')
  String get action;

  @BuiltValueField(wireName: r'trip_place_id')
  String? get tripPlaceId;

  CompiledRebindRequest._();

  factory CompiledRebindRequest([void updates(CompiledRebindRequestBuilder b)]) = _$CompiledRebindRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompiledRebindRequestBuilder b) => b
      ..sourceKind = 'tracking_event';

  @BuiltValueSerializer(custom: true)
  static Serializer<CompiledRebindRequest> get serializer => _$CompiledRebindRequestSerializer();
}

class _$CompiledRebindRequestSerializer implements PrimitiveSerializer<CompiledRebindRequest> {
  @override
  final Iterable<Type> types = const [CompiledRebindRequest, _$CompiledRebindRequest];

  @override
  final String wireName = r'CompiledRebindRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompiledRebindRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.sourceEventId != null) {
      yield r'source_event_id';
      yield serializers.serialize(
        object.sourceEventId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sourceMediaId != null) {
      yield r'source_media_id';
      yield serializers.serialize(
        object.sourceMediaId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sourceKind != null) {
      yield r'source_kind';
      yield serializers.serialize(
        object.sourceKind,
        specifiedType: const FullType(String),
      );
    }
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(String),
    );
    if (object.tripPlaceId != null) {
      yield r'trip_place_id';
      yield serializers.serialize(
        object.tripPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompiledRebindRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompiledRebindRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceEventId = valueDes;
          break;
        case r'source_media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceMediaId = valueDes;
          break;
        case r'source_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceKind = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.action = valueDes;
          break;
        case r'trip_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tripPlaceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompiledRebindRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompiledRebindRequestBuilder();
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

