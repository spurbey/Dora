// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_quality.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExportQuality _$n480p = const ExportQuality._('n480p');
const ExportQuality _$n720p = const ExportQuality._('n720p');
const ExportQuality _$n1080p = const ExportQuality._('n1080p');

ExportQuality _$valueOf(String name) {
  switch (name) {
    case 'n480p':
      return _$n480p;
    case 'n720p':
      return _$n720p;
    case 'n1080p':
      return _$n1080p;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExportQuality> _$values =
    BuiltSet<ExportQuality>(const <ExportQuality>[
  _$n480p,
  _$n720p,
  _$n1080p,
]);

class _$ExportQualityMeta {
  const _$ExportQualityMeta();
  ExportQuality get n480p => _$n480p;
  ExportQuality get n720p => _$n720p;
  ExportQuality get n1080p => _$n1080p;
  ExportQuality valueOf(String name) => _$valueOf(name);
  BuiltSet<ExportQuality> get values => _$values;
}

abstract class _$ExportQualityMixin {
  // ignore: non_constant_identifier_names
  _$ExportQualityMeta get ExportQuality => const _$ExportQualityMeta();
}

Serializer<ExportQuality> _$exportQualitySerializer =
    _$ExportQualitySerializer();

class _$ExportQualitySerializer implements PrimitiveSerializer<ExportQuality> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n480p': '480p',
    'n720p': '720p',
    'n1080p': '1080p',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '480p': 'n480p',
    '720p': 'n720p',
    '1080p': 'n1080p',
  };

  @override
  final Iterable<Type> types = const <Type>[ExportQuality];
  @override
  final String wireName = 'ExportQuality';

  @override
  Object serialize(Serializers serializers, ExportQuality object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExportQuality deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExportQuality.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
