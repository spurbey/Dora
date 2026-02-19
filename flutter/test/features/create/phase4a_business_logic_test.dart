import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/route_repository.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/editor_state.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/trip.dart';

void main() {
  group('Phase 4A - Domain contracts', () {
    test('EditorMode includes city and multi-route variants', () {
      expect(EditorMode.values, contains(EditorMode.addCity));
      expect(EditorMode.values, contains(EditorMode.addRouteAir));
      expect(EditorMode.values, contains(EditorMode.addRouteCar));
      expect(EditorMode.values, contains(EditorMode.addRouteWalking));
    });

    test('Place supports placeType and rating fields', () {
      final now = DateTime(2026, 2, 19);
      final place = Place(
        id: 'place-1',
        tripId: 'trip-1',
        name: 'Tokyo',
        coordinates: const AppLatLng(latitude: 35.6762, longitude: 139.6503),
        orderIndex: 0,
        placeType: 'city',
        rating: 5,
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );

      expect(place.placeType, 'city');
      expect(place.rating, 5);
    });

    test('EditorState keeps route drawing item context', () {
      final now = DateTime(2026, 2, 19);
      final trip = Trip(
        id: 'trip-1',
        userId: 'user-1',
        name: 'Iceland',
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );

      final state = EditorState(
        trip: trip,
        routeStartItemId: 'place-1',
        routeStartItemType: 'city',
      );

      expect(state.routeStartItemId, 'place-1');
      expect(state.routeStartItemType, 'city');
    });
  });

  group('Phase 4A - Route generation rules', () {
    late AppDatabase database;
    late RouteRepository repository;

    setUpAll(() {
      database = AppDatabase();
      repository = RouteRepository(database);
    });

    tearDownAll(() async {
      await database.close();
    });

    test('ground route maps to ground category and preserves endpoints/order', () {
      final route = repository.generateRoute(
        tripId: 'trip-1',
        start: const AppLatLng(latitude: 35.6762, longitude: 139.6503),
        end: const AppLatLng(latitude: 34.6937, longitude: 135.5023),
        transportMode: 'car',
        startPlaceId: 'place-a',
        endPlaceId: 'place-b',
        orderIndex: 3,
      );

      expect(route.transportMode, 'car');
      expect(route.routeCategory, 'ground');
      expect(route.startPlaceId, 'place-a');
      expect(route.endPlaceId, 'place-b');
      expect(route.orderIndex, 3);
      expect(route.distance, isNotNull);
      expect(route.distance!, greaterThan(0));
      expect(route.duration, isNotNull);
      expect(route.duration!, greaterThan(0));
    });

    test('air route uses air category via dedicated helper', () {
      final route = repository.generateAirRoute(
        tripId: 'trip-1',
        start: const AppLatLng(latitude: 51.5072, longitude: -0.1276),
        end: const AppLatLng(latitude: 40.7128, longitude: -74.0060),
        startPlaceId: 'city-london',
        endPlaceId: 'city-nyc',
        orderIndex: 6,
      );

      expect(route.transportMode, 'air');
      expect(route.routeCategory, 'air');
      expect(route.startPlaceId, 'city-london');
      expect(route.endPlaceId, 'city-nyc');
      expect(route.orderIndex, 6);
      expect(route.coordinates.length, 2);
    });

    test('walking mode should be slower than car for same path', () {
      const start = AppLatLng(latitude: 12.9716, longitude: 77.5946);
      const end = AppLatLng(latitude: 13.0827, longitude: 80.2707);

      final carRoute = repository.generateRoute(
        tripId: 'trip-1',
        start: start,
        end: end,
        transportMode: 'car',
      );

      final walkingRoute = repository.generateRoute(
        tripId: 'trip-1',
        start: start,
        end: end,
        transportMode: 'foot',
      );

      expect(walkingRoute.duration, isNotNull);
      expect(carRoute.duration, isNotNull);
      expect(
        walkingRoute.duration!,
        greaterThan(carRoute.duration!),
        reason:
            'Business rule: walking routes must take longer than car routes.',
      );
    });
  });
}
