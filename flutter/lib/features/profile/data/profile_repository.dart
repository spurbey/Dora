import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/profile/data/models/user_profile.dart';
import 'package:dora/features/trips/data/models/trip_stats.dart';

class ProfileRepository {
  ProfileRepository(this._db, this._authService);

  final AppDatabase _db;
  final AuthService _authService;

  Future<UserProfile> getProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw ProfileRepositoryException('No authenticated user');
    }

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
}

class ProfileRepositoryException implements Exception {
  ProfileRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
