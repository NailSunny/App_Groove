import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Горизонтальный выбор дня недели (как в schedule.dart клиента).
class WeekDaySelector extends StatelessWidget {
  final DateTime currentWeek;
  final int selectedDayIndex;
  final ValueChanged<DateTime> onWeekChanged;
  final ValueChanged<int> onDaySelected;

  const WeekDaySelector({
    super.key,
    required this.currentWeek,
    required this.selectedDayIndex,
    required this.onWeekChanged,
    required this.onDaySelected,
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                final newWeek = currentWeek.subtract(const Duration(days: 7));
                final newWeekStart = DateTime(newWeek.year, newWeek.month, newWeek.day)
                    .subtract(Duration(days: newWeek.weekday - 1));
                if (!newWeekStart.isBefore(currentWeekStart)) {
                  onWeekChanged(newWeek);
                }
              },
            ),
            Text(
              '${DateFormat('d MMM', 'ru').format(weekDays.first)} - '
              '${DateFormat('d MMM', 'ru').format(weekDays.last)}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () =>
                  onWeekChanged(currentWeek.add(const Duration(days: 7))),
            ),
          ],
        ),
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

  static DateTime selectedDate(DateTime currentWeek, int selectedDayIndex) {
    final weekStart = currentWeek.subtract(
      Duration(days: currentWeek.weekday - 1),
    );
    return weekStart.add(Duration(days: selectedDayIndex));
  }
}
