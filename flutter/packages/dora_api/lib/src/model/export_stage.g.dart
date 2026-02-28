// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_stage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExportStage _$snapshotting = const ExportStage._('snapshotting');
const ExportStage _$assetFetch = const ExportStage._('assetFetch');
const ExportStage _$rendering = const ExportStage._('rendering');
const ExportStage _$encoding = const ExportStage._('encoding');
const ExportStage _$uploading = const ExportStage._('uploading');
const ExportStage _$finalizing = const ExportStage._('finalizing');

ExportStage _$valueOf(String name) {
  switch (name) {
    case 'snapshotting':
      return _$snapshotting;
    case 'assetFetch':
      return _$assetFetch;
    case 'rendering':
      return _$rendering;
    case 'encoding':
      return _$encoding;
    case 'uploading':
      return _$uploading;
    case 'finalizing':
      return _$finalizing;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExportStage> _$values =
    BuiltSet<ExportStage>(const <ExportStage>[
  _$snapshotting,
  _$assetFetch,
  _$rendering,
  _$encoding,
  _$uploading,
  _$finalizing,
]);

class _$ExportStageMeta {
  const _$ExportStageMeta();
  ExportStage get snapshotting => _$snapshotting;
  ExportStage get assetFetch => _$assetFetch;
  ExportStage get rendering => _$rendering;
  ExportStage get encoding => _$encoding;
  ExportStage get uploading => _$uploading;
  ExportStage get finalizing => _$finalizing;
  ExportStage valueOf(String name) => _$valueOf(name);
  BuiltSet<ExportStage> get values => _$values;
}

abstract class _$ExportStageMixin {
  // ignore: non_constant_identifier_names
  _$ExportStageMeta get ExportStage => const _$ExportStageMeta();
}

Serializer<ExportStage> _$exportStageSerializer = _$ExportStageSerializer();

class _$ExportStageSerializer implements PrimitiveSerializer<ExportStage> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'snapshotting': 'snapshotting',
    'assetFetch': 'asset_fetch',
    'rendering': 'rendering',
    'encoding': 'encoding',
    'uploading': 'uploading',
    'finalizing': 'finalizing',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'snapshotting': 'snapshotting',
    'asset_fetch': 'assetFetch',
    'rendering': 'rendering',
    'encoding': 'encoding',
    'uploading': 'uploading',
    'finalizing': 'finalizing',
  };

  @override
  final Iterable<Type> types = const <Type>[ExportStage];
  @override
  final String wireName = 'ExportStage';

  @override
  Object serialize(Serializers serializers, ExportStage object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExportStage deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExportStage.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
