import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/drift_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final appDatabaseInitProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  // Force open/initialize the database at startup.
  await db.customSelect('SELECT 1').get();
});
