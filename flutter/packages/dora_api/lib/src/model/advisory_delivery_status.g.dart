// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_delivery_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdvisoryDeliveryStatus _$pending =
    const AdvisoryDeliveryStatus._('pending');
const AdvisoryDeliveryStatus _$delivered =
    const AdvisoryDeliveryStatus._('delivered');
const AdvisoryDeliveryStatus _$expired =
    const AdvisoryDeliveryStatus._('expired');

AdvisoryDeliveryStatus _$valueOf(String name) {
  switch (name) {
    case 'pending':
      return _$pending;
    case 'delivered':
      return _$delivered;
    case 'expired':
      return _$expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdvisoryDeliveryStatus> _$values =
    BuiltSet<AdvisoryDeliveryStatus>(const <AdvisoryDeliveryStatus>[
  _$pending,
  _$delivered,
  _$expired,
]);

class _$AdvisoryDeliveryStatusMeta {
  const _$AdvisoryDeliveryStatusMeta();
  AdvisoryDeliveryStatus get pending => _$pending;
  AdvisoryDeliveryStatus get delivered => _$delivered;
  AdvisoryDeliveryStatus get expired => _$expired;
  AdvisoryDeliveryStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<AdvisoryDeliveryStatus> get values => _$values;
}

abstract class _$AdvisoryDeliveryStatusMixin {
  // ignore: non_constant_identifier_names
  _$AdvisoryDeliveryStatusMeta get AdvisoryDeliveryStatus =>
      const _$AdvisoryDeliveryStatusMeta();
}

Serializer<AdvisoryDeliveryStatus> _$advisoryDeliveryStatusSerializer =
    _$AdvisoryDeliveryStatusSerializer();

class _$AdvisoryDeliveryStatusSerializer
    implements PrimitiveSerializer<AdvisoryDeliveryStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'delivered': 'delivered',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'delivered': 'delivered',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[AdvisoryDeliveryStatus];
  @override
  final String wireName = 'AdvisoryDeliveryStatus';

  @override
  Object serialize(Serializers serializers, AdvisoryDeliveryStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdvisoryDeliveryStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdvisoryDeliveryStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
