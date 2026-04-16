//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_action_type.g.dart';

class UserActionType extends EnumClass {

  @BuiltValueEnumConst(wireName: r'dismissed')
  static const UserActionType dismissed = _$dismissed;
  @BuiltValueEnumConst(wireName: r'liked')
  static const UserActionType liked = _$liked;
  @BuiltValueEnumConst(wireName: r'saved')
  static const UserActionType saved = _$saved;
  @BuiltValueEnumConst(wireName: r'acted_on')
  static const UserActionType actedOn = _$actedOn;
  @BuiltValueEnumConst(wireName: r'converted_to_place')
  static const UserActionType convertedToPlace = _$convertedToPlace;

  static Serializer<UserActionType> get serializer => _$userActionTypeSerializer;

  const UserActionType._(String name): super(name);

  static BuiltSet<UserActionType> get values => _$values;
  static UserActionType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class UserActionTypeMixin = Object with _$UserActionTypeMixin;

