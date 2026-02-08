import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';

class TripContextMenu extends StatelessWidget {
  const TripContextMenu({
    super.key,
    required this.trip,
    required this.onEdit,
    required this.onDuplicate,
    required this.onShare,
    required this.onExport,
    required this.onDelete,
  });

  final UserTrip trip;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onShare;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trip.name, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          _MenuItem(
            icon: Icons.edit,
            label: 'Edit',
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          _MenuItem(
            icon: Icons.content_copy,
            label: 'Duplicate',
            onTap: () {
              Navigator.pop(context);
              onDuplicate();
            },
          ),
          _MenuItem(
            icon: Icons.share,
            label: trip.visibility == 'public' ? 'Make Private' : 'Share',
            onTap: () {
              Navigator.pop(context);
              onShare();
            },
          ),
          _MenuItem(
            icon: Icons.movie,
            label: 'Export Video',
            onTap: () {
              Navigator.pop(context);
              onExport();
            },
          ),
          const Divider(height: AppSpacing.xl),
          _MenuItem(
            icon: Icons.delete,
            label: 'Delete',
            color: AppColors.error,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: foreground),
      title: Text(
        label,
        style: AppTypography.body.copyWith(color: foreground),
      ),
      onTap: onTap,
    );
  }
}
