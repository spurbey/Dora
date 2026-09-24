import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:dora/core/notifications/push_token_client.dart';

/// Mobile-only Firebase push client. Never imported on web (see
/// push_client_factory.dart conditional import) because
/// firebase_messaging_web 3.5.x is incompatible with the current Dart SDK.
class FirebasePushTokenClient implements PushTokenClient {
  FirebasePushTokenClient(this._messaging);

  final FirebaseMessaging _messaging;
  bool _permissionRequested = false;
  Stream<String>? _tokenRefreshStream;

  @override
  Future<bool> ensurePermissionRequested() async {
    if (_permissionRequested) {
      return true;
    }
    _permissionRequested = true;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );
      return settings.authorizationStatus != AuthorizationStatus.denied;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh {
    return _tokenRefreshStream ??=
        _messaging.onTokenRefresh.where((token) => token.isNotEmpty);
  }
}
