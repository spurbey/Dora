//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_quality.g.dart';

class ExportQuality extends EnumClass {

  @BuiltValueEnumConst(wireName: r'480p')
  static const ExportQuality n480p = _$n480p;
  @BuiltValueEnumConst(wireName: r'720p')
  static const ExportQuality n720p = _$n720p;
  @BuiltValueEnumConst(wireName: r'1080p')
  static const ExportQuality n1080p = _$n1080p;

  static Serializer<ExportQuality> get serializer => _$exportQualitySerializer;

  const ExportQuality._(String name): super(name);

  static BuiltSet<ExportQuality> get values => _$values;
  static ExportQuality valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ExportQualityMixin = Object with _$ExportQualityMixin;

