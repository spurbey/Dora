/// Image widget that understands web-capture `memory://` URIs.
///
/// Resolution order: memory bytes (hot cache, else IndexedDB) → local file
/// (mobile) → remote URL → broken-image placeholder. Platform-agnostic: the
/// `memory://` branch simply never triggers on mobile.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dora/core/media/web_capture_bytes_store.dart';

class MemoryAwareImage extends StatefulWidget {
  const MemoryAwareImage({
    super.key,
    this.localUri,
    this.thumbnailPath,
    this.remoteUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String? localUri;
  final String? thumbnailPath;
  final String? remoteUrl;
  final BoxFit fit;
  final Widget? placeholder;

  @override
  State<MemoryAwareImage> createState() => _MemoryAwareImageState();
}

class _MemoryAwareImageState extends State<MemoryAwareImage> {
  @override
  Widget build(BuildContext context) {
    final memId = mediaIdFromMemoryUri(widget.thumbnailPath) ??
        mediaIdFromMemoryUri(widget.localUri);
    if (memId != null) {
      final hot = WebCaptureBytesStore.instance.peek(memId);
      if (hot != null) {
        return Image.memory(hot, fit: widget.fit);
      }
      // Cold start (e.g. after reload): bytes persist in IndexedDB on web.
      if (kIsWeb) {
        return FutureBuilder(
          future: WebCaptureBytesStore.instance.read(memId),
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (bytes != null) {
              return Image.memory(bytes, fit: widget.fit);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return widget.placeholder ?? const _BrokenImage();
          },
        );
      }
      return widget.placeholder ?? const _BrokenImage();
    }

    final thumb = widget.thumbnailPath;
    if (thumb != null && thumb.isNotEmpty) {
      if (thumb.startsWith('http')) {
        return Image.network(thumb, fit: widget.fit);
      }
      if (!kIsWeb) {
        final file = File(thumb);
        if (file.existsSync()) {
          return Image.file(file, fit: widget.fit);
        }
      }
    }
    final local = widget.localUri;
    if (local != null && local.isNotEmpty && !kIsWeb) {
      final file = File(local);
      if (file.existsSync()) {
        return Image.file(file, fit: widget.fit);
      }
    }
    final url = widget.remoteUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: widget.fit);
    }
    return widget.placeholder ?? const _BrokenImage();
  }
}

/// Synchronous provider resolver for call sites built around
/// `ImageProvider` (e.g. `Image(image: ...)`). Returns a `MemoryImage` on a
/// hot-cache hit, otherwise null (caller falls through to existing logic).
MemoryImage? memoryImageIfHot(String? localUri, [String? thumbnailPath]) {
  final memId = mediaIdFromMemoryUri(thumbnailPath) ??
      mediaIdFromMemoryUri(localUri);
  if (memId == null) return null;
  final bytes = WebCaptureBytesStore.instance.peek(memId);
  if (bytes == null) return null;
  return MemoryImage(bytes);
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Icon(Icons.broken_image_outlined));
  }
}
