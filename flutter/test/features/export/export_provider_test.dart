import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/export/data/export_api.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';

void main() {
  group('exportPrecheckProvider', () {
    test('returns guard result from repository evaluation', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTrip(
        db,
        tripId: 'trip-provider-test',
        serverTripId: null,
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          exportApiProvider.overrideWithValue(_FakeExportApi()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(exportPrecheckProvider('trip-provider-test').future);

      expect(result.tripExists, isTrue);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.tripNotSynced));
    });
  });
}

Future<void> _insertTrip(
  AppDatabase database, {
  required String tripId,
  required String? serverTripId,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.trips).insert(
        TripsCompanion.insert(
          id: tripId,
          userId: 'user-1',
          name: 'Provider Test Trip',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
          serverTripId: Value(serverTripId),
        ),
      );
}

class _FakeExportApi extends ExportApi {
  _FakeExportApi() : super(Dio());
}
