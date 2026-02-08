//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_response.g.dart';

/// Trip response schema.  Attributes:     id: Trip UUID     user_id: Owner user ID     title: Trip title     description: Trip description     start_date: Trip start date     end_date: Trip end date     cover_photo_url: Cover photo URL     visibility: Visibility setting     views_count: Number of views     saves_count: Number of saves     created_at: Creation timestamp     updated_at: Last update timestamp  Config:     from_attributes: Enable ORM mode for SQLAlchemy models
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [title] 
/// * [description] 
/// * [startDate] 
/// * [endDate] 
/// * [coverPhotoUrl] 
/// * [visibility] 
/// * [viewsCount] 
/// * [savesCount] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class TripResponse implements Built<TripResponse, TripResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'start_date')
  Date? get startDate;

  @BuiltValueField(wireName: r'end_date')
  Date? get endDate;

  @BuiltValueField(wireName: r'cover_photo_url')
  String? get coverPhotoUrl;

  @BuiltValueField(wireName: r'visibility')
  String get visibility;

  @BuiltValueField(wireName: r'views_count')
  int get viewsCount;

  @BuiltValueField(wireName: r'saves_count')
  int get savesCount;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  TripResponse._();

  factory TripResponse([void updates(TripResponseBuilder b)]) = _$TripResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripResponse> get serializer => _$TripResponseSerializer();
}

class _$TripResponseSerializer implements PrimitiveSerializer<TripResponse> {
  @override
  final Iterable<Type> types = const [TripResponse, _$TripResponse];

  @override
  final String wireName = r'TripResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.startDate != null) {
      yield r'start_date';
      yield serializers.serialize(
        object.startDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.endDate != null) {
      yield r'end_date';
      yield serializers.serialize(
        object.endDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.coverPhotoUrl != null) {
      yield r'cover_photo_url';
      yield serializers.serialize(
        object.coverPhotoUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'visibility';
    yield serializers.serialize(
      object.visibility,
      specifiedType: const FullType(String),
    );
    yield r'views_count';
    yield serializers.serialize(
      object.viewsCount,
      specifiedType: const FullType(int),
    );
    yield r'saves_count';
    yield serializers.serialize(
      object.savesCount,
      specifiedType: const FullType(int),
    );
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
    TripResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripResponseBuilder result,
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
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'start_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.startDate = valueDes;
          break;
        case r'end_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.endDate = valueDes;
          break;
        case r'cover_photo_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.coverPhotoUrl = valueDes;
          break;
        case r'visibility':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.visibility = valueDes;
          break;
        case r'views_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.viewsCount = valueDes;
          break;
        case r'saves_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.savesCount = valueDes;
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
  TripResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripResponseBuilder();
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

