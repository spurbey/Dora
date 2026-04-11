import 'package:dora/core/map/models/app_latlng.dart';

enum V2ResolverTriggerSource {
  captureCreated('capture_created'),
  resumed('network_recovered'),
  liveOpen('live_open'),
  editorOpen('editor_open');

  const V2ResolverTriggerSource(this.wireValue);
  final String wireValue;
}

enum V2ResolverAttemptResult {
  autoPlace('auto_place'),
  reviewRequired('review_required'),
  unresolved('unresolved'),
  skippedLocked('skipped_locked'),
  providerError('provider_error');

  const V2ResolverAttemptResult(this.wireValue);
  final String wireValue;
}

class V2ResolverCandidate {
  const V2ResolverCandidate({
    required this.providerPlaceId,
    required this.name,
    required this.label,
    required this.coordinates,
    required this.confidenceScore,
    required this.distanceM,
    required this.rawJson,
  });

  final String? providerPlaceId;
  final String name;
  final String? label;
  final AppLatLng coordinates;
  final double confidenceScore;
  final double distanceM;
  final Map<String, dynamic> rawJson;
}

class V2ResolverDecision {
  const V2ResolverDecision({
    required this.resolverState,
    required this.decisionSource,
    required this.placeBindKind,
    required this.placeBindId,
    required this.placeBindName,
    required this.geotagFinalReason,
    required this.resultKind,
  });

  final String resolverState;
  final String? decisionSource;
  final String? placeBindKind;
  final String? placeBindId;
  final String? placeBindName;
  final String? geotagFinalReason;
  final V2ResolverAttemptResult resultKind;
}
