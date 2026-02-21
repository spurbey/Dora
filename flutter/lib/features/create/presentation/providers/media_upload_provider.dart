import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/media/adapters/dora_media_uploader.dart';
import 'package:dora/core/media/app_media_uploader.dart';
import 'package:dora/core/media/image_compressor.dart';
import 'package:dora/core/media/media_permissions.dart';
import 'package:dora/core/media/media_queue_bootstrap.dart';
import 'package:dora/core/media/thumbnail_generator.dart';
import 'package:dora/core/media/upload_queue_worker.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/create/data/media_repository.dart';
import 'package:dora/features/create/data/place_repository.dart';

final mediaPermissionsProvider = Provider<MediaPermissions>(
  (ref) => const MediaPermissions(),
);

final imageCompressorProvider = Provider<ImageCompressor>(
  (ref) => const ImageCompressor(),
);

final thumbnailGeneratorProvider = Provider<ThumbnailGenerator>(
  (ref) => const ThumbnailGenerator(),
);

final placeRepositoryForMediaProvider = Provider<PlaceRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final searchApi = ref.watch(searchApiProvider);
  final placesApi = ref.watch(placesApiProvider);
  final authService = ref.watch(authServiceProvider);
  return PlaceRepository(
    db,
    searchApi: searchApi,
    placesApi: placesApi,
    authService: authService,
  );
});

final appMediaUploaderProvider = Provider<AppMediaUploader>((ref) {
  final mediaApi = ref.watch(mediaApiProvider);
  final authService = ref.watch(authServiceProvider);
  return DoraMediaUploader(
    mediaApi: mediaApi,
    authService: authService,
  );
});

final uploadQueueWorkerProvider = Provider<UploadQueueWorker>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final placeRepository = ref.watch(placeRepositoryForMediaProvider);
  final uploader = ref.watch(appMediaUploaderProvider);
  final compressor = ref.watch(imageCompressorProvider);
  final thumbnailGenerator = ref.watch(thumbnailGeneratorProvider);
  return UploadQueueWorker(
    database: db,
    placeRepository: placeRepository,
    uploader: uploader,
    imageCompressor: compressor,
    thumbnailGenerator: thumbnailGenerator,
  );
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final queueWorker = ref.watch(uploadQueueWorkerProvider);
  final placeRepository = ref.watch(placeRepositoryForMediaProvider);
  final uploader = ref.watch(appMediaUploaderProvider);
  return MediaRepository(
    db,
    queueWorker: queueWorker,
    placeRepository: placeRepository,
    mediaUploader: uploader,
  );
});

final mediaQueueBootstrapProvider = Provider<void>((ref) {
  final worker = ref.watch(uploadQueueWorkerProvider);
  final bootstrap = MediaQueueBootstrap(worker);
  bootstrap.start();
  ref.onDispose(bootstrap.dispose);
});

class MediaUploadContext {
  const MediaUploadContext({
    required this.tripId,
    required this.placeId,
  });

  final String tripId;
  final String placeId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MediaUploadContext &&
        other.tripId == tripId &&
        other.placeId == placeId;
  }

  @override
  int get hashCode => Object.hash(tripId, placeId);
}

class MediaUploadState {
  const MediaUploadState({
    this.submitting = false,
    this.selectedPaths = const <String>[],
    this.errorMessage,
    this.infoMessage,
  });

  final bool submitting;
  final List<String> selectedPaths;
  final String? errorMessage;
  final String? infoMessage;

  MediaUploadState copyWith({
    bool? submitting,
    List<String>? selectedPaths,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return MediaUploadState(
      submitting: submitting ?? this.submitting,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}

class MediaUploadController extends StateNotifier<MediaUploadState> {
  MediaUploadController({
    required MediaRepository repository,
    required MediaUploadContext context,
  })  : _repository = repository,
        _context = context,
        super(const MediaUploadState());

  final MediaRepository _repository;
  final MediaUploadContext _context;

  static const int maxSelection = 10;

  void addSelectedPaths(List<String> paths) {
    if (paths.isEmpty) {
      return;
    }
    final merged = [...state.selectedPaths];
    for (final path in paths) {
      if (!merged.contains(path)) {
        merged.add(path);
      }
    }
    final clipped = merged.take(maxSelection).toList();
    final truncated = clipped.length < merged.length;
    state = state.copyWith(
      selectedPaths: clipped,
      infoMessage:
          truncated ? 'Selection capped at $maxSelection photos.' : null,
      clearInfo: !truncated,
      clearError: true,
    );
  }

  void removeSelectedPath(String path) {
    final updated = [...state.selectedPaths]..remove(path);
    state = state.copyWith(
      selectedPaths: updated,
      clearError: true,
      clearInfo: true,
    );
  }

  Future<bool> enqueueSelection() async {
    if (state.selectedPaths.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Select at least one photo before enqueue.',
        clearInfo: true,
      );
      return false;
    }

    state = state.copyWith(submitting: true, clearError: true, clearInfo: true);
    try {
      await _repository.enqueueFilePaths(
        tripId: _context.tripId,
        placeId: _context.placeId,
        filePaths: state.selectedPaths,
      );
      state = state.copyWith(
        submitting: false,
        selectedPaths: const <String>[],
        clearError: true,
        clearInfo: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        submitting: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<void> retryUpload(String mediaId) async {
    await _repository.retryUpload(mediaId);
  }

  Future<void> cancelUpload(String mediaId) async {
    await _repository.cancelUpload(mediaId);
  }

  Future<void> removeMedia(String mediaId) async {
    await _repository.removeMedia(mediaId);
  }

  Future<void> startQueue() async {
    await _repository.startQueue();
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }
}

final mediaUploadControllerProvider = StateNotifierProvider.family<
    MediaUploadController, MediaUploadState, MediaUploadContext>(
  (ref, context) {
    final repository = ref.watch(mediaRepositoryProvider);
    return MediaUploadController(
      repository: repository,
      context: context,
    );
  },
);
