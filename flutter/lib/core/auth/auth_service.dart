import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthTokenProvider {
  Future<String?> getAccessToken();

  Future<String?> refreshAccessToken({bool force});
}

class AuthService implements AuthTokenProvider {
  AuthService(this._supabase);

  final SupabaseClient _supabase;
  Future<String?>? _refreshInFlight;

  Stream<User?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<String?> getAccessToken() async {
    return refreshAccessToken(force: false);
  }

  @override
  Future<String?> refreshAccessToken({bool force = false}) async {
    final current = _supabase.auth.currentSession;
    if (current == null) {
      return null;
    }

    if (!force && !current.isExpired) {
      return current.accessToken;
    }

    if (_refreshInFlight != null) {
      return _refreshInFlight;
    }

    final refresh = _runRefresh();
    _refreshInFlight = refresh;
    try {
      return await refresh;
    } finally {
      if (identical(_refreshInFlight, refresh)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<String?> _runRefresh() async {
    try {
      final refreshed = await _supabase.auth.refreshSession();
      return refreshed.session?.accessToken ??
          _supabase.auth.currentSession?.accessToken;
    } catch (_) {
      final latest = _supabase.auth.currentSession;
      if (latest != null && !latest.isExpired) {
        return latest.accessToken;
      }
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.dora.travel://login-callback/',
    );
  }
}
