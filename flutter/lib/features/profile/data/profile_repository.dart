import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/profile/data/models/user_profile.dart';
import 'package:dora/features/trips/data/models/trip_stats.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class ProfileRepository {
  ProfileRepository(
    this._db,
    this._authService, {
    openapi.UsersApi? usersApi,
  }) : _usersApi = usersApi;

  final AppDatabase _db;
  final AuthService _authService;
  final openapi.UsersApi? _usersApi;

  Future<UserProfile> getProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw ProfileRepositoryException('No authenticated user');
    }

    final fallback = await _getLocalProfile(user);
    final usersApi = _usersApi;
    if (usersApi == null) {
      return fallback;
    }

    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return fallback;
    }

    try {
      final response =
          await usersApi.getCurrentUserCompleteProfileApiV1UsersMeProfileGet(
        authorization: 'Bearer $token',
      );
      final remote = response.data;
      if (remote == null) {
        return fallback;
      }
      return _mapRemoteProfile(remote);
    } catch (_) {
      return fallback;
    }
  }

  Future<TripStats> getStats() async {
    final trips = await _db.userTripsDao.getTrips();
    final totalPlaces = trips.fold<int>(
      0,
      (sum, trip) => sum + trip.placeCount,
    );

    return TripStats(
      totalTrips: trips.length,
      totalPlaces: totalPlaces,
      totalVideos: 0,
      totalViews: 0,
    );
  }

  Future<void> updateAvatar(Object file) async {
    // TODO: Replace with real upload flow in Phase 4.
  }

  Future<void> clearCache() async {
    await _db.transaction(() async {
      await _db.delete(_db.userTrips).go();
      await _db.delete(_db.publicTrips).go();
      await _db.delete(_db.trips).go();
      await _db.delete(_db.places).go();
      await _db.delete(_db.routes).go();
      await _db.delete(_db.media).go();
    });
  }

  String _fallbackUsername(User user) {
    final email = user.email;
    if (email == null || !email.contains('@')) {
      return 'Traveler';
    }
    return email.split('@').first;
  }

  Future<UserProfile> _getLocalProfile(User user) async {
    final stats = await getStats();
    final username =
        (user.userMetadata?['username'] as String?) ?? _fallbackUsername(user);
    final avatarUrl = user.userMetadata?['avatar_url'] as String?;

    return UserProfile(
      userId: user.id,
      username: username,
      email: user.email ?? '',
      avatarUrl: avatarUrl,
      stats: stats,
    );
  }

  UserProfile _mapRemoteProfile(openapi.UserProfileResponse response) {
    final user = response.user;
    final stats = response.stats;
    return UserProfile(
      userId: user.id,
      username: user.username,
      email: user.email,
      avatarUrl: user.avatarUrl,
      stats: TripStats(
        totalTrips: stats.tripCount ?? 0,
        totalPlaces: stats.placeCount ?? 0,
        totalVideos: 0,
        totalViews: stats.totalViews ?? 0,
      ),
    );
  }
}

class ProfileRepositoryException implements Exception {
  ProfileRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
