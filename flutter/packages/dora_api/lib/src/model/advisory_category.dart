//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_category.g.dart';

class AdvisoryCategory extends EnumClass {

  @BuiltValueEnumConst(wireName: r'safety_warning')
  static const AdvisoryCategory safetyWarning = _$safetyWarning;
  @BuiltValueEnumConst(wireName: r'scam_alert')
  static const AdvisoryCategory scamAlert = _$scamAlert;
  @BuiltValueEnumConst(wireName: r'food_tip')
  static const AdvisoryCategory foodTip = _$foodTip;
  @BuiltValueEnumConst(wireName: r'photo_spot')
  static const AdvisoryCategory photoSpot = _$photoSpot;
  @BuiltValueEnumConst(wireName: r'transport_tip')
  static const AdvisoryCategory transportTip = _$transportTip;
  @BuiltValueEnumConst(wireName: r'accommodation')
  static const AdvisoryCategory accommodation = _$accommodation;
  @BuiltValueEnumConst(wireName: r'cultural_etiquette')
  static const AdvisoryCategory culturalEtiquette = _$culturalEtiquette;
  @BuiltValueEnumConst(wireName: r'must_do')
  static const AdvisoryCategory mustDo = _$mustDo;
  @BuiltValueEnumConst(wireName: r'avoid')
  static const AdvisoryCategory avoid = _$avoid;
  @BuiltValueEnumConst(wireName: r'general_tip')
  static const AdvisoryCategory generalTip = _$generalTip;

  static Serializer<AdvisoryCategory> get serializer => _$advisoryCategorySerializer;

  const AdvisoryCategory._(String name): super(name);

  static BuiltSet<AdvisoryCategory> get values => _$values;
  static AdvisoryCategory valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AdvisoryCategoryMixin = Object with _$AdvisoryCategoryMixin;

