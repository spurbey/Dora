import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/map/app_map_controller.dart';
import 'package:dora/core/map/app_map_view.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/features/vault/presentation/providers/vault_marker_provider.dart';
import 'package:dora/features/vault/presentation/providers/vault_provider.dart';

/// Renders geotagged Vault media as markers on an [AppMapView]. Tapping a
/// marker sets [vaultSelectedMediaIdProvider]; when the selected id changes
/// (e.g. from the carousel), the map flies to the matching coordinate.
///
/// This is the task-19 scaffold: markers are plain camera-icon pins. Rich
/// thumbnail markers land in task 20.
class VaultMap extends ConsumerStatefulWidget {
  const VaultMap({super.key});

  @override
  ConsumerState<VaultMap> createState() => _VaultMapState();
}

class _VaultMapState extends ConsumerState<VaultMap> {
  AppMapController? _controller;

  static const AppLatLng _fallbackCenter = AppLatLng(
    latitude: 27.7172,
    longitude: 85.3240,
  );

  AppLatLng _resolveInitialCenter(List<MediaItem> geotagged) {
    if (geotagged.isEmpty) {
      return _fallbackCenter;
    }
    final first = geotagged.first;
    return AppLatLng(
      latitude: first.latitude!,
      longitude: first.longitude!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final geotagged = ref.watch(vaultGeotaggedMediaProvider);
    final markerState = ref.watch(vaultMarkerControllerProvider);

    // React to selection changes from carousel side.
    ref.listen<String?>(vaultSelectedMediaIdProvider, (_, next) {
      if (next == null) return;
      final match = geotagged.where((m) => m.id == next).firstOrNull;
      if (match == null) return;
      _controller?.flyTo(
        AppLatLng(latitude: match.latitude!, longitude: match.longitude!),
        zoom: 14,
        duration: const Duration(milliseconds: 400),
      );
    });

    final markers = geotagged
        .map(
          (media) => AppMarker(
            id: media.id,
            position: AppLatLng(
              latitude: media.latitude!,
              longitude: media.longitude!,
            ),
            // Custom thumbnail marker if rendered; fall back to the adapter's
            // default glyph marker until the bytes land.
            iconPngBytes: markerState.bytesById[media.id],
            color: AppColors.accent,
            markerType:
                markerState.bytesById.containsKey(media.id)
                    ? 'vault_media_thumb'
                    : 'vault_media',
            onTap: () => ref
                .read(vaultSelectedMediaIdProvider.notifier)
                .state = media.id,
          ),
        )
        .toList(growable: false);

    return AppMapView(
      initialCenter: _resolveInitialCenter(geotagged),
      initialZoom: geotagged.isEmpty ? 3 : 12,
      markers: markers,
      showUserLocation: true,
      showCompass: false,
      showScaleBar: false,
      onMapCreated: (controller) => _controller = controller,
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
