import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/notifications/push_token_client.dart';

class PushTokenLifecycleBootstrap with WidgetsBindingObserver {
  PushTokenLifecycleBootstrap({
    required Stream<Object?> authStateChanges,
    required bool Function() isSignedIn,
    required LiveTrackingApi liveTrackingApi,
    required PushTokenClient pushTokenClient,
    Uuid? uuid,
    DateTime Function()? clock,
    String Function()? platformResolver,
    String? Function()? localeResolver,
  }) : _authStateChanges = authStateChanges,
       _isSignedIn = isSignedIn,
       _liveTrackingApi = liveTrackingApi,
       _pushTokenClient = pushTokenClient,
       _uuid = uuid ?? const Uuid(),
       _clock = clock ?? (() => DateTime.now().toUtc()),
       _platformResolver = platformResolver ?? defaultPushPlatform,
       _localeResolver = localeResolver ?? defaultLocaleTag;

  final Stream<Object?> _authStateChanges;
  final bool Function() _isSignedIn;
  final LiveTrackingApi _liveTrackingApi;
  final PushTokenClient _pushTokenClient;
  final Uuid _uuid;
  final DateTime Function() _clock;
  final String Function() _platformResolver;
  final String? Function() _localeResolver;

  StreamSubscription<Object?>? _authSubscription;
  StreamSubscription<String>? _refreshSubscription;
  String? _lastKnownToken;
  String? _queuedTokenOverride;
  bool _started = false;
  bool _signedIn = false;
  bool _syncInFlight = false;
  bool _registerPending = false;

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    _signedIn = _isSignedIn();

    WidgetsBinding.instance.addObserver(this);
    _authSubscription = _authStateChanges.listen(_handleAuthStateChanged);
    _refreshSubscription = _pushTokenClient.onTokenRefresh.listen(
      (token) {
        if (!_signedIn || token.isEmpty) {
          return;
        }
        _scheduleRegister(tokenOverride: token);
      },
      onError: (_) {},
    );

    if (_signedIn) {
      _scheduleRegister();
    }
  }

  void dispose() {
    if (!_started) {
      return;
    }
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_authSubscription?.cancel());
    unawaited(_refreshSubscription?.cancel());
    _authSubscription = null;
    _refreshSubscription = null;
    _queuedTokenOverride = null;
    _registerPending = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _signedIn) {
      _scheduleRegister();
    }
  }

  void _handleAuthStateChanged(Object? user) {
    final nextSignedIn = user != null;
    if (nextSignedIn == _signedIn) {
      return;
    }

    _signedIn = nextSignedIn;
    if (_signedIn) {
      _scheduleRegister();
      return;
    }

    _queuedTokenOverride = null;
    _registerPending = false;
    unawaited(_deactivateAfterRegisterDrain());
  }

  void _scheduleRegister({String? tokenOverride}) {
    if (!_signedIn) {
      return;
    }
    final normalizedToken = tokenOverride?.trim();
    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      _queuedTokenOverride = normalizedToken;
    }
    if (_syncInFlight) {
      _registerPending = true;
      return;
    }
    unawaited(_drainRegisterQueue());
  }

  Future<void> _drainRegisterQueue() async {
    if (_syncInFlight) {
      return;
    }
    _syncInFlight = true;
    try {
      do {
        _registerPending = false;
        final tokenOverride = _queuedTokenOverride;
        _queuedTokenOverride = null;
        await _registerCurrentToken(tokenOverride: tokenOverride);
      } while (_registerPending && _signedIn);
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> _registerCurrentToken({String? tokenOverride}) async {
    if (!_signedIn) {
      return;
    }

    final permissionGranted = await _pushTokenClient.ensurePermissionRequested();
    if (!permissionGranted) {
      return;
    }

    final token = tokenOverride ?? await _pushTokenClient.getToken();
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) {
      return;
    }
    if (!_signedIn) {
      return;
    }

    try {
      await _liveTrackingApi.registerDeviceToken(
        idempotencyKey: _uuid.v4(),
        clientEventId: _uuid.v4(),
        platform: _platformResolver(),
        pushToken: normalizedToken,
        seenAt: _clock(),
        locale: _localeResolver(),
      );
      _lastKnownToken = normalizedToken;
    } catch (_) {
      // Best-effort lifecycle sync to avoid blocking app flows.
    }
  }

  Future<void> _deactivateAfterRegisterDrain() async {
    var spin = 0;
    while (_syncInFlight && spin < 30) {
      spin += 1;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await _deactivateLastKnownToken();
  }

  Future<void> _deactivateLastKnownToken() async {
    final token = _lastKnownToken ?? await _pushTokenClient.getToken();
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) {
      return;
    }

    try {
      await _liveTrackingApi.deactivateDeviceToken(
        idempotencyKey: _uuid.v4(),
        clientEventId: _uuid.v4(),
        pushToken: normalizedToken,
        deactivatedAt: _clock(),
      );
      _lastKnownToken = null;
    } catch (_) {
      // Best-effort lifecycle sync to avoid blocking logout.
    }
  }
}

String defaultPushPlatform() {
  if (kIsWeb) {
    return 'web';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.android:
      return 'android';
    default:
      return 'web';
  }
}

String? defaultLocaleTag() {
  final locale = PlatformDispatcher.instance.locale;
  final tag = locale.toLanguageTag();
  if (tag.isEmpty) {
    return null;
  }
  return tag;
}
