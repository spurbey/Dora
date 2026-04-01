//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/checkin_place_override.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkin_confirm_request.g.dart';

/// CheckinConfirmRequest
///
/// Properties:
/// * [clientEventId] 
/// * [confirmedAt] 
/// * [placeOverride] 
@BuiltValue()
abstract class CheckinConfirmRequest implements Built<CheckinConfirmRequest, CheckinConfirmRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'confirmed_at')
  DateTime get confirmedAt;

  @BuiltValueField(wireName: r'place_override')
  CheckinPlaceOverride? get placeOverride;

  CheckinConfirmRequest._();

  factory CheckinConfirmRequest([void updates(CheckinConfirmRequestBuilder b)]) = _$CheckinConfirmRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckinConfirmRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckinConfirmRequest> get serializer => _$CheckinConfirmRequestSerializer();
}

class _$CheckinConfirmRequestSerializer implements PrimitiveSerializer<CheckinConfirmRequest> {
  @override
  final Iterable<Type> types = const [CheckinConfirmRequest, _$CheckinConfirmRequest];

  @override
  final String wireName = r'CheckinConfirmRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckinConfirmRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'confirmed_at';
    yield serializers.serialize(
      object.confirmedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.placeOverride != null) {
      yield r'place_override';
      yield serializers.serialize(
        object.placeOverride,
        specifiedType: const FullType.nullable(CheckinPlaceOverride),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckinConfirmRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckinConfirmRequestBuilder result,
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
        case r'confirmed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.confirmedAt = valueDes;
          break;
        case r'place_override':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CheckinPlaceOverride),
          ) as CheckinPlaceOverride?;
          if (valueDes == null) continue;
          result.placeOverride.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckinConfirmRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckinConfirmRequestBuilder();
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

