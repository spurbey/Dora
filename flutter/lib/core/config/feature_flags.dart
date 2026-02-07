import 'package:firebase_remote_config/firebase_remote_config.dart';

class FeatureFlags {
  FeatureFlags._();

  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  static bool get enableExport => _remoteConfig.getBool('enable_export');
  static bool get enableRouteDrawing =>
      _remoteConfig.getBool('enable_route_drawing');
}
