//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/search_result.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_response.g.dart';

/// Search API response wrapper.  Attributes:     results: List of ranked search results     count: Number of results returned     query: Original search query (echoed back)
///
/// Properties:
/// * [results] 
/// * [count] 
/// * [query] 
@BuiltValue()
abstract class SearchResponse implements Built<SearchResponse, SearchResponseBuilder> {
  @BuiltValueField(wireName: r'results')
  BuiltList<SearchResult> get results;

  @BuiltValueField(wireName: r'count')
  int get count;

  @BuiltValueField(wireName: r'query')
  String get query;

  SearchResponse._();

  factory SearchResponse([void updates(SearchResponseBuilder b)]) = _$SearchResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchResponse> get serializer => _$SearchResponseSerializer();
}

class _$SearchResponseSerializer implements PrimitiveSerializer<SearchResponse> {
  @override
  final Iterable<Type> types = const [SearchResponse, _$SearchResponse];

  @override
  final String wireName = r'SearchResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'results';
    yield serializers.serialize(
      object.results,
      specifiedType: const FullType(BuiltList, [FullType(SearchResult)]),
    );
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(int),
    );
    yield r'query';
    yield serializers.serialize(
      object.query,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SearchResult)]),
          ) as BuiltList<SearchResult>;
          result.results.replace(valueDes);
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        case r'query':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.query = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchResponseBuilder();
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

