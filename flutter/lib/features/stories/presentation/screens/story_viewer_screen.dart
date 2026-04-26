import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
  static const _progressTick = Duration(milliseconds: 50);

  int _index = 0;
  VideoPlayerController? _videoController;
  VideoPlayerController? _nextVideoController;
  String? _nextVideoStoryId;
  Timer? _progressTimer;
  final Stopwatch _photoStopwatch = Stopwatch();
  final Set<String> _viewedStoryIds = <String>{};
  final Set<String> _photoPlaybackReady = <String>{};
  bool _muted = true;
  bool _holdingPause = false;
  bool _transitioning = false;
  int _activationToken = 0;
  double _currentStoryProgress = 0;

  StoryFeedItem get _current => widget.items[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.items.length - 1);
    unawaited(_activateCurrent());
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _photoStopwatch.stop();
    _videoController?.dispose();
    _nextVideoController?.dispose();
    super.dispose();
  }

  Future<void> _activateCurrent() async {
    final activation = ++_activationToken;
    _transitioning = false;
    _cancelProgressLoop();
    final previous = _videoController;
    _videoController = null;
    if (previous != null) {
      await previous.dispose();
    }
    final item = _current;
    if (_viewedStoryIds.add(item.id)) {
      unawaited(
        ref.read(storyFeedControllerProvider.notifier).markViewed(item.id),
      );
    }
    unawaited(
        _warmPhotoUrls(item, updateCurrent: true, activation: activation));

    if (item.mediaType == StoryMediaType.video && item.mediaUrl != null) {
      final controller = await _resolveActiveVideoController(
        item: item,
        activation: activation,
      );
      if (controller != null && mounted && activation == _activationToken) {
        _videoController = controller;
        controller.addListener(() => _onVideoProgress(controller, activation));
        if (_holdingPause) {
          await controller.pause();
        } else {
          await controller.play();
        }
        if (mounted && activation == _activationToken) {
          setState(() {
            _currentStoryProgress = 0;
          });
        }
      } else {
        _startPhotoProgressLoop(
          activation: activation,
          duration: _photoDurationFor(item),
        );
      }
    } else {
      _startPhotoProgressLoop(
        activation: activation,
        duration: _photoDurationFor(item),
      );
    }

    unawaited(_warmNextStory(activation: activation));
  }

  void _onVideoProgress(VideoPlayerController controller, int activation) {
    if (!mounted ||
        activation != _activationToken ||
        _videoController != controller) {
      return;
    }
    final value = controller.value;
    if (!value.isInitialized || value.duration <= Duration.zero) {
      return;
    }
    final progress =
        (value.position.inMilliseconds / value.duration.inMilliseconds)
            .clamp(0.0, 1.0);
    if ((progress - _currentStoryProgress).abs() >= 0.01 && mounted) {
      setState(() {
        _currentStoryProgress = progress;
      });
    }
    if (value.position >= value.duration - const Duration(milliseconds: 120)) {
      unawaited(_goNext());
    }
  }

  Future<void> _goNext() async {
    if (!mounted || _transitioning) return;
    _transitioning = true;
    if (_index >= widget.items.length - 1) {
      Navigator.of(context).maybePop();
      _transitioning = false;
      return;
    }
    setState(() {
      _index += 1;
    });
    await _activateCurrent();
  }

  Future<void> _goPrev() async {
    if (!mounted || _transitioning) return;
    _transitioning = true;
    if (_index <= 0) {
      _transitioning = false;
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
    _photoStopwatch.stop();
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
    _photoStopwatch.start();
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
    final previewUrl = _previewUrl(item);
    final photoUrl = _photoUrlForDisplay(item);

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
              else if (photoUrl != null || previewUrl != null)
                CachedNetworkImage(
                  imageUrl: photoUrl ?? previewUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white70),
                  ),
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
                      child: Row(
                        children: List<Widget>.generate(widget.items.length,
                            (segmentIndex) {
                          final value = segmentIndex < _index
                              ? 1.0
                              : segmentIndex > _index
                                  ? 0.0
                                  : _currentStoryProgress.clamp(0.0, 1.0);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: segmentIndex == widget.items.length - 1
                                      ? 0
                                      : 4),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 3,
                                backgroundColor: Colors.white24,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }),
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

  String? _previewUrl(StoryFeedItem item) {
    return item.thumbnailUrl ?? item.mediaUrl;
  }

  String? _photoUrlForDisplay(StoryFeedItem item) {
    if (item.mediaType != StoryMediaType.photo) {
      return null;
    }
    final preview = _previewUrl(item);
    if (_photoPlaybackReady.contains(item.id) && item.mediaUrl != null) {
      return item.mediaUrl;
    }
    return preview;
  }

  Duration _photoDurationFor(StoryFeedItem item) {
    final durationMs = item.durationMs;
    if (durationMs != null && durationMs > 0) {
      return Duration(milliseconds: durationMs.clamp(1, 60000));
    }
    return _photoDuration;
  }

  void _cancelProgressLoop() {
    _progressTimer?.cancel();
    _progressTimer = null;
    _photoStopwatch
      ..stop()
      ..reset();
    if (mounted) {
      setState(() {
        _currentStoryProgress = 0;
      });
    } else {
      _currentStoryProgress = 0;
    }
  }

  void _startPhotoProgressLoop({
    required int activation,
    required Duration duration,
  }) {
    _cancelProgressLoop();
    if (!_holdingPause) {
      _photoStopwatch.start();
    }
    _progressTimer = Timer.periodic(_progressTick, (_) {
      if (!mounted || activation != _activationToken) {
        _cancelProgressLoop();
        return;
      }
      if (_holdingPause || duration <= Duration.zero) {
        return;
      }
      final progress =
          (_photoStopwatch.elapsed.inMilliseconds / duration.inMilliseconds)
              .clamp(0.0, 1.0);
      if ((progress - _currentStoryProgress).abs() >= 0.01) {
        setState(() {
          _currentStoryProgress = progress;
        });
      }
      if (progress >= 1.0) {
        unawaited(_goNext());
      }
    });
  }

  Future<void> _warmPhotoUrls(
    StoryFeedItem item, {
    required bool updateCurrent,
    required int activation,
  }) async {
    if (!mounted) return;
    final preview = _previewUrl(item);
    if (preview != null) {
      await _precacheImage(preview);
    }
    if (item.mediaType != StoryMediaType.photo || item.mediaUrl == null) {
      return;
    }
    if (_photoPlaybackReady.contains(item.id) || item.mediaUrl == preview) {
      return;
    }
    await _precacheImage(item.mediaUrl!);
    if (!mounted || activation != _activationToken) {
      return;
    }
    _photoPlaybackReady.add(item.id);
    if (updateCurrent && _current.id == item.id) {
      setState(() {});
    }
  }

  Future<void> _precacheImage(String url) async {
    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
    } catch (_) {
      // best effort
    }
  }

  Future<void> _warmNextStory({required int activation}) async {
    if (!mounted || activation != _activationToken) {
      return;
    }
    final nextIndex = _index + 1;
    if (nextIndex >= widget.items.length) {
      await _disposeNextVideoController();
      return;
    }
    final nextItem = widget.items[nextIndex];
    await _warmPhotoUrls(
      nextItem,
      updateCurrent: false,
      activation: activation,
    );
    if (nextItem.mediaType != StoryMediaType.video ||
        nextItem.mediaUrl == null) {
      await _disposeNextVideoController();
      return;
    }
    if (_nextVideoStoryId == nextItem.id &&
        _nextVideoController?.value.isInitialized == true) {
      return;
    }
    await _disposeNextVideoController();
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(nextItem.mediaUrl!));
    try {
      await controller.initialize();
      if (!mounted ||
          activation != _activationToken ||
          _index + 1 >= widget.items.length ||
          widget.items[_index + 1].id != nextItem.id) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(false);
      await controller.setVolume(_muted ? 0 : 1);
      _nextVideoController = controller;
      _nextVideoStoryId = nextItem.id;
    } catch (_) {
      await controller.dispose();
    }
  }

  Future<VideoPlayerController?> _resolveActiveVideoController({
    required StoryFeedItem item,
    required int activation,
  }) async {
    if (item.mediaUrl == null) {
      return null;
    }
    late final VideoPlayerController controller;
    if (_nextVideoStoryId == item.id &&
        _nextVideoController != null &&
        _nextVideoController!.value.isInitialized) {
      controller = _nextVideoController!;
      _nextVideoController = null;
      _nextVideoStoryId = null;
    } else {
      controller = VideoPlayerController.networkUrl(Uri.parse(item.mediaUrl!));
      try {
        await controller.initialize();
      } catch (_) {
        await controller.dispose();
        return null;
      }
    }
    if (!mounted || activation != _activationToken) {
      await controller.dispose();
      return null;
    }
    await controller.setLooping(false);
    await controller.setVolume(_muted ? 0 : 1);
    return controller;
  }

  Future<void> _disposeNextVideoController() async {
    final previous = _nextVideoController;
    _nextVideoController = null;
    _nextVideoStoryId = null;
    if (previous != null) {
      await previous.dispose();
    }
  }
}
