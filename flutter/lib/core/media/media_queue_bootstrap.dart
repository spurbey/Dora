import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:dora/core/media/upload_queue_worker.dart';

class MediaQueueBootstrap with WidgetsBindingObserver {
  MediaQueueBootstrap(
    this._worker, {
    Duration heartbeatInterval = const Duration(seconds: 20),
  }) : _heartbeatInterval = heartbeatInterval;

  final UploadQueueWorker _worker;
  final Duration _heartbeatInterval;

  Timer? _heartbeatTimer;
  bool _started = false;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      unawaited(_worker.startIfIdle());
    });
    unawaited(_worker.startIfIdle());
  }

  void dispose() {
    if (!_started) {
      return;
    }
    _started = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_worker.startIfIdle());
    }
  }
}
