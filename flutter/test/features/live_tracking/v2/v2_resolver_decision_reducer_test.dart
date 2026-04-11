import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_decision_reducer.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';

void main() {
  group('V2ResolverDecisionReducer', () {
    const reducer = V2ResolverDecisionReducer();

    test('returns auto place for unique high-confidence close candidate', () {
      final decision = reducer.reduce(
        const [
          V2ResolverCandidate(
            providerPlaceId: 'gid:1',
            name: 'Cafe',
            label: 'Cafe Label',
            coordinates: AppLatLng(latitude: 27.7, longitude: 85.3),
            confidenceScore: 0.91,
            distanceM: 25,
            rawJson: <String, dynamic>{},
          ),
          V2ResolverCandidate(
            providerPlaceId: 'gid:2',
            name: 'Bakery',
            label: 'Bakery Label',
            coordinates: AppLatLng(latitude: 27.7001, longitude: 85.3001),
            confidenceScore: 0.72,
            distanceM: 33,
            rawJson: <String, dynamic>{},
          ),
        ],
      );

      expect(decision.resolverState, 'place_bound');
      expect(decision.decisionSource, 'auto_high_confidence');
      expect(decision.resultKind, V2ResolverAttemptResult.autoPlace);
    });

    test('returns review required for ambiguous tie', () {
      final decision = reducer.reduce(
        const [
          V2ResolverCandidate(
            providerPlaceId: 'gid:1',
            name: 'Cafe A',
            label: 'A',
            coordinates: AppLatLng(latitude: 27.7, longitude: 85.3),
            confidenceScore: 0.72,
            distanceM: 40,
            rawJson: <String, dynamic>{},
          ),
          V2ResolverCandidate(
            providerPlaceId: 'gid:2',
            name: 'Cafe B',
            label: 'B',
            coordinates: AppLatLng(latitude: 27.7002, longitude: 85.3002),
            confidenceScore: 0.71,
            distanceM: 45,
            rawJson: <String, dynamic>{},
          ),
        ],
      );

      expect(decision.resolverState, 'review_required');
      expect(decision.resultKind, V2ResolverAttemptResult.reviewRequired);
    });

    test('returns unresolved for weak candidate set', () {
      final decision = reducer.reduce(
        const [
          V2ResolverCandidate(
            providerPlaceId: 'gid:1',
            name: 'Far Place',
            label: 'Far',
            coordinates: AppLatLng(latitude: 27.7, longitude: 85.3),
            confidenceScore: 0.41,
            distanceM: 240,
            rawJson: <String, dynamic>{},
          ),
        ],
      );

      expect(decision.resolverState, 'geotag_unresolved');
      expect(decision.resultKind, V2ResolverAttemptResult.unresolved);
    });
  });
}
