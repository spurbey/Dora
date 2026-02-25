import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/navigation/app_router.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/theme/app_theme.dart';
import 'package:dora/features/create/presentation/providers/entity_sync_provider.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';

class DoraApp extends ConsumerWidget {
  const DoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appDatabaseInitProvider);
    ref.watch(entitySyncBootstrapProvider);
    ref.watch(mediaQueueBootstrapProvider);
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
