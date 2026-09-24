import 'package:dora/core/notifications/push_token_client.dart';

/// Web factory — push disabled for web MVP (no FCM VAPID/service-worker
/// wired yet). Lifecycle bootstrap becomes a safe no-op.
PushTokenClient createPushClient() => const NoopPushTokenClient();
