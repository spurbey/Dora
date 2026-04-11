class Env {
  Env._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const String mapboxToken =
      String.fromEnvironment('MAPBOX_TOKEN', defaultValue: '');
  static const String orsApiKey =
      String.fromEnvironment('ORS_API_KEY', defaultValue: '');
  static const String openRouteServiceApiKey =
      String.fromEnvironment('OPENROUTESERVICE_API_KEY', defaultValue: '');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8000');
  static const String sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static bool get isProduction =>
      const String.fromEnvironment('ENVIRONMENT') == 'production';
  static bool get isStaging =>
      const String.fromEnvironment('ENVIRONMENT') == 'staging';
  static bool get isDevelopment => !isProduction && !isStaging;

  static String get effectiveOrsApiKey {
    final ors = orsApiKey.trim();
    if (ors.isNotEmpty) {
      return ors;
    }
    return openRouteServiceApiKey.trim();
  }
}
