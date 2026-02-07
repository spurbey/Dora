//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'toll_cost.g.dart';

/// TollCost
@BuiltValue()
abstract class TollCost implements Built<TollCost, TollCostBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  TollCost._();

  factory TollCost([void updates(TollCostBuilder b)]) = _$TollCost;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TollCostBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TollCost> get serializer => _$TollCostSerializer();
}

class _$TollCostSerializer implements PrimitiveSerializer<TollCost> {
  @override
  final Iterable<Type> types = const [TollCost, _$TollCost];

  @override
  final String wireName = r'TollCost';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TollCost object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    TollCost object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  TollCost deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TollCostBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

