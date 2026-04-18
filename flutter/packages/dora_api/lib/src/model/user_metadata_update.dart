//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_metadata_update.g.dart';

/// UserMetadataUpdate
///
/// Properties:
/// * [dietaryRestrictions] 
/// * [dislikes] 
/// * [preferredTravelStyle] 
/// * [budgetRange] 
/// * [notificationEnabled] 
@BuiltValue()
abstract class UserMetadataUpdate implements Built<UserMetadataUpdate, UserMetadataUpdateBuilder> {
  @BuiltValueField(wireName: r'dietary_restrictions')
  BuiltList<String>? get dietaryRestrictions;

  @BuiltValueField(wireName: r'dislikes')
  BuiltList<String>? get dislikes;

  @BuiltValueField(wireName: r'preferred_travel_style')
  BuiltList<String>? get preferredTravelStyle;

  @BuiltValueField(wireName: r'budget_range')
  String? get budgetRange;

  @BuiltValueField(wireName: r'notification_enabled')
  bool? get notificationEnabled;

  UserMetadataUpdate._();

  factory UserMetadataUpdate([void updates(UserMetadataUpdateBuilder b)]) = _$UserMetadataUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserMetadataUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserMetadataUpdate> get serializer => _$UserMetadataUpdateSerializer();
}

class _$UserMetadataUpdateSerializer implements PrimitiveSerializer<UserMetadataUpdate> {
  @override
  final Iterable<Type> types = const [UserMetadataUpdate, _$UserMetadataUpdate];

  @override
  final String wireName = r'UserMetadataUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserMetadataUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.dietaryRestrictions != null) {
      yield r'dietary_restrictions';
      yield serializers.serialize(
        object.dietaryRestrictions,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.dislikes != null) {
      yield r'dislikes';
      yield serializers.serialize(
        object.dislikes,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.preferredTravelStyle != null) {
      yield r'preferred_travel_style';
      yield serializers.serialize(
        object.preferredTravelStyle,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.budgetRange != null) {
      yield r'budget_range';
      yield serializers.serialize(
        object.budgetRange,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.notificationEnabled != null) {
      yield r'notification_enabled';
      yield serializers.serialize(
        object.notificationEnabled,
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserMetadataUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserMetadataUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'dietary_restrictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.dietaryRestrictions.replace(valueDes);
          break;
        case r'dislikes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.dislikes.replace(valueDes);
          break;
        case r'preferred_travel_style':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.preferredTravelStyle.replace(valueDes);
          break;
        case r'budget_range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.budgetRange = valueDes;
          break;
        case r'notification_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.notificationEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserMetadataUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserMetadataUpdateBuilder();
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

