//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_job_stage.g.dart';

class AdvisoryJobStage extends EnumClass {

  @BuiltValueEnumConst(wireName: r'route_segmentation')
  static const AdvisoryJobStage routeSegmentation = _$routeSegmentation;
  @BuiltValueEnumConst(wireName: r'reddit_scrape')
  static const AdvisoryJobStage redditScrape = _$redditScrape;
  @BuiltValueEnumConst(wireName: r'tripadvisor_scrape')
  static const AdvisoryJobStage tripadvisorScrape = _$tripadvisorScrape;
  @BuiltValueEnumConst(wireName: r'gmaps_scrape')
  static const AdvisoryJobStage gmapsScrape = _$gmapsScrape;
  @BuiltValueEnumConst(wireName: r'llm_extraction')
  static const AdvisoryJobStage llmExtraction = _$llmExtraction;
  @BuiltValueEnumConst(wireName: r'scoring')
  static const AdvisoryJobStage scoring = _$scoring;
  @BuiltValueEnumConst(wireName: r'delivery')
  static const AdvisoryJobStage delivery = _$delivery;

  static Serializer<AdvisoryJobStage> get serializer => _$advisoryJobStageSerializer;

  const AdvisoryJobStage._(String name): super(name);

  static BuiltSet<AdvisoryJobStage> get values => _$values;
  static AdvisoryJobStage valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class AdvisoryJobStageMixin = Object with _$AdvisoryJobStageMixin;

