import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/config/feature_flags.dart';
import 'package:dora/core/utils/logger.dart';

enum LiveSystemV2Surface {
  live('live'),
  editor('editor'),
  runtime('runtime');

  const LiveSystemV2Surface(this.value);
  final String value;
}

enum LiveSystemV2Subsystem {
  localJournal('enable_v2_local_journal'),
  localCompiler('enable_v2_local_compiler'),
  sessionCommitWorker('enable_v2_session_commit_worker'),
  tripPublishWorker('enable_v2_trip_publish_worker'),
  backendIngest('enable_v2_backend_ingest'),
  liveEditorUiContract('enable_v2_live_editor_ui_contract');

  const LiveSystemV2Subsystem(this.flagKey);
  final String flagKey;
}

class LiveSystemV2FlagSnapshot {
  const LiveSystemV2FlagSnapshot({
    required this.enableLiveSystemV2,
    required this.enableV2LocalJournal,
    required this.enableV2LocalCompiler,
    required this.enableV2SessionCommitWorker,
    required this.enableV2TripPublishWorker,
    required this.enableV2BackendIngest,
    required this.enableV2LiveEditorUiContract,
  });

  factory LiveSystemV2FlagSnapshot.fromFeatureFlags() {
    return LiveSystemV2FlagSnapshot(
      enableLiveSystemV2: FeatureFlags.enableLiveSystemV2,
      enableV2LocalJournal: FeatureFlags.enableV2LocalJournal,
      enableV2LocalCompiler: FeatureFlags.enableV2LocalCompiler,
      enableV2SessionCommitWorker: FeatureFlags.enableV2SessionCommitWorker,
      enableV2TripPublishWorker: FeatureFlags.enableV2TripPublishWorker,
      enableV2BackendIngest: FeatureFlags.enableV2BackendIngest,
      enableV2LiveEditorUiContract: FeatureFlags.enableV2LiveEditorUiContract,
    );
  }

  final bool enableLiveSystemV2;
  final bool enableV2LocalJournal;
  final bool enableV2LocalCompiler;
  final bool enableV2SessionCommitWorker;
  final bool enableV2TripPublishWorker;
  final bool enableV2BackendIngest;
  final bool enableV2LiveEditorUiContract;

  bool isEnabledForSubsystem(LiveSystemV2Subsystem subsystem) {
    switch (subsystem) {
      case LiveSystemV2Subsystem.localJournal:
        return enableV2LocalJournal;
      case LiveSystemV2Subsystem.localCompiler:
        return enableV2LocalCompiler;
      case LiveSystemV2Subsystem.sessionCommitWorker:
        return enableV2SessionCommitWorker;
      case LiveSystemV2Subsystem.tripPublishWorker:
        return enableV2TripPublishWorker;
      case LiveSystemV2Subsystem.backendIngest:
        return enableV2BackendIngest;
      case LiveSystemV2Subsystem.liveEditorUiContract:
        return enableV2LiveEditorUiContract;
    }
  }

  Map<String, Object> toLogData() {
    return <String, Object>{
      'enable_live_system_v2': enableLiveSystemV2,
      'enable_v2_local_journal': enableV2LocalJournal,
      'enable_v2_local_compiler': enableV2LocalCompiler,
      'enable_v2_session_commit_worker': enableV2SessionCommitWorker,
      'enable_v2_trip_publish_worker': enableV2TripPublishWorker,
      'enable_v2_backend_ingest': enableV2BackendIngest,
      'enable_v2_live_editor_ui_contract': enableV2LiveEditorUiContract,
    };
  }
}

class LiveSystemV2Decision {
  const LiveSystemV2Decision({
    required this.tripId,
    required this.surface,
    required this.requiredSubsystems,
    required this.enabled,
    required this.deniedByFlag,
  });

  final String tripId;
  final LiveSystemV2Surface surface;
  final Set<LiveSystemV2Subsystem> requiredSubsystems;
  final bool enabled;
  final String? deniedByFlag;
}

typedef LiveSystemV2FlagReader = LiveSystemV2FlagSnapshot Function();

class LiveSystemV2Gate {
  LiveSystemV2Gate({
    LiveSystemV2FlagReader? readFlags,
  }) : _readFlags = readFlags ?? LiveSystemV2FlagSnapshot.fromFeatureFlags;

  final LiveSystemV2FlagReader _readFlags;
  final Set<String> _evaluatedEventKeys = <String>{};
  final Set<String> _deniedEventKeys = <String>{};
  final Set<String> _dualWriteGuardKeys = <String>{};

  LiveSystemV2Decision evaluate({
    required String tripId,
    required LiveSystemV2Surface surface,
    Set<LiveSystemV2Subsystem> requiredSubsystems = const {},
  }) {
    final flags = _readFlags();
    final normalizedRequirements = requiredSubsystems.toList(growable: false)
      ..sort((a, b) => a.flagKey.compareTo(b.flagKey));

    String? deniedByFlag;
    if (!flags.enableLiveSystemV2) {
      deniedByFlag = 'enable_live_system_v2';
    } else {
      for (final subsystem in normalizedRequirements) {
        if (!flags.isEnabledForSubsystem(subsystem)) {
          deniedByFlag = subsystem.flagKey;
          break;
        }
      }
    }

    final enabled = deniedByFlag == null;
    final decision = LiveSystemV2Decision(
      tripId: tripId,
      surface: surface,
      requiredSubsystems: Set<LiveSystemV2Subsystem>.from(
        normalizedRequirements,
      ),
      enabled: enabled,
      deniedByFlag: deniedByFlag,
    );
    _emitEvaluation(decision);
    if (!enabled) {
      _emitDeniedSubflag(decision, deniedByFlag);
    }
    return decision;
  }

  bool preventDualWrite({
    required String tripId,
    required LiveSystemV2Surface surface,
    required bool v1WriteRequested,
    required bool v2WriteRequested,
    String? reason,
  }) {
    if (!v1WriteRequested || !v2WriteRequested) {
      return true;
    }
    final key = '$tripId|${surface.value}|${reason ?? ''}';
    if (_dualWriteGuardKeys.add(key)) {
      Logger.warning(
        'v2_guard_dual_write_prevented',
        <String, Object?>{
          'trip_id': tripId,
          'surface': surface.value,
          'reason': reason ?? 'mixed_v1_v2_write_request',
        },
      );
    }
    return false;
  }

  void _emitEvaluation(LiveSystemV2Decision decision) {
    final requiredFlags = decision.requiredSubsystems
        .map((subsystem) => subsystem.flagKey)
        .toList(growable: false)
      ..sort();
    final key = [
      decision.tripId,
      decision.surface.value,
      decision.enabled.toString(),
      decision.deniedByFlag ?? '',
      requiredFlags.join(','),
    ].join('|');
    if (_evaluatedEventKeys.add(key)) {
      Logger.info(
        'v2_gate_evaluated',
        <String, Object?>{
          'trip_id': decision.tripId,
          'surface': decision.surface.value,
          'enabled': decision.enabled,
          'required_subflags': requiredFlags,
          'denied_by': decision.deniedByFlag,
        },
      );
    }
  }

  void _emitDeniedSubflag(
    LiveSystemV2Decision decision,
    String deniedByFlag,
  ) {
    final key = [
      decision.tripId,
      decision.surface.value,
      deniedByFlag,
    ].join('|');
    if (_deniedEventKeys.add(key)) {
      Logger.warning(
        'v2_gate_denied_subflag',
        <String, Object?>{
          'trip_id': decision.tripId,
          'surface': decision.surface.value,
          'denied_by': deniedByFlag,
        },
      );
    }
  }
}

final liveSystemV2RolloutGateProvider = Provider<LiveSystemV2Gate>((ref) {
  return LiveSystemV2Gate();
});

bool _didEmitV2FlagSnapshot = false;

final liveSystemV2ObservabilityBootstrapProvider = Provider<void>((ref) {
  if (_didEmitV2FlagSnapshot) {
    return;
  }
  _didEmitV2FlagSnapshot = true;
  final snapshot = LiveSystemV2FlagSnapshot.fromFeatureFlags();
  Logger.info('v2_flags_snapshot', snapshot.toLogData());
});
