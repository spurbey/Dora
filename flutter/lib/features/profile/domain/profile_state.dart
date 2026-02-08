import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/features/profile/data/models/user_profile.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    required UserProfile profile,
    @Default(false) bool isSigningOut,
    @Default(false) bool isClearingCache,
  }) = _ProfileState;
}
