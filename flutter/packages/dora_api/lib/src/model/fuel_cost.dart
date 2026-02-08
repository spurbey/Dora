//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'fuel_cost.g.dart';

/// FuelCost
@BuiltValue()
abstract class FuelCost implements Built<FuelCost, FuelCostBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  FuelCost._();

  factory FuelCost([void updates(FuelCostBuilder b)]) = _$FuelCost;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FuelCostBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FuelCost> get serializer => _$FuelCostSerializer();
}

class _$FuelCostSerializer implements PrimitiveSerializer<FuelCost> {
  @override
  final Iterable<Type> types = const [FuelCost, _$FuelCost];

  @override
  final String wireName = r'FuelCost';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FuelCost object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    FuelCost object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  FuelCost deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FuelCostBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

