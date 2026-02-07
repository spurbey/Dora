import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/daos/place_dao.dart';
import 'package:dora/core/storage/daos/route_dao.dart';
import 'package:dora/core/storage/daos/trip_dao.dart';
import 'package:dora/core/storage/tables/media_table.dart';
import 'package:dora/core/storage/tables/places_table.dart';
import 'package:dora/core/storage/tables/routes_table.dart';
import 'package:dora/core/storage/tables/trips_table.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [Trips, Places, Routes, Media],
  daos: [TripDao, PlaceDao, RouteDao, MediaDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations.
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
