import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:dora/features/stories/data/models/story_models.dart';
import 'package:dora/features/stories/presentation/providers/stories_providers.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  final List<StoryFeedItem> items;
  final int initialIndex;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  static const _photoDuration = Duration(seconds: 5);
  int _index = 0;
  VideoPlayerController? _videoController;
  Timer? _advanceTimer;
  bool _muted = true;
  bool _holdingPause = false;

  StoryFeedItem get _current => widget.items[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.items.length - 1);
    unawaited(_activateCurrent());
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _activateCurrent() async {
    _advanceTimer?.cancel();
    final previous = _videoController;
    _videoController = null;
    if (previous != null) {
      await previous.dispose();
    }
    final item = _current;
    unawaited(
      ref.read(storyFeedControllerProvider.notifier).markViewed(item.id),
    );

    if (item.mediaType == StoryMediaType.video && item.mediaUrl != null) {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(item.mediaUrl!));
      _videoController = controller;
      try {
        await controller.initialize();
        if (!mounted || _videoController != controller) {
          await controller.dispose();
          return;
        }
        await controller.setLooping(false);
        await controller.setVolume(_muted ? 0 : 1);
        await controller.play();
        controller.addListener(() {
          if (!mounted || _videoController != controller) return;
          final value = controller.value;
          if (!value.isInitialized || value.duration.inMilliseconds <= 0)
            return;
          if (value.position >=
              value.duration - const Duration(milliseconds: 120)) {
            _goNext();
          }
        });
        final fallback = item.durationMs != null && item.durationMs! > 0
            ? Duration(milliseconds: item.durationMs!.clamp(1, 60000))
            : controller.value.duration;
        if (fallback > Duration.zero) {
          _advanceTimer =
              Timer(fallback + const Duration(milliseconds: 300), _goNext);
        }
        setState(() {});
      } catch (_) {
        _startPhotoTimer();
      }
    } else {
      _startPhotoTimer();
    }
  }

  void _startPhotoTimer() {
    _advanceTimer?.cancel();
    _advanceTimer = Timer(_photoDuration, _goNext);
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    if (_index >= widget.items.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _index += 1;
    });
    await _activateCurrent();
  }

  Future<void> _goPrev() async {
    if (!mounted) return;
    if (_index <= 0) {
      return;
    }
    setState(() {
      _index -= 1;
    });
    await _activateCurrent();
  }

  Future<void> _toggleMute() async {
    final controller = _videoController;
    if (controller == null) return;
    _muted = !_muted;
    await controller.setVolume(_muted ? 0 : 1);
    if (mounted) setState(() {});
  }

  Future<void> _pauseForHold() async {
    if (_holdingPause) return;
    _holdingPause = true;
    _advanceTimer?.cancel();
    final controller = _videoController;
    if (controller != null && controller.value.isPlaying) {
      await controller.pause();
    }
  }

  Future<void> _resumeAfterHold() async {
    if (!_holdingPause) return;
    _holdingPause = false;
    final controller = _videoController;
    if (controller != null) {
      await controller.play();
      return;
    }
    _startPhotoTimer();
  }

  Future<void> _handleMenuAction(String action) async {
    final current = _current;
    switch (action) {
      case 'hide':
        await ref
            .read(storyFeedControllerProvider.notifier)
            .hideStory(current.id);
        if (mounted) Navigator.of(context).maybePop();
        return;
      case 'mute':
        await ref
            .read(storyFeedControllerProvider.notifier)
            .muteAuthor(current.authorUserId);
        if (mounted) Navigator.of(context).maybePop();
        return;
      case 'report':
        await ref.read(storyFeedControllerProvider.notifier).reportStory(
              storyId: current.id,
              reason: 'inappropriate',
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Story reported')),
          );
        }
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _current;
    final controller = _videoController;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onLongPressStart: (_) => _pauseForHold(),
          onLongPressEnd: (_) => _resumeAfterHold(),
          onTapUp: (details) async {
            final width = MediaQuery.of(context).size.width;
            final dx = details.localPosition.dx;
            if (dx < width * 0.33) {
              await _goPrev();
              return;
            }
            if (dx > width * 0.66) {
              await _goNext();
              return;
            }
            if (item.mediaType == StoryMediaType.video) {
              await _toggleMute();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (item.mediaType == StoryMediaType.video &&
                  controller != null &&
                  controller.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              else if (item.mediaUrl != null || item.thumbnailUrl != null)
                Image.network(
                  item.mediaUrl ?? item.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white70)),
                )
              else
                const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.white70),
                ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: widget.items.length <= 1
                            ? 1
                            : (_index + 1) / widget.items.length,
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 56,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text(
                        item.authorUserId.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.isOwn
                            ? 'You'
                            : '@${item.authorUserId.substring(0, 6)}',
                        style: const TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.mediaType == StoryMediaType.video)
                      Icon(
                        _muted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                    PopupMenuButton<String>(
                      color: Colors.black87,
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'hide',
                          child: Text('Hide Story',
                              style: TextStyle(color: Colors.white)),
                        ),
                        PopupMenuItem(
                          value: 'mute',
                          child: Text('Mute Author',
                              style: TextStyle(color: Colors.white)),
                        ),
                        PopupMenuItem(
                          value: 'report',
                          child: Text('Report',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
