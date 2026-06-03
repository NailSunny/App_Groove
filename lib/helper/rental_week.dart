/// Диапазон аренды для клиента: текущая и следующая неделя (пн … вс).
abstract final class RentalWeek {
  static DateTime mondayOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final offset = d.weekday - 1;
    return d.subtract(Duration(days: offset));
  }

  static DateTime get allowedStart => mondayOfWeek(DateTime.now());

  static DateTime get allowedEnd => allowedStart.add(const Duration(days: 13));

  static bool isAllowed(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (d.isBefore(todayOnly)) return false;
    return !d.isBefore(allowedStart) && !d.isAfter(allowedEnd);
  }

  static String cacheKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Слоты студии (совпадают с [ScheduleSlotConstants] на API).
abstract final class StudioSlots {
  static const times = [
    '08:30',
    '09:40',
    '10:50',
    '12:00',
    '13:10',
    '14:20',
    '15:30',
    '16:40',
    '17:50',
    '19:00',
    '20:10',
  ];

  static int indexOf(String time) => times.indexOf(time);
}
