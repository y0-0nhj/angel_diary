class DateUtils {
  static String getDateString(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  static String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return '오늘';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return '어제';
    } else if (dateToCheck == today.add(const Duration(days: 1))) {
      return '내일';
    }

    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = startOfDay(start);
    final endDate = startOfDay(end);

    while (!isSameDay(current, endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    days.add(endDate);

    return days;
  }
}
