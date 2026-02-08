//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_metadata_create.g.dart';

/// Trip metadata creation schema.  Inherits all fields from TripMetadataBase. Used for POST /trips/{trip_id}/metadata endpoint.  Business Logic:     - trip_id is taken from URL path parameter     - All fields are optional except is_discoverable (defaults to False)
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
@BuiltValue()
abstract class TripMetadataCreate implements Built<TripMetadataCreate, TripMetadataCreateBuilder> {
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

  TripMetadataCreate._();

  factory TripMetadataCreate([void updates(TripMetadataCreateBuilder b)]) = _$TripMetadataCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripMetadataCreateBuilder b) => b
      ..isDiscoverable = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripMetadataCreate> get serializer => _$TripMetadataCreateSerializer();
}

class _$TripMetadataCreateSerializer implements PrimitiveSerializer<TripMetadataCreate> {
  @override
  final Iterable<Type> types = const [TripMetadataCreate, _$TripMetadataCreate];

  @override
  final String wireName = r'TripMetadataCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripMetadataCreate object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    TripMetadataCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripMetadataCreateBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripMetadataCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripMetadataCreateBuilder();
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

