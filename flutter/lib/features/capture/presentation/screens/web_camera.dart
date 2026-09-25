/// Direct browser camera access for web capture. Web-only.
///
/// Drives `getUserMedia` + canvas snapshot (photo) + `MediaRecorder` (video)
/// through `package:web`, with zero plugin dependencies (the `camera`
/// plugin's web registration proved unreliable in this toolchain).
/// UI lives in `web_capture_screen.dart`; this file owns the DOM elements
/// and the byte pipeline.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class WebCameraController {
  web.HTMLVideoElement? _video;
  JSAny? _stream;
  JSAny? _recorder;
  final List<JSAny> _chunks = [];
  bool _recording = false;

  bool get isRecording => _recording;
  bool get isReady => _video != null && _stream != null;

  /// Attaches the live preview to [element] and starts the device camera.
  /// Throws a [WebCameraException] with a human-readable [message].
  Future<void> start(web.HTMLVideoElement element) async {
    await stop();
    _video = element;
    try {
      final mediaDevices = web.window.navigator.mediaDevices;
      final constraints = web.MediaStreamConstraints(
        video: <String, Object?>{
          'facingMode': 'environment',
          'width': {'ideal': 1280},
        }.jsify()!,
        audio: true.toJS,
      );
      final stream = await mediaDevices.getUserMedia(constraints).toDart;
      _stream = stream;
      element.srcObject = stream;
      await element.play().toDart;
    } catch (e) {
      await stop();
      throw WebCameraException(_humanMessage(e));
    }
  }

  /// Captures the current preview frame as JPEG bytes.
  Future<Uint8List> takePhoto() async {
    final video = _video;
    final stream = _stream;
    if (video == null || stream == null) {
      throw const WebCameraException('Camera is not started.');
    }
    try {
      final width = video.videoWidth;
      final height = video.videoHeight;
      if (width == 0 || height == 0) {
        throw const WebCameraException('Camera preview is not ready yet.');
      }
      final canvas =
          web.document.createElement('canvas') as web.HTMLCanvasElement;
      canvas.width = width;
      canvas.height = height;
      final ctx = canvas.getContext('2d');
      // drawImage has only the 9-arg overload in package:web and the video
      // element isn't statically a CanvasImageSource, so call through
      // dynamically (valid at runtime per the canvas spec).
      (ctx as JSObject).callMethodVarArgs('drawImage'.toJS, [
        video,
        0.toJS,
        0.toJS,
        width.toJS,
        height.toJS,
        0.toJS,
        0.toJS,
        width.toJS,
        height.toJS,
      ]);
      final dataUrl = canvas.toDataURL('image/jpeg', 0.92.toJS);
      final comma = dataUrl.indexOf(',');
      if (comma < 0) {
        throw const WebCameraException('Photo encoding failed.');
      }
      return base64Decode(dataUrl.substring(comma + 1));
    } catch (e) {
      if (e is WebCameraException) rethrow;
      throw WebCameraException('Photo capture failed: $e');
    }
  }

  /// Begins MediaRecorder capture on the live stream.
  Future<void> startRecording() async {
    if (_stream == null) {
      throw const WebCameraException('Camera is not started.');
    }
    if (_recording) return;
    try {
      final recorderCtor =
          globalContext.getProperty('MediaRecorder'.toJS);
      if (recorderCtor.isUndefinedOrNull) {
        throw const WebCameraException(
            'Video recording is not supported in this browser.');
      }
      _chunks.clear();
      final recorder = (recorderCtor as JSFunction).callAsConstructor(
        _stream!,
        <String, Object?>{'mimeType': 'video/webm'}.jsify(),
      );
      (recorder as JSObject).setProperty(
        'ondataavailable'.toJS,
        ((JSAny e) {
          try {
            final data =
                (e as JSObject).getProperty('data'.toJS);
            if (data.isUndefinedOrNull) return;
            final size = ((data as JSObject).getProperty('size'.toJS)
                    as JSNumber)
                .toDartDouble;
            if (size > 0) _chunks.add(data);
          } catch (_) {}
        }).toJS,
      );
      recorder.callMethod('start'.toJS, 250.toJS);
      _recorder = recorder;
      _recording = true;
    } catch (e) {
      if (e is WebCameraException) rethrow;
      throw WebCameraException('Recording failed to start: $e');
    }
  }

  /// Stops recording and returns the video bytes (webm).
  Future<Uint8List> stopRecording() async {
    final recorder = _recorder;
    if (!_recording || recorder == null) {
      throw const WebCameraException('No recording in progress.');
    }
    try {
      final completer = Completer<Uint8List>();
      (recorder as JSObject).setProperty(
        'onstop'.toJS,
        // NOTE: must stay synchronous — `.toJS` closures cannot be async.
        ((JSAny _) {
          try {
            final blobCtor =
                globalContext.getProperty('Blob'.toJS);
            final blob = (blobCtor as JSFunction).callAsConstructor(
              _chunks.jsify(),
              <String, Object?>{'type': 'video/webm'}.jsify(),
            );
            _blobToBytes(blob).then(
              completer.complete,
              onError: (Object e) => completer.completeError(
                  WebCameraException('Could not finalize video: $e')),
            );
          } catch (e) {
            completer.completeError(
                WebCameraException('Could not finalize video: $e'));
          }
        }).toJS,
      );
      recorder.callMethod('stop'.toJS);
      _recording = false;
      _recorder = null;
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw const WebCameraException('Timed out finalizing video.'),
      );
    } catch (e) {
      _recording = false;
      _recorder = null;
      if (e is WebCameraException) rethrow;
      throw WebCameraException('Could not stop recording: $e');
    }
  }

  Future<void> stop() async {
    _recording = false;
    _recorder = null;
    try {
      final stream = _stream;
      if (stream != null) {
        final tracks = ((stream as JSObject)
                .callMethod('getTracks'.toJS) as JSArray)
            .toDart;
        for (final track in tracks) {
          try {
            (track as JSObject).callMethod('stop'.toJS);
          } catch (_) {}
        }
      }
    } catch (_) {}
    _stream = null;
    try {
      final video = _video;
      if (video != null) {
        video.srcObject = null;
      }
    } catch (_) {}
    _video = null;
    _chunks.clear();
  }

  Future<Uint8List> _blobToBytes(JSAny blob) async {
    final buffer = await ((blob as JSObject)
            .callMethod('arrayBuffer'.toJS) as JSPromise)
        .toDart;
    final bytes = (buffer as JSArrayBuffer).toDart.asUint8List();
    return Uint8List.fromList(bytes);
  }

  String _humanMessage(Object e) {
    final text = e.toString();
    if (text.contains('NotAllowedError') ||
        text.contains('Permission denied') ||
        text.contains('denied')) {
      return 'Camera access was denied. Allow camera access in the browser address bar, then reopen this screen.';
    }
    if (text.contains('NotFoundError') || text.contains('Overconstrained')) {
      return 'No camera found on this device.';
    }
    if (text.contains('NotReadableError')) {
      return 'The camera is busy in another app or tab.';
    }
    if (text.contains('Secure')) {
      return 'Camera needs a secure (HTTPS) page. Please use the https address.';
    }
    return 'Camera failed to start.';
  }
}

class WebCameraException implements Exception {
  const WebCameraException(this.message);
  final String message;

  @override
  String toString() => message;
}
