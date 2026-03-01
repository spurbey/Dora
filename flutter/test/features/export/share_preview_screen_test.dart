import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora_api/dora_api.dart';

import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/presentation/providers/export_provider.dart';
import 'package:dora/features/export/presentation/screens/share_preview_screen.dart';

void main() {
  group('SharePreviewScreen', () {
    testWidgets('renders Export Ready heading', (tester) async {
      await tester.pumpWidget(_wrap(_completedJob()));
      await tester.pump();
      expect(find.text('Export Ready'), findsOneWidget);
      expect(find.text('Your video is ready'), findsOneWidget);
    });

    testWidgets('shows Download Video and Copy Share Link buttons',
        (tester) async {
      await tester.pumpWidget(_wrap(_completedJob()));
      await tester.pump();
      expect(find.text('Download Video'), findsOneWidget);
      expect(find.text('Copy Share Link'), findsOneWidget);
    });

    testWidgets('shows thumbnail placeholder when thumbnailUrl is null',
        (tester) async {
      final job = ExportJob(
        jobId: 'job-1',
        status: ExportJobStatus.completed,
        progress: 1.0,
        thumbnailUrl: null,
      );
      await tester.pumpWidget(_wrap(job));
      await tester.pump();
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });

    testWidgets('Done button navigates back', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportRepositoryProvider.overrideWithValue(_FakeRepo()),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SharePreviewScreen(
                        job: _completedJob(),
                        tripId: 'trip-1',
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Export Ready'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Export Ready'), findsNothing);
    });
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

ExportJob _completedJob() => const ExportJob(
      jobId: 'job-1',
      status: ExportJobStatus.completed,
      progress: 1.0,
      outputUrl: 'https://example.com/video.mp4',
      thumbnailUrl: null,
    );

Widget _wrap(ExportJob job) {
  return ProviderScope(
    overrides: [
      exportRepositoryProvider.overrideWithValue(_FakeRepo()),
    ],
    child: MaterialApp(
      home: SharePreviewScreen(job: job, tripId: 'trip-1'),
    ),
  );
}

class _FakeRepo implements ExportRepositoryContract {
  @override
  Future<ExportPrecheckResult> evaluatePreSubmitGuards(String tripId) async =>
      throw UnimplementedError();

  @override
  Future<ExportSubmitResult> submitClassicExport(String localTripId) async =>
      throw UnimplementedError();

  @override
  Future<ExportSubmitResult> submitExport(
          String localTripId, ExportTemplate template) async =>
      throw UnimplementedError();

  @override
  Future<ExportJob> getJobStatus(String jobId) async =>
      throw UnimplementedError();

  @override
  Future<void> cancelJob(String jobId) async {}

  @override
  Future<String> getDownloadUrl(String jobId) async =>
      'https://example.com/download/$jobId';

  @override
  Future<String> getShareUrl(String jobId) async =>
      'https://dora.app/share/$jobId';
}
