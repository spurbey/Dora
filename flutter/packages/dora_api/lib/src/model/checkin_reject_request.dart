//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkin_reject_request.g.dart';

/// CheckinRejectRequest
///
/// Properties:
/// * [clientEventId] 
/// * [rejectedAt] 
/// * [reason] 
@BuiltValue()
abstract class CheckinRejectRequest implements Built<CheckinRejectRequest, CheckinRejectRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'rejected_at')
  DateTime get rejectedAt;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  CheckinRejectRequest._();

  factory CheckinRejectRequest([void updates(CheckinRejectRequestBuilder b)]) = _$CheckinRejectRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckinRejectRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckinRejectRequest> get serializer => _$CheckinRejectRequestSerializer();
}

class _$CheckinRejectRequestSerializer implements PrimitiveSerializer<CheckinRejectRequest> {
  @override
  final Iterable<Type> types = const [CheckinRejectRequest, _$CheckinRejectRequest];

  @override
  final String wireName = r'CheckinRejectRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckinRejectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'rejected_at';
    yield serializers.serialize(
      object.rejectedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckinRejectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckinRejectRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientEventId = valueDes;
          break;
        case r'rejected_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.rejectedAt = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckinRejectRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckinRejectRequestBuilder();
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

