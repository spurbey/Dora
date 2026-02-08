import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/features/trips/data/models/trip_stats.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String username,
    required String email,
    String? avatarUrl,
    required TripStats stats,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
