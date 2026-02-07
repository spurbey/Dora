//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'budget_per_person.g.dart';

/// BudgetPerPerson
@BuiltValue()
abstract class BudgetPerPerson implements Built<BudgetPerPerson, BudgetPerPersonBuilder> {
  /// Any Of [String], [num]
  AnyOf get anyOf;

  BudgetPerPerson._();

  factory BudgetPerPerson([void updates(BudgetPerPersonBuilder b)]) = _$BudgetPerPerson;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BudgetPerPersonBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BudgetPerPerson> get serializer => _$BudgetPerPersonSerializer();
}

class _$BudgetPerPersonSerializer implements PrimitiveSerializer<BudgetPerPerson> {
  @override
  final Iterable<Type> types = const [BudgetPerPerson, _$BudgetPerPerson];

  @override
  final String wireName = r'BudgetPerPerson';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BudgetPerPerson object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    BudgetPerPerson object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  BudgetPerPerson deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BudgetPerPersonBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(num), FullType(String), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

