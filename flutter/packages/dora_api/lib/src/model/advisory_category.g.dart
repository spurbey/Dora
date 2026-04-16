// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdvisoryCategory _$safetyWarning =
    const AdvisoryCategory._('safetyWarning');
const AdvisoryCategory _$scamAlert = const AdvisoryCategory._('scamAlert');
const AdvisoryCategory _$foodTip = const AdvisoryCategory._('foodTip');
const AdvisoryCategory _$photoSpot = const AdvisoryCategory._('photoSpot');
const AdvisoryCategory _$transportTip =
    const AdvisoryCategory._('transportTip');
const AdvisoryCategory _$accommodation =
    const AdvisoryCategory._('accommodation');
const AdvisoryCategory _$culturalEtiquette =
    const AdvisoryCategory._('culturalEtiquette');
const AdvisoryCategory _$mustDo = const AdvisoryCategory._('mustDo');
const AdvisoryCategory _$avoid = const AdvisoryCategory._('avoid');
const AdvisoryCategory _$generalTip = const AdvisoryCategory._('generalTip');

AdvisoryCategory _$valueOf(String name) {
  switch (name) {
    case 'safetyWarning':
      return _$safetyWarning;
    case 'scamAlert':
      return _$scamAlert;
    case 'foodTip':
      return _$foodTip;
    case 'photoSpot':
      return _$photoSpot;
    case 'transportTip':
      return _$transportTip;
    case 'accommodation':
      return _$accommodation;
    case 'culturalEtiquette':
      return _$culturalEtiquette;
    case 'mustDo':
      return _$mustDo;
    case 'avoid':
      return _$avoid;
    case 'generalTip':
      return _$generalTip;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdvisoryCategory> _$values =
    BuiltSet<AdvisoryCategory>(const <AdvisoryCategory>[
  _$safetyWarning,
  _$scamAlert,
  _$foodTip,
  _$photoSpot,
  _$transportTip,
  _$accommodation,
  _$culturalEtiquette,
  _$mustDo,
  _$avoid,
  _$generalTip,
]);

class _$AdvisoryCategoryMeta {
  const _$AdvisoryCategoryMeta();
  AdvisoryCategory get safetyWarning => _$safetyWarning;
  AdvisoryCategory get scamAlert => _$scamAlert;
  AdvisoryCategory get foodTip => _$foodTip;
  AdvisoryCategory get photoSpot => _$photoSpot;
  AdvisoryCategory get transportTip => _$transportTip;
  AdvisoryCategory get accommodation => _$accommodation;
  AdvisoryCategory get culturalEtiquette => _$culturalEtiquette;
  AdvisoryCategory get mustDo => _$mustDo;
  AdvisoryCategory get avoid => _$avoid;
  AdvisoryCategory get generalTip => _$generalTip;
  AdvisoryCategory valueOf(String name) => _$valueOf(name);
  BuiltSet<AdvisoryCategory> get values => _$values;
}

abstract class _$AdvisoryCategoryMixin {
  // ignore: non_constant_identifier_names
  _$AdvisoryCategoryMeta get AdvisoryCategory => const _$AdvisoryCategoryMeta();
}

Serializer<AdvisoryCategory> _$advisoryCategorySerializer =
    _$AdvisoryCategorySerializer();

class _$AdvisoryCategorySerializer
    implements PrimitiveSerializer<AdvisoryCategory> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'safetyWarning': 'safety_warning',
    'scamAlert': 'scam_alert',
    'foodTip': 'food_tip',
    'photoSpot': 'photo_spot',
    'transportTip': 'transport_tip',
    'accommodation': 'accommodation',
    'culturalEtiquette': 'cultural_etiquette',
    'mustDo': 'must_do',
    'avoid': 'avoid',
    'generalTip': 'general_tip',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'safety_warning': 'safetyWarning',
    'scam_alert': 'scamAlert',
    'food_tip': 'foodTip',
    'photo_spot': 'photoSpot',
    'transport_tip': 'transportTip',
    'accommodation': 'accommodation',
    'cultural_etiquette': 'culturalEtiquette',
    'must_do': 'mustDo',
    'avoid': 'avoid',
    'general_tip': 'generalTip',
  };

  @override
  final Iterable<Type> types = const <Type>[AdvisoryCategory];
  @override
  final String wireName = 'AdvisoryCategory';

  @override
  Object serialize(Serializers serializers, AdvisoryCategory object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdvisoryCategory deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdvisoryCategory.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
