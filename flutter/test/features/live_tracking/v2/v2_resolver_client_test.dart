import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_client.dart';

void main() {
  group('V2ResolverClient', () {
    test('parses ORS pelias reverse payload into normalized candidates',
        () async {
      final mockClient = MockClient((_) async {
        return http.Response(
          '''
          {
            "features": [
              {
                "geometry": {"coordinates": [85.3000, 27.7000]},
                "properties": {
                  "gid": "openstreetmap:venue:123",
                  "name": "Cafe One",
                  "label": "Cafe One, Kathmandu",
                  "confidence": 0.83,
                  "distance": 18.0
                }
              },
              {
                "geometry": {"coordinates": [85.3002, 27.7002]},
                "properties": {
                  "gid": "openstreetmap:venue:456",
                  "name": "Cafe Two",
                  "confidence": 0.72
                }
              }
            ]
          }
          ''',
          200,
        );
      });
      final client = V2ResolverClient(
        httpClient: mockClient,
        apiKeyOverride: 'test-key',
      );

      final candidates = await client.fetchReverseCandidates(
        location: const AppLatLng(latitude: 27.7, longitude: 85.3),
      );

      expect(candidates.length, 2);
      expect(candidates.first.providerPlaceId, 'openstreetmap:venue:123');
      expect(candidates.first.name, 'Cafe One');
      expect(candidates.first.confidenceScore, 0.83);
      expect(candidates.first.distanceM, 18.0);
      expect(candidates.last.name, 'Cafe Two');
      expect(candidates.last.distanceM, greaterThan(0));
    });

    test('throws when ORS key is missing', () async {
      final client = V2ResolverClient(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      await expectLater(
        () => client.fetchReverseCandidates(
          location: const AppLatLng(latitude: 27.7, longitude: 85.3),
        ),
        throwsA(isA<V2ResolverProviderException>()),
      );
    });
  });
}
