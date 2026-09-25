import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders a small rounded-square marker image with a thumbnail baked in,
/// suitable for Mapbox `PointAnnotationOptions.image`. Results are memoised
/// in a simple LRU so the map can update every frame without re-rendering.
class ThumbnailMarkerRenderer {
  ThumbnailMarkerRenderer({this.capacity = 128});

  final int capacity;
  final Map<String, Uint8List> _cache = <String, Uint8List>{};
  final Map<String, Future<Uint8List?>> _inFlight =
      <String, Future<Uint8List?>>{};

  /// Returns the cached marker PNG for [cacheKey] if we already have one,
  /// otherwise triggers a one-shot render and returns null. The map will
  /// observe the newly-cached bytes on the next rebuild because the caller
  /// re-watches the provider/state that invalidated the key.
  Uint8List? lookup(String cacheKey) => _cache[cacheKey];

  /// Builds the marker bytes for [sourcePath] if not cached. Safe to call
  /// multiple times with the same key; concurrent calls share one future.
  Future<Uint8List?> ensure({
    required String cacheKey,
    required String sourcePath,
    Color borderColor = Colors.white,
    Color backgroundColor = const Color(0xFFE8E8E8),
  }) {
    final cached = _cache[cacheKey];
    if (cached != null) {
      return Future<Uint8List?>.value(cached);
    }
    final running = _inFlight[cacheKey];
    if (running != null) {
      return running;
    }
    final future = _render(
      sourcePath: sourcePath,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
    ).then((bytes) {
      if (bytes != null) {
        _remember(cacheKey, bytes);
      }
      return bytes;
    }).whenComplete(() {
      _inFlight.remove(cacheKey);
    });
    _inFlight[cacheKey] = future;
    return future;
  }

  /// Web-capture variant: renders from in-memory bytes (for `memory://`
  /// URIs that have no filesystem path). Same cache semantics as [ensure].
  Future<Uint8List?> ensureBytes({
    required String cacheKey,
    required Uint8List bytes,
    Color borderColor = Colors.white,
    Color backgroundColor = const Color(0xFFE8E8E8),
  }) {
    final cached = _cache[cacheKey];
    if (cached != null) {
      return Future<Uint8List?>.value(cached);
    }
    final running = _inFlight[cacheKey];
    if (running != null) {
      return running;
    }
    final future = _renderBytes(
      bytes: bytes,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
    ).then((rendered) {
      if (rendered != null) {
        _remember(cacheKey, rendered);
      }
      return rendered;
    }).whenComplete(() {
      _inFlight.remove(cacheKey);
    });
    _inFlight[cacheKey] = future;
    return future;
  }

  void invalidate(String cacheKey) {
    _cache.remove(cacheKey);
  }

  void clear() {
    _cache.clear();
    _inFlight.clear();
  }

  void _remember(String cacheKey, Uint8List bytes) {
    if (_cache.length >= capacity) {
      // LRU eviction: drop the oldest entry (Dart's Map iterates in insertion
      // order, so removing the first key works).
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[cacheKey] = bytes;
  }

  Future<Uint8List?> _render({
    required String sourcePath,
    required Color borderColor,
    required Color backgroundColor,
  }) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    return _renderBytes(
      bytes: bytes,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
    );
  }

  Future<Uint8List?> _renderBytes({
    required Uint8List bytes,
    required Color borderColor,
    required Color backgroundColor,
  }) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 96,
      targetHeight: 96,
    );
    final frame = await codec.getNextFrame();
    final sourceImage = frame.image;

    const size = 112;
    const sizeDouble = 112.0;
    const innerInset = 6.0;
    const cornerRadius = 16.0;
    const shadowBlur = 8.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const fullRect = Rect.fromLTWH(0, 0, sizeDouble, sizeDouble);

    // Soft drop shadow so the marker reads against busy map tiles.
    final shadowRRect = RRect.fromRectAndRadius(
      fullRect.deflate(innerInset / 2),
      const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(
      shadowRRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, shadowBlur),
    );

    // White rounded border (frame).
    final borderRRect = RRect.fromRectAndRadius(
      fullRect.deflate(innerInset),
      const Radius.circular(cornerRadius - 2),
    );
    canvas.drawRRect(borderRRect, Paint()..color = borderColor);

    // Inner image area (3px inside the border frame).
    final innerRRect = borderRRect.deflate(3);
    final innerRect = Rect.fromLTRB(
      innerRRect.left,
      innerRRect.top,
      innerRRect.right,
      innerRRect.bottom,
    );
    final imageRRect = RRect.fromRectAndRadius(
      innerRect,
      const Radius.circular(cornerRadius - 4),
    );

    canvas.drawRRect(imageRRect, Paint()..color = backgroundColor);
    canvas.save();
    canvas.clipRRect(imageRRect);
    canvas.drawImageRect(
      sourceImage,
      Rect.fromLTWH(
        0,
        0,
        sourceImage.width.toDouble(),
        sourceImage.height.toDouble(),
      ),
      innerRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();

    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(size, size);
    final byteData =
        await outputImage.toByteData(format: ui.ImageByteFormat.png);
    sourceImage.dispose();
    outputImage.dispose();
    if (byteData == null) {
      return null;
    }
    return byteData.buffer.asUint8List();
  }
}

