//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_metadata_response.g.dart';

/// Trip metadata response schema.  Attributes:     trip_id: Trip UUID     traveler_type: Array of traveler types     age_group: Target age group     travel_style: Array of travel styles     difficulty_level: Overall difficulty     budget_category: Budget level     activity_focus: Array of activity types     is_discoverable: Whether trip can be found in public search     quality_score: System-calculated quality score (0-1)     tags: User-defined tags     created_at: Creation timestamp     updated_at: Last update timestamp  Config:     from_attributes: Enable ORM mode for SQLAlchemy models
///
/// Properties:
/// * [travelerType] 
/// * [ageGroup] 
/// * [travelStyle] 
/// * [difficultyLevel] 
/// * [budgetCategory] 
/// * [activityFocus] 
/// * [isDiscoverable] 
/// * [tags] 
/// * [tripId] 
/// * [qualityScore] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class TripMetadataResponse implements Built<TripMetadataResponse, TripMetadataResponseBuilder> {
  @BuiltValueField(wireName: r'traveler_type')
  BuiltList<String>? get travelerType;

  @BuiltValueField(wireName: r'age_group')
  String? get ageGroup;

  @BuiltValueField(wireName: r'travel_style')
  BuiltList<String>? get travelStyle;

  @BuiltValueField(wireName: r'difficulty_level')
  String? get difficultyLevel;

  @BuiltValueField(wireName: r'budget_category')
  String? get budgetCategory;

  @BuiltValueField(wireName: r'activity_focus')
  BuiltList<String>? get activityFocus;

  @BuiltValueField(wireName: r'is_discoverable')
  bool? get isDiscoverable;

  @BuiltValueField(wireName: r'tags')
  BuiltList<String>? get tags;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'quality_score')
  num get qualityScore;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  TripMetadataResponse._();

  factory TripMetadataResponse([void updates(TripMetadataResponseBuilder b)]) = _$TripMetadataResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripMetadataResponseBuilder b) => b
      ..isDiscoverable = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripMetadataResponse> get serializer => _$TripMetadataResponseSerializer();
}

class _$TripMetadataResponseSerializer implements PrimitiveSerializer<TripMetadataResponse> {
  @override
  final Iterable<Type> types = const [TripMetadataResponse, _$TripMetadataResponse];

  @override
  final String wireName = r'TripMetadataResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.travelerType != null) {
      yield r'traveler_type';
      yield serializers.serialize(
        object.travelerType,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.ageGroup != null) {
      yield r'age_group';
      yield serializers.serialize(
        object.ageGroup,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.travelStyle != null) {
      yield r'travel_style';
      yield serializers.serialize(
        object.travelStyle,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.difficultyLevel != null) {
      yield r'difficulty_level';
      yield serializers.serialize(
        object.difficultyLevel,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.budgetCategory != null) {
      yield r'budget_category';
      yield serializers.serialize(
        object.budgetCategory,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.activityFocus != null) {
      yield r'activity_focus';
      yield serializers.serialize(
        object.activityFocus,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.isDiscoverable != null) {
      yield r'is_discoverable';
      yield serializers.serialize(
        object.isDiscoverable,
        specifiedType: const FullType(bool),
      );
    }
    if (object.tags != null) {
      yield r'tags';
      yield serializers.serialize(
        object.tags,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'quality_score';
    yield serializers.serialize(
      object.qualityScore,
      specifiedType: const FullType(num),
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
    TripMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripMetadataResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'traveler_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.travelerType.replace(valueDes);
          break;
        case r'age_group':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ageGroup = valueDes;
          break;
        case r'travel_style':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.travelStyle.replace(valueDes);
          break;
        case r'difficulty_level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.difficultyLevel = valueDes;
          break;
        case r'budget_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.budgetCategory = valueDes;
          break;
        case r'activity_focus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.activityFocus.replace(valueDes);
          break;
        case r'is_discoverable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDiscoverable = valueDes;
          break;
        case r'tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.tags.replace(valueDes);
          break;
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'quality_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.qualityScore = valueDes;
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
  TripMetadataResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripMetadataResponseBuilder();
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

