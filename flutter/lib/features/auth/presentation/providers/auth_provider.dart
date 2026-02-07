import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(Supabase.instance.client);
}

@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<User?> build() {
    final service = ref.watch(authServiceProvider);
    return service.authStateChanges;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(authServiceProvider);
      await service.signInWithEmail(email, password);
      return service.currentUser;
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(authServiceProvider);
      await service.signUp(email, password);
      return service.currentUser;
    });
  }

  Future<void> signOut() async {
    final service = ref.read(authServiceProvider);
    await service.signOut();
  }
}
