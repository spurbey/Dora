import 'package:firebase_messaging/firebase_messaging.dart';

abstract class PushTokenClient {
  Future<bool> ensurePermissionRequested();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;
}

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

class NoopPushTokenClient implements PushTokenClient {
  const NoopPushTokenClient();

  @override
  Future<bool> ensurePermissionRequested() async => false;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();
}
