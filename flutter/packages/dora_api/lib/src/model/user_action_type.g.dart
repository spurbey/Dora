// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_action_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserActionType _$dismissed = const UserActionType._('dismissed');
const UserActionType _$liked = const UserActionType._('liked');
const UserActionType _$saved = const UserActionType._('saved');
const UserActionType _$actedOn = const UserActionType._('actedOn');
const UserActionType _$convertedToPlace =
    const UserActionType._('convertedToPlace');

UserActionType _$valueOf(String name) {
  switch (name) {
    case 'dismissed':
      return _$dismissed;
    case 'liked':
      return _$liked;
    case 'saved':
      return _$saved;
    case 'actedOn':
      return _$actedOn;
    case 'convertedToPlace':
      return _$convertedToPlace;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserActionType> _$values =
    BuiltSet<UserActionType>(const <UserActionType>[
  _$dismissed,
  _$liked,
  _$saved,
  _$actedOn,
  _$convertedToPlace,
]);

class _$UserActionTypeMeta {
  const _$UserActionTypeMeta();
  UserActionType get dismissed => _$dismissed;
  UserActionType get liked => _$liked;
  UserActionType get saved => _$saved;
  UserActionType get actedOn => _$actedOn;
  UserActionType get convertedToPlace => _$convertedToPlace;
  UserActionType valueOf(String name) => _$valueOf(name);
  BuiltSet<UserActionType> get values => _$values;
}

abstract class _$UserActionTypeMixin {
  // ignore: non_constant_identifier_names
  _$UserActionTypeMeta get UserActionType => const _$UserActionTypeMeta();
}

Serializer<UserActionType> _$userActionTypeSerializer =
    _$UserActionTypeSerializer();

class _$UserActionTypeSerializer
    implements PrimitiveSerializer<UserActionType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dismissed': 'dismissed',
    'liked': 'liked',
    'saved': 'saved',
    'actedOn': 'acted_on',
    'convertedToPlace': 'converted_to_place',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'dismissed': 'dismissed',
    'liked': 'liked',
    'saved': 'saved',
    'acted_on': 'actedOn',
    'converted_to_place': 'convertedToPlace',
  };

  @override
  final Iterable<Type> types = const <Type>[UserActionType];
  @override
  final String wireName = 'UserActionType';

  @override
  Object serialize(Serializers serializers, UserActionType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UserActionType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UserActionType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
