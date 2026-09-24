import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/notifications/push_client_factory.dart';
import 'package:dora/core/notifications/push_token_client.dart';
import 'package:dora/core/notifications/push_token_lifecycle_bootstrap.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';

final pushTokenClientProvider = Provider<PushTokenClient>((ref) {
  return createPushClient();
});

final pushTokenLifecycleBootstrapProvider = Provider<void>((ref) {
  final authService = ref.watch(authServiceProvider);
  final liveTrackingApi = ref.watch(liveTrackingApiProvider);
  final pushTokenClient = ref.watch(pushTokenClientProvider);

  final bootstrap = PushTokenLifecycleBootstrap(
    authStateChanges: authService.authStateChanges,
    isSignedIn: () => authService.currentUser != null,
    liveTrackingApi: liveTrackingApi,
    pushTokenClient: pushTokenClient,
  );
  bootstrap.start();

  ref.onDispose(bootstrap.dispose);
});
