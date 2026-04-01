//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/checkin_candidate_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'pending_checkins_response.g.dart';

/// PendingCheckinsResponse
///
/// Properties:
/// * [candidates] 
/// * [total] 
@BuiltValue()
abstract class PendingCheckinsResponse implements Built<PendingCheckinsResponse, PendingCheckinsResponseBuilder> {
  @BuiltValueField(wireName: r'candidates')
  BuiltList<CheckinCandidateResponse> get candidates;

  @BuiltValueField(wireName: r'total')
  int get total;

  PendingCheckinsResponse._();

  factory PendingCheckinsResponse([void updates(PendingCheckinsResponseBuilder b)]) = _$PendingCheckinsResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PendingCheckinsResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PendingCheckinsResponse> get serializer => _$PendingCheckinsResponseSerializer();
}

class _$PendingCheckinsResponseSerializer implements PrimitiveSerializer<PendingCheckinsResponse> {
  @override
  final Iterable<Type> types = const [PendingCheckinsResponse, _$PendingCheckinsResponse];

  @override
  final String wireName = r'PendingCheckinsResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PendingCheckinsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'candidates';
    yield serializers.serialize(
      object.candidates,
      specifiedType: const FullType(BuiltList, [FullType(CheckinCandidateResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PendingCheckinsResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PendingCheckinsResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'candidates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CheckinCandidateResponse)]),
          ) as BuiltList<CheckinCandidateResponse>;
          result.candidates.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PendingCheckinsResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PendingCheckinsResponseBuilder();
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

