//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_delivery_status.g.dart';

class AdvisoryDeliveryStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const AdvisoryDeliveryStatus pending = _$pending;
  @BuiltValueEnumConst(wireName: r'delivered')
  static const AdvisoryDeliveryStatus delivered = _$delivered;
  @BuiltValueEnumConst(wireName: r'expired')
  static const AdvisoryDeliveryStatus expired = _$expired;

  static Serializer<AdvisoryDeliveryStatus> get serializer => _$advisoryDeliveryStatusSerializer;

  const AdvisoryDeliveryStatus._(String name): super(name);

  static BuiltSet<AdvisoryDeliveryStatus> get values => _$values;
  static AdvisoryDeliveryStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AdvisoryDeliveryStatusMixin = Object with _$AdvisoryDeliveryStatusMixin;

