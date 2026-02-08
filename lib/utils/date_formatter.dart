import 'package:intl/intl.dart';

/// Utility class for formatting dates in the application
class DateFormatter {
  DateFormatter._();

  /// Default date format: "January 2, 2026"
  static final DateFormat _defaultFormat = DateFormat('MMMM d, y');

  /// Date format with time: "January 2, 2026, 10:30 AM"
  static final DateFormat _fullFormat = DateFormat('MMMM d, y, h:mm a');

  /// Short date format: "Jan 2, 2026"
  static final DateFormat _shortFormat = DateFormat('MMM d, y');

  /// Date only format: "02/01/2026"
  static final DateFormat _dateOnlyFormat = DateFormat('dd/MM/y');

  /// Time only format: "10:30 AM"
  static final DateFormat _timeOnlyFormat = DateFormat('h:mm a');

  /// Relative date format: "2 days ago"
  static String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      }
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Formats date to default format: "January 2, 2026"
  static String format(DateTime? date) {
    if (date == null) return 'N/A';
    return _defaultFormat.format(date);
  }

  /// Formats date with time: "January 2, 2026, 10:30 AM"
  static String formatWithTime(DateTime? date) {
    if (date == null) return 'N/A';
    return _fullFormat.format(date);
  }

  /// Formats date to short format: "Jan 2, 2026"
  static String formatShort(DateTime? date) {
    if (date == null) return 'N/A';
    return _shortFormat.format(date);
  }

  /// Formats date only: "02/01/2026"
  static String formatDateOnly(DateTime? date) {
    if (date == null) return 'N/A';
    return _dateOnlyFormat.format(date);
  }

  /// Formats time only: "10:30 AM"
  static String formatTimeOnly(DateTime? date) {
    if (date == null) return 'N/A';
    return _timeOnlyFormat.format(date);
  }

  /// Formats date as relative: "2 days ago"
  static String formatRelative(DateTime? date) {
    if (date == null) return 'N/A';
    return _getRelativeDate(date);
  }

  /// Formats date for order display
  /// Shows relative date if within 7 days, otherwise shows full date
  static String formatForOrder(DateTime? date) {
    if (date == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      return _getRelativeDate(date);
    }
    return _fullFormat.format(date);
  }

  /// Parses a date string to DateTime
  static DateTime? parse(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Gets the start of day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Gets the end of day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Checks if two dates are on the same day
  static bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Checks if a date is today
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    return isSameDay(date, DateTime.now());
  }

  /// Checks if a date is yesterday
  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
}
