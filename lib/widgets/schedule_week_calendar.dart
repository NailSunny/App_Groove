import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Календарь недели как в [SchedulePage] (стрелки, диапазон дат, дни пн–вс).
class ScheduleWeekCalendar extends StatelessWidget {
  final DateTime currentWeek;
  final int selectedDayIndex;
  final ValueChanged<DateTime> onWeekChanged;
  final ValueChanged<int> onDaySelected;
  /// Не листать недели раньше текущей (для клиентского расписания).
  final bool blockPastWeeks;

  const ScheduleWeekCalendar({
    super.key,
    required this.currentWeek,
    required this.selectedDayIndex,
    required this.onWeekChanged,
    required this.onDaySelected,
    this.blockPastWeeks = false,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = currentWeek.subtract(
      Duration(days: currentWeek.weekday - 1),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    final today = DateTime.now();
    final currentWeekStart = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_left,
                color: blockPastWeeks &&
                        weekStart.isAtSameMomentAs(currentWeekStart)
                    ? Colors.white24
                    : Colors.white,
              ),
              onPressed: blockPastWeeks
                  ? () {
                      final newWeek = currentWeek.subtract(const Duration(days: 7));
                      final newWeekStart = DateTime(newWeek.year, newWeek.month, newWeek.day)
                          .subtract(Duration(days: newWeek.weekday - 1));
                      if (!newWeekStart.isBefore(currentWeekStart)) {
                        onWeekChanged(newWeek);
                      }
                    }
                  : () => onWeekChanged(currentWeek.subtract(Duration(days: 7))),
            ),
            Text(
              '${DateFormat('d MMM', 'ru').format(weekDays.first)} - '
              '${DateFormat('d MMM', 'ru').format(weekDays.last)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => onWeekChanged(currentWeek.add(const Duration(days: 7))),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final day = weekDays[i];
            final selected = i == selectedDayIndex;
            return GestureDetector(
              onTap: () => onDaySelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  border: selected
                      ? Border.all(color: Color(0xFFFFCC32), width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'ru').format(day),
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    SizedBox(height: 2),
                    Text(
                      DateFormat('d', 'ru').format(day),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  static DateTime weekMonday(DateTime currentWeek) =>
      currentWeek.subtract(Duration(days: currentWeek.weekday - 1));

  static DateTime selectedDate(DateTime currentWeek, int selectedDayIndex) =>
      weekMonday(currentWeek).add(Duration(days: selectedDayIndex));
}
