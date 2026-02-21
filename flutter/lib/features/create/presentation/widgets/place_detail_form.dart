import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';

class PlaceDetailForm extends StatefulWidget {
  const PlaceDetailForm({
    super.key,
    required this.place,
    required this.onSave,
    required this.onDelete,
    this.onManageMedia,
    this.mediaItems = const <MediaItem>[],
  });

  final Place place;
  final ValueChanged<Place> onSave;
  final VoidCallback onDelete;
  final VoidCallback? onManageMedia;
  final List<MediaItem> mediaItems;

  @override
  State<PlaceDetailForm> createState() => _PlaceDetailFormState();
}

class _PlaceDetailFormState extends State<PlaceDetailForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  String? _visitTime;
  String? _placeType;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.place.name);
    _notesController = TextEditingController(text: widget.place.notes ?? '');
    _visitTime = widget.place.visitTime;
    _placeType = widget.place.placeType;
    _rating = widget.place.rating ?? 0;
  }

  @override
  void didUpdateWidget(covariant PlaceDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.id != widget.place.id) {
      _nameController.text = widget.place.name;
      _notesController.text = widget.place.notes ?? '';
      _visitTime = widget.place.visitTime;
      _placeType = widget.place.placeType;
      _rating = widget.place.rating ?? 0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(widget.place.copyWith(
      name: _nameController.text.trim(),
      notes: _notesController.text.trim(),
      visitTime: _visitTime,
      placeType: _placeType,
      rating: _rating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final photoPreviews = _buildPhotoPreviews();

    return SingleChildScrollView(
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          TextField(
            controller: _nameController,
            style: AppTypography.h3,
            decoration: InputDecoration(
              hintText: 'Place name',
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
            ),
          ),
          if (widget.place.address != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.place.address!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Place Type
          Text('Type', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _typeChip('restaurant', 'Restaurant'),
              _typeChip('hotel', 'Hotel'),
              _typeChip('attraction', 'Attraction'),
              _typeChip('museum', 'Museum'),
              _typeChip('park', 'Park'),
              _typeChip('cafe', 'Cafe'),
              _typeChip('shopping', 'Shopping'),
              _typeChip('nightlife', 'Nightlife'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Rating
          Text('Rating', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() {
                  _rating = _rating == index + 1 ? 0 : index + 1;
                }),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    index < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: index < _rating
                        ? Colors.amber
                        : AppColors.textSecondary,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),

          // Visit Time
          Text('Visit Time', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _visitChip('Morning'),
              _visitChip('Afternoon'),
              _visitChip('Evening'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Photos
          Row(
            children: [
              Text('Photos', style: AppTypography.caption),
              const Spacer(),
              if (widget.onManageMedia != null)
                TextButton.icon(
                  onPressed: widget.onManageMedia,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                  label: const Text('Manage'),
                ),
            ],
          ),
          SizedBox(
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final preview in photoPreviews)
                  Stack(
                    children: [
                      Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.borderSm,
                          color: AppColors.surface,
                          image: DecorationImage(
                            image: preview.imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (preview.uploadStatus == 'failed')
                        Positioned(
                          top: 4,
                          right: 12,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (preview.uploadStatus != 'uploaded')
                        Positioned(
                          top: 4,
                          right: 12,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                InkWell(
                  onTap: widget.onManageMedia,
                  borderRadius: AppRadius.borderSm,
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderSm,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.add, color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Notes
          Text('Notes', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add your notes...',
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
                child: const Text('Delete Place'),
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

  List<_PhotoPreview> _buildPhotoPreviews() {
    final previews = <_PhotoPreview>[];
    final seenUrls = <String>{};

    for (final item in widget.mediaItems) {
      final provider = _imageProviderForMedia(item);
      if (provider == null) {
        continue;
      }

      previews.add(
        _PhotoPreview(
          imageProvider: provider,
          uploadStatus: item.uploadStatus,
        ),
      );

      final remoteUrl = item.url;
      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        seenUrls.add(remoteUrl);
      }
    }

    for (final url in widget.place.photoUrls) {
      if (seenUrls.contains(url)) {
        continue;
      }
      previews.add(
        _PhotoPreview(
          imageProvider: NetworkImage(url),
          uploadStatus: 'uploaded',
        ),
      );
    }

    return previews;
  }

  ImageProvider<Object>? _imageProviderForMedia(MediaItem item) {
    final thumb = item.thumbnailPath;
    if (thumb != null && thumb.isNotEmpty) {
      if (thumb.startsWith('http')) {
        return NetworkImage(thumb);
      }
      final file = File(thumb);
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

  Widget _typeChip(String value, String label) {
    final selected = _placeType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _placeType = value),
      selectedColor: AppColors.accentSoft,
      labelStyle: AppTypography.caption.copyWith(
        color: selected ? AppColors.accent : AppColors.textSecondary,
      ),
    );
  }

  Widget _visitChip(String value) {
    final selected = _visitTime == value.toLowerCase();
    return ChoiceChip(
      label: Text(value),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _visitTime = value.toLowerCase();
        });
      },
      selectedColor: AppColors.accentSoft,
      labelStyle: AppTypography.caption.copyWith(
        color: selected ? AppColors.accent : AppColors.textSecondary,
      ),
    );
  }
}

class _PhotoPreview {
  const _PhotoPreview({
    required this.imageProvider,
    required this.uploadStatus,
  });

  final ImageProvider<Object> imageProvider;
  final String uploadStatus;
}
