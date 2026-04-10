import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/config/live_system_v2_gate.dart';
import 'package:dora/core/navigation/app_router.dart';
import 'package:dora/core/notifications/live_tracking_deep_link_provider.dart';
import 'package:dora/core/notifications/push_token_lifecycle_provider.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/app_theme.dart';
import 'package:dora/features/create/presentation/providers/entity_sync_provider.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_runtime_provider.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';
import 'package:dora/features/create/presentation/providers/tracking_sync_provider.dart';

class DoraApp extends ConsumerWidget {
  const DoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDatabaseInitProvider);
    ref.watch(liveSystemV2ObservabilityBootstrapProvider);
    ref.watch(entitySyncBootstrapProvider);
    ref.watch(trackingSyncBootstrapProvider);
    ref.watch(liveTrackingCaptureBootstrapProvider);
    ref.watch(mediaQueueBootstrapProvider);
    ref.watch(pushTokenLifecycleBootstrapProvider);
    ref.watch(liveTrackingDeepLinkBootstrapProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Dora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
