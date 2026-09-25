import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/media/thumbnail_generator.dart';
import 'package:dora/core/media/web_capture_bytes_store.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/vault/presentation/providers/vault_provider.dart';
import 'package:dora/features/vault/presentation/utils/thumbnail_marker_renderer.dart';

/// One renderer per session — the LRU lives for the process lifetime so the
/// Vault tab can close/reopen without repaying the render cost.
final thumbnailMarkerRendererProvider = Provider<ThumbnailMarkerRenderer>(
  (ref) {
    final renderer = ThumbnailMarkerRenderer();
    ref.onDispose(renderer.clear);
    return renderer;
  },
);

/// Thumbnail generator singleton.
final _thumbnailGeneratorProvider = Provider<ThumbnailGenerator>(
  (_) => const ThumbnailGenerator(),
);

/// Public value object: marker bytes keyed by media id, plus the total count
/// of in-flight renders (so the map can redraw as each one lands).
class VaultMarkerState {
  const VaultMarkerState({
    required this.bytesById,
    required this.version,
  });

  final Map<String, Uint8List> bytesById;
  final int version;
}

/// Notifier that, for each geotagged media:
///   1. Picks a source path (thumbnailLocalPath > localUri).
///   2. If only localUri is present (and it exists), it also kicks off a
///      background thumbnail generation that writes back via MediaDao so the
///      next paint can use the smaller file.
///   3. Renders the marker PNG via [ThumbnailMarkerRenderer], caches it, and
///      bumps the state version whenever a new render lands.
///
/// The map watches this provider and maps each media id → Uint8List to build
/// an [AppMarker] with `iconPngBytes`.
class VaultMarkerController extends Notifier<VaultMarkerState> {
  final Set<String> _generating = <String>{};

  @override
  VaultMarkerState build() {
    // React to media list changes: new media → trigger render; removed media
    // → drop from the renderer cache so we can evict.
    ref.listen<AsyncValue<List<MediaItem>>>(vaultAllMediaProvider, (_, next) {
      next.whenData(_onMediaChanged);
    });
    // Initial run against whatever is already cached.
    final snapshot = ref.read(vaultAllMediaProvider).valueOrNull;
    if (snapshot != null) {
      Future.microtask(() => _onMediaChanged(snapshot));
    }
    return const VaultMarkerState(bytesById: {}, version: 0);
  }

  void _onMediaChanged(List<MediaItem> items) {
    final renderer = ref.read(thumbnailMarkerRendererProvider);
    final currentIds = items.map((m) => m.id).toSet();

    // Drop evicted ids from the LRU.
    for (final existing in state.bytesById.keys.toList(growable: false)) {
      if (!currentIds.contains(existing)) {
        renderer.invalidate(existing);
      }
    }

    for (final item in items) {
      if (item.latitude == null || item.longitude == null) continue;
      final cacheKey = _cacheKeyFor(item);
      if (state.bytesById.containsKey(item.id)) {
        // Key may have changed if the thumbnail path was just filled in.
        if (renderer.lookup(cacheKey) != null) continue;
      }
      unawaited(_renderOne(item));
    }
  }

  String _cacheKeyFor(MediaItem item) {
    // Cache on (id, thumbnailLocalPath) so once the thumbnail is generated
    // we render a fresh marker rather than re-using the localUri render.
    return '${item.id}|${item.thumbnailLocalPath ?? item.localUri ?? ''}';
  }

  Future<void> _renderOne(MediaItem item) async {
    final renderer = ref.read(thumbnailMarkerRendererProvider);
    final cacheKey = _cacheKeyFor(item);

    final sourcePath = item.thumbnailLocalPath?.isNotEmpty == true
        ? item.thumbnailLocalPath!
        : (item.localUri?.isNotEmpty == true ? item.localUri! : null);

    if (sourcePath == null) {
      return;
    }

    // Web captures have no filesystem path — render the marker from the
    // stored bytes instead.
    final Uint8List? bytes;
    final memId = mediaIdFromMemoryUri(sourcePath);
    if (memId != null) {
      final stored = await WebCaptureBytesStore.instance.read(memId);
      if (stored == null) return;
      bytes = await renderer.ensureBytes(
        cacheKey: cacheKey,
        bytes: stored,
      );
    } else {
      bytes = await renderer.ensure(
        cacheKey: cacheKey,
        sourcePath: sourcePath,
      );
    }
    if (bytes != null) {
      final next = Map<String, Uint8List>.from(state.bytesById);
      next[item.id] = bytes;
      state = VaultMarkerState(
        bytesById: next,
        version: state.version + 1,
      );
    }

    // Kick off thumbnail generation in the background if we only had the
    // full-res localUri. The MediaDao write bubbles through the main stream
    // and we render a new (smaller) marker next time.
    if (item.thumbnailLocalPath == null || item.thumbnailLocalPath!.isEmpty) {
      unawaited(_generateThumbnail(item));
    }
  }

  Future<void> _generateThumbnail(MediaItem item) async {
    final sourcePath = item.localUri;
    if (sourcePath == null || sourcePath.isEmpty) return;
    // Web captures are already in the bytes store; file thumbnails N/A.
    if (isMemoryUri(sourcePath)) return;
    if (!_generating.add(item.id)) return;
    try {
      final source = File(sourcePath);
      if (!await source.exists()) return;
      final generator = ref.read(_thumbnailGeneratorProvider);
      final thumbnailPath = await generator.generate(
        sourcePath: sourcePath,
        mediaId: item.id,
      );
      if (thumbnailPath == null) return;
      final db = ref.read(appDatabaseProvider);
      await db.mediaDao.updateLocalArtifacts(
        mediaId: item.id,
        thumbnailLocalPath: thumbnailPath,
      );
    } catch (error, stack) {
      debugPrint('[vault] thumbnail generation failed for ${item.id}: $error');
      debugPrint('$stack');
    } finally {
      _generating.remove(item.id);
    }
  }
}

final vaultMarkerControllerProvider =
    NotifierProvider<VaultMarkerController, VaultMarkerState>(
  VaultMarkerController.new,
);
