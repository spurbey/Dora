import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';

class PhotoGridItem extends StatelessWidget {
  const PhotoGridItem({
    super.key,
    required this.item,
    this.onTap,
  });

  final MediaItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage(item);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderSm,
      child: ClipRRect(
        borderRadius: AppRadius.borderSm,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image == null)
              const ColoredBox(
                color: AppColors.surface,
                child: Icon(Icons.broken_image_outlined),
              )
            else
              Image(
                image: image,
                fit: BoxFit.cover,
              ),
            if (item.uploadStatus == 'uploading' ||
                item.uploadStatus == 'compressing' ||
                item.uploadStatus == 'queued')
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: item.uploadStatus == 'queued' ? null : item.uploadProgress,
                  minHeight: 3,
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object>? _resolveImage(MediaItem item) {
    final thumbnail = item.thumbnailPath;
    if (thumbnail != null && thumbnail.isNotEmpty) {
      if (thumbnail.startsWith('http')) {
        return NetworkImage(thumbnail);
      }
      final file = File(thumbnail);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    final localPath = item.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    final url = item.url;
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return null;
  }
}
