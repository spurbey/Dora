//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_result_debug.g.dart';

/// Debug information for result ranking (optional).  Attributes:     source_score: Source weight score (0-1)     source_contribution: Contribution to final score     text_score: Text relevance score (0-1)     text_contribution: Contribution to final score     popularity_score: Popularity score (0-1)     popularity_contribution: Contribution to final score     freshness_score: Freshness score (0-1)     freshness_contribution: Contribution to final score     final_score: Total weighted score (0-1)     breakdown: Human-readable score calculation
///
/// Properties:
/// * [sourceScore] 
/// * [sourceContribution] 
/// * [textScore] 
/// * [textContribution] 
/// * [popularityScore] 
/// * [popularityContribution] 
/// * [freshnessScore] 
/// * [freshnessContribution] 
/// * [finalScore] 
/// * [breakdown] 
@BuiltValue()
abstract class SearchResultDebug implements Built<SearchResultDebug, SearchResultDebugBuilder> {
  @BuiltValueField(wireName: r'source_score')
  num get sourceScore;

  @BuiltValueField(wireName: r'source_contribution')
  num get sourceContribution;

  @BuiltValueField(wireName: r'text_score')
  num get textScore;

  @BuiltValueField(wireName: r'text_contribution')
  num get textContribution;

  @BuiltValueField(wireName: r'popularity_score')
  num get popularityScore;

  @BuiltValueField(wireName: r'popularity_contribution')
  num get popularityContribution;

  @BuiltValueField(wireName: r'freshness_score')
  num get freshnessScore;

  @BuiltValueField(wireName: r'freshness_contribution')
  num get freshnessContribution;

  @BuiltValueField(wireName: r'final_score')
  num get finalScore;

  @BuiltValueField(wireName: r'breakdown')
  String get breakdown;

  SearchResultDebug._();

  factory SearchResultDebug([void updates(SearchResultDebugBuilder b)]) = _$SearchResultDebug;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchResultDebugBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchResultDebug> get serializer => _$SearchResultDebugSerializer();
}

class _$SearchResultDebugSerializer implements PrimitiveSerializer<SearchResultDebug> {
  @override
  final Iterable<Type> types = const [SearchResultDebug, _$SearchResultDebug];

  @override
  final String wireName = r'SearchResultDebug';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchResultDebug object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'source_score';
    yield serializers.serialize(
      object.sourceScore,
      specifiedType: const FullType(num),
    );
    yield r'source_contribution';
    yield serializers.serialize(
      object.sourceContribution,
      specifiedType: const FullType(num),
    );
    yield r'text_score';
    yield serializers.serialize(
      object.textScore,
      specifiedType: const FullType(num),
    );
    yield r'text_contribution';
    yield serializers.serialize(
      object.textContribution,
      specifiedType: const FullType(num),
    );
    yield r'popularity_score';
    yield serializers.serialize(
      object.popularityScore,
      specifiedType: const FullType(num),
    );
    yield r'popularity_contribution';
    yield serializers.serialize(
      object.popularityContribution,
      specifiedType: const FullType(num),
    );
    yield r'freshness_score';
    yield serializers.serialize(
      object.freshnessScore,
      specifiedType: const FullType(num),
    );
    yield r'freshness_contribution';
    yield serializers.serialize(
      object.freshnessContribution,
      specifiedType: const FullType(num),
    );
    yield r'final_score';
    yield serializers.serialize(
      object.finalScore,
      specifiedType: const FullType(num),
    );
    yield r'breakdown';
    yield serializers.serialize(
      object.breakdown,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchResultDebug object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchResultDebugBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sourceScore = valueDes;
          break;
        case r'source_contribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.sourceContribution = valueDes;
          break;
        case r'text_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.textScore = valueDes;
          break;
        case r'text_contribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.textContribution = valueDes;
          break;
        case r'popularity_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.popularityScore = valueDes;
          break;
        case r'popularity_contribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.popularityContribution = valueDes;
          break;
        case r'freshness_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.freshnessScore = valueDes;
          break;
        case r'freshness_contribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.freshnessContribution = valueDes;
          break;
        case r'final_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.finalScore = valueDes;
          break;
        case r'breakdown':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.breakdown = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchResultDebug deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchResultDebugBuilder();
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

