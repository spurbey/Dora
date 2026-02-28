//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_aspect_ratio.g.dart';

class ExportAspectRatio extends EnumClass {

  @BuiltValueEnumConst(wireName: r'9:16')
  static const ExportAspectRatio n9colon16 = _$n9colon16;
  @BuiltValueEnumConst(wireName: r'1:1')
  static const ExportAspectRatio n1colon1 = _$n1colon1;
  @BuiltValueEnumConst(wireName: r'16:9')
  static const ExportAspectRatio n16colon9 = _$n16colon9;

  static Serializer<ExportAspectRatio> get serializer => _$exportAspectRatioSerializer;

  const ExportAspectRatio._(String name): super(name);

  static BuiltSet<ExportAspectRatio> get values => _$values;
  static ExportAspectRatio valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ExportAspectRatioMixin = Object with _$ExportAspectRatioMixin;

