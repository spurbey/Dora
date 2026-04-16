// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdvisorySource _$reddit = const AdvisorySource._('reddit');
const AdvisorySource _$tripadvisor = const AdvisorySource._('tripadvisor');
const AdvisorySource _$googleMaps = const AdvisorySource._('googleMaps');
const AdvisorySource _$combined = const AdvisorySource._('combined');

AdvisorySource _$valueOf(String name) {
  switch (name) {
    case 'reddit':
      return _$reddit;
    case 'tripadvisor':
      return _$tripadvisor;
    case 'googleMaps':
      return _$googleMaps;
    case 'combined':
      return _$combined;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdvisorySource> _$values =
    BuiltSet<AdvisorySource>(const <AdvisorySource>[
  _$reddit,
  _$tripadvisor,
  _$googleMaps,
  _$combined,
]);

class _$AdvisorySourceMeta {
  const _$AdvisorySourceMeta();
  AdvisorySource get reddit => _$reddit;
  AdvisorySource get tripadvisor => _$tripadvisor;
  AdvisorySource get googleMaps => _$googleMaps;
  AdvisorySource get combined => _$combined;
  AdvisorySource valueOf(String name) => _$valueOf(name);
  BuiltSet<AdvisorySource> get values => _$values;
}

abstract class _$AdvisorySourceMixin {
  // ignore: non_constant_identifier_names
  _$AdvisorySourceMeta get AdvisorySource => const _$AdvisorySourceMeta();
}

Serializer<AdvisorySource> _$advisorySourceSerializer =
    _$AdvisorySourceSerializer();

class _$AdvisorySourceSerializer
    implements PrimitiveSerializer<AdvisorySource> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'reddit': 'reddit',
    'tripadvisor': 'tripadvisor',
    'googleMaps': 'google_maps',
    'combined': 'combined',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'reddit': 'reddit',
    'tripadvisor': 'tripadvisor',
    'google_maps': 'googleMaps',
    'combined': 'combined',
  };

  @override
  final Iterable<Type> types = const <Type>[AdvisorySource];
  @override
  final String wireName = 'AdvisorySource';

  @override
  Object serialize(Serializers serializers, AdvisorySource object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdvisorySource deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdvisorySource.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
