// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_job_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdvisoryJobType _$preTrip = const AdvisoryJobType._('preTrip');
const AdvisoryJobType _$onDemand = const AdvisoryJobType._('onDemand');
const AdvisoryJobType _$locationTrigger =
    const AdvisoryJobType._('locationTrigger');

AdvisoryJobType _$valueOf(String name) {
  switch (name) {
    case 'preTrip':
      return _$preTrip;
    case 'onDemand':
      return _$onDemand;
    case 'locationTrigger':
      return _$locationTrigger;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdvisoryJobType> _$values =
    BuiltSet<AdvisoryJobType>(const <AdvisoryJobType>[
  _$preTrip,
  _$onDemand,
  _$locationTrigger,
]);

class _$AdvisoryJobTypeMeta {
  const _$AdvisoryJobTypeMeta();
  AdvisoryJobType get preTrip => _$preTrip;
  AdvisoryJobType get onDemand => _$onDemand;
  AdvisoryJobType get locationTrigger => _$locationTrigger;
  AdvisoryJobType valueOf(String name) => _$valueOf(name);
  BuiltSet<AdvisoryJobType> get values => _$values;
}

abstract class _$AdvisoryJobTypeMixin {
  // ignore: non_constant_identifier_names
  _$AdvisoryJobTypeMeta get AdvisoryJobType => const _$AdvisoryJobTypeMeta();
}

Serializer<AdvisoryJobType> _$advisoryJobTypeSerializer =
    _$AdvisoryJobTypeSerializer();

class _$AdvisoryJobTypeSerializer
    implements PrimitiveSerializer<AdvisoryJobType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'preTrip': 'pre_trip',
    'onDemand': 'on_demand',
    'locationTrigger': 'location_trigger',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pre_trip': 'preTrip',
    'on_demand': 'onDemand',
    'location_trigger': 'locationTrigger',
  };

  @override
  final Iterable<Type> types = const <Type>[AdvisoryJobType];
  @override
  final String wireName = 'AdvisoryJobType';

  @override
  Object serialize(Serializers serializers, AdvisoryJobType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdvisoryJobType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdvisoryJobType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
