//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/export_job_summary_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_job_list_response.g.dart';

/// ExportJobListResponse
///
/// Properties:
/// * [exports] 
/// * [total] 
/// * [page] 
/// * [pageSize] 
/// * [totalPages] 
@BuiltValue()
abstract class ExportJobListResponse implements Built<ExportJobListResponse, ExportJobListResponseBuilder> {
  @BuiltValueField(wireName: r'exports')
  BuiltList<ExportJobSummaryResponse> get exports;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'page_size')
  int get pageSize;

  @BuiltValueField(wireName: r'total_pages')
  int get totalPages;

  ExportJobListResponse._();

  factory ExportJobListResponse([void updates(ExportJobListResponseBuilder b)]) = _$ExportJobListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportJobListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportJobListResponse> get serializer => _$ExportJobListResponseSerializer();
}

class _$ExportJobListResponseSerializer implements PrimitiveSerializer<ExportJobListResponse> {
  @override
  final Iterable<Type> types = const [ExportJobListResponse, _$ExportJobListResponse];

  @override
  final String wireName = r'ExportJobListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportJobListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'exports';
    yield serializers.serialize(
      object.exports,
      specifiedType: const FullType(BuiltList, [FullType(ExportJobSummaryResponse)]),
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
    ExportJobListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportJobListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exports':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ExportJobSummaryResponse)]),
          ) as BuiltList<ExportJobSummaryResponse>;
          result.exports.replace(valueDes);
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
  ExportJobListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportJobListResponseBuilder();
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

