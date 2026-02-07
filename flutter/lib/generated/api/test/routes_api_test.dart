import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for RoutesApi
void main() {
  final instance = DoraApi().getRoutesApi();

  group(RoutesApi, () {
    // Add Waypoint
    //
    // Add waypoint to a route.
    //
    //Future<WaypointResponse> addWaypointApiV1RoutesRouteIdWaypointsPost(String routeId, String authorization, WaypointCreate waypointCreate) async
    test('test addWaypointApiV1RoutesRouteIdWaypointsPost', () async {
      // TODO
    });

    // Create Route
    //
    // Create a route for a trip.
    //
    //Future<RouteResponse> createRouteApiV1TripsTripIdRoutesPost(String tripId, String authorization, RouteCreate routeCreate) async
    test('test createRouteApiV1TripsTripIdRoutesPost', () async {
      // TODO
    });

    // Create Route Metadata
    //
    // Create metadata for a route.
    //
    //Future<RouteMetadataResponse> createRouteMetadataApiV1RoutesRouteIdMetadataPost(String routeId, String authorization, RouteMetadataCreate routeMetadataCreate) async
    test('test createRouteMetadataApiV1RoutesRouteIdMetadataPost', () async {
      // TODO
    });

    // Delete Route
    //
    // Delete a route.
    //
    //Future deleteRouteApiV1RoutesRouteIdDelete(String routeId, String authorization) async
    test('test deleteRouteApiV1RoutesRouteIdDelete', () async {
      // TODO
    });

    // Delete Route Metadata
    //
    // Delete metadata for a route.
    //
    //Future deleteRouteMetadataApiV1RoutesRouteIdMetadataDelete(String routeId, String authorization) async
    test('test deleteRouteMetadataApiV1RoutesRouteIdMetadataDelete', () async {
      // TODO
    });

    // Delete Waypoint
    //
    // Delete a waypoint.
    //
    //Future deleteWaypointApiV1WaypointsWaypointIdDelete(String waypointId, String authorization) async
    test('test deleteWaypointApiV1WaypointsWaypointIdDelete', () async {
      // TODO
    });

    // Generate Route
    //
    // Auto-generate route from coordinates using Mapbox Directions API.  Requires MAPBOX_ACCESS_TOKEN in environment.
    //
    //Future<RouteGenerateResponse> generateRouteApiV1RoutesGeneratePost(String authorization, RouteGenerateRequest routeGenerateRequest) async
    test('test generateRouteApiV1RoutesGeneratePost', () async {
      // TODO
    });

    // Get Route
    //
    // Get route details.
    //
    //Future<RouteResponse> getRouteApiV1RoutesRouteIdGet(String routeId, String authorization) async
    test('test getRouteApiV1RoutesRouteIdGet', () async {
      // TODO
    });

    // Get Route Metadata
    //
    // Get metadata for a route.
    //
    //Future<RouteMetadataResponse> getRouteMetadataApiV1RoutesRouteIdMetadataGet(String routeId, String authorization) async
    test('test getRouteMetadataApiV1RoutesRouteIdMetadataGet', () async {
      // TODO
    });

    // List Trip Routes
    //
    // List routes for a trip.
    //
    //Future<RouteListResponse> listTripRoutesApiV1TripsTripIdRoutesGet(String tripId, String authorization) async
    test('test listTripRoutesApiV1TripsTripIdRoutesGet', () async {
      // TODO
    });

    // List Waypoints
    //
    // List waypoints for a route.
    //
    //Future<WaypointListResponse> listWaypointsApiV1RoutesRouteIdWaypointsGet(String routeId, String authorization) async
    test('test listWaypointsApiV1RoutesRouteIdWaypointsGet', () async {
      // TODO
    });

    // Update Route
    //
    // Update a route.
    //
    //Future<RouteResponse> updateRouteApiV1RoutesRouteIdPatch(String routeId, String authorization, RouteUpdate routeUpdate) async
    test('test updateRouteApiV1RoutesRouteIdPatch', () async {
      // TODO
    });

    // Update Route Metadata
    //
    // Update metadata for a route.
    //
    //Future<RouteMetadataResponse> updateRouteMetadataApiV1RoutesRouteIdMetadataPatch(String routeId, String authorization, RouteMetadataUpdate routeMetadataUpdate) async
    test('test updateRouteMetadataApiV1RoutesRouteIdMetadataPatch', () async {
      // TODO
    });

    // Update Waypoint
    //
    // Update a waypoint.
    //
    //Future<WaypointResponse> updateWaypointApiV1WaypointsWaypointIdPatch(String waypointId, String authorization, WaypointUpdate waypointUpdate) async
    test('test updateWaypointApiV1WaypointsWaypointIdPatch', () async {
      // TODO
    });

  });
}
