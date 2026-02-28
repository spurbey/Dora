//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/export_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_cancel_response.g.dart';

/// ExportCancelResponse
///
/// Properties:
/// * [status] 
@BuiltValue()
abstract class ExportCancelResponse implements Built<ExportCancelResponse, ExportCancelResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  ExportStatus get status;
  // enum statusEnum {  queued,  processing,  cancel_requested,  completed,  failed,  canceled,  blocked,  };

  ExportCancelResponse._();

  factory ExportCancelResponse([void updates(ExportCancelResponseBuilder b)]) = _$ExportCancelResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportCancelResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportCancelResponse> get serializer => _$ExportCancelResponseSerializer();
}

class _$ExportCancelResponseSerializer implements PrimitiveSerializer<ExportCancelResponse> {
  @override
  final Iterable<Type> types = const [ExportCancelResponse, _$ExportCancelResponse];

  @override
  final String wireName = r'ExportCancelResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportCancelResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ExportStatus),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportCancelResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportCancelResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExportStatus),
          ) as ExportStatus;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportCancelResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportCancelResponseBuilder();
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

