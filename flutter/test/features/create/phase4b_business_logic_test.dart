import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/geocoding/geocoding_provider.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/editor_state.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/domain/trip.dart';
import 'package:dora/features/create/presentation/providers/city_search_provider.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/create/presentation/providers/map_provider.dart';
import 'package:dora/features/create/presentation/screens/city_search_screen.dart';
import 'package:dora/features/create/presentation/widgets/city_detail_form.dart';
import 'package:dora/features/create/presentation/widgets/place_detail_form.dart';

class _FakeGeocodingService implements AppGeocodingService {
  _FakeGeocodingService({
    this.results = const [],
    this.throwOnSearch = false,
  });

  final List<GeocodingResult> results;
  final bool throwOnSearch;
  final List<String> searchQueries = [];

  @override
  Future<List<GeocodingResult>> searchCities(
    String query, {
    AppLatLng? proximity,
  }) async {
    searchQueries.add(query);
    if (throwOnSearch) {
      throw Exception('search failed');
    }
    return results;
  }

  @override
  Future<GeocodingResult?> reverseGeocode(AppLatLng coordinates) async {
    if (results.isEmpty) return null;
    return results.first;
  }
}

class _FakeEditorController extends EditorController {
  _FakeEditorController({
    required this.initialState,
    this.onAddPlace,
  });

  final EditorState initialState;
  final void Function(Place place)? onAddPlace;

  @override
  Future<EditorState> build(String tripId) async => initialState;

  @override
  void addPlace(Place place) {
    onAddPlace?.call(place);
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        places: [...current.places, place],
      ),
    );
  }
}

void main() {
  group('Phase 4B - City search provider', () {
    test('ignores short queries and keeps empty results', () async {
      final fakeService = _FakeGeocodingService();
      final container = ProviderContainer(overrides: [
        geocodingServiceProvider.overrideWithValue(fakeService),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(citySearchControllerProvider.notifier);
      controller.search('a');

      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(fakeService.searchQueries, isEmpty);
      expect(container.read(citySearchControllerProvider).value, isEmpty);
    });

    test('debounces rapid input and searches only latest query', () async {
      final fakeService = _FakeGeocodingService(
        results: const [
          GeocodingResult(
            name: 'Tokyo',
            country: 'Japan',
            coordinates: AppLatLng(latitude: 35.6762, longitude: 139.6503),
          ),
        ],
      );
      final container = ProviderContainer(overrides: [
        geocodingServiceProvider.overrideWithValue(fakeService),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(citySearchControllerProvider.notifier);
      controller.search('to');
      controller.search('tok');
      controller.search('tokyo');

      await Future<void>.delayed(const Duration(milliseconds: 360));

      expect(fakeService.searchQueries, ['tokyo']);
      final state = container.read(citySearchControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.requireValue.single.name, 'Tokyo');
    });

    test('exposes AsyncError when search fails', () async {
      final fakeService = _FakeGeocodingService(throwOnSearch: true);
      final container = ProviderContainer(overrides: [
        geocodingServiceProvider.overrideWithValue(fakeService),
      ]);
      addTearDown(container.dispose);

      container.read(citySearchControllerProvider.notifier).search('tokyo');
      await Future<void>.delayed(const Duration(milliseconds: 360));

      final state = container.read(citySearchControllerProvider);
      expect(state.hasError, isTrue);
    });
  });

  group('Phase 4B - Map provider projections', () {
    test('builds city/place marker styles and route colors from editor state',
        () async {
      final now = DateTime(2026, 2, 19);
      final trip = Trip(
        id: 'trip-1',
        userId: 'user-1',
        name: 'Japan',
        centerPoint: const AppLatLng(latitude: 35.6762, longitude: 139.6503),
        zoom: 11,
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );

      final city = Place(
        id: 'city-1',
        tripId: trip.id,
        name: 'Tokyo',
        coordinates: const AppLatLng(latitude: 35.6762, longitude: 139.6503),
        placeType: 'city',
        orderIndex: 0,
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );
      final placeA = Place(
        id: 'place-1',
        tripId: trip.id,
        name: 'Shibuya',
        coordinates: const AppLatLng(latitude: 35.6595, longitude: 139.7005),
        placeType: 'attraction',
        orderIndex: 1,
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );
      final placeB = Place(
        id: 'place-2',
        tripId: trip.id,
        name: 'Asakusa',
        coordinates: const AppLatLng(latitude: 35.7148, longitude: 139.7967),
        placeType: 'attraction',
        orderIndex: 2,
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );

      final routes = [
        create_route.Route(
          id: 'route-car',
          tripId: trip.id,
          coordinates: const [
            AppLatLng(latitude: 35.6762, longitude: 139.6503),
            AppLatLng(latitude: 35.6595, longitude: 139.7005),
          ],
          transportMode: 'car',
          localUpdatedAt: now,
          serverUpdatedAt: now,
        ),
        create_route.Route(
          id: 'route-foot',
          tripId: trip.id,
          coordinates: const [
            AppLatLng(latitude: 35.6595, longitude: 139.7005),
            AppLatLng(latitude: 35.7148, longitude: 139.7967),
          ],
          transportMode: 'foot',
          localUpdatedAt: now,
          serverUpdatedAt: now,
        ),
        create_route.Route(
          id: 'route-air',
          tripId: trip.id,
          coordinates: const [
            AppLatLng(latitude: 35.6762, longitude: 139.6503),
            AppLatLng(latitude: 34.6937, longitude: 135.5023),
          ],
          transportMode: 'air',
          localUpdatedAt: now,
          serverUpdatedAt: now,
        ),
      ];

      final editorState = EditorState(
        trip: trip,
        places: [placeB, city, placeA],
        routes: routes,
        mode: EditorMode.view,
        routeStartItemId: 'place-2',
      );

      final container = ProviderContainer(
        overrides: [
          editorControllerProvider(trip.id).overrideWith(
            () => _FakeEditorController(initialState: editorState),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(editorControllerProvider(trip.id).future);

      final state = container.read(mapStateProvider(trip.id));
      expect(state.markers, hasLength(3));
      expect(state.routes, hasLength(3));

      final cityMarker = state.markers.firstWhere((m) => m.id == city.id);
      expect(cityMarker.markerType, 'city');
      expect(cityMarker.label, 'C');
      expect(cityMarker.color, AppColors.primary);

      final shibuyaMarker = state.markers.firstWhere((m) => m.id == placeA.id);
      expect(shibuyaMarker.markerType, 'place');
      expect(shibuyaMarker.label, '1');
      expect(shibuyaMarker.color, AppColors.accent);

      final asakusaMarker = state.markers.firstWhere((m) => m.id == placeB.id);
      expect(asakusaMarker.label, '2');
      expect(asakusaMarker.color, const Color(0xFFE53935));

      final carRoute = state.routes.firstWhere((r) => r.id == 'route-car');
      final footRoute = state.routes.firstWhere((r) => r.id == 'route-foot');
      final airRoute = state.routes.firstWhere((r) => r.id == 'route-air');

      expect(carRoute.color, AppColors.accent);
      expect(footRoute.color, const Color(0xFFB96B2B));
      expect(airRoute.color, const Color(0xFF4F46E5));
    });
  });

  group('Phase 4B - City search screen integration', () {
    testWidgets('selecting a search result adds city as placeType=city',
        (tester) async {
      final fakeService = _FakeGeocodingService(
        results: const [
          GeocodingResult(
            name: 'Paris',
            country: 'France',
            coordinates: AppLatLng(latitude: 48.8566, longitude: 2.3522),
          ),
        ],
      );
      final now = DateTime(2026, 2, 19);
      final trip = Trip(
        id: 'trip-1',
        userId: 'user-1',
        name: 'Europe',
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );
      final addedPlaces = <Place>[];
      final initialEditorState = EditorState(trip: trip);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            geocodingServiceProvider.overrideWithValue(fakeService),
            editorControllerProvider(trip.id).overrideWith(
              () => _FakeEditorController(
                initialState: initialEditorState,
                onAddPlace: addedPlaces.add,
              ),
            ),
          ],
          child: MaterialApp(
            home: CitySearchScreen(tripId: trip.id),
          ),
        ),
      );

      expect(find.text('Search for your destination'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'paris');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 360));

      expect(find.text('Paris'), findsOneWidget);
      await tester.tap(find.text('Paris'));
      await tester.pumpAndSettle();

      expect(addedPlaces, hasLength(1));
      final created = addedPlaces.single;
      expect(created.tripId, trip.id);
      expect(created.name, 'Paris');
      expect(created.address, 'France');
      expect(created.placeType, 'city');
      expect(created.orderIndex, 0);
    });
  });

  group('Phase 4B - Detail forms save contract', () {
    testWidgets('CityDetailForm returns edited city data', (tester) async {
      final now = DateTime(2026, 2, 19);
      final city = Place(
        id: 'city-1',
        tripId: 'trip-1',
        name: 'Tokyo',
        address: 'Japan',
        coordinates: const AppLatLng(latitude: 35.6762, longitude: 139.6503),
        placeType: 'city',
        orderIndex: 0,
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );
      Place? saved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CityDetailForm(
              city: city,
              onSave: (value) => saved = value,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Kyoto');
      await tester.enterText(find.byType(TextField).last, 'Old capital');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(saved, isNotNull);
      expect(saved!.name, 'Kyoto');
      expect(saved!.notes, 'Old capital');
      expect(saved!.placeType, 'city');
    });

    testWidgets('PlaceDetailForm saves selected type, rating, visit time, notes',
        (tester) async {
      final now = DateTime(2026, 2, 19);
      final place = Place(
        id: 'place-1',
        tripId: 'trip-1',
        name: 'Louvre',
        coordinates: const AppLatLng(latitude: 48.8606, longitude: 2.3376),
        orderIndex: 1,
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );
      Place? saved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceDetailForm(
              place: place,
              onSave: (value) => saved = value,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Museum'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.star_border_rounded).first);
      await tester.pump();

      await tester.tap(find.text('Evening'));
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'Book tickets early');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(saved, isNotNull);
      expect(saved!.placeType, 'museum');
      expect(saved!.rating, 1);
      expect(saved!.visitTime, 'evening');
      expect(saved!.notes, 'Book tickets early');
    });
  });
}
