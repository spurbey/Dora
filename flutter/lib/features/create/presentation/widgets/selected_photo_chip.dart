import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dora/core/media/web_capture_bytes_store.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/shared/widgets/memory_aware_image.dart';

class SelectedPhotoChip extends StatelessWidget {
  const SelectedPhotoChip({
    super.key,
    required this.path,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final memImage = memoryImageIfHot(path);
    final ImageProvider? provider;
    if (memImage != null) {
      provider = memImage;
    } else if (!kIsWeb) {
      provider = FileImage(File(path));
    } else {
      provider = null;
    }
    return Stack(
      children: [
        Container(
          width: 74,
          height: 74,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderSm,
            color: provider == null ? Colors.black12 : null,
            image: provider == null
                ? null
                : DecorationImage(
                    image: provider,
                    fit: BoxFit.cover,
                  ),
          ),
          child: provider == null
              ? const Icon(Icons.broken_image_outlined, size: 28)
              : null,
        ),
        Positioned(
          right: AppSpacing.sm,
          top: 0,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
