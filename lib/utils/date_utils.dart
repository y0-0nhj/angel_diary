String getDateString(DateTime date) {
  return date.toIso8601String().split('T')[0];
}

String getFormattedDate(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now).inDays;

  if (difference == 0) {
    return '오늘';
  } else if (difference == -1) {
    return '어제';
  } else if (difference == 1) {
    return '내일';
  }

  return '${date.year}년 ${date.month}월 ${date.day}일';
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

DateTime getStartOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime getEndOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59);
}
