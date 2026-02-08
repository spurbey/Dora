//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'app_schemas_auth_user_response.g.dart';

/// User data in API responses.  Attributes:     id: User UUID     email: User email     username: Unique username     full_name: Optional full name     avatar_url: Optional profile picture URL     bio: Optional bio     is_premium: Premium subscription status     is_verified: Email verification status     created_at: Account creation timestamp      Config:     from_attributes: Enable ORM mode for SQLAlchemy models
///
/// Properties:
/// * [id] 
/// * [email] 
/// * [username] 
/// * [fullName] 
/// * [avatarUrl] 
/// * [bio] 
/// * [isPremium] 
/// * [isVerified] 
/// * [createdAt] 
@BuiltValue()
abstract class AppSchemasAuthUserResponse implements Built<AppSchemasAuthUserResponse, AppSchemasAuthUserResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'full_name')
  String? get fullName;

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'is_premium')
  bool get isPremium;

  @BuiltValueField(wireName: r'is_verified')
  bool get isVerified;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  AppSchemasAuthUserResponse._();

  factory AppSchemasAuthUserResponse([void updates(AppSchemasAuthUserResponseBuilder b)]) = _$AppSchemasAuthUserResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppSchemasAuthUserResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppSchemasAuthUserResponse> get serializer => _$AppSchemasAuthUserResponseSerializer();
}

class _$AppSchemasAuthUserResponseSerializer implements PrimitiveSerializer<AppSchemasAuthUserResponse> {
  @override
  final Iterable<Type> types = const [AppSchemasAuthUserResponse, _$AppSchemasAuthUserResponse];

  @override
  final String wireName = r'AppSchemasAuthUserResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppSchemasAuthUserResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    if (object.fullName != null) {
      yield r'full_name';
      yield serializers.serialize(
        object.fullName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.avatarUrl != null) {
      yield r'avatar_url';
      yield serializers.serialize(
        object.avatarUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.bio != null) {
      yield r'bio';
      yield serializers.serialize(
        object.bio,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'is_premium';
    yield serializers.serialize(
      object.isPremium,
      specifiedType: const FullType(bool),
    );
    yield r'is_verified';
    yield serializers.serialize(
      object.isVerified,
      specifiedType: const FullType(bool),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AppSchemasAuthUserResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AppSchemasAuthUserResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'full_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fullName = valueDes;
          break;
        case r'avatar_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bio = valueDes;
          break;
        case r'is_premium':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPremium = valueDes;
          break;
        case r'is_verified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isVerified = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppSchemasAuthUserResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppSchemasAuthUserResponseBuilder();
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

