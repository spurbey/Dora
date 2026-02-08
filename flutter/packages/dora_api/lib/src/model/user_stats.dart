//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_stats.g.dart';

/// Detailed user statistics.  Attributes:     trip_count: Total trips created     place_count: Total places across all trips     public_trip_count: Number of public trips     total_views: Total views across all trips     total_saves: Total saves across all trips     photos_uploaded: Number of photos uploaded      Used by /users/me/stats endpoint for dashboard display.
///
/// Properties:
/// * [tripCount] 
/// * [placeCount] 
/// * [publicTripCount] 
/// * [totalViews] 
/// * [totalSaves] 
/// * [photosUploaded] 
@BuiltValue()
abstract class UserStats implements Built<UserStats, UserStatsBuilder> {
  @BuiltValueField(wireName: r'trip_count')
  int? get tripCount;

  @BuiltValueField(wireName: r'place_count')
  int? get placeCount;

  @BuiltValueField(wireName: r'public_trip_count')
  int? get publicTripCount;

  @BuiltValueField(wireName: r'total_views')
  int? get totalViews;

  @BuiltValueField(wireName: r'total_saves')
  int? get totalSaves;

  @BuiltValueField(wireName: r'photos_uploaded')
  int? get photosUploaded;

  UserStats._();

  factory UserStats([void updates(UserStatsBuilder b)]) = _$UserStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserStatsBuilder b) => b
      ..tripCount = 0
      ..placeCount = 0
      ..publicTripCount = 0
      ..totalViews = 0
      ..totalSaves = 0
      ..photosUploaded = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserStats> get serializer => _$UserStatsSerializer();
}

class _$UserStatsSerializer implements PrimitiveSerializer<UserStats> {
  @override
  final Iterable<Type> types = const [UserStats, _$UserStats];

  @override
  final String wireName = r'UserStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.publicTripCount != null) {
      yield r'public_trip_count';
      yield serializers.serialize(
        object.publicTripCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalViews != null) {
      yield r'total_views';
      yield serializers.serialize(
        object.totalViews,
        specifiedType: const FullType(int),
      );
    }
    if (object.totalSaves != null) {
      yield r'total_saves';
      yield serializers.serialize(
        object.totalSaves,
        specifiedType: const FullType(int),
      );
    }
    if (object.photosUploaded != null) {
      yield r'photos_uploaded';
      yield serializers.serialize(
        object.photosUploaded,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'public_trip_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.publicTripCount = valueDes;
          break;
        case r'total_views':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalViews = valueDes;
          break;
        case r'total_saves':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalSaves = valueDes;
          break;
        case r'photos_uploaded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.photosUploaded = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserStatsBuilder();
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

