import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/config/live_system_v2_gate.dart';

void main() {
  group('LiveSystemV2Gate', () {
    test('denies when global V2 flag is disabled', () {
      final gate = LiveSystemV2Gate(
        readFlags: () => const LiveSystemV2FlagSnapshot(
          enableLiveSystemV2: false,
          enableV2LocalJournal: true,
          enableV2LocalCompiler: true,
          enableV2SessionCommitWorker: true,
          enableV2TripPublishWorker: true,
          enableV2BackendIngest: true,
          enableV2LiveEditorUiContract: true,
        ),
      );

      final decision = gate.evaluate(
        tripId: 'trip-1',
        surface: LiveSystemV2Surface.live,
        requiredSubsystems: const {LiveSystemV2Subsystem.localJournal},
      );

      expect(decision.enabled, isFalse);
      expect(decision.deniedByFlag, 'enable_live_system_v2');
    });

    test('denies when required sub-flag is disabled', () {
      final gate = LiveSystemV2Gate(
        readFlags: () => const LiveSystemV2FlagSnapshot(
          enableLiveSystemV2: true,
          enableV2LocalJournal: true,
          enableV2LocalCompiler: false,
          enableV2SessionCommitWorker: true,
          enableV2TripPublishWorker: true,
          enableV2BackendIngest: true,
          enableV2LiveEditorUiContract: true,
        ),
      );

      final decision = gate.evaluate(
        tripId: 'trip-2',
        surface: LiveSystemV2Surface.editor,
        requiredSubsystems: const {
          LiveSystemV2Subsystem.localCompiler,
          LiveSystemV2Subsystem.liveEditorUiContract,
        },
      );

      expect(decision.enabled, isFalse);
      expect(decision.deniedByFlag, 'enable_v2_local_compiler');
    });

    test('allows when global and required sub-flags are enabled', () {
      final gate = LiveSystemV2Gate(
        readFlags: () => const LiveSystemV2FlagSnapshot(
          enableLiveSystemV2: true,
          enableV2LocalJournal: true,
          enableV2LocalCompiler: true,
          enableV2SessionCommitWorker: false,
          enableV2TripPublishWorker: false,
          enableV2BackendIngest: false,
          enableV2LiveEditorUiContract: true,
        ),
      );

      final decision = gate.evaluate(
        tripId: 'trip-3',
        surface: LiveSystemV2Surface.editor,
        requiredSubsystems: const {
          LiveSystemV2Subsystem.localCompiler,
          LiveSystemV2Subsystem.liveEditorUiContract,
        },
      );

      expect(decision.enabled, isTrue);
      expect(decision.deniedByFlag, isNull);
    });

    test('prevents dual write when both V1 and V2 writes are requested', () {
      final gate = LiveSystemV2Gate(
        readFlags: () => const LiveSystemV2FlagSnapshot(
          enableLiveSystemV2: true,
          enableV2LocalJournal: true,
          enableV2LocalCompiler: true,
          enableV2SessionCommitWorker: true,
          enableV2TripPublishWorker: true,
          enableV2BackendIngest: true,
          enableV2LiveEditorUiContract: true,
        ),
      );

      final allowed = gate.preventDualWrite(
        tripId: 'trip-4',
        surface: LiveSystemV2Surface.runtime,
        v1WriteRequested: true,
        v2WriteRequested: true,
      );

      expect(allowed, isFalse);
    });
  });
}
