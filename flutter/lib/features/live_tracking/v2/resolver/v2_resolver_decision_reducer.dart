import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';

class V2ResolverDecisionReducer {
  const V2ResolverDecisionReducer({
    this.confidenceMin = 0.60,
    this.uniqueMarginMin = 0.05,
    this.tieEpsilon = 0.02,
    this.distanceMaxM = 100.0,
  });

  final double confidenceMin;
  final double uniqueMarginMin;
  final double tieEpsilon;
  final double distanceMaxM;

  V2ResolverDecision reduce(List<V2ResolverCandidate> candidates) {
    if (candidates.isEmpty) {
      return const V2ResolverDecision(
        resolverState: 'geotag_unresolved',
        decisionSource: null,
        placeBindKind: null,
        placeBindId: null,
        placeBindName: null,
        geotagFinalReason: null,
        resultKind: V2ResolverAttemptResult.unresolved,
      );
    }

    final top = candidates.first;
    final topScore = top.confidenceScore;
    final topDistance = top.distanceM;
    final secondScore =
        candidates.length > 1 ? candidates[1].confidenceScore : double.nan;
    final margin = candidates.length > 1 ? topScore - secondScore : 1.0;
    final isTie =
        candidates.length > 1 && (topScore - secondScore).abs() <= tieEpsilon;
    final hasQuality = topScore >= confidenceMin && topDistance <= distanceMaxM;

    if (hasQuality && margin >= uniqueMarginMin && !isTie) {
      return V2ResolverDecision(
        resolverState: 'place_bound',
        decisionSource: 'auto_high_confidence',
        placeBindKind: 'provider_poi',
        placeBindId: top.providerPlaceId,
        placeBindName: top.name,
        geotagFinalReason: null,
        resultKind: V2ResolverAttemptResult.autoPlace,
      );
    }

    if (topScore >= confidenceMin && isTie) {
      return const V2ResolverDecision(
        resolverState: 'review_required',
        decisionSource: null,
        placeBindKind: null,
        placeBindId: null,
        placeBindName: null,
        geotagFinalReason: null,
        resultKind: V2ResolverAttemptResult.reviewRequired,
      );
    }

    return const V2ResolverDecision(
      resolverState: 'geotag_unresolved',
      decisionSource: null,
      placeBindKind: null,
      placeBindId: null,
      placeBindName: null,
      geotagFinalReason: null,
      resultKind: V2ResolverAttemptResult.unresolved,
    );
  }
}
