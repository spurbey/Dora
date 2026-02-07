import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:dora/core/config/env_config.dart';

class Logger {
  Logger._();

  static void debug(String message, [dynamic data]) {
    if (!Env.isProduction) {
      // ignore: avoid_print
      print('DEBUG: $message ${data ?? ''}');
    }
  }

  static void info(String message, [dynamic data]) {
    if (!Env.isProduction) {
      // ignore: avoid_print
      print('INFO: $message ${data ?? ''}');
    }
  }

  static void warning(String message, [dynamic data]) {
    if (!Env.isProduction) {
      // ignore: avoid_print
      print('WARN: $message ${data ?? ''}');
    }
  }

  static void error(String message, dynamic error, StackTrace? stack) {
    // ignore: avoid_print
    print('ERROR: $message');
    if (Env.isProduction) {
      Sentry.captureException(error, stackTrace: stack);
    }
  }
}
