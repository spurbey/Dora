//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_source.g.dart';

class AdvisorySource extends EnumClass {

  @BuiltValueEnumConst(wireName: r'reddit')
  static const AdvisorySource reddit = _$reddit;
  @BuiltValueEnumConst(wireName: r'tripadvisor')
  static const AdvisorySource tripadvisor = _$tripadvisor;
  @BuiltValueEnumConst(wireName: r'google_maps')
  static const AdvisorySource googleMaps = _$googleMaps;
  @BuiltValueEnumConst(wireName: r'combined')
  static const AdvisorySource combined = _$combined;

  static Serializer<AdvisorySource> get serializer => _$advisorySourceSerializer;

  const AdvisorySource._(String name): super(name);

  static BuiltSet<AdvisorySource> get values => _$values;
  static AdvisorySource valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AdvisorySourceMixin = Object with _$AdvisorySourceMixin;

