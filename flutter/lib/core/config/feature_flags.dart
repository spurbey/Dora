import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:dora/core/config/env_config.dart';

class FeatureFlags {
  FeatureFlags._();

  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;
  static bool _initialized = false;

  static const String _enableExportOverride =
      String.fromEnvironment('ENABLE_EXPORT', defaultValue: 'auto');
  static const String _enableRouteDrawingOverride =
      String.fromEnvironment('ENABLE_ROUTE_DRAWING', defaultValue: 'auto');
  static const String _enableLiveSystemV2Override =
      String.fromEnvironment('ENABLE_LIVE_SYSTEM_V2', defaultValue: 'auto');
  static const String _enableV2LocalJournalOverride =
      String.fromEnvironment('ENABLE_V2_LOCAL_JOURNAL', defaultValue: 'auto');
  static const String _enableV2LocalCompilerOverride =
      String.fromEnvironment('ENABLE_V2_LOCAL_COMPILER', defaultValue: 'auto');
  static const String _enableV2SessionCommitWorkerOverride =
      String.fromEnvironment(
    'ENABLE_V2_SESSION_COMMIT_WORKER',
    defaultValue: 'auto',
  );
  static const String _enableV2TripPublishWorkerOverride =
      String.fromEnvironment(
    'ENABLE_V2_TRIP_PUBLISH_WORKER',
    defaultValue: 'auto',
  );
  static const String _enableV2BackendIngestOverride =
      String.fromEnvironment('ENABLE_V2_BACKEND_INGEST', defaultValue: 'auto');
  static const String _enableV2LiveEditorUiContractOverride =
      String.fromEnvironment(
    'ENABLE_V2_LIVE_EDITOR_UI_CONTRACT',
    defaultValue: 'auto',
  );
  static const String _enableAdvisoryPipelineOverride = String.fromEnvironment(
    'ADVISORY_PIPELINE',
    defaultValue: 'auto',
  );
  static const String _enableStoriesPublishOverride =
      String.fromEnvironment('ENABLE_STORIES_PUBLISH', defaultValue: 'auto');
  static const String _enableStoriesFeedOverride =
      String.fromEnvironment('ENABLE_STORIES_FEED', defaultValue: 'auto');
  static const String _enableLiveScreenV3Override =
      String.fromEnvironment('ENABLE_LIVE_SCREEN_V3', defaultValue: 'auto');

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults({
      // Dev should be usable without requiring a Firebase console flag setup.
      'enable_export': !Env.isProduction,
      'enable_route_drawing': false,
      'enable_live_system_v2': false,
      'enable_v2_local_journal': false,
      'enable_v2_local_compiler': false,
      'enable_v2_session_commit_worker': false,
      'enable_v2_trip_publish_worker': false,
      'enable_v2_backend_ingest': false,
      'enable_v2_live_editor_ui_contract': false,
      'enable_advisory_pipeline': false,
      'enable_stories_publish': false,
      'enable_stories_feed': false,
      'enable_live_screen_v3': false,
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep app functional with local defaults when Remote Config is unavailable.
    }

    _initialized = true;
  }

  static bool get enableExport {
    final override = _parseOverride(_enableExportOverride);
    if (override != null) return override;
    if (!_initialized) return !Env.isProduction;
    return _remoteConfig.getBool('enable_export');
  }

  static bool get enableRouteDrawing {
    final override = _parseOverride(_enableRouteDrawingOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_route_drawing');
  }

  static bool get enableLiveSystemV2 {
    final override = _parseOverride(_enableLiveSystemV2Override);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_live_system_v2');
  }

  static bool get enableV2LocalJournal {
    final override = _parseOverride(_enableV2LocalJournalOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_v2_local_journal');
  }

  static bool get enableV2LocalCompiler {
    final override = _parseOverride(_enableV2LocalCompilerOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_v2_local_compiler');
  }

  static bool get enableV2SessionCommitWorker {
    final override = _parseOverride(_enableV2SessionCommitWorkerOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_v2_session_commit_worker');
  }

  static bool get enableV2TripPublishWorker {
    final override = _parseOverride(_enableV2TripPublishWorkerOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_v2_trip_publish_worker');
  }

  static bool get enableV2BackendIngest {
    final override = _parseOverride(_enableV2BackendIngestOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_v2_backend_ingest');
  }

  static bool get enableV2LiveEditorUiContract {
    final override = _parseOverride(_enableV2LiveEditorUiContractOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_v2_live_editor_ui_contract');
  }

  static bool get enableAdvisoryPipeline {
    final override = _parseOverride(_enableAdvisoryPipelineOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_advisory_pipeline');
  }

  static bool get enableStoriesPublish {
    final override = _parseOverride(_enableStoriesPublishOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_stories_publish');
  }

  static bool get enableStoriesFeed {
    final override = _parseOverride(_enableStoriesFeedOverride);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_stories_feed');
  }

  static bool get enableLiveScreenV3 {
    final override = _parseOverride(_enableLiveScreenV3Override);
    if (override != null) return override;
    if (!_initialized) return false;
    return _remoteConfig.getBool('enable_live_screen_v3');
  }

  static bool? _parseOverride(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }
}
