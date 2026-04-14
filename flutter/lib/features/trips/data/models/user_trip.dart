import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_trip.freezed.dart';
part 'user_trip.g.dart';

@freezed
class UserTrip with _$UserTrip {
  const factory UserTrip({
    required String id,
    required String userId,
    required String name,
    String? description,
    String? coverPhotoUrl,
    DateTime? startDate,
    DateTime? endDate,
    @Default('private') String visibility,
    @Default(0) int placeCount,
    @Default('editing') String status,
    DateTime? lastEditedAt,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('synced') String syncStatus,
    required DateTime createdAt,
  }) = _UserTrip;

  factory UserTrip.fromJson(Map<String, dynamic> json) =>
      _$UserTripFromJson(json);
}

extension UserTripX on UserTrip {
  bool get isActive => status == 'live_editing';
  bool get isCompleted => status == 'saved' || status == 'published';
  bool get isShared => status == 'published' || visibility == 'public';

  int? get durationDays {
    if (startDate == null || endDate == null) {
      return null;
    }
    final diff = endDate!.difference(startDate!).inDays;
    return diff >= 0 ? diff + 1 : null;
  }
}
