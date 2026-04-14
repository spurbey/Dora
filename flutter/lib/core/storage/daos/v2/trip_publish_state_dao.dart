import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/trip_publish_state_table.dart';

part 'trip_publish_state_dao.g.dart';

@DriftAccessor(tables: [TripPublishState])
class TripPublishStateDao extends DatabaseAccessor<AppDatabase>
    with _$TripPublishStateDaoMixin {
  TripPublishStateDao(super.db);

  Future<TripPublishStateRow?> getState(String tripLocalId) =>
      (select(tripPublishState)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..limit(1))
          .getSingleOrNull();

  Future<int> upsertState(TripPublishStateCompanion row) =>
      into(tripPublishState).insertOnConflictUpdate(row);

  Stream<TripPublishStateRow?> watchState(String tripLocalId) =>
      (select(tripPublishState)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..limit(1))
          .watchSingleOrNull();
}
