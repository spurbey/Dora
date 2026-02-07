//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/trip_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_list_response.g.dart';

/// Paginated trip list response.  Attributes:     trips: List of trips     total: Total number of trips (before pagination)     page: Current page number (1-indexed)     page_size: Number of items per page     total_pages: Total number of pages  Used for GET /trips endpoint with pagination.
///
/// Properties:
/// * [trips] 
/// * [total] 
/// * [page] 
/// * [pageSize] 
/// * [totalPages] 
@BuiltValue()
abstract class TripListResponse implements Built<TripListResponse, TripListResponseBuilder> {
  @BuiltValueField(wireName: r'trips')
  BuiltList<TripResponse> get trips;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'page_size')
  int get pageSize;

  @BuiltValueField(wireName: r'total_pages')
  int get totalPages;

  TripListResponse._();

  factory TripListResponse([void updates(TripListResponseBuilder b)]) = _$TripListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripListResponse> get serializer => _$TripListResponseSerializer();
}

class _$TripListResponseSerializer implements PrimitiveSerializer<TripListResponse> {
  @override
  final Iterable<Type> types = const [TripListResponse, _$TripListResponse];

  @override
  final String wireName = r'TripListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trips';
    yield serializers.serialize(
      object.trips,
      specifiedType: const FullType(BuiltList, [FullType(TripResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(int),
    );
    yield r'page_size';
    yield serializers.serialize(
      object.pageSize,
      specifiedType: const FullType(int),
    );
    yield r'total_pages';
    yield serializers.serialize(
      object.totalPages,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trips':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TripResponse)]),
          ) as BuiltList<TripResponse>;
          result.trips.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.page = valueDes;
          break;
        case r'page_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pageSize = valueDes;
          break;
        case r'total_pages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalPages = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripListResponseBuilder();
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

