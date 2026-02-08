import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/daos/place_dao.dart';
import 'package:dora/core/storage/daos/public_trips_dao.dart';
import 'package:dora/core/storage/daos/route_dao.dart';
import 'package:dora/core/storage/daos/trip_dao.dart';
import 'package:dora/core/storage/daos/user_trips_dao.dart';
import 'package:dora/core/storage/tables/media_table.dart';
import 'package:dora/core/storage/tables/places_table.dart';
import 'package:dora/core/storage/tables/public_trips_table.dart';
import 'package:dora/core/storage/tables/routes_table.dart';
import 'package:dora/core/storage/tables/trips_table.dart';
import 'package:dora/core/storage/tables/user_trips_table.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [Trips, Places, Routes, Media, PublicTrips, UserTrips],
  daos: [
    TripDao,
    PlaceDao,
    RouteDao,
    MediaDao,
    PublicTripsDao,
    UserTripsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(publicTrips);
          }
          if (from < 3) {
            await m.createTable(userTrips);
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'dora.db'));
      return NativeDatabase(file);
    });
  }
}
