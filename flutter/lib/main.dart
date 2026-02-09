import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/app.dart';
import 'package:dora/core/config/env_config.dart';
import 'package:dora/core/config/feature_flags.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    // Allow app to run without Firebase config files.
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  if (Env.mapboxToken.isNotEmpty) {
    MapboxOptions.setAccessToken(Env.mapboxToken);
  }

  if (firebaseReady) {
    await FeatureFlags.initialize();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
  );

  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.environment = Env.isProduction ? 'production' : 'development';
    },
    appRunner: () => runApp(
      const ProviderScope(child: DoraApp()),
    ),
  );
}
