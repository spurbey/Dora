import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/capture/data/media_capture_file_store.dart';
import 'package:dora/features/capture/domain/capture_orchestrator.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';

final mediaCaptureFileStoreProvider = Provider<MediaCaptureFileStore>((ref) {
  return const MediaCaptureFileStore();
});

final captureOrchestratorProvider = Provider<CaptureOrchestrator>((ref) {
  return CaptureOrchestrator(
    mediaDao: ref.watch(mediaDaoProvider),
    storiesDao: ref.watch(storiesDaoProvider),
    liveCaptureRepository: ref.watch(v2LiveCaptureJournalRepositoryProvider),
    fileStore: ref.watch(mediaCaptureFileStoreProvider),
    locationService: ref.watch(locationServiceProvider),
    resolveOwnerUserId: () =>
        Supabase.instance.client.auth.currentUser?.id ?? 'unknown',
  );
});
