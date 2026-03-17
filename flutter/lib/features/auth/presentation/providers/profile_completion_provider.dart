import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora_api/dora_api.dart';

class ProfileCompletionStatus {
  const ProfileCompletionStatus({
    required this.requiresCompletion,
    required this.isSocialAuth,
    required this.username,
    required this.fullName,
  });

  final bool requiresCompletion;
  final bool isSocialAuth;
  final String username;
  final String fullName;
}

class ProfileCompletionException implements Exception {
  ProfileCompletionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProfileCompletionRepository {
  ProfileCompletionRepository(this._authService, this._usersApi);

  final AuthService _authService;
  final UsersApi _usersApi;

  Future<ProfileCompletionStatus> getStatus() async {
    final user = _authService.currentUser;
    if (user == null) {
      return const ProfileCompletionStatus(
        requiresCompletion: false,
        isSocialAuth: false,
        username: '',
        fullName: '',
      );
    }

    final isSocialAuth = _isSocialAuth(user);
    if (!isSocialAuth) {
      return const ProfileCompletionStatus(
        requiresCompletion: false,
        isSocialAuth: false,
        username: '',
        fullName: '',
      );
    }

    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return const ProfileCompletionStatus(
        requiresCompletion: false,
        isSocialAuth: true,
        username: '',
        fullName: '',
      );
    }

    try {
      final response = await _usersApi.getCurrentUserProfileApiV1UsersMeGet(
        authorization: 'Bearer $token',
      );
      final profile = response.data;
      final username = profile?.username.trim() ?? '';
      final fullName = profile?.fullName?.trim() ?? '';
      final requiresCompletion = username.isEmpty ||
          fullName.isEmpty ||
          _looksGeneratedUsername(username);

      return ProfileCompletionStatus(
        requiresCompletion: requiresCompletion,
        isSocialAuth: true,
        username: username,
        fullName: fullName,
      );
    } on DioException catch (error) {
      throw ProfileCompletionException(
        _extractErrorMessage(error) ??
            'Unable to check profile status. Please try again.',
      );
    }
  }

  Future<void> completeProfile({
    required String username,
    required String fullName,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ProfileCompletionException(
          'Session expired. Please sign in again.');
    }

    try {
      await _usersApi.updateCurrentUserProfileApiV1UsersMePatch(
        authorization: 'Bearer $token',
        userUpdate: UserUpdate(
          (b) => b
            ..username = username.trim()
            ..fullName = fullName.trim(),
        ),
      );
    } on DioException catch (error) {
      throw ProfileCompletionException(
        _extractErrorMessage(error) ??
            'Unable to update profile. Please try again.',
      );
    }
  }

  bool _isSocialAuth(User user) {
    final provider = user.appMetadata['provider']?.toString().toLowerCase();
    final providersMeta = user.appMetadata['providers'];
    final providers = providersMeta is List
        ? providersMeta.map((p) => p.toString().toLowerCase()).toSet()
        : <String>{};

    if (provider != null && provider.isNotEmpty && provider != 'email') {
      return true;
    }

    return providers.any((value) => value != 'email');
  }

  bool _looksGeneratedUsername(String username) {
    return RegExp(r'^user_[a-z0-9]{4,}$', caseSensitive: false)
        .hasMatch(username);
  }

  String? _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }
    return null;
  }
}

final profileCompletionRepositoryProvider =
    Provider<ProfileCompletionRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final usersApi = ref.watch(usersApiProvider);
  return ProfileCompletionRepository(authService, usersApi);
});

final profileCompletionStatusProvider =
    FutureProvider<ProfileCompletionStatus>((ref) async {
  final repository = ref.watch(profileCompletionRepositoryProvider);
  return repository.getStatus();
});
