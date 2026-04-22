import 'package:drift/drift.dart';

@TableIndex(
  name: 'route_segment_claim_local_trip_segment_idx',
  columns: {#tripLocalId, #routeSegmentKey},
)
@TableIndex(
  name: 'route_segment_claim_local_trip_manual_route_idx',
  columns: {#tripLocalId, #manualRouteId},
)
@DataClassName('RouteSegmentClaimLocalRow')
class RouteSegmentClaimLocal extends Table {
  @override
  String get tableName => 'route_segment_claim_local';

  TextColumn get tripLocalId => text()();
  TextColumn get manualRouteId => text()();
  TextColumn get routeSegmentKey => text()();
  TextColumn get claimSource => text()();
  RealColumn get confidence => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {
        tripLocalId,
        manualRouteId,
        routeSegmentKey,
      };
}
