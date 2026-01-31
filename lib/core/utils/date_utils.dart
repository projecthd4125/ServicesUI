import 'package:intl/intl.dart';

/// Utility class for date formatting and manipulation
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _standardFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _fullFormat = DateFormat('MMMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy hh:mm a');

  /// Format date in standard format (e.g., "Jan 23, 2026")
  static String formatDate(DateTime date) {
    return _standardFormat.format(date);
  }

  /// Format date in full format (e.g., "January 23, 2026")
  static String formatDateFull(DateTime date) {
    return _fullFormat.format(date);
  }

  /// Format time (e.g., "02:30 PM")
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format date and time (e.g., "Jan 23, 2026 02:30 PM")
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format date range (e.g., "Jan 23, 2026 - Jan 30, 2026")
  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}
