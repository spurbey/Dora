import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/presentation/providers/media_upload_provider.dart';

final placeMediaProvider =
    StreamProvider.autoDispose.family<List<MediaItem>, String>(
  (ref, placeId) {
    final repository = ref.watch(mediaRepositoryProvider);
    return repository.watchPlaceMedia(placeId);
  },
);

final placePendingUploadCountProvider =
    StreamProvider.autoDispose.family<int, String>(
  (ref, placeId) {
    final repository = ref.watch(mediaRepositoryProvider);
    return repository.watchPendingCount(placeId);
  },
);
