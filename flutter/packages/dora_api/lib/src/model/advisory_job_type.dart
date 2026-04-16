//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_job_type.g.dart';

class AdvisoryJobType extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pre_trip')
  static const AdvisoryJobType preTrip = _$preTrip;
  @BuiltValueEnumConst(wireName: r'on_demand')
  static const AdvisoryJobType onDemand = _$onDemand;
  @BuiltValueEnumConst(wireName: r'location_trigger')
  static const AdvisoryJobType locationTrigger = _$locationTrigger;

  static Serializer<AdvisoryJobType> get serializer => _$advisoryJobTypeSerializer;

  const AdvisoryJobType._(String name): super(name);

  static BuiltSet<AdvisoryJobType> get values => _$values;
  static AdvisoryJobType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AdvisoryJobTypeMixin = Object with _$AdvisoryJobTypeMixin;

