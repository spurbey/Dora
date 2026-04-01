//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/compiled_timeline_entry.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'compiled_timeline_day_group.g.dart';

/// CompiledTimelineDayGroup
///
/// Properties:
/// * [day] 
/// * [placeEntries] 
/// * [onRouteEntries] 
@BuiltValue()
abstract class CompiledTimelineDayGroup implements Built<CompiledTimelineDayGroup, CompiledTimelineDayGroupBuilder> {
  @BuiltValueField(wireName: r'day')
  Date get day;

  @BuiltValueField(wireName: r'place_entries')
  BuiltList<CompiledTimelineEntry>? get placeEntries;

  @BuiltValueField(wireName: r'on_route_entries')
  BuiltList<CompiledTimelineEntry>? get onRouteEntries;

  CompiledTimelineDayGroup._();

  factory CompiledTimelineDayGroup([void updates(CompiledTimelineDayGroupBuilder b)]) = _$CompiledTimelineDayGroup;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompiledTimelineDayGroupBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompiledTimelineDayGroup> get serializer => _$CompiledTimelineDayGroupSerializer();
}

class _$CompiledTimelineDayGroupSerializer implements PrimitiveSerializer<CompiledTimelineDayGroup> {
  @override
  final Iterable<Type> types = const [CompiledTimelineDayGroup, _$CompiledTimelineDayGroup];

  @override
  final String wireName = r'CompiledTimelineDayGroup';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompiledTimelineDayGroup object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'day';
    yield serializers.serialize(
      object.day,
      specifiedType: const FullType(Date),
    );
    if (object.placeEntries != null) {
      yield r'place_entries';
      yield serializers.serialize(
        object.placeEntries,
        specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineEntry)]),
      );
    }
    if (object.onRouteEntries != null) {
      yield r'on_route_entries';
      yield serializers.serialize(
        object.onRouteEntries,
        specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineEntry)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompiledTimelineDayGroup object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompiledTimelineDayGroupBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.day = valueDes;
          break;
        case r'place_entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineEntry)]),
          ) as BuiltList<CompiledTimelineEntry>;
          result.placeEntries.replace(valueDes);
          break;
        case r'on_route_entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineEntry)]),
          ) as BuiltList<CompiledTimelineEntry>;
          result.onRouteEntries.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompiledTimelineDayGroup deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompiledTimelineDayGroupBuilder();
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

