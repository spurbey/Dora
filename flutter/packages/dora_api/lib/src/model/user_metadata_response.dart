//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_metadata_response.g.dart';

/// UserMetadataResponse
///
/// Properties:
/// * [userId] 
/// * [dietaryRestrictions] 
/// * [budgetRange] 
/// * [preferredTravelStyle] 
/// * [dislikes] 
/// * [notificationEnabled] 
/// * [advisoryQuietHours] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class UserMetadataResponse implements Built<UserMetadataResponse, UserMetadataResponseBuilder> {
  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'dietary_restrictions')
  BuiltList<String> get dietaryRestrictions;

  @BuiltValueField(wireName: r'budget_range')
  String? get budgetRange;

  @BuiltValueField(wireName: r'preferred_travel_style')
  BuiltList<String> get preferredTravelStyle;

  @BuiltValueField(wireName: r'dislikes')
  BuiltList<String> get dislikes;

  @BuiltValueField(wireName: r'notification_enabled')
  bool get notificationEnabled;

  @BuiltValueField(wireName: r'advisory_quiet_hours')
  JsonObject? get advisoryQuietHours;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  UserMetadataResponse._();

  factory UserMetadataResponse([void updates(UserMetadataResponseBuilder b)]) = _$UserMetadataResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserMetadataResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserMetadataResponse> get serializer => _$UserMetadataResponseSerializer();
}

class _$UserMetadataResponseSerializer implements PrimitiveSerializer<UserMetadataResponse> {
  @override
  final Iterable<Type> types = const [UserMetadataResponse, _$UserMetadataResponse];

  @override
  final String wireName = r'UserMetadataResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'dietary_restrictions';
    yield serializers.serialize(
      object.dietaryRestrictions,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.budgetRange != null) {
      yield r'budget_range';
      yield serializers.serialize(
        object.budgetRange,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'preferred_travel_style';
    yield serializers.serialize(
      object.preferredTravelStyle,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'dislikes';
    yield serializers.serialize(
      object.dislikes,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'notification_enabled';
    yield serializers.serialize(
      object.notificationEnabled,
      specifiedType: const FullType(bool),
    );
    if (object.advisoryQuietHours != null) {
      yield r'advisory_quiet_hours';
      yield serializers.serialize(
        object.advisoryQuietHours,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UserMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserMetadataResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'dietary_restrictions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.dietaryRestrictions.replace(valueDes);
          break;
        case r'budget_range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.budgetRange = valueDes;
          break;
        case r'preferred_travel_style':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.preferredTravelStyle.replace(valueDes);
          break;
        case r'dislikes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.dislikes.replace(valueDes);
          break;
        case r'notification_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.notificationEnabled = valueDes;
          break;
        case r'advisory_quiet_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.advisoryQuietHours = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserMetadataResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserMetadataResponseBuilder();
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

