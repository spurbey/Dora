import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/media/app_media_uploader.dart';
import 'package:dora/core/media/image_compressor.dart';
import 'package:dora/core/media/thumbnail_generator.dart';
import 'package:dora/core/media/upload_queue_worker.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/media_repository.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.token = 'test-token'});

  final String token;

  @override
  Stream<User?> get authStateChanges => Stream<User?>.value(null);

  @override
  User? get currentUser => null;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<String?> refreshAccessToken({bool force = false}) async => token;

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponse> signUp(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }
}

class _FakeUploader implements AppMediaUploader {
  _FakeUploader({
    this.uploadGate,
    this.uploadedFileUrl = 'https://cdn.example/media.jpg',
    this.remoteMediaId = 'remote-media-id',
  });

  final Completer<void>? uploadGate;
  final String uploadedFileUrl;
  final String remoteMediaId;

  final Completer<void> uploadStarted = Completer<void>();
  int uploadCalls = 0;
  int deleteCalls = 0;
  String? lastTripPlaceId;
  String? lastFilePath;

  @override
  Future<void> deleteMedia({
    required String mediaId,
  }) async {
    deleteCalls += 1;
  }

  @override
  Future<UploadedPhotoResult> uploadPhoto(UploadPhotoRequest request) async {
    uploadCalls += 1;
    lastTripPlaceId = request.tripPlaceId;
    lastFilePath = request.filePath;
    if (!uploadStarted.isCompleted) {
      uploadStarted.complete();
    }

    request.onProgress?.call(0.25);
    if (uploadGate != null) {
      await uploadGate!.future;
    }
    request.onProgress?.call(1.0);

    return UploadedPhotoResult(
      mediaId: remoteMediaId,
      fileUrl: uploadedFileUrl,
      fileType: 'photo',
      tripId: 'remote-trip-id',
      tripPlaceId: request.tripPlaceId,
      createdAt: DateTime.utc(2026, 2, 21),
    );
  }
}

class _PassthroughCompressor extends ImageCompressor {
  const _PassthroughCompressor();

  @override
  Future<CompressedImageResult> compress({
    required String inputPath,
    required String mediaId,
  }) async {
    final source = File(inputPath);
    if (!await source.exists()) {
      throw ImageCompressionException(
        'Source file missing for compression: $inputPath',
      );
    }
    return CompressedImageResult(
      file: source,
      isTemporary: false,
    );
  }
}

class _NoopThumbnailGenerator extends ThumbnailGenerator {
  const _NoopThumbnailGenerator();

  @override
  Future<String?> generate({
    required String sourcePath,
    required String mediaId,
  }) async {
    return null;
  }
}

class _FakePlacesApi extends openapi.PlacesApi {
  _FakePlacesApi()
      : super(
          Dio(),
          openapi.standardSerializers,
        );

  int createCalls = 0;
  String? lastTripId;
  String? lastAuthorization;

  @override
  Future<Response<openapi.PlaceResponse>> createPlaceApiV1PlacesPost({
    required String authorization,
    required openapi.PlaceCreate placeCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCalls += 1;
    lastAuthorization = authorization;
    lastTripId = placeCreate.tripId;

    final now = DateTime.utc(2026, 2, 21);
    final payload = openapi.PlaceResponse((builder) {
      builder
        ..id = 'remote-place-created'
        ..tripId = placeCreate.tripId
        ..userId = 'user-1'
        ..name = placeCreate.name
        ..lat = placeCreate.lat
        ..lng = placeCreate.lng
        ..orderInTrip = placeCreate.orderInTrip
        ..createdAt = now
        ..updatedAt = now;
    });

    return Response<openapi.PlaceResponse>(
      data: payload,
      requestOptions: RequestOptions(path: '/api/v1/places'),
      statusCode: 201,
    );
  }
}

class _TripNotFoundPlacesApi extends openapi.PlacesApi {
  _TripNotFoundPlacesApi()
      : super(
          Dio(),
          openapi.standardSerializers,
        );

  int createCalls = 0;
  String? lastTripId;

  @override
  Future<Response<openapi.PlaceResponse>> createPlaceApiV1PlacesPost({
    required String authorization,
    required openapi.PlaceCreate placeCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCalls += 1;
    lastTripId = placeCreate.tripId;
    throw _tripNotFoundDioException(path: '/api/v1/places');
  }
}

class _StorageMisconfiguredPlacesApi extends openapi.PlacesApi {
  _StorageMisconfiguredPlacesApi()
      : super(
          Dio(),
          openapi.standardSerializers,
        );

  @override
  Future<Response<openapi.PlaceResponse>> createPlaceApiV1PlacesPost({
    required String authorization,
    required openapi.PlaceCreate placeCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final request = RequestOptions(path: '/api/v1/places');
    final response = Response<dynamic>(
      requestOptions: request,
      statusCode: 503,
      statusMessage: 'Service Unavailable',
      data: <String, dynamic>{'detail': 'Storage service misconfigured'},
    );

    throw DioException(
      requestOptions: request,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Storage service misconfigured',
    );
  }
}

class _FakeTripsApi extends openapi.TripsApi {
  _FakeTripsApi({
    this.existingTripIds = const <String>{},
  }) : super(
          Dio(),
          openapi.standardSerializers,
        );

  final Set<String> existingTripIds;
  int getCalls = 0;
  int createCalls = 0;
  String? lastGetTripId;

  @override
  Future<Response<openapi.TripResponse>> getTripApiV1TripsTripIdGet({
    required String tripId,
    required String authorization,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    getCalls += 1;
    lastGetTripId = tripId;

    if (!existingTripIds.contains(tripId)) {
      throw _tripNotFoundDioException(path: '/api/v1/trips/$tripId');
    }

    final now = DateTime.utc(2026, 2, 21);
    return Response<openapi.TripResponse>(
      data: openapi.TripResponse((builder) {
        builder
          ..id = tripId
          ..userId = 'user-1'
          ..title = 'Existing Trip'
          ..visibility = 'private'
          ..viewsCount = 0
          ..savesCount = 0
          ..createdAt = now
          ..updatedAt = now;
      }),
      requestOptions: RequestOptions(path: '/api/v1/trips/$tripId'),
      statusCode: 200,
    );
  }

  @override
  Future<Response<openapi.TripResponse>> createTripApiV1TripsPost({
    required String authorization,
    required openapi.TripCreate tripCreate,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    createCalls += 1;
    throw StateError(
      'createTripApiV1TripsPost should not be called in stale-trip retry path tests',
    );
  }
}

DioException _tripNotFoundDioException({
  required String path,
}) {
  final request = RequestOptions(path: path);
  final response = Response<dynamic>(
    requestOptions: request,
    statusCode: 404,
    statusMessage: 'Not Found',
    data: <String, dynamic>{'detail': 'Trip not found'},
  );
  return DioException(
    requestOptions: request,
    response: response,
    type: DioExceptionType.badResponse,
    message: 'Trip not found',
  );
}

Future<File> _createTempFile(String suffix) async {
  final dir = await Directory.systemTemp.createTemp('dora-media-test');
  final file = File('${dir.path}/$suffix');
  await file.writeAsBytes(const [1, 2, 3, 4, 5], flush: true);
  return file;
}

Future<void> _clearTables(AppDatabase database) async {
  await database.customStatement('DELETE FROM media_attachments');
  await database.customStatement('DELETE FROM media');
  await database.customStatement('DELETE FROM routes');
  await database.customStatement('DELETE FROM places');
  await database.customStatement('DELETE FROM user_trips');
  await database.customStatement('DELETE FROM public_trips');
  await database.customStatement('DELETE FROM trips');
}

Future<List<MediaItem>> _mediaRowsForPlace(
  AppDatabase database,
  String placeLocalId,
) async {
  final rows = await database.customSelect(
    '''
    SELECT m.* FROM media m
    INNER JOIN media_attachments ma ON ma.media_id = m.id
    WHERE ma.target_kind = 'place'
      AND ma.target_local_id = ?
      AND ma.role = 'review'
      AND ma.detached_at IS NULL
      AND m.deleted_at IS NULL
    ORDER BY m.captured_at DESC
    ''',
    variables: [drift.Variable<String>(placeLocalId)],
    readsFrom: {database.media, database.mediaAttachments},
  ).get();
  return rows.map((row) => database.media.map(row.data)).toList(growable: false);
}

Future<void> _insertTripRow({
  required AppDatabase database,
  required String localTripId,
  required String? serverTripId,
}) async {
  final now = DateTime.utc(2026, 2, 21);
  await database.tripDao.insertTrip(
    TripsCompanion(
      id: drift.Value(localTripId),
      serverTripId: drift.Value(serverTripId),
      userId: const drift.Value('user-1'),
      name: const drift.Value('Trip for Media Tests'),
      description: const drift.Value.absent(),
      startDate: const drift.Value.absent(),
      endDate: const drift.Value.absent(),
      tags: const drift.Value(<String>[]),
      visibility: const drift.Value('private'),
      centerPoint: const drift.Value.absent(),
      zoom: const drift.Value(12.0),
      localUpdatedAt: drift.Value(now),
      serverUpdatedAt: drift.Value(now),
      syncStatus: const drift.Value('synced'),
      createdAt: drift.Value(now),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Media upload integration', () {
    late AppDatabase database;
    late _FakeAuthService authService;
    late TripRepository tripRepository;
    late PlaceRepository placeRepository;
    late _FakeUploader uploader;
    late UploadQueueWorker queueWorker;
    late MediaRepository mediaRepository;
    late Directory testSupportDir;

    const localTripId = 'local-trip-1';
    const localPlaceId = 'local-place-1';
    const remotePlaceId = 'remote-place-1';

    Future<void> seedPlaceWithRemoteId() async {
      final now = DateTime.utc(2026, 2, 21);
      await placeRepository.addPlace(
        Place(
          id: localPlaceId,
          serverPlaceId: remotePlaceId,
          tripId: localTripId,
          name: 'Seed Place',
          coordinates: const AppLatLng(latitude: 37.7749, longitude: -122.4194),
          orderIndex: 0,
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'pending',
        ),
      );
    }

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      await _clearTables(database);
      testSupportDir =
          await Directory.systemTemp.createTemp('dora-media-support');

      authService = _FakeAuthService();
      tripRepository = TripRepository(database, authService);
      placeRepository = PlaceRepository(
        database,
        tripRepository: tripRepository,
      );
      uploader = _FakeUploader();
      queueWorker = UploadQueueWorker(
        database: database,
        placeRepository: placeRepository,
        uploader: uploader,
        imageCompressor: const _PassthroughCompressor(),
        thumbnailGenerator: const _NoopThumbnailGenerator(),
        maxConcurrency: 1,
      );
      mediaRepository = MediaRepository(
        database,
        queueWorker: queueWorker,
        placeRepository: placeRepository,
        mediaUploader: uploader,
        supportDirectoryProvider: () async => testSupportDir,
        resolveOwnerUserId: () => 'user-1',
      );
    });

    tearDown(() async {
      await _clearTables(database);
      await database.close();
      if (await testSupportDir.exists()) {
        await testSupportDir.delete(recursive: true);
      }
    });

    test('queued media uploads and bridges photo URL into place', () async {
      await seedPlaceWithRemoteId();
      final source = await _createTempFile('queue-success.jpg');
      addTearDown(() async {
        if (await source.exists()) {
          await source.delete();
        }
      });

      await mediaRepository.enqueueFilePaths(
        tripId: localTripId,
        placeId: localPlaceId,
        filePaths: [source.path],
      );
      await mediaRepository.enqueueMediaForTripPublish(localTripId);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final mediaRows = await _mediaRowsForPlace(database, localPlaceId);
      expect(mediaRows, hasLength(1));
      final row = mediaRows.single;
      expect(row.uploadState, 'uploaded');
      expect(row.uploadProgress, 1.0);
      expect(row.remoteUrl, isNotNull);
      expect(row.remoteUrl, uploader.uploadedFileUrl);
      expect(uploader.lastTripPlaceId, remotePlaceId);

      final place = await placeRepository.getPlace(localPlaceId);
      expect(place, isNotNull);
      expect(place!.photoUrls, contains(uploader.uploadedFileUrl));
    });

    test('editor media stays local_only until trip publish triggers queueing',
        () async {
      await seedPlaceWithRemoteId();
      final source = await _createTempFile('queue-local-only.jpg');
      addTearDown(() async {
        if (await source.exists()) {
          await source.delete();
        }
      });

      await mediaRepository.enqueueFilePaths(
        tripId: localTripId,
        placeId: localPlaceId,
        filePaths: [source.path],
      );

      // Before publish: worker should not touch local_only rows.
      await queueWorker.startIfIdle();
      final beforePublish = await _mediaRowsForPlace(database, localPlaceId);
      expect(beforePublish, hasLength(1));
      expect(beforePublish.single.uploadState, 'local_only');
      expect(uploader.uploadCalls, 0);

      // Simulate trip publish — flips local_only → queued, then worker runs.
      await mediaRepository.enqueueMediaForTripPublish(localTripId);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final afterPublish = await _mediaRowsForPlace(database, localPlaceId);
      expect(afterPublish.single.uploadState, 'uploaded');
      expect(uploader.uploadCalls, 1);
    });

    test('canceling in-flight upload keeps row canceled and avoids URL bridge',
        () async {
      await seedPlaceWithRemoteId();

      final source = await _createTempFile('queue-cancel.jpg');
      addTearDown(() async {
        if (await source.exists()) {
          await source.delete();
        }
      });

      final mediaId = 'media-cancel-1';
      final now = DateTime.utc(2026, 2, 21);
      await database.mediaDao.insertMedia(
        MediaCompanion.insert(
          id: mediaId,
          ownerUserId: 'user-cancel',
          originScope: 'editor',
          mediaType: const drift.Value('photo'),
          localUri: drift.Value(source.path),
          capturedAt: now,
          uploadState: const drift.Value('queued'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.mediaAttachmentsDao.insertAttachment(
        MediaAttachmentsCompanion.insert(
          id: 'attach-cancel-1',
          mediaId: mediaId,
          targetKind: 'place',
          targetLocalId: localPlaceId,
          role: 'review',
          attachedAt: now,
        ),
      );

      final gate = Completer<void>();
      uploader = _FakeUploader(
        uploadGate: gate,
        uploadedFileUrl: 'https://cdn.example/canceled.jpg',
        remoteMediaId: 'remote-canceled-id',
      );
      queueWorker = UploadQueueWorker(
        database: database,
        placeRepository: placeRepository,
        uploader: uploader,
        imageCompressor: const _PassthroughCompressor(),
        thumbnailGenerator: const _NoopThumbnailGenerator(),
        maxConcurrency: 1,
      );
      mediaRepository = MediaRepository(
        database,
        queueWorker: queueWorker,
        placeRepository: placeRepository,
        mediaUploader: uploader,
        supportDirectoryProvider: () async => testSupportDir,
        resolveOwnerUserId: () => 'user-1',
      );

      final processing = queueWorker.startIfIdle();
      await uploader.uploadStarted.future.timeout(const Duration(seconds: 3));

      await mediaRepository.cancelUpload(mediaId);
      gate.complete();
      await processing;

      final row = await database.mediaDao.getMediaById(mediaId);
      expect(row, isNotNull);
      expect(row!.uploadState, 'canceled');
      expect(row.remoteUrl, isNull);
      expect(uploader.deleteCalls, 1);

      final place = await placeRepository.getPlace(localPlaceId);
      expect(place, isNotNull);
      expect(place!.photoUrls, isEmpty);
    });

    test('ensureRemotePlaceId uses serverTripId for place creation', () async {
      const localTripWithServerId = 'local-trip-2';
      const serverTripId = 'remote-trip-2';
      const localPlaceWithoutServer = 'local-place-2';
      await _insertTripRow(
        database: database,
        localTripId: localTripWithServerId,
        serverTripId: serverTripId,
      );

      final now = DateTime.utc(2026, 2, 21);
      await database.placeDao.insertPlace(
        PlacesCompanion(
          id: const drift.Value(localPlaceWithoutServer),
          serverPlaceId: const drift.Value(null),
          tripId: const drift.Value(localTripWithServerId),
          name: const drift.Value('Needs Remote Place'),
          address: const drift.Value.absent(),
          coordinates: const drift.Value(
              AppLatLng(latitude: 51.5072, longitude: -0.1276)),
          notes: const drift.Value.absent(),
          visitTime: const drift.Value.absent(),
          dayNumber: const drift.Value.absent(),
          orderIndex: const drift.Value(1),
          photoUrls: const drift.Value(<String>[]),
          placeType: const drift.Value.absent(),
          rating: const drift.Value.absent(),
          localUpdatedAt: drift.Value(now),
          serverUpdatedAt: drift.Value(now),
          syncStatus: const drift.Value('pending'),
        ),
      );

      final fakePlacesApi = _FakePlacesApi();
      final repo = PlaceRepository(
        database,
        tripRepository: TripRepository(database, authService),
        placesApi: fakePlacesApi,
        authService: authService,
      );

      final remotePlaceIdResolved =
          await repo.ensureRemotePlaceId(localPlaceWithoutServer);

      expect(remotePlaceIdResolved, 'remote-place-created');
      expect(fakePlacesApi.lastTripId, serverTripId);
      expect(fakePlacesApi.lastAuthorization, startsWith('Bearer '));

      final place = await repo.getPlace(localPlaceWithoutServer);
      expect(place, isNotNull);
      expect(place!.serverPlaceId, 'remote-place-created');
    });

    test('ensureRemotePlaceId deduplicates across repository instances',
        () async {
      const localTripWithServerId = 'local-trip-shared-dedup';
      const serverTripId = 'remote-trip-shared-dedup';
      const localPlaceWithoutServer = 'local-place-shared-dedup';

      await _insertTripRow(
        database: database,
        localTripId: localTripWithServerId,
        serverTripId: serverTripId,
      );

      final now = DateTime.utc(2026, 2, 21);
      await database.placeDao.insertPlace(
        PlacesCompanion(
          id: const drift.Value(localPlaceWithoutServer),
          serverPlaceId: const drift.Value(null),
          tripId: const drift.Value(localTripWithServerId),
          name: const drift.Value('Shared Dedup Place'),
          address: const drift.Value.absent(),
          coordinates: const drift.Value(
            AppLatLng(latitude: 28.2096, longitude: 83.9856),
          ),
          notes: const drift.Value.absent(),
          visitTime: const drift.Value.absent(),
          dayNumber: const drift.Value.absent(),
          orderIndex: const drift.Value(1),
          photoUrls: const drift.Value(<String>[]),
          placeType: const drift.Value.absent(),
          rating: const drift.Value.absent(),
          localUpdatedAt: drift.Value(now),
          serverUpdatedAt: drift.Value(now),
          syncStatus: const drift.Value('pending'),
        ),
      );

      final fakePlacesApi = _FakePlacesApi();
      final repoA = PlaceRepository(
        database,
        tripRepository: TripRepository(database, authService),
        placesApi: fakePlacesApi,
        authService: authService,
      );
      final repoB = PlaceRepository(
        database,
        tripRepository: TripRepository(database, authService),
        placesApi: fakePlacesApi,
        authService: authService,
      );

      final results = await Future.wait([
        repoA.ensureRemotePlaceId(localPlaceWithoutServer),
        repoB.ensureRemotePlaceId(localPlaceWithoutServer),
      ]);

      expect(results, ['remote-place-created', 'remote-place-created']);
      expect(fakePlacesApi.createCalls, 1);

      final place = await repoA.getPlace(localPlaceWithoutServer);
      expect(place, isNotNull);
      expect(place!.serverPlaceId, 'remote-place-created');
    });

    test(
        'stale serverTripId does not create new backend trip after trip-not-found',
        () async {
      const localTripWithStaleServerId = 'local-trip-stale';
      const staleServerTripId = 'remote-trip-deleted';
      const localPlaceWithoutServer = 'local-place-stale';
      await _insertTripRow(
        database: database,
        localTripId: localTripWithStaleServerId,
        serverTripId: staleServerTripId,
      );

      final now = DateTime.utc(2026, 2, 21);
      await database.placeDao.insertPlace(
        PlacesCompanion(
          id: const drift.Value(localPlaceWithoutServer),
          serverPlaceId: const drift.Value(null),
          tripId: const drift.Value(localTripWithStaleServerId),
          name: const drift.Value('Stale Trip Place'),
          address: const drift.Value.absent(),
          coordinates: const drift.Value(
              AppLatLng(latitude: 48.8566, longitude: 2.3522)),
          notes: const drift.Value.absent(),
          visitTime: const drift.Value.absent(),
          dayNumber: const drift.Value.absent(),
          orderIndex: const drift.Value(1),
          photoUrls: const drift.Value(<String>[]),
          placeType: const drift.Value.absent(),
          rating: const drift.Value.absent(),
          localUpdatedAt: drift.Value(now),
          serverUpdatedAt: drift.Value(now),
          syncStatus: const drift.Value('pending'),
        ),
      );

      final fakeTripsApi = _FakeTripsApi();
      final failingPlacesApi = _TripNotFoundPlacesApi();
      final staleAwareTripRepository = TripRepository(
        database,
        authService,
        tripsApi: fakeTripsApi,
      );
      final repo = PlaceRepository(
        database,
        tripRepository: staleAwareTripRepository,
        placesApi: failingPlacesApi,
        authService: authService,
      );

      await expectLater(
        repo.ensureRemotePlaceId(localPlaceWithoutServer),
        throwsA(
          isA<PlaceIdentityException>().having(
            (error) => error.message,
            'message',
            contains('Trip is not available on backend for media upload'),
          ),
        ),
      );

      expect(failingPlacesApi.createCalls, 1);
      expect(failingPlacesApi.lastTripId, staleServerTripId);
      expect(fakeTripsApi.getCalls, 1);
      expect(fakeTripsApi.lastGetTripId, localTripWithStaleServerId);
      expect(fakeTripsApi.createCalls, 0);

      final tripAfterFailure =
          await staleAwareTripRepository.getTrip(localTripWithStaleServerId);
      expect(tripAfterFailure, isNotNull);
      expect(tripAfterFailure!.serverTripId, isNull);
    });

    test('non-retryable storage misconfiguration is surfaced from place sync',
        () async {
      const localTripWithServerId = 'local-trip-storage-misconfig';
      const serverTripId = 'remote-trip-storage-misconfig';
      const localPlaceWithoutServer = 'local-place-storage-misconfig';

      await _insertTripRow(
        database: database,
        localTripId: localTripWithServerId,
        serverTripId: serverTripId,
      );

      final now = DateTime.utc(2026, 2, 21);
      await database.placeDao.insertPlace(
        PlacesCompanion(
          id: const drift.Value(localPlaceWithoutServer),
          serverPlaceId: const drift.Value(null),
          tripId: const drift.Value(localTripWithServerId),
          name: const drift.Value('Storage Misconfigured Place'),
          address: const drift.Value.absent(),
          coordinates: const drift.Value(
            AppLatLng(latitude: 40.7128, longitude: -74.0060),
          ),
          notes: const drift.Value.absent(),
          visitTime: const drift.Value.absent(),
          dayNumber: const drift.Value.absent(),
          orderIndex: const drift.Value(1),
          photoUrls: const drift.Value(<String>[]),
          placeType: const drift.Value.absent(),
          rating: const drift.Value.absent(),
          localUpdatedAt: drift.Value(now),
          serverUpdatedAt: drift.Value(now),
          syncStatus: const drift.Value('pending'),
        ),
      );

      final repo = PlaceRepository(
        database,
        tripRepository: TripRepository(
          database,
          authService,
          tripsApi: _FakeTripsApi(existingTripIds: {serverTripId}),
        ),
        placesApi: _StorageMisconfiguredPlacesApi(),
        authService: authService,
      );

      await expectLater(
        repo.ensureRemotePlaceId(localPlaceWithoutServer),
        throwsA(
          isA<PlaceIdentityException>()
              .having((error) => error.retryable, 'retryable', false)
              .having(
                (error) => error.message,
                'message',
                contains('Backend storage is misconfigured'),
              ),
        ),
      );
    });
  });
}
