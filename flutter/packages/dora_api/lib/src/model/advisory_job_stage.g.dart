// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_job_stage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdvisoryJobStage _$routeSegmentation =
    const AdvisoryJobStage._('routeSegmentation');
const AdvisoryJobStage _$redditScrape =
    const AdvisoryJobStage._('redditScrape');
const AdvisoryJobStage _$tripadvisorScrape =
    const AdvisoryJobStage._('tripadvisorScrape');
const AdvisoryJobStage _$gmapsScrape = const AdvisoryJobStage._('gmapsScrape');
const AdvisoryJobStage _$llmExtraction =
    const AdvisoryJobStage._('llmExtraction');
const AdvisoryJobStage _$scoring = const AdvisoryJobStage._('scoring');
const AdvisoryJobStage _$delivery = const AdvisoryJobStage._('delivery');

AdvisoryJobStage _$valueOf(String name) {
  switch (name) {
    case 'routeSegmentation':
      return _$routeSegmentation;
    case 'redditScrape':
      return _$redditScrape;
    case 'tripadvisorScrape':
      return _$tripadvisorScrape;
    case 'gmapsScrape':
      return _$gmapsScrape;
    case 'llmExtraction':
      return _$llmExtraction;
    case 'scoring':
      return _$scoring;
    case 'delivery':
      return _$delivery;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdvisoryJobStage> _$values =
    BuiltSet<AdvisoryJobStage>(const <AdvisoryJobStage>[
  _$routeSegmentation,
  _$redditScrape,
  _$tripadvisorScrape,
  _$gmapsScrape,
  _$llmExtraction,
  _$scoring,
  _$delivery,
]);

class _$AdvisoryJobStageMeta {
  const _$AdvisoryJobStageMeta();
  AdvisoryJobStage get routeSegmentation => _$routeSegmentation;
  AdvisoryJobStage get redditScrape => _$redditScrape;
  AdvisoryJobStage get tripadvisorScrape => _$tripadvisorScrape;
  AdvisoryJobStage get gmapsScrape => _$gmapsScrape;
  AdvisoryJobStage get llmExtraction => _$llmExtraction;
  AdvisoryJobStage get scoring => _$scoring;
  AdvisoryJobStage get delivery => _$delivery;
  AdvisoryJobStage valueOf(String name) => _$valueOf(name);
  BuiltSet<AdvisoryJobStage> get values => _$values;
}

abstract class _$AdvisoryJobStageMixin {
  // ignore: non_constant_identifier_names
  _$AdvisoryJobStageMeta get AdvisoryJobStage => const _$AdvisoryJobStageMeta();
}

Serializer<AdvisoryJobStage> _$advisoryJobStageSerializer =
    _$AdvisoryJobStageSerializer();

class _$AdvisoryJobStageSerializer
    implements PrimitiveSerializer<AdvisoryJobStage> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'routeSegmentation': 'route_segmentation',
    'redditScrape': 'reddit_scrape',
    'tripadvisorScrape': 'tripadvisor_scrape',
    'gmapsScrape': 'gmaps_scrape',
    'llmExtraction': 'llm_extraction',
    'scoring': 'scoring',
    'delivery': 'delivery',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'route_segmentation': 'routeSegmentation',
    'reddit_scrape': 'redditScrape',
    'tripadvisor_scrape': 'tripadvisorScrape',
    'gmaps_scrape': 'gmapsScrape',
    'llm_extraction': 'llmExtraction',
    'scoring': 'scoring',
    'delivery': 'delivery',
  };

  @override
  final Iterable<Type> types = const <Type>[AdvisoryJobStage];
  @override
  final String wireName = 'AdvisoryJobStage';

  @override
  Object serialize(Serializers serializers, AdvisoryJobStage object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdvisoryJobStage deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdvisoryJobStage.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
