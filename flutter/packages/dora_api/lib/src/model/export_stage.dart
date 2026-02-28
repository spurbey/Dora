//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_stage.g.dart';

class ExportStage extends EnumClass {

  @BuiltValueEnumConst(wireName: r'snapshotting')
  static const ExportStage snapshotting = _$snapshotting;
  @BuiltValueEnumConst(wireName: r'asset_fetch')
  static const ExportStage assetFetch = _$assetFetch;
  @BuiltValueEnumConst(wireName: r'rendering')
  static const ExportStage rendering = _$rendering;
  @BuiltValueEnumConst(wireName: r'encoding')
  static const ExportStage encoding = _$encoding;
  @BuiltValueEnumConst(wireName: r'uploading')
  static const ExportStage uploading = _$uploading;
  @BuiltValueEnumConst(wireName: r'finalizing')
  static const ExportStage finalizing = _$finalizing;

  static Serializer<ExportStage> get serializer => _$exportStageSerializer;

  const ExportStage._(String name): super(name);

  static BuiltSet<ExportStage> get values => _$values;
  static ExportStage valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ExportStageMixin = Object with _$ExportStageMixin;

