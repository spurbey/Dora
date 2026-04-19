import 'package:flutter/foundation.dart';

import 'package:dora/core/storage/drift_database.dart';

@immutable
class QueuedMediaTask {
  const QueuedMediaTask({
    required this.id,
    required this.localUri,
    required this.retryCount,
    required this.workerSessionId,
    required this.mediaType,
    required this.originScope,
  });

  final String id;
  final String localUri;
  final int retryCount;
  final String workerSessionId;
  final String mediaType;
  final String originScope;

  factory QueuedMediaTask.fromRow(MediaItem row) {
    final localUri = row.localUri;
    final workerSessionId = row.workerSessionId;

    if (localUri == null || localUri.isEmpty) {
      throw QueuedMediaTaskException(
          'Queue row ${row.id} has no localUri for upload');
    }
    if (workerSessionId == null || workerSessionId.isEmpty) {
      throw QueuedMediaTaskException(
          'Queue row ${row.id} is not claimed by a worker');
    }

    return QueuedMediaTask(
      id: row.id,
      localUri: localUri,
      retryCount: row.retryCount,
      workerSessionId: workerSessionId,
      mediaType: row.mediaType,
      originScope: row.originScope,
    );
  }
}

class QueuedMediaTaskException implements Exception {
  QueuedMediaTaskException(this.message);

  final String message;

  @override
  String toString() => message;
}
