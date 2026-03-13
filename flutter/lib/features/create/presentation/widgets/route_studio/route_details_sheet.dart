import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;

/// Modal bottom sheet for viewing/editing route metadata (name, description).
/// Replaces `RouteDetailForm` usage inside BottomDetailPanel for routes.
class RouteDetailsSheet extends StatefulWidget {
  const RouteDetailsSheet({
    super.key,
    required this.route,
    required this.onSave,
    this.startPlaceName,
    this.endPlaceName,
  });

  final create_route.Route route;
  final ValueChanged<create_route.Route> onSave;
  final String? startPlaceName;
  final String? endPlaceName;

  @override
  State<RouteDetailsSheet> createState() => _RouteDetailsSheetState();
}

class _RouteDetailsSheetState extends State<RouteDetailsSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.route.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.route.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    widget.onSave(widget.route.copyWith(
      name: name.isEmpty ? null : name,
      description: description.isEmpty ? null : description,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text('Route Details', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),

            // Transport badge
            _TransportBadge(mode: widget.route.transportMode),
            const SizedBox(height: AppSpacing.md),

            // Endpoints (read-only)
            if (widget.startPlaceName != null ||
                widget.endPlaceName != null) ...[
              _EndpointsRow(
                start: widget.startPlaceName,
                end: widget.endPlaceName,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Distance & Duration
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Distance',
                    value: _formatDistance(widget.route.distance),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _InfoTile(
                    label: 'Duration',
                    value: _formatDuration(widget.route.duration),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Name field
            Text('Name', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Give this route a name...',
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description field
            Text('Description', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe this route...',
                border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double? km) {
    if (km == null) return '--';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return '--';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _TransportBadge extends StatelessWidget {
  const _TransportBadge({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (mode) {
      'air' => (Icons.flight, 'Flight', const Color(0xFF4F46E5)),
      'foot' || 'walk' || 'walking' => (
          Icons.directions_walk,
          'Walking',
          const Color(0xFFB96B2B)
        ),
      'bike' || 'cycling' => (
          Icons.directions_bike,
          'Cycling',
          const Color(0xFF1D9A6C)
        ),
      _ => (Icons.directions_car, 'Driving', AppColors.accent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndpointsRow extends StatelessWidget {
  const _EndpointsRow({this.start, this.end});

  final String? start;
  final String? end;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allSm,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        children: [
          const Icon(Icons.trip_origin, size: 14, color: AppColors.accent),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              start ?? '?',
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(Icons.arrow_forward, size: 14, color: AppColors.textSecondary),
          ),
          const Icon(Icons.place, size: 14, color: AppColors.error),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              end ?? '?',
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.body),
        ],
      ),
    );
  }
}
