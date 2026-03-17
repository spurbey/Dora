import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this._supabase);

  final SupabaseClient _supabase;

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

  Future<String?> getAccessToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      return null;
    }

    if (!session.isExpired) {
      return session.accessToken;
    }

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
