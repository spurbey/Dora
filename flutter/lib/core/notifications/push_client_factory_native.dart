import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:dora/core/notifications/push_token_client.dart';
import 'package:dora/core/notifications/push_token_client_firebase.dart';

/// Mobile factory — may throw if Firebase isn't configured; provider falls
/// back to Noop.
PushTokenClient createPushClient() {
  try {
    return FirebasePushTokenClient(FirebaseMessaging.instance);
  } catch (_) {
    return const NoopPushTokenClient();
  }
}
