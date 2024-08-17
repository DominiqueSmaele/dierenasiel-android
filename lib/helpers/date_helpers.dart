extension DateHelpers on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isBeforeTime {
    final now = DateTime.now();

    return now.hour >= hour && now.minute >= minute;
  }
}
