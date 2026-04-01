//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/checkin_candidate_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkin_action_response.g.dart';

/// CheckinActionResponse
///
/// Properties:
/// * [candidate] 
/// * [idempotencyReplayed] 
@BuiltValue()
abstract class CheckinActionResponse implements Built<CheckinActionResponse, CheckinActionResponseBuilder> {
  @BuiltValueField(wireName: r'candidate')
  CheckinCandidateResponse get candidate;

  @BuiltValueField(wireName: r'idempotency_replayed')
  bool get idempotencyReplayed;

  CheckinActionResponse._();

  factory CheckinActionResponse([void updates(CheckinActionResponseBuilder b)]) = _$CheckinActionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckinActionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckinActionResponse> get serializer => _$CheckinActionResponseSerializer();
}

class _$CheckinActionResponseSerializer implements PrimitiveSerializer<CheckinActionResponse> {
  @override
  final Iterable<Type> types = const [CheckinActionResponse, _$CheckinActionResponse];

  @override
  final String wireName = r'CheckinActionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckinActionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'candidate';
    yield serializers.serialize(
      object.candidate,
      specifiedType: const FullType(CheckinCandidateResponse),
    );
    yield r'idempotency_replayed';
    yield serializers.serialize(
      object.idempotencyReplayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckinActionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckinActionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'candidate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CheckinCandidateResponse),
          ) as CheckinCandidateResponse;
          result.candidate.replace(valueDes);
          break;
        case r'idempotency_replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.idempotencyReplayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckinActionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckinActionResponseBuilder();
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

