import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/domain/export_template.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';
import 'package:dora/features/export/presentation/screens/export_studio_screen.dart';

void main() {
  group('ExportStudioScreen — configure phase', () {
    testWidgets('disables Start Export when pre-submit guard fails',
        (tester) async {
      final repo = _FakeExportRepository(
        prechecks: [_precheck(hasServerTripId: false)],
      );
      addTearDown(repo.dispose);

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(
        find.text('Trip must be synced before exporting.'),
        findsOneWidget,
      );
    });

    testWidgets('enables Start Export when pre-submit guard passes',
        (tester) async {
      final repo = _FakeExportRepository(
        prechecks: [_precheck(hasServerTripId: true)],
      );
      addTearDown(repo.dispose);

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('re-checks guards at submit time before calling API',
        (tester) async {
      final repo = _FakeExportRepository(
        prechecks: [
          _precheck(hasServerTripId: true),
          _precheck(hasServerTripId: true, pendingMediaCount: 1),
        ],
      );
      addTearDown(repo.dispose);

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Export'));
      await tester.pumpAndSettle();

      expect(repo.submitCalls, 0);
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

    testWidgets('submits export and transitions to tracking phase',
        (tester) async {
      final repo = _FakeExportRepository(
        prechecks: [
          _precheck(hasServerTripId: true),
          _precheck(hasServerTripId: true),
        ],
        submitResult:
            const ExportSubmitResult(jobId: 'job-123', deduplicated: false),
        statusTimeline: [
          _makeJob(ExportJobStatus.queued, jobId: 'job-123'),
        ],
      );
      addTearDown(repo.dispose);

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Export'));
      await tester.pump();
      await tester.pump();

      expect(repo.submitCalls, 1);
      expect(find.text('Waiting in queue...'), findsOneWidget);
    });

    testWidgets('shows template choices and submits selected template',
        (tester) async {
      ExportTemplate? submitted;
      final repo = _FakeExportRepository(
        prechecks: [
          _precheck(hasServerTripId: true),
          _precheck(hasServerTripId: true),
        ],
        submitResult: const ExportSubmitResult(
          jobId: 'job-cinematic',
          deduplicated: false,
        ),
        statusTimeline: [
          _makeJob(ExportJobStatus.queued, jobId: 'job-cinematic'),
        ],
        onSubmit: (template) => submitted = template,
      );
      addTearDown(repo.dispose);

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Cinematic'), findsOneWidget);

      await tester.tap(find.text('Cinematic'));
      await tester.pump();
      await tester.tap(find.text('Start Export'));
      await tester.pump();

      expect(submitted, ExportTemplate.cinematic);
    });
  });

  group('ExportStudioScreen — tracking phase', () {
    testWidgets('shows queued state copy and cancel action', (tester) async {
      await _pumpToTracking(
        tester,
        _makeJob(ExportJobStatus.queued),
      );

      expect(find.text('Waiting in queue...'), findsOneWidget);
      expect(find.text('Cancel Export'), findsOneWidget);
    });

    testWidgets('shows processing stage label and progress bar',
        (tester) async {
      await _pumpToTracking(
        tester,
        _makeJob(
          ExportJobStatus.processing,
          stage: ExportJobStage.rendering,
          progress: 0.5,
        ),
      );

      expect(find.text('Rendering your video...'), findsOneWidget);
      expect(find.text('Rendering video...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows canceling state while cancel_requested', (tester) async {
      await _pumpToTracking(
        tester,
        _makeJob(ExportJobStatus.cancelRequested),
      );

      expect(find.text('Canceling...'), findsOneWidget);
      expect(find.text('Cancel Export'), findsNothing);
    });

    testWidgets('shows failed state and error details', (tester) async {
      await _pumpToTracking(
        tester,
        _makeJob(ExportJobStatus.failed, errorMessage: 'renderer crashed'),
      );

      expect(find.text('Export failed'), findsOneWidget);
      expect(find.text('renderer crashed'), findsOneWidget);
      expect(find.text('Start New Export'), findsOneWidget);
    });

    testWidgets('shows canceled state', (tester) async {
      await _pumpToTracking(
        tester,
        _makeJob(ExportJobStatus.canceled),
      );

      expect(find.text('Export canceled'), findsOneWidget);
      expect(find.text('Start New Export'), findsOneWidget);
    });

    testWidgets('shows blocked state with support link', (tester) async {
      await _pumpToTracking(
        tester,
        _makeJob(ExportJobStatus.blocked, errorCode: 'asset_all_404'),
      );

      expect(find.text('Export blocked'), findsOneWidget);
      expect(
        find.textContaining('All media in this trip is unavailable'),
        findsOneWidget,
      );
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.text('Start New Export'), findsOneWidget);
    });

    testWidgets('navigates to completion screen when job is completed',
        (tester) async {
      await _pumpToTracking(
        tester,
        _makeJob(ExportJobStatus.completed),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Export Ready'), findsOneWidget);
      expect(find.text('Your video is ready'), findsOneWidget);
    });

    testWidgets('refreshes status immediately after cancel confirm',
        (tester) async {
      final repo = _FakeExportRepository(
        prechecks: [
          _precheck(hasServerTripId: true),
          _precheck(hasServerTripId: true),
        ],
        submitResult:
            const ExportSubmitResult(jobId: 'job-cancel', deduplicated: false),
        statusTimeline: [
          _makeJob(ExportJobStatus.queued, jobId: 'job-cancel'),
          _makeJob(ExportJobStatus.canceled, jobId: 'job-cancel'),
        ],
      );
      addTearDown(repo.dispose);

      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Export'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting in queue...'), findsOneWidget);

      await tester.tap(find.text('Cancel Export'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel export'));
      await tester.pump();
      await tester.pump();

      expect(repo.cancelCalls, 1);
      expect(find.text('Export canceled'), findsOneWidget);
    });
  });
}

Widget _wrap(ExportRepositoryContract repo) {
  return ProviderScope(
    overrides: [
      exportRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(
      home: ExportStudioScreen(tripId: 'trip-1'),
    ),
  );
}

Future<void> _pumpToTracking(WidgetTester tester, ExportJob job) async {
  final repo = _FakeExportRepository(
    prechecks: [
      _precheck(hasServerTripId: true),
      _precheck(hasServerTripId: true),
    ],
    submitResult: ExportSubmitResult(jobId: job.jobId, deduplicated: false),
    statusTimeline: [job],
  );
  addTearDown(repo.dispose);

  await tester.pumpWidget(_wrap(repo));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Start Export'));
  await tester.pump();
  await tester.pump();
}

ExportPrecheckResult _precheck({
  required bool hasServerTripId,
  int pendingMediaCount = 0,
  int failedMediaCount = 0,
  int blockingSyncTaskCount = 0,
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

ExportJob _makeJob(
  ExportJobStatus status, {
  String jobId = 'job-test',
  ExportJobStage? stage,
  double progress = 0.0,
  String? errorCode,
  String? errorMessage,
}) {
  return ExportJob(
    jobId: jobId,
    status: status,
    progress: progress,
    stage: stage,
    errorCode: errorCode,
    errorMessage: errorMessage,
  );
}

class _FakeExportRepository implements ExportRepositoryContract {
  _FakeExportRepository({
    required this.prechecks,
    this.submitResult = const ExportSubmitResult(
      jobId: 'job-default',
      deduplicated: false,
    ),
    this.statusTimeline,
    this.onSubmit,
  });

  final List<ExportPrecheckResult> prechecks;
  final ExportSubmitResult submitResult;
  final List<ExportJob>? statusTimeline;
  final void Function(ExportTemplate template)? onSubmit;

  int submitCalls = 0;
  int cancelCalls = 0;
  int _precheckCalls = 0;
  int _statusCalls = 0;

  @override
  Future<ExportPrecheckResult> evaluatePreSubmitGuards(String tripId) async {
    if (prechecks.isEmpty) {
      throw StateError('No precheck results configured.');
    }
    final index =
        _precheckCalls >= prechecks.length ? prechecks.length - 1 : _precheckCalls;
    _precheckCalls += 1;
    return prechecks[index];
  }

  @override
  Future<ExportSubmitResult> submitClassicExport(String localTripId) =>
      submitExport(localTripId, ExportTemplate.classic);

  @override
  Future<ExportSubmitResult> submitExport(
      String localTripId, ExportTemplate template) async {
    submitCalls += 1;
    onSubmit?.call(template);
    return submitResult;
  }

  @override
  Future<ExportJob> getJobStatus(String jobId) async {
    final timeline = statusTimeline;
    if (timeline == null || timeline.isEmpty) {
      throw const ExportRepositoryException('No job status configured.');
    }
    final index = _statusCalls >= timeline.length ? timeline.length - 1 : _statusCalls;
    _statusCalls += 1;
    return timeline[index];
  }

  @override
  Future<void> cancelJob(String jobId) async {
    cancelCalls += 1;
  }

  @override
  Future<String> getDownloadUrl(String jobId) async =>
      'https://example.com/download/$jobId';

  @override
  Future<String> getShareUrl(String jobId) async =>
      'https://dora.app/share/$jobId';

  Future<void> dispose() async {}
}
