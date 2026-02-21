import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

@immutable
class CompressedImageResult {
  const CompressedImageResult({
    required this.file,
    required this.isTemporary,
  });

  final File file;
  final bool isTemporary;
}

class ImageCompressor {
  const ImageCompressor();

  Future<CompressedImageResult> compress({
    required String inputPath,
    required String mediaId,
  }) async {
    final source = File(inputPath);
    if (!await source.exists()) {
      throw ImageCompressionException(
          'Source file missing for compression: $inputPath');
    }

    final tempDir = await getTemporaryDirectory();
    final mediaTempDir = Directory(p.join(tempDir.path, 'dora', 'media'));
    if (!await mediaTempDir.exists()) {
      await mediaTempDir.create(recursive: true);
    }

    final destinationPath = p.join(
      mediaTempDir.path,
      '${mediaId}_compressed.jpg',
    );
    final compressed = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      destinationPath,
      quality: 85,
      minWidth: 1920,
      minHeight: 1080,
      format: CompressFormat.jpeg,
      keepExif: true,
    );

    if (compressed == null) {
      return CompressedImageResult(file: source, isTemporary: false);
    }

    return CompressedImageResult(
      file: File(compressed.path),
      isTemporary: compressed.path != source.path,
    );
  }
}

class ImageCompressionException implements Exception {
  ImageCompressionException(this.message);

  final String message;

  @override
  String toString() => message;
}
