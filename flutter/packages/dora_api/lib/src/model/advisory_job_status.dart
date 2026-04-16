//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_job_status.g.dart';

class AdvisoryJobStatus extends EnumClass {

  @BuiltValueEnumConst(wireName: r'queued')
  static const AdvisoryJobStatus queued = _$queued;
  @BuiltValueEnumConst(wireName: r'processing')
  static const AdvisoryJobStatus processing = _$processing;
  @BuiltValueEnumConst(wireName: r'cancel_requested')
  static const AdvisoryJobStatus cancelRequested = _$cancelRequested;
  @BuiltValueEnumConst(wireName: r'completed')
  static const AdvisoryJobStatus completed = _$completed;
  @BuiltValueEnumConst(wireName: r'failed')
  static const AdvisoryJobStatus failed = _$failed;
  @BuiltValueEnumConst(wireName: r'canceled')
  static const AdvisoryJobStatus canceled = _$canceled;
  @BuiltValueEnumConst(wireName: r'blocked')
  static const AdvisoryJobStatus blocked = _$blocked;

  static Serializer<AdvisoryJobStatus> get serializer => _$advisoryJobStatusSerializer;

  const AdvisoryJobStatus._(String name): super(name);

  static BuiltSet<AdvisoryJobStatus> get values => _$values;
  static AdvisoryJobStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AdvisoryJobStatusMixin = Object with _$AdvisoryJobStatusMixin;

