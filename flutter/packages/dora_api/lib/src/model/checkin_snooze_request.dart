//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkin_snooze_request.g.dart';

/// CheckinSnoozeRequest
///
/// Properties:
/// * [clientEventId] 
/// * [snoozedUntil] 
@BuiltValue()
abstract class CheckinSnoozeRequest implements Built<CheckinSnoozeRequest, CheckinSnoozeRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'snoozed_until')
  DateTime get snoozedUntil;

  CheckinSnoozeRequest._();

  factory CheckinSnoozeRequest([void updates(CheckinSnoozeRequestBuilder b)]) = _$CheckinSnoozeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckinSnoozeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckinSnoozeRequest> get serializer => _$CheckinSnoozeRequestSerializer();
}

class _$CheckinSnoozeRequestSerializer implements PrimitiveSerializer<CheckinSnoozeRequest> {
  @override
  final Iterable<Type> types = const [CheckinSnoozeRequest, _$CheckinSnoozeRequest];

  @override
  final String wireName = r'CheckinSnoozeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckinSnoozeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'snoozed_until';
    yield serializers.serialize(
      object.snoozedUntil,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckinSnoozeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckinSnoozeRequestBuilder result,
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
        case r'snoozed_until':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.snoozedUntil = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckinSnoozeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckinSnoozeRequestBuilder();
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

