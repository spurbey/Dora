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

  static bool? _parseOverride(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }
}
