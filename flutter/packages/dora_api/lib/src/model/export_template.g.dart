// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_template.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExportTemplate _$classic = const ExportTemplate._('classic');
const ExportTemplate _$cinematic = const ExportTemplate._('cinematic');

ExportTemplate _$valueOf(String name) {
  switch (name) {
    case 'classic':
      return _$classic;
    case 'cinematic':
      return _$cinematic;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExportTemplate> _$values =
    BuiltSet<ExportTemplate>(const <ExportTemplate>[
  _$classic,
  _$cinematic,
]);

class _$ExportTemplateMeta {
  const _$ExportTemplateMeta();
  ExportTemplate get classic => _$classic;
  ExportTemplate get cinematic => _$cinematic;
  ExportTemplate valueOf(String name) => _$valueOf(name);
  BuiltSet<ExportTemplate> get values => _$values;
}

abstract class _$ExportTemplateMixin {
  // ignore: non_constant_identifier_names
  _$ExportTemplateMeta get ExportTemplate => const _$ExportTemplateMeta();
}

Serializer<ExportTemplate> _$exportTemplateSerializer =
    _$ExportTemplateSerializer();

class _$ExportTemplateSerializer
    implements PrimitiveSerializer<ExportTemplate> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'classic': 'classic',
    'cinematic': 'cinematic',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'classic': 'classic',
    'cinematic': 'cinematic',
  };

  @override
  final Iterable<Type> types = const <Type>[ExportTemplate];
  @override
  final String wireName = 'ExportTemplate';

  @override
  Object serialize(Serializers serializers, ExportTemplate object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExportTemplate deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExportTemplate.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
