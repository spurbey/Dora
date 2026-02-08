//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/search_result_debug.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'search_result.g.dart';

/// Unified search result from any source.  Attributes:     id: Result ID (\"local:uuid\" or \"foursquare:fsq_id\")     name: Place name     lat: Latitude     lng: Longitude     address: Full address (if available)     source: Data source (\"local\" | \"foursquare\")     distance_m: Distance from search center in meters     rating: Rating 0-10 scale (if available)     popularity: Save count for local, None for external     has_user_content: True if source=\"local\"     score: Ranking score (0-1, higher = more relevant)     _debug: Score breakdown (only if debug=True)
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [lat] 
/// * [lng] 
/// * [address] 
/// * [source_] 
/// * [distanceM] 
/// * [rating] 
/// * [popularity] 
/// * [hasUserContent] 
/// * [score] - Ranking score
/// * [debug] 
@BuiltValue()
abstract class SearchResult implements Built<SearchResult, SearchResultBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'lat')
  num get lat;

  @BuiltValueField(wireName: r'lng')
  num get lng;

  @BuiltValueField(wireName: r'address')
  String? get address;

  @BuiltValueField(wireName: r'source')
  String get source_;

  @BuiltValueField(wireName: r'distance_m')
  num get distanceM;

  @BuiltValueField(wireName: r'rating')
  num? get rating;

  @BuiltValueField(wireName: r'popularity')
  int? get popularity;

  @BuiltValueField(wireName: r'has_user_content')
  bool get hasUserContent;

  /// Ranking score
  @BuiltValueField(wireName: r'score')
  num? get score;

  @BuiltValueField(wireName: r'_debug')
  SearchResultDebug? get debug;

  SearchResult._();

  factory SearchResult([void updates(SearchResultBuilder b)]) = _$SearchResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SearchResultBuilder b) => b
      ..score = 0.0;

  @BuiltValueSerializer(custom: true)
  static Serializer<SearchResult> get serializer => _$SearchResultSerializer();
}

class _$SearchResultSerializer implements PrimitiveSerializer<SearchResult> {
  @override
  final Iterable<Type> types = const [SearchResult, _$SearchResult];

  @override
  final String wireName = r'SearchResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SearchResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'lat';
    yield serializers.serialize(
      object.lat,
      specifiedType: const FullType(num),
    );
    yield r'lng';
    yield serializers.serialize(
      object.lng,
      specifiedType: const FullType(num),
    );
    if (object.address != null) {
      yield r'address';
      yield serializers.serialize(
        object.address,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(String),
    );
    yield r'distance_m';
    yield serializers.serialize(
      object.distanceM,
      specifiedType: const FullType(num),
    );
    if (object.rating != null) {
      yield r'rating';
      yield serializers.serialize(
        object.rating,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.popularity != null) {
      yield r'popularity';
      yield serializers.serialize(
        object.popularity,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'has_user_content';
    yield serializers.serialize(
      object.hasUserContent,
      specifiedType: const FullType(bool),
    );
    if (object.score != null) {
      yield r'score';
      yield serializers.serialize(
        object.score,
        specifiedType: const FullType(num),
      );
    }
    if (object.debug != null) {
      yield r'_debug';
      yield serializers.serialize(
        object.debug,
        specifiedType: const FullType.nullable(SearchResultDebug),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SearchResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SearchResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lng = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.address = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.source_ = valueDes;
          break;
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceM = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.rating = valueDes;
          break;
        case r'popularity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.popularity = valueDes;
          break;
        case r'has_user_content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasUserContent = valueDes;
          break;
        case r'score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.score = valueDes;
          break;
        case r'_debug':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(SearchResultDebug),
          ) as SearchResultDebug?;
          if (valueDes == null) continue;
          result.debug.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SearchResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SearchResultBuilder();
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

