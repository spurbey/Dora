/// Session + persisted byte storage for web captures. Web-only.
///
/// Mobile captures live as files; browsers have no filesystem paths, so web
/// captures are addressed as `memory://<mediaId>` URIs and their bytes live
/// here: hot in memory, durable in IndexedDB (`dora-media` store). Viewers
/// resolve `memory://` URIs through [read] instead of `File(...)`.
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

const String kMemoryUriScheme = 'memory://';

bool isMemoryUri(String? uri) =>
    uri != null && uri.startsWith(kMemoryUriScheme);

String memoryUriFor(String mediaId) => '$kMemoryUriScheme$mediaId';

String? mediaIdFromMemoryUri(String? uri) {
  if (!isMemoryUri(uri)) return null;
  final id = uri!.substring(kMemoryUriScheme.length);
  return id.isEmpty ? null : id;
}

class WebCaptureBytesStore {
  WebCaptureBytesStore._();

  static final WebCaptureBytesStore instance = WebCaptureBytesStore._();

  final Map<String, Uint8List> _memory = {};

  /// Synchronous hot-cache lookup. Null means "not in this session" —
  /// callers fall back to async [read] (IndexedDB) or a placeholder.
  Uint8List? peek(String mediaId) => _memory[mediaId];

  Future<void> write(String mediaId, Uint8List bytes) async {
    _memory[mediaId] = bytes;
    try {
      final db = await _openDb();
      final tx = (db as JSObject)
          .callMethod('transaction'.toJS, 'media'.toJS, 'readwrite'.toJS);
      final store = (tx as JSObject)
          .callMethod('objectStore'.toJS, 'media'.toJS);
      (store as JSObject).callMethod(
        'put'.toJS,
        bytes.toJS,
        mediaId.toJS,
      );
    } catch (_) {
      // Memory copy above is enough for the session; persistence is best-effort.
    }
  }

  Future<Uint8List?> read(String mediaId) async {
    final hot = _memory[mediaId];
    if (hot != null) return hot;
    try {
      final db = await _openDb();
      final tx = (db as JSObject)
          .callMethod('transaction'.toJS, 'media'.toJS, 'readonly'.toJS);
      final store = (tx as JSObject)
          .callMethod('objectStore'.toJS, 'media'.toJS);
      final request =
          (store as JSObject).callMethod('get'.toJS, mediaId.toJS);
      final result = await _requestToFuture(request);
      if (result == null || result.isUndefinedOrNull) return null;
      final bytes = (result as JSArrayBuffer).toDart;
      final out = Uint8List.fromList(bytes.asUint8List());
      _memory[mediaId] = out;
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<JSAny> _openDb() {
    final completer = Completer<JSAny>();
    try {
      final request = web.window.indexedDB
          .open('dora-media', 1);
      (request as JSObject).setProperty(
        'onupgradeneeded'.toJS,
        ((JSAny _) {
          try {
            final db = ((request as JSObject).getProperty('result'.toJS));
            (db as JSObject).callMethod(
              'createObjectStore'.toJS,
              'media'.toJS,
            );
          } catch (_) {}
        }).toJS,
      );
      (request as JSObject).setProperty(
        'onsuccess'.toJS,
        ((JSAny _) {
          completer.complete(
              (request as JSObject).getProperty('result'.toJS));
        }).toJS,
      );
      (request as JSObject).setProperty(
        'onerror'.toJS,
        ((JSAny _) {
          completer.completeError(StateError('idb open failed'));
        }).toJS,
      );
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  Future<JSAny?> _requestToFuture(JSAny? request) {
    final completer = Completer<JSAny?>();
    if (request == null) {
      completer.complete(null);
      return completer.future;
    }
    try {
      final req = request as JSObject;
      req.setProperty(
        'onsuccess'.toJS,
        ((JSAny _) {
          completer.complete(req.getProperty('result'.toJS));
        }).toJS,
      );
      req.setProperty(
        'onerror'.toJS,
        ((JSAny _) {
          completer.complete(null);
        }).toJS,
      );
    } catch (_) {
      completer.complete(null);
    }
    return completer.future;
  }
}
