//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/advisory_source.dart';
import 'package:dora_api/src/model/advisory_category.dart';
import 'package:dora_api/src/model/advisory_delivery_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_insight_response.g.dart';

/// AdvisoryInsightResponse
///
/// Properties:
/// * [id] 
/// * [category] 
/// * [source_] 
/// * [title] 
/// * [body] 
/// * [placeName] 
/// * [placeLat] 
/// * [placeLng] 
/// * [confidenceScore] 
/// * [contextSignal] 
/// * [bestFor] 
/// * [sourceUrls] 
/// * [sourceCount] 
/// * [status] 
/// * [observedAt] 
/// * [deliveredAt] 
/// * [createdAt] 
@BuiltValue()
abstract class AdvisoryInsightResponse implements Built<AdvisoryInsightResponse, AdvisoryInsightResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'category')
  AdvisoryCategory get category;
  // enum categoryEnum {  safety_warning,  scam_alert,  food_tip,  photo_spot,  transport_tip,  accommodation,  cultural_etiquette,  must_do,  avoid,  general_tip,  };

  @BuiltValueField(wireName: r'source')
  AdvisorySource get source_;
  // enum source_Enum {  reddit,  tripadvisor,  google_maps,  combined,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'place_name')
  String? get placeName;

  @BuiltValueField(wireName: r'place_lat')
  num? get placeLat;

  @BuiltValueField(wireName: r'place_lng')
  num? get placeLng;

  @BuiltValueField(wireName: r'confidence_score')
  num get confidenceScore;

  @BuiltValueField(wireName: r'context_signal')
  String? get contextSignal;

  @BuiltValueField(wireName: r'best_for')
  String? get bestFor;

  @BuiltValueField(wireName: r'source_urls')
  BuiltList<String>? get sourceUrls;

  @BuiltValueField(wireName: r'source_count')
  int? get sourceCount;

  @BuiltValueField(wireName: r'status')
  AdvisoryDeliveryStatus get status;
  // enum statusEnum {  pending,  delivered,  expired,  };

  @BuiltValueField(wireName: r'observed_at')
  DateTime? get observedAt;

  @BuiltValueField(wireName: r'delivered_at')
  DateTime? get deliveredAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  AdvisoryInsightResponse._();

  factory AdvisoryInsightResponse([void updates(AdvisoryInsightResponseBuilder b)]) = _$AdvisoryInsightResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryInsightResponseBuilder b) => b
      ..sourceCount = 1;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryInsightResponse> get serializer => _$AdvisoryInsightResponseSerializer();
}

class _$AdvisoryInsightResponseSerializer implements PrimitiveSerializer<AdvisoryInsightResponse> {
  @override
  final Iterable<Type> types = const [AdvisoryInsightResponse, _$AdvisoryInsightResponse];

  @override
  final String wireName = r'AdvisoryInsightResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryInsightResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(AdvisoryCategory),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(AdvisorySource),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    if (object.placeName != null) {
      yield r'place_name';
      yield serializers.serialize(
        object.placeName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.placeLat != null) {
      yield r'place_lat';
      yield serializers.serialize(
        object.placeLat,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.placeLng != null) {
      yield r'place_lng';
      yield serializers.serialize(
        object.placeLng,
        specifiedType: const FullType.nullable(num),
      );
    }
    yield r'confidence_score';
    yield serializers.serialize(
      object.confidenceScore,
      specifiedType: const FullType(num),
    );
    if (object.contextSignal != null) {
      yield r'context_signal';
      yield serializers.serialize(
        object.contextSignal,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.bestFor != null) {
      yield r'best_for';
      yield serializers.serialize(
        object.bestFor,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sourceUrls != null) {
      yield r'source_urls';
      yield serializers.serialize(
        object.sourceUrls,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.sourceCount != null) {
      yield r'source_count';
      yield serializers.serialize(
        object.sourceCount,
        specifiedType: const FullType(int),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdvisoryDeliveryStatus),
    );
    if (object.observedAt != null) {
      yield r'observed_at';
      yield serializers.serialize(
        object.observedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.deliveredAt != null) {
      yield r'delivered_at';
      yield serializers.serialize(
        object.deliveredAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdvisoryInsightResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryInsightResponseBuilder result,
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
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdvisoryCategory),
          ) as AdvisoryCategory;
          result.category = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdvisorySource),
          ) as AdvisorySource;
          result.source_ = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'place_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.placeName = valueDes;
          break;
        case r'place_lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.placeLat = valueDes;
          break;
        case r'place_lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.placeLng = valueDes;
          break;
        case r'confidence_score':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.confidenceScore = valueDes;
          break;
        case r'context_signal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.contextSignal = valueDes;
          break;
        case r'best_for':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bestFor = valueDes;
          break;
        case r'source_urls':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.sourceUrls.replace(valueDes);
          break;
        case r'source_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sourceCount = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdvisoryDeliveryStatus),
          ) as AdvisoryDeliveryStatus;
          result.status = valueDes;
          break;
        case r'observed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.observedAt = valueDes;
          break;
        case r'delivered_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deliveredAt = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdvisoryInsightResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryInsightResponseBuilder();
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

