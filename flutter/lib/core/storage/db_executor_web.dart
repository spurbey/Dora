import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Web database connection (Flutter Web).
/// Uses sql.js-backed Drift storage persisted to IndexedDB when available,
/// volatile in-memory otherwise. Requires sql.js in web/index.html.
///
/// MVP note: same schema as native (schemaVersion 25), offline-first tables
/// work, but large media blobs should stay server-backed on web.
QueryExecutor openDbConnection() {
  return LazyDatabase(() async {
    DriftWebStorage storage;
    try {
      storage = await DriftWebStorage.indexedDbIfSupported('dora');
    } catch (_) {
      storage = DriftWebStorage.volatile();
    }
    return WebDatabase.withStorage(storage);
  });
}
