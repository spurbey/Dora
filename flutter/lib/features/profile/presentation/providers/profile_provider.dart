import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/features/profile/data/models/user_profile.dart';
import 'package:dora/features/profile/data/profile_repository.dart';

part 'profile_provider.g.dart';

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final authService = ref.watch(authServiceProvider);
  return ProfileRepository(db, authService);
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<UserProfile> build() async {
    final repository = ref.watch(profileRepositoryProvider);
    return repository.getProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      return repository.getProfile();
    });
  }

  Future<void> clearCache() async {
    final repository = ref.read(profileRepositoryProvider);
    await repository.clearCache();
    await refresh();
  }

  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
  }
}
