import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/features/create/data/arc_generator.dart';
import 'package:dora/features/create/domain/editor_mode.dart';
import 'package:dora/features/create/domain/editor_state.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;
import 'package:dora/features/create/domain/trip.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/create/presentation/providers/map_provider.dart';
import 'package:dora/features/create/presentation/widgets/floating_tool_panel.dart';
import 'package:dora/features/create/presentation/widgets/route_detail_form.dart';

class _StaticEditorController extends EditorController {
  _StaticEditorController({required this.initialState});

  final EditorState initialState;

  @override
  Future<EditorState> build(String tripId) async => initialState;
}

class _SpyRouteDrawingEditorController extends EditorController {
  _SpyRouteDrawingEditorController({required this.initialState});

  final EditorState initialState;
  int drawRouteCalls = 0;
  String? lastStartPlaceId;
  String? lastEndPlaceId;
  EditorMode? lastCapturedMode;

  @override
  Future<EditorState> build(String tripId) async => initialState;

  @override
  Future<void> drawRoute(
    String startPlaceId,
    String endPlaceId, {
    EditorMode? capturedMode,
  }) async {
    drawRouteCalls += 1;
    lastStartPlaceId = startPlaceId;
    lastEndPlaceId = endPlaceId;
    lastCapturedMode = capturedMode;

    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final start = current.places.firstWhere((p) => p.id == startPlaceId);
    final end = current.places.firstWhere((p) => p.id == endPlaceId);
    final transportMode = switch (capturedMode ?? current.mode) {
      EditorMode.addRouteAir => 'air',
      EditorMode.addRouteWalking => 'foot',
      _ => 'car',
    };
    final now = DateTime(2026, 2, 20);
    final route = create_route.Route(
      id: 'route-$drawRouteCalls',
      tripId: current.trip.id,
      coordinates: [start.coordinates, end.coordinates],
      transportMode: transportMode,
      startPlaceId: startPlaceId,
      endPlaceId: endPlaceId,
      localUpdatedAt: now,
      serverUpdatedAt: now,
    );

    state = AsyncData(current.copyWith(
      routes: [...current.routes, route],
      selectedItemId: route.id,
      selectedItemType: 'route',
      bottomPanelExpanded: true,
      mode: EditorMode.editItem,
    ));
  }
}

Trip _trip() {
  final now = DateTime(2026, 2, 20);
  return Trip(
    id: 'trip-1',
    userId: 'user-1',
    name: 'Phase 4C',
    centerPoint: const AppLatLng(latitude: 35.0, longitude: 139.0),
    zoom: 11,
    localUpdatedAt: now,
    serverUpdatedAt: now,
  );
}

Place _place({
  required String id,
  required String name,
  required double lat,
  required double lon,
  required int orderIndex,
  String? placeType,
}) {
  final now = DateTime(2026, 2, 20);
  return Place(
    id: id,
    tripId: 'trip-1',
    name: name,
    coordinates: AppLatLng(latitude: lat, longitude: lon),
    orderIndex: orderIndex,
    placeType: placeType,
    localUpdatedAt: now,
    serverUpdatedAt: now,
  );
}

create_route.Route _route({
  required String id,
  required String mode,
  required List<AppLatLng> coords,
  String? startPlaceId,
  String? endPlaceId,
}) {
  final now = DateTime(2026, 2, 20);
  return create_route.Route(
    id: id,
    tripId: 'trip-1',
    coordinates: coords,
    transportMode: mode,
    startPlaceId: startPlaceId,
    endPlaceId: endPlaceId,
    localUpdatedAt: now,
    serverUpdatedAt: now,
  );
}

void main() {
  group('Phase 4C - Arc generator', () {
    test('generates great-circle arc with endpoints preserved', () {
      const start = AppLatLng(latitude: 35.6762, longitude: 139.6503);
      const end = AppLatLng(latitude: 37.7749, longitude: -122.4194);

      final points = ArcGenerator.generateArc(start, end, points: 20);

      expect(points, hasLength(21));
      expect(points.first.latitude, closeTo(start.latitude, 1e-6));
      expect(points.first.longitude, closeTo(start.longitude, 1e-6));
      expect(points.last.latitude, closeTo(end.latitude, 1e-6));
      expect(points.last.longitude, closeTo(end.longitude, 1e-6));
    });

    test('returns start/end when points are effectively identical', () {
      const p = AppLatLng(latitude: 48.8566, longitude: 2.3522);

      final points = ArcGenerator.generateArc(p, p, points: 50);

      expect(points, hasLength(2));
      expect(points.first, p);
      expect(points.last, p);
    });
  });

  group('Phase 4C - Editor route drawing', () {
    test('air route mode accepts only cities for start and end', () async {
      final cityA = _place(
        id: 'city-a',
        name: 'Tokyo',
        lat: 35.6762,
        lon: 139.6503,
        orderIndex: 0,
        placeType: 'city',
      );
      final placeB = _place(
        id: 'place-b',
        name: 'Shibuya',
        lat: 35.6595,
        lon: 139.7005,
        orderIndex: 1,
        placeType: 'attraction',
      );
      final cityC = _place(
        id: 'city-c',
        name: 'Osaka',
        lat: 34.6937,
        lon: 135.5023,
        orderIndex: 2,
        placeType: 'city',
      );
      final initial = EditorState(
        trip: _trip(),
        places: [cityA, placeB, cityC],
        mode: EditorMode.addRouteAir,
      );

      final container = ProviderContainer(
        overrides: [
          editorControllerProvider('trip-1').overrideWith(
            () => _SpyRouteDrawingEditorController(initialState: initial),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(editorControllerProvider('trip-1').future);

      final controller = container.read(
            editorControllerProvider('trip-1').notifier,
          ) as _SpyRouteDrawingEditorController;

      controller.handlePlaceTap(placeB.id);
      expect(
        container.read(editorControllerProvider('trip-1')).valueOrNull?.routeStartItemId,
        isNull,
      );
      expect(controller.drawRouteCalls, 0);

      controller.handlePlaceTap(cityA.id);
      expect(
        container.read(editorControllerProvider('trip-1')).valueOrNull?.routeStartItemId,
        cityA.id,
      );

      controller.handlePlaceTap(placeB.id);
      expect(
        container.read(editorControllerProvider('trip-1')).valueOrNull?.routeStartItemId,
        cityA.id,
      );
      expect(controller.drawRouteCalls, 0);

      controller.handlePlaceTap(cityC.id);
      final state = container.read(editorControllerProvider('trip-1')).valueOrNull;
      expect(controller.drawRouteCalls, 1);
      expect(controller.lastStartPlaceId, cityA.id);
      expect(controller.lastEndPlaceId, cityC.id);
      expect(controller.lastCapturedMode, EditorMode.addRouteAir);
      expect(state?.selectedItemType, 'route');
      expect(state?.bottomPanelExpanded, isTrue);
    });

    test('canceling route mode clears drafted route start selection', () async {
      final cityA = _place(
        id: 'city-a',
        name: 'Tokyo',
        lat: 35.6762,
        lon: 139.6503,
        orderIndex: 0,
        placeType: 'city',
      );
      final initial = EditorState(
        trip: _trip(),
        places: [cityA],
        mode: EditorMode.addRouteCar,
        routeStartItemId: cityA.id,
        routeStartItemType: 'city',
      );

      final container = ProviderContainer(
        overrides: [
          editorControllerProvider('trip-1').overrideWith(
            () => _StaticEditorController(initialState: initial),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(editorControllerProvider('trip-1').future);

      final controller = container.read(editorControllerProvider('trip-1').notifier);
      controller.deselectAll();
      final state = container.read(editorControllerProvider('trip-1')).valueOrNull;

      expect(state?.mode, EditorMode.view);
      expect(state?.selectedItemId, isNull);
      expect(state?.selectedItemType, isNull);
      expect(state?.routeStartItemId, isNull);
      expect(state?.routeStartItemType, isNull);
    });
  });

  group('Phase 4C - Map provider projections', () {
    test('applies route mode styles, selected width boost, and route-start marker',
        () async {
      final cityA = _place(
        id: 'city-a',
        name: 'Tokyo',
        lat: 35.6762,
        lon: 139.6503,
        orderIndex: 0,
        placeType: 'city',
      );
      final placeB = _place(
        id: 'place-b',
        name: 'Shibuya',
        lat: 35.6595,
        lon: 139.7005,
        orderIndex: 1,
        placeType: 'attraction',
      );
      final placeC = _place(
        id: 'place-c',
        name: 'Asakusa',
        lat: 35.7148,
        lon: 139.7967,
        orderIndex: 2,
        placeType: 'attraction',
      );

      final routes = [
        _route(
          id: 'r-air',
          mode: 'air',
          coords: const [
            AppLatLng(latitude: 35.6762, longitude: 139.6503),
            AppLatLng(latitude: 34.6937, longitude: 135.5023),
          ],
          startPlaceId: cityA.id,
          endPlaceId: placeC.id,
        ),
        _route(
          id: 'r-car',
          mode: 'car',
          coords: const [
            AppLatLng(latitude: 35.6595, longitude: 139.7005),
            AppLatLng(latitude: 35.7148, longitude: 139.7967),
          ],
          startPlaceId: placeB.id,
          endPlaceId: placeC.id,
        ),
      ];

      final editor = EditorState(
        trip: _trip(),
        places: [cityA, placeB, placeC],
        routes: routes,
        selectedItemId: 'r-air',
        selectedItemType: 'route',
        routeStartItemId: placeB.id,
      );

      final container = ProviderContainer(
        overrides: [
          editorControllerProvider('trip-1').overrideWith(
            () => _StaticEditorController(initialState: editor),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(editorControllerProvider('trip-1').future);

      final map = container.read(mapStateProvider('trip-1'));
      final startMarker = map.markers.firstWhere((m) => m.id == placeB.id);
      final air = map.routes.firstWhere((r) => r.id == 'r-air');
      final car = map.routes.firstWhere((r) => r.id == 'r-car');

      expect(startMarker.color, const Color(0xFFE53935));
      expect(air.color, const Color(0xFF4F46E5));
      expect(air.dashed, isTrue);
      expect(air.width, 4.0); // base 2.0, selected = 2x
      expect(car.color, AppColors.accent);
      expect(car.width, 4.0);
    });

    test('adds synthetic connection lines for sequential places without explicit routes',
        () async {
      final cityA = _place(
        id: 'city-a',
        name: 'Tokyo',
        lat: 35.6762,
        lon: 139.6503,
        orderIndex: 0,
        placeType: 'city',
      );
      final placeB = _place(
        id: 'place-b',
        name: 'Shibuya',
        lat: 35.6595,
        lon: 139.7005,
        orderIndex: 1,
      );
      final placeC = _place(
        id: 'place-c',
        name: 'Asakusa',
        lat: 35.7148,
        lon: 139.7967,
        orderIndex: 2,
      );
      final editor = EditorState(
        trip: _trip(),
        places: [cityA, placeB, placeC],
        routes: const [],
      );

      final container = ProviderContainer(
        overrides: [
          editorControllerProvider('trip-1').overrideWith(
            () => _StaticEditorController(initialState: editor),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(editorControllerProvider('trip-1').future);

      final map = container.read(mapStateProvider('trip-1'));

      // For 3 sequential places with no explicit routes, expect 2 gray connection lines.
      expect(map.routes, hasLength(2));
    });
  });

  group('Phase 4C - Route detail form contract', () {
    testWidgets('transport mode remains read-only while name/description are editable',
        (tester) async {
      final now = DateTime(2026, 2, 20);
      final route = create_route.Route(
        id: 'r-1',
        tripId: 'trip-1',
        coordinates: const [
          AppLatLng(latitude: 35.6762, longitude: 139.6503),
          AppLatLng(latitude: 34.6937, longitude: 135.5023),
        ],
        transportMode: 'air',
        distance: 396.0,
        duration: 34,
        name: 'Old name',
        description: 'Old description',
        startPlaceId: 'city-a',
        endPlaceId: 'city-b',
        localUpdatedAt: now,
        serverUpdatedAt: now,
      );
      create_route.Route? saved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteDetailForm(
              route: route,
              startPlaceName: 'Tokyo',
              endPlaceName: 'Osaka',
              onSave: (value) => saved = value,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Flight'), findsOneWidget);
      expect(find.text('Tokyo'), findsOneWidget);
      expect(find.text('Osaka'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'HND -> ITM');
      await tester.enterText(find.byType(TextField).last, 'Morning connection');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(saved, isNotNull);
      expect(saved!.transportMode, 'air');
      expect(saved!.name, 'HND -> ITM');
      expect(saved!.description, 'Morning connection');
      expect(saved!.startPlaceId, 'city-a');
      expect(saved!.endPlaceId, 'city-b');
    });
  });

  group('Phase 4C - Route tool menu', () {
    testWidgets('route tool expands and selecting Air emits addRouteAir',
        (tester) async {
      EditorMode? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingToolPanel(
              currentMode: EditorMode.view,
              onToolSelected: (mode) => selected = mode,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Route'));
      await tester.pumpAndSettle();
      expect(find.text('Air'), findsOneWidget);
      expect(find.text('Car'), findsOneWidget);
      expect(find.text('Walk'), findsOneWidget);

      await tester.tap(find.text('Air'));
      await tester.pump();
      expect(selected, EditorMode.addRouteAir);
    });
  });
}
