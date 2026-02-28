import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';
import 'package:dora/features/export/presentation/screens/export_studio_screen.dart';

void main() {
  group('ExportStudioScreen', () {
    testWidgets('disables Start Export when pre-submit guard fails',
        (tester) async {
      final fakeRepository = _FakeExportRepository(
        prechecks: [
          _precheck(
            hasServerTripId: false,
            pendingMediaCount: 0,
            failedMediaCount: 0,
            blockingSyncTaskCount: 0,
          ),
        ],
      );
      addTearDown(fakeRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ExportStudioScreen(tripId: 'trip-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(
          find.text('Trip must be synced before exporting.'), findsOneWidget);
    });

    testWidgets('enables Start Export when pre-submit guard passes',
        (tester) async {
      final fakeRepository = _FakeExportRepository(
        prechecks: [
          _precheck(
            hasServerTripId: true,
            pendingMediaCount: 0,
            failedMediaCount: 0,
            blockingSyncTaskCount: 0,
          ),
        ],
      );
      addTearDown(fakeRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ExportStudioScreen(tripId: 'trip-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('re-checks guards at submit time before calling API',
        (tester) async {
      final fakeRepository = _FakeExportRepository(
        prechecks: [
          _precheck(
            hasServerTripId: true,
            pendingMediaCount: 0,
            failedMediaCount: 0,
            blockingSyncTaskCount: 0,
          ),
          _precheck(
            hasServerTripId: true,
            pendingMediaCount: 1,
            failedMediaCount: 0,
            blockingSyncTaskCount: 0,
          ),
        ],
      );
      addTearDown(fakeRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ExportStudioScreen(tripId: 'trip-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Export'));
      await tester.pumpAndSettle();

      expect(fakeRepository.submitCalls, 0);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching:
              find.text('Finish pending media uploads before exporting.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('submits export when latest guard check passes',
        (tester) async {
      final fakeRepository = _FakeExportRepository(
        prechecks: [
          _precheck(
            hasServerTripId: true,
            pendingMediaCount: 0,
            failedMediaCount: 0,
            blockingSyncTaskCount: 0,
          ),
          _precheck(
            hasServerTripId: true,
            pendingMediaCount: 0,
            failedMediaCount: 0,
            blockingSyncTaskCount: 0,
          ),
        ],
        submitResult: const ExportSubmitResult(
          jobId: 'job-123',
          deduplicated: false,
        ),
      );
      addTearDown(fakeRepository.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: ExportStudioScreen(tripId: 'trip-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Export'));
      await tester.pumpAndSettle();

      expect(fakeRepository.submitCalls, 1);
      expect(find.text('Export job queued: job-123'), findsOneWidget);
    });
  });
}

ExportPrecheckResult _precheck({
  required bool hasServerTripId,
  required int pendingMediaCount,
  required int failedMediaCount,
  required int blockingSyncTaskCount,
}) {
  return ExportPrecheckResult(
    tripId: 'trip-1',
    tripExists: true,
    hasServerTripId: hasServerTripId,
    pendingMediaCount: pendingMediaCount,
    failedMediaCount: failedMediaCount,
    blockingSyncTaskCount: blockingSyncTaskCount,
  );
}

class _FakeExportRepository implements ExportRepositoryContract {
  _FakeExportRepository({
    required this.prechecks,
    this.submitResult = const ExportSubmitResult(
      jobId: 'job-default',
      deduplicated: false,
    ),
    this.submitError,
  });

  final List<ExportPrecheckResult> prechecks;
  final ExportSubmitResult submitResult;
  final ExportRepositoryException? submitError;

  int submitCalls = 0;
  int _precheckCalls = 0;

  @override
  Future<ExportPrecheckResult> evaluatePreSubmitGuards(String tripId) async {
    if (prechecks.isEmpty) {
      throw StateError('No precheck results configured for fake repository.');
    }
    final index = _precheckCalls >= prechecks.length
        ? prechecks.length - 1
        : _precheckCalls;
    _precheckCalls += 1;
    return prechecks[index];
  }

  @override
  Future<ExportSubmitResult> submitClassicExport(String localTripId) async {
    submitCalls += 1;
    final error = submitError;
    if (error != null) {
      throw error;
    }
    return submitResult;
  }

  Future<void> dispose() async {}
}
