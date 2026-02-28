// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_aspect_ratio.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExportAspectRatio _$n9colon16 = const ExportAspectRatio._('n9colon16');
const ExportAspectRatio _$n1colon1 = const ExportAspectRatio._('n1colon1');
const ExportAspectRatio _$n16colon9 = const ExportAspectRatio._('n16colon9');

ExportAspectRatio _$valueOf(String name) {
  switch (name) {
    case 'n9colon16':
      return _$n9colon16;
    case 'n1colon1':
      return _$n1colon1;
    case 'n16colon9':
      return _$n16colon9;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExportAspectRatio> _$values =
    BuiltSet<ExportAspectRatio>(const <ExportAspectRatio>[
  _$n9colon16,
  _$n1colon1,
  _$n16colon9,
]);

class _$ExportAspectRatioMeta {
  const _$ExportAspectRatioMeta();
  ExportAspectRatio get n9colon16 => _$n9colon16;
  ExportAspectRatio get n1colon1 => _$n1colon1;
  ExportAspectRatio get n16colon9 => _$n16colon9;
  ExportAspectRatio valueOf(String name) => _$valueOf(name);
  BuiltSet<ExportAspectRatio> get values => _$values;
}

abstract class _$ExportAspectRatioMixin {
  // ignore: non_constant_identifier_names
  _$ExportAspectRatioMeta get ExportAspectRatio =>
      const _$ExportAspectRatioMeta();
}

Serializer<ExportAspectRatio> _$exportAspectRatioSerializer =
    _$ExportAspectRatioSerializer();

class _$ExportAspectRatioSerializer
    implements PrimitiveSerializer<ExportAspectRatio> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n9colon16': '9:16',
    'n1colon1': '1:1',
    'n16colon9': '16:9',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '9:16': 'n9colon16',
    '1:1': 'n1colon1',
    '16:9': 'n16colon9',
  };

  @override
  final Iterable<Type> types = const <Type>[ExportAspectRatio];
  @override
  final String wireName = 'ExportAspectRatio';

  @override
  Object serialize(Serializers serializers, ExportAspectRatio object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExportAspectRatio deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExportAspectRatio.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
