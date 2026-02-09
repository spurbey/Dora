import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/places_table.dart';

part 'place_dao.g.dart';

@DriftAccessor(tables: [Places])
class PlaceDao extends DatabaseAccessor<AppDatabase> with _$PlaceDaoMixin {
  PlaceDao(AppDatabase db) : super(db);

  Future<List<PlaceRow>> getPlacesForTrip(String tripId) =>
      (select(places)
            ..where((p) => p.tripId.equals(tripId))
            ..orderBy([(p) => OrderingTerm.asc(p.orderIndex)]))
          .get();

  Future<PlaceRow?> getPlaceById(String id) =>
      (select(places)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertPlace(PlacesCompanion place) => into(places).insert(place);

  Future<void> insertPlaces(List<PlacesCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(places, entries);
    });
  }

  Future<bool> updatePlace(PlacesCompanion place) =>
      update(places).replace(place);

  Future<int> deletePlace(String id) =>
      (delete(places)..where((p) => p.id.equals(id))).go();

  Future<void> deletePlacesForTrip(String tripId) =>
      (delete(places)..where((p) => p.tripId.equals(tripId))).go();
}
