import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Native (Android/iOS/desktop) database connection.
/// Web uses db_executor_web.dart via conditional import in drift_database.dart.
QueryExecutor openDbConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dora.db'));
    return NativeDatabase(file);
  });
}
