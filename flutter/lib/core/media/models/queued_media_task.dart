import 'package:flutter/foundation.dart';

import 'package:dora/core/storage/drift_database.dart';

@immutable
class QueuedMediaTask {
  const QueuedMediaTask({
    required this.id,
    required this.tripId,
    required this.placeId,
    required this.localPath,
    required this.retryCount,
    required this.workerSessionId,
  });

  final String id;
  final String tripId;
  final String placeId;
  final String localPath;
  final int retryCount;
  final String workerSessionId;

  factory QueuedMediaTask.fromRow(MediaItem row) {
    final localPath = row.localPath;
    final placeId = row.placeId;
    final workerSessionId = row.workerSessionId;

    if (localPath == null || localPath.isEmpty) {
      throw QueuedMediaTaskException(
          'Queue row ${row.id} has no localPath for upload');
    }
    if (placeId == null || placeId.isEmpty) {
      throw QueuedMediaTaskException(
          'Queue row ${row.id} has no placeId for upload');
    }
    if (workerSessionId == null || workerSessionId.isEmpty) {
      throw QueuedMediaTaskException(
          'Queue row ${row.id} is not claimed by a worker');
    }

    return QueuedMediaTask(
      id: row.id,
      tripId: row.tripId,
      placeId: placeId,
      localPath: localPath,
      retryCount: row.retryCount,
      workerSessionId: workerSessionId,
    );
  }
}

class QueuedMediaTaskException implements Exception {
  QueuedMediaTaskException(this.message);

  final String message;

  @override
  String toString() => message;
}
