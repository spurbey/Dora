/// Browser camera capture screen. Web-only.
///
/// Preview is a platform-view `<video>` element driven by [WebCameraController]
/// (direct `getUserMedia`, no plugins). Photo shutter + video record/stop,
/// confirm discards or persists via
/// [CameraCaptureController.persistWebCapture].
library;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

import 'package:dora/features/capture/presentation/providers/camera_capture_controller.dart';
import 'package:dora/features/capture/presentation/screens/web_camera.dart';

const String _kCamViewType = 'dora-camera-preview';
bool _kCamFactoryRegistered = false;
final Set<String> _claimedCamIds = <String>{};

enum _WebCaptureMode { photo, video }

class WebCaptureScreen extends ConsumerStatefulWidget {
  const WebCaptureScreen({super.key});

  @override
  ConsumerState<WebCaptureScreen> createState() => _WebCaptureScreenState();
}

class _WebCaptureScreenState extends ConsumerState<WebCaptureScreen> {
  final _camera = WebCameraController();
  String? _claimedId;
  bool _starting = true;
  String? _error;
  _WebCaptureMode _mode = _WebCaptureMode.photo;
  bool _busy = false;
  bool _recording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  ({Uint8List bytes, String filename, String mime})? _pending;

  @override
  void initState() {
    super.initState();
    if (!_kCamFactoryRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(
        _kCamViewType,
        (int id) {
          final video =
              web.document.createElement('video') as web.HTMLVideoElement;
          video.id = 'dora-cam-$id';
          video.autoplay = true;
          video.muted = true;
          const playsInline = 'playsinline';
          video.setAttribute(playsInline, playsInline);
          video.style.width = '100%';
          video.style.height = '100%';
          video.style.objectFit = 'cover';
          video.style.backgroundColor = 'black';
          return video;
        },
      );
      _kCamFactoryRegistered = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    for (var attempt = 0; attempt < 50; attempt++) {
      if (!mounted) return;
      final el = _claimVideo();
      if (el != null) {
        try {
          await _camera.start(el);
        } on WebCameraException catch (e) {
          if (mounted) {
            setState(() {
              _error = e.message;
              _starting = false;
            });
          }
          return;
        } catch (e) {
          if (mounted) {
            setState(() {
              _error = 'Camera failed to start.';
              _starting = false;
            });
          }
          return;
        }
        if (mounted) setState(() => _starting = false);
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (mounted) {
      setState(() {
        _error = 'Camera preview did not load.';
        _starting = false;
      });
    }
  }

  web.HTMLVideoElement? _claimVideo() {
    try {
      final nodes = web.document.querySelectorAll('video[id^="dora-cam-"]');
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes.item(i);
        if (node is! web.HTMLVideoElement) continue;
        if (_claimedCamIds.contains(node.id)) continue;
        _claimedCamIds.add(node.id);
        _claimedId = node.id;
        return node;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    if (_claimedId != null) {
      _claimedCamIds.remove(_claimedId);
      _claimedId = null;
    }
    _recordTimer?.cancel();
    unawaited(_camera.stop());
    super.dispose();
  }

  Future<void> _onShutter() async {
    if (_busy || _starting || _error != null) return;
    setState(() => _busy = true);
    try {
      if (_mode == _WebCaptureMode.photo) {
        final bytes = await _camera.takePhoto();
        if (mounted) {
          setState(() {
            _pending = (
              bytes: bytes,
              filename: 'capture-${DateTime.now().millisecondsSinceEpoch}.jpg',
              mime: 'image/jpeg',
            );
          });
        }
      } else if (_recording) {
        final bytes = await _camera.stopRecording();
        _recordTimer?.cancel();
        if (mounted) {
          setState(() {
            _recording = false;
            _pending = (
              bytes: bytes,
              filename: 'capture-${DateTime.now().millisecondsSinceEpoch}.webm',
              mime: 'video/webm',
            );
          });
        }
      } else {
        await _camera.startRecording();
        if (mounted) {
          setState(() {
            _recording = true;
            _recordSeconds = 0;
          });
          _recordTimer?.cancel();
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => _recordSeconds++);
          });
        }
      }
    } on WebCameraException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted && !_recording) setState(() => _busy = false);
      if (mounted && _mode == _WebCaptureMode.photo) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _onConfirm() async {
    final pending = _pending;
    if (pending == null || _busy) return;
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(cameraCaptureControllerProvider.notifier)
          .persistWebCapture(
            bytes: pending.bytes,
            filename: pending.filename,
            mimeType: pending.mime,
          );
      if (!mounted) return;
      switch (result.kind) {
        case CameraCaptureResultKind.attachedToTrip:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to ${result.tripName ?? 'trip'}')),
          );
          context.pop(result);
        case CameraCaptureResultKind.savedToVault:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to vault')),
          );
          context.pop(result);
        case CameraCaptureResultKind.permissionDenied:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location permission is needed to save')),
          );
        case CameraCaptureResultKind.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.errorMessage ?? 'Save failed')),
          );
        case CameraCaptureResultKind.cancelled:
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // The platform view MUST stay mounted in every state: the browser only
    // creates the <video> element while it is in the tree, and claiming
    // happens after the first frame. Loading/error UIs overlay it.
    //
    // The preview intentionally takes the top ~62%: controls live on plain
    // canvas below it so taps can never be swallowed by the video element.
    return Column(
      children: [
        Expanded(
          flex: 62,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const HtmlElementView(viewType: _kCamViewType),
              if (_starting)
                Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
              if (!_starting && _error != null) _errorFill(),
            ],
          ),
        ),
        if (!_starting && _error != null)
          _errorActions()
        else if (!_starting && _pending != null)
          Expanded(flex: 38, child: _confirmPanel())
        else if (!_starting)
          _controlsPanel(),
      ],
    );
  }

  Widget _errorFill() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined,
                size: 48, color: Colors.white70),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _errorActions() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      alignment: Alignment.center,
      child: FilledButton(
        onPressed: () => context.pop(),
        child: const Text('Go back'),
      ),
    );
  }

  Widget _controlsPanel() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_recording)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _formatDuration(_recordSeconds),
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeButton(
              label: 'Photo',
              icon: Icons.photo_camera_outlined,
              selected: _mode == _WebCaptureMode.photo,
              onTap: () {
                debugPrint('[webcam] photo tap');
                if (!_recording) {
                  setState(() => _mode = _WebCaptureMode.photo);
                }
              },
            ),
            const SizedBox(width: 12),
            _ModeButton(
              label: 'Video',
              icon: Icons.videocam_outlined,
              selected: _mode == _WebCaptureMode.video,
              onTap: () {
                debugPrint('[webcam] video tap');
                if (!_recording) {
                  setState(() => _mode = _WebCaptureMode.video);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: GestureDetector(
            onTap: _busy ? null : _onShutter,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _recording ? Colors.red : Colors.white24,
              ),
              child: Icon(
                _mode == _WebCaptureMode.photo || !_recording
                    ? Icons.circle
                    : Icons.stop_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _confirmPanel() {
    final pending = _pending!;
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
          child: Center(
            child: pending.mime.startsWith('video')
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam,
                          size: 64, color: Colors.white70),
                      SizedBox(height: 12),
                      Text('Video captured',
                          style: TextStyle(color: Colors.white)),
                    ],
                  )
                : Image.memory(pending.bytes, fit: BoxFit.contain),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 28, left: 24, right: 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _pending = null),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white),
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _onConfirm,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

/// Big-target photo/video mode toggle.
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white70),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? Colors.black87 : Colors.white),
            const SizedBox(width: 6),
            Text(
              '${selected ? '● ' : ''}$label',
              style: TextStyle(
                color: selected ? Colors.black87 : Colors.white,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
