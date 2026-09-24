import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';

import 'package:dora/core/media/media_permissions.dart';
import 'package:dora/core/theme/app_colors.dart';

enum GalleryPickerMediaFilter {
  images,
  videos,
  imagesAndVideos,
}

enum GalleryPickerLaunchContext {
  fab,
  liveTracking,
  tripUpload,
  legacyCapture,
}

enum GallerySelectionKind {
  photo,
  video,
}

class GalleryPickerRequest {
  const GalleryPickerRequest({
    required this.allowedMedia,
    required this.maxSelection,
    required this.launchContext,
    this.preselectedAssetIds = const <String>{},
  }) : assert(maxSelection > 0, 'maxSelection must be greater than 0');

  final GalleryPickerMediaFilter allowedMedia;
  final int maxSelection;
  final GalleryPickerLaunchContext launchContext;
  final Set<String> preselectedAssetIds;
}

class GalleryPickerSelection {
  const GalleryPickerSelection({
    required this.path,
    required this.kind,
    required this.assetId,
  });

  final String path;
  final GallerySelectionKind kind;
  final String assetId;
}

class GalleryPickerResult {
  const GalleryPickerResult({
    required this.assets,
  });

  final List<GalleryPickerSelection> assets;
}

class CustomGalleryPicker {
  const CustomGalleryPicker({
    MediaPermissions permissions = const MediaPermissions(),
  }) : _permissions = permissions;

  final MediaPermissions _permissions;

  Future<GalleryPickerResult?> pick({
    required BuildContext context,
    required GalleryPickerRequest request,
  }) async {
    // Web + iOS use the image_picker fallback (browser file picker on web).
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return _pickWithImagePickerFallback(request);
    }
    return _pickWithInstaAssetsPicker(
      context: context,
      request: request,
    );
  }

  Future<GalleryPickerResult?> _pickWithInstaAssetsPicker({
    required BuildContext context,
    required GalleryPickerRequest request,
  }) async {
    final selectedAssets = await _resolvePreselectedAssets(
      request.preselectedAssetIds,
    );
    if (!context.mounted) return null;
    var permissionDenied = false;
    String? deniedMessage;

    final assets = await InstaAssetPicker.pickAssets(
      context,
      useRootNavigator: false,
      requestType: _requestType(request.allowedMedia),
      maxAssets: request.maxSelection,
      selectedAssets: selectedAssets,
      pickerConfig: InstaAssetPickerConfig(
        title: _titleForContext(request.launchContext),
        closeOnComplete: true,
        skipCropOnComplete: true,
        themeColor: AppColors.accent,
      ),
      onCompleted: (_) {},
      onPermissionDenied: (_, delegateDescription) {
        permissionDenied = true;
        deniedMessage = delegateDescription;
      },
    );

    if (!context.mounted) return null;
    if (permissionDenied) {
      final retry = await _showPermissionDialog(
        context: context,
        message: deniedMessage ??
            'Gallery permission is required. Allow photos/videos access to continue.',
      );
      if (retry && context.mounted) {
        return _pickWithInstaAssetsPicker(
          context: context,
          request: request,
        );
      }
      return null;
    }
    if (assets == null || assets.isEmpty) {
      return null;
    }

    final selections = <GalleryPickerSelection>[];
    for (final asset in assets) {
      final file = await asset.file;
      final path = file?.path.trim() ?? '';
      if (path.isEmpty) continue;
      selections.add(
        GalleryPickerSelection(
          path: path,
          kind: asset.type == AssetType.video
              ? GallerySelectionKind.video
              : GallerySelectionKind.photo,
          assetId: asset.id,
        ),
      );
    }
    if (selections.isEmpty) {
      return null;
    }
    return GalleryPickerResult(assets: selections);
  }

  Future<List<AssetEntity>> _resolvePreselectedAssets(Set<String> ids) async {
    if (ids.isEmpty) return const <AssetEntity>[];
    final assets = <AssetEntity>[];
    for (final id in ids) {
      final asset = await AssetEntity.fromId(id);
      if (asset != null) {
        assets.add(asset);
      }
    }
    return assets;
  }

  RequestType _requestType(GalleryPickerMediaFilter mediaFilter) {
    switch (mediaFilter) {
      case GalleryPickerMediaFilter.images:
        return RequestType.image;
      case GalleryPickerMediaFilter.videos:
        return RequestType.video;
      case GalleryPickerMediaFilter.imagesAndVideos:
        return RequestType.common;
    }
  }

  String _titleForContext(GalleryPickerLaunchContext context) {
    switch (context) {
      case GalleryPickerLaunchContext.fab:
        return 'Select from Gallery';
      case GalleryPickerLaunchContext.liveTracking:
        return 'Attach from Gallery';
      case GalleryPickerLaunchContext.tripUpload:
        return 'Pick Trip Photos';
      case GalleryPickerLaunchContext.legacyCapture:
        return 'Select Media';
    }
  }

  Future<bool> _showPermissionDialog({
    required BuildContext context,
    required String message,
  }) async {
    final action = await showDialog<_PermissionAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_PermissionAction.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_PermissionAction.tryAgain),
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_PermissionAction.openSettings),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    if (action == _PermissionAction.openSettings) {
      await _permissions.openSettings();
      return false;
    }
    return action == _PermissionAction.tryAgain;
  }

  Future<GalleryPickerResult?> _pickWithImagePickerFallback(
    GalleryPickerRequest request,
  ) async {
    final picker = ImagePicker();
    switch (request.allowedMedia) {
      case GalleryPickerMediaFilter.images:
        if (request.maxSelection > 1) {
          final picked = await picker.pickMultiImage(imageQuality: 92);
          if (picked.isEmpty) return null;
          return GalleryPickerResult(
            assets: picked
                .take(request.maxSelection)
                .where((file) => file.path.trim().isNotEmpty)
                .map(
                  (file) => GalleryPickerSelection(
                    path: file.path,
                    kind: GallerySelectionKind.photo,
                    assetId: file.path,
                  ),
                )
                .toList(growable: false),
          );
        }
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked == null || picked.path.trim().isEmpty) {
          return null;
        }
        return GalleryPickerResult(
          assets: [
            GalleryPickerSelection(
              path: picked.path,
              kind: GallerySelectionKind.photo,
              assetId: picked.path,
            ),
          ],
        );
      case GalleryPickerMediaFilter.videos:
        final picked = await picker.pickVideo(source: ImageSource.gallery);
        if (picked == null || picked.path.trim().isEmpty) {
          return null;
        }
        return GalleryPickerResult(
          assets: [
            GalleryPickerSelection(
              path: picked.path,
              kind: GallerySelectionKind.video,
              assetId: picked.path,
            ),
          ],
        );
      case GalleryPickerMediaFilter.imagesAndVideos:
        final picked = await picker.pickMedia(imageQuality: 92);
        if (picked == null || picked.path.trim().isEmpty) {
          return null;
        }
        final lower = picked.path.toLowerCase();
        final isVideo = lower.endsWith('.mp4') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.m4v');
        return GalleryPickerResult(
          assets: [
            GalleryPickerSelection(
              path: picked.path,
              kind: isVideo
                  ? GallerySelectionKind.video
                  : GallerySelectionKind.photo,
              assetId: picked.path,
            ),
          ],
        );
    }
  }
}

enum _PermissionAction {
  cancel,
  tryAgain,
  openSettings,
}
