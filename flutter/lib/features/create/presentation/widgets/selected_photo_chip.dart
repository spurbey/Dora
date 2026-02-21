import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';

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
    return Stack(
      children: [
        Container(
          width: 74,
          height: 74,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderSm,
            image: DecorationImage(
              image: FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
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
