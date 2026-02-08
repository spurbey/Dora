import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '${weeks}w ago';
    }

    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  static String formatTripMeta({
    required int placeCount,
    int? durationDays,
  }) {
    final days = durationDays != null ? ' · $durationDays days' : '';
    return '$placeCount places$days';
  }
}
