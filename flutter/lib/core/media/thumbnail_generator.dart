import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ThumbnailGenerator {
  const ThumbnailGenerator();

  Future<String?> generate({
    required String sourcePath,
    required String mediaId,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw ThumbnailGenerationException(
          'Source file missing for thumbnail: $sourcePath');
    }

    final cacheDir = await getTemporaryDirectory();
    final thumbnailsDir = Directory(p.join(cacheDir.path, 'dora', 'thumbnails'));
    if (!await thumbnailsDir.exists()) {
      await thumbnailsDir.create(recursive: true);
    }

    final destinationPath = p.join(
      thumbnailsDir.path,
      '${mediaId}_thumb.jpg',
    );
    final thumb = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      destinationPath,
      quality: 72,
      minWidth: 360,
      minHeight: 360,
      format: CompressFormat.jpeg,
    );
    return thumb?.path;
  }
}

class ThumbnailGenerationException implements Exception {
  ThumbnailGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}
