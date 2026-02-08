//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/budget_per_person.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'place_metadata_update.g.dart';

/// Place metadata update schema.  All fields are optional for partial updates.  Attributes:     component_type: New component type     experience_tags: New experience tags     best_for: New best_for tags     budget_per_person: New budget estimate     duration_hours: New duration estimate     difficulty_rating: New difficulty rating     physical_demand: New physical demand level     best_time: New best time to visit     is_public: New public setting  Business Rules:     - Only owner can update     - Only provided fields are updated     - contribution_score cannot be updated (system-managed)
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
@BuiltValue()
abstract class PlaceMetadataUpdate implements Built<PlaceMetadataUpdate, PlaceMetadataUpdateBuilder> {
  @BuiltValueField(wireName: r'component_type')
  String? get componentType;

  @BuiltValueField(wireName: r'experience_tags')
  BuiltList<String>? get experienceTags;

  @BuiltValueField(wireName: r'best_for')
  BuiltList<String>? get bestFor;

  @BuiltValueField(wireName: r'budget_per_person')
  BudgetPerPerson? get budgetPerPerson;

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

  PlaceMetadataUpdate._();

  factory PlaceMetadataUpdate([void updates(PlaceMetadataUpdateBuilder b)]) = _$PlaceMetadataUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PlaceMetadataUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PlaceMetadataUpdate> get serializer => _$PlaceMetadataUpdateSerializer();
}

class _$PlaceMetadataUpdateSerializer implements PrimitiveSerializer<PlaceMetadataUpdate> {
  @override
  final Iterable<Type> types = const [PlaceMetadataUpdate, _$PlaceMetadataUpdate];

  @override
  final String wireName = r'PlaceMetadataUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PlaceMetadataUpdate object, {
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
        specifiedType: const FullType.nullable(BudgetPerPerson),
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
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PlaceMetadataUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PlaceMetadataUpdateBuilder result,
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
            specifiedType: const FullType.nullable(BudgetPerPerson),
          ) as BudgetPerPerson?;
          if (valueDes == null) continue;
          result.budgetPerPerson.replace(valueDes);
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
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isPublic = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PlaceMetadataUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PlaceMetadataUpdateBuilder();
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

