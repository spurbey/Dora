import 'dart:async';

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
import 'package:dora/features/live_tracking/v2/commit/v2_session_commit_models.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';

class DoraApp extends ConsumerStatefulWidget {
  const DoraApp({super.key});

  @override
  ConsumerState<DoraApp> createState() => _DoraAppState();
}

class _DoraAppState extends ConsumerState<DoraApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(v2SessionCommitOrchestratorProvider).runGlobal(
              source: V2CommitTriggerSource.resumed,
              limit: 20,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
