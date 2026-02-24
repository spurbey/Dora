import 'package:flutter/material.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/route.dart' as create_route;

class RouteDetailForm extends StatefulWidget {
  const RouteDetailForm({
    super.key,
    required this.route,
    required this.onSave,
    required this.onDelete,
    this.startPlaceName,
    this.endPlaceName,
  });

  final create_route.Route route;
  final ValueChanged<create_route.Route> onSave;
  final VoidCallback onDelete;
  final String? startPlaceName;
  final String? endPlaceName;

  @override
  State<RouteDetailForm> createState() => _RouteDetailFormState();
}

class _RouteDetailFormState extends State<RouteDetailForm> {
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
  void didUpdateWidget(covariant RouteDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.route.id != widget.route.id) {
      _nameController.text = widget.route.name ?? '';
      _descriptionController.text = widget.route.description ?? '';
    }
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transport mode badge (read-only)
          _TransportBadge(mode: widget.route.transportMode),
          const SizedBox(height: AppSpacing.md),

          // Start → End
          if (widget.startPlaceName != null || widget.endPlaceName != null) ...[
            _RouteEndpoints(
              start: widget.startPlaceName,
              end: widget.endPlaceName,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Waypoints summary
          if (widget.route.waypoints.isNotEmpty) ...[
            _WaypointList(waypoints: widget.route.waypoints),
            const SizedBox(height: AppSpacing.md),
          ],

          // Distance & Duration
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Distance',
                  value:
                      '${widget.route.distance?.toStringAsFixed(1) ?? '--'} km',
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
          const SizedBox(height: AppSpacing.md),

          // Route name
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

          // Description
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

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Delete Route'),
              ),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int? minutes) {
    if (minutes == null) return '--';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _WaypointList extends StatelessWidget {
  const _WaypointList({required this.waypoints});

  final List<AppLatLng> waypoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allSm,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waypoints (${waypoints.length})',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (int i = 0; i < waypoints.length; i++)
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : 4,
              ),
              child: Text(
                'W${i + 1}: '
                '${waypoints[i].latitude.toStringAsFixed(5)}, '
                '${waypoints[i].longitude.toStringAsFixed(5)}',
                style: AppTypography.caption,
              ),
            ),
        ],
      ),
    );
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

class _RouteEndpoints extends StatelessWidget {
  const _RouteEndpoints({this.start, this.end});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (start != null)
            Row(
              children: [
                const Icon(Icons.trip_origin, size: 14, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    start!,
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (start != null && end != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Container(width: 2, height: 10, color: AppColors.divider),
            ),
          if (end != null)
            Row(
              children: [
                const Icon(Icons.place, size: 14, color: AppColors.error),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    end!,
                    style: AppTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
