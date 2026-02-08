//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/app_schemas_auth_user_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'me_response.g.dart';

/// Current user info with additional stats.  Attributes:     user: User data     trip_count: Number of trips created     place_count: Total places across all trips      Used by /auth/me endpoint.
///
/// Properties:
/// * [user] 
/// * [tripCount] 
/// * [placeCount] 
@BuiltValue()
abstract class MeResponse implements Built<MeResponse, MeResponseBuilder> {
  @BuiltValueField(wireName: r'user')
  AppSchemasAuthUserResponse get user;

  @BuiltValueField(wireName: r'trip_count')
  int? get tripCount;

  @BuiltValueField(wireName: r'place_count')
  int? get placeCount;

  MeResponse._();

  factory MeResponse([void updates(MeResponseBuilder b)]) = _$MeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MeResponseBuilder b) => b
      ..tripCount = 0
      ..placeCount = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<MeResponse> get serializer => _$MeResponseSerializer();
}

class _$MeResponseSerializer implements PrimitiveSerializer<MeResponse> {
  @override
  final Iterable<Type> types = const [MeResponse, _$MeResponse];

  @override
  final String wireName = r'MeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(AppSchemasAuthUserResponse),
    );
    if (object.tripCount != null) {
      yield r'trip_count';
      yield serializers.serialize(
        object.tripCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.placeCount != null) {
      yield r'place_count';
      yield serializers.serialize(
        object.placeCount,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MeResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AppSchemasAuthUserResponse),
          ) as AppSchemasAuthUserResponse;
          result.user.replace(valueDes);
          break;
        case r'trip_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.tripCount = valueDes;
          break;
        case r'place_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.placeCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MeResponseBuilder();
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

