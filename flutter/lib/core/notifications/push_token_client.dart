abstract class PushTokenClient {
  Future<bool> ensurePermissionRequested();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;
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
