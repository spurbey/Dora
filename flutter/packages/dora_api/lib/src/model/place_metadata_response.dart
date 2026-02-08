//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'place_metadata_response.g.dart';

/// Place metadata response schema.  Attributes:     place_id: Place UUID     component_type: Type of component     experience_tags: Array of experience descriptors     best_for: Array of audience types     budget_per_person: Estimated cost per person     duration_hours: Recommended time to spend     difficulty_rating: Physical difficulty rating     physical_demand: Physical demand level     best_time: Optimal time to visit     is_public: Whether place can be discovered publicly     contribution_score: Quality score for this component (0-1)     created_at: Creation timestamp     updated_at: Last update timestamp  Config:     from_attributes: Enable ORM mode for SQLAlchemy models
///
/// Properties:
/// * [componentType] 
/// * [experienceTags] 
/// * [bestFor] 
/// * [budgetPerPerson] 
/// * [durationHours] 
/// * [difficultyRating] 
/// * [physicalDemand] 
/// * [bestTime] 
/// * [isPublic] 
/// * [placeId] 
/// * [contributionScore] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class PlaceMetadataResponse implements Built<PlaceMetadataResponse, PlaceMetadataResponseBuilder> {
  @BuiltValueField(wireName: r'component_type')
  String? get componentType;

  @BuiltValueField(wireName: r'experience_tags')
  BuiltList<String>? get experienceTags;

  @BuiltValueField(wireName: r'best_for')
  BuiltList<String>? get bestFor;

  @BuiltValueField(wireName: r'budget_per_person')
  String? get budgetPerPerson;

  @BuiltValueField(wireName: r'duration_hours')
  num? get durationHours;

  @BuiltValueField(wireName: r'difficulty_rating')
  int? get difficultyRating;

  @BuiltValueField(wireName: r'physical_demand')
  String? get physicalDemand;

  @BuiltValueField(wireName: r'best_time')
  String? get bestTime;

  @BuiltValueField(wireName: r'is_public')
  bool? get isPublic;

  @BuiltValueField(wireName: r'place_id')
  String get placeId;

  @BuiltValueField(wireName: r'contribution_score')
  num get contributionScore;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  PlaceMetadataResponse._();

  factory PlaceMetadataResponse([void updates(PlaceMetadataResponseBuilder b)]) = _$PlaceMetadataResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlaceMetadataResponseBuilder b) => b
      ..isPublic = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlaceMetadataResponse> get serializer => _$PlaceMetadataResponseSerializer();
}

class _$PlaceMetadataResponseSerializer implements PrimitiveSerializer<PlaceMetadataResponse> {
  @override
  final Iterable<Type> types = const [PlaceMetadataResponse, _$PlaceMetadataResponse];

  @override
  final String wireName = r'PlaceMetadataResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlaceMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.componentType != null) {
      yield r'component_type';
      yield serializers.serialize(
        object.componentType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.experienceTags != null) {
      yield r'experience_tags';
      yield serializers.serialize(
        object.experienceTags,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.bestFor != null) {
      yield r'best_for';
      yield serializers.serialize(
        object.bestFor,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.budgetPerPerson != null) {
      yield r'budget_per_person';
      yield serializers.serialize(
        object.budgetPerPerson,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.durationHours != null) {
      yield r'duration_hours';
      yield serializers.serialize(
        object.durationHours,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.difficultyRating != null) {
      yield r'difficulty_rating';
      yield serializers.serialize(
        object.difficultyRating,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.physicalDemand != null) {
      yield r'physical_demand';
      yield serializers.serialize(
        object.physicalDemand,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.bestTime != null) {
      yield r'best_time';
      yield serializers.serialize(
        object.bestTime,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.isPublic != null) {
      yield r'is_public';
      yield serializers.serialize(
        object.isPublic,
        specifiedType: const FullType(bool),
      );
    }
    yield r'place_id';
    yield serializers.serialize(
      object.placeId,
      specifiedType: const FullType(String),
    );
    yield r'contribution_score';
    yield serializers.serialize(
      object.contributionScore,
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
    PlaceMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlaceMetadataResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'component_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.componentType = valueDes;
          break;
        case r'experience_tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.experienceTags.replace(valueDes);
          break;
        case r'best_for':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.bestFor.replace(valueDes);
          break;
        case r'budget_per_person':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.budgetPerPerson = valueDes;
          break;
        case r'duration_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.durationHours = valueDes;
          break;
        case r'difficulty_rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.difficultyRating = valueDes;
          break;
        case r'physical_demand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.physicalDemand = valueDes;
          break;
        case r'best_time':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bestTime = valueDes;
          break;
        case r'is_public':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPublic = valueDes;
          break;
        case r'place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.placeId = valueDes;
          break;
        case r'contribution_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.contributionScore = valueDes;
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
  PlaceMetadataResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlaceMetadataResponseBuilder();
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

