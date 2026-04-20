import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/capture/domain/capture_models.dart';
import 'package:dora/features/capture/domain/camera_runtime_config.dart';

class ManagedCaptureFile {
  const ManagedCaptureFile({
    required this.path,
    required this.bytesSize,
  });

  final String path;
  final int? bytesSize;
}

class MediaCaptureFileStore {
  const MediaCaptureFileStore();

  Future<ManagedCaptureFile> copyCaptureToManaged({
    required String sourcePath,
    required String mediaId,
    required CapturedMediaKind mediaKind,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('Captured file not found');
    }
    final supportDir = await getApplicationSupportDirectory();
    final targetDir = Directory(
      p.join(supportDir.path, 'dora', 'media', 'captures'),
    );
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final extension = _extensionFor(
      sourcePath: sourcePath,
      mediaKind: mediaKind,
    );
    final targetPath = p.join(targetDir.path, '$mediaId$extension');
    final copied = await source.copy(targetPath);
    final bytes = await copied.length();
    return ManagedCaptureFile(path: copied.path, bytesSize: bytes);
  }

  Future<void> cleanupTempCaptureFiles() async {
    final tempDir = await getTemporaryDirectory();
    final capturesDir = Directory(p.join(tempDir.path, 'dora', 'captures'));
    if (!await capturesDir.exists()) {
      return;
    }
    final now = DateTime.now().toUtc();
    await for (final entity in capturesDir.list(followLinks: false)) {
      if (entity is! File) continue;
      try {
        final stat = await entity.stat();
        final modified = stat.modified.toUtc();
        if (now.difference(modified) > kTempCaptureTtl) {
          await entity.delete();
        }
      } catch (_) {
        // Best effort janitor only.
      }
    }
  }

  Future<void> cleanupOrphanManagedFiles(AppDatabase db) async {
    final supportDir = await getApplicationSupportDirectory();
    final capturesDir = Directory(
      p.join(supportDir.path, 'dora', 'media', 'captures'),
    );
    if (!await capturesDir.exists()) {
      return;
    }

    final rows = await db.customSelect(
      '''
      SELECT local_uri
      FROM media
      WHERE local_uri IS NOT NULL
        AND deleted_at IS NULL
      ''',
      variables: const [],
      readsFrom: {db.media},
    ).get();
    final tracked = rows
        .map((row) => row.read<String?>('local_uri'))
        .whereType<String>()
        .toSet();

    await for (final entity in capturesDir.list(followLinks: false)) {
      if (entity is! File) continue;
      if (!tracked.contains(entity.path)) {
        try {
          await entity.delete();
        } catch (_) {
          // Best effort janitor only.
        }
      }
    }
  }

  Future<String> buildTempCapturePath({
    required CapturedMediaKind mediaKind,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final capturesDir = Directory(p.join(tempDir.path, 'dora', 'captures'));
    if (!await capturesDir.exists()) {
      await capturesDir.create(recursive: true);
    }
    final extension = mediaKind == CapturedMediaKind.video ? '.mp4' : '.jpg';
    return p.join(
      capturesDir.path,
      '${DateTime.now().microsecondsSinceEpoch}$extension',
    );
  }

  String _extensionFor({
    required String sourcePath,
    required CapturedMediaKind mediaKind,
  }) {
    final ext = p.extension(sourcePath).toLowerCase();
    if (ext.isNotEmpty) {
      return ext;
    }
    return mediaKind == CapturedMediaKind.video ? '.mp4' : '.jpg';
  }
}
