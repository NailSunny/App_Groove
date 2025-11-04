import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/arenda_dto.dart';
import 'package:groove_app/api_service/arenda_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArendaPage extends StatefulWidget {
  const ArendaPage({super.key});

  @override
  State<ArendaPage> createState() => _ArendaPageState();
}

class _ArendaPageState extends State<ArendaPage> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _checkFullyBookedDates();
  }

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<String> _availableSlots = [];
  bool _loading = false;

  final Set<DateTime> _fullyBookedDates = {};

  Future<void> _checkFullyBookedDates() async {
    _fullyBookedDates.clear();
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, i);

      if (date.isBefore(DateTime.now())) continue;

      try {
        final slots = await fetchFreeHours(date) ?? [];
        if (slots.length >= 14) {
          _fullyBookedDates.add(date);
        }
      } catch (e) {
        // Можно проигнорировать или логировать
      }
    }

    setState(() {});
  }

  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
  ];
  final Set<String> _selectedSlots = {};

  int get _price => _selectedSlots.length * 600;

  List<String> get _sortedSlots {
    List<String> sorted = _selectedSlots.toList();
    sorted.sort();
    return sorted;
  }

  String _buildTimeRange() {
    if (_selectedSlots.isEmpty) return '';

    final sorted = _sortedSlots;
    final startIndex = _timeSlots.indexOf(sorted.first);
    int endIndex = startIndex;

    // Двигаемся от начала, пока слоты подряд и выбраны
    for (int i = startIndex + 1; i < _timeSlots.length; i++) {
      final current = _timeSlots[i];
      if (_selectedSlots.contains(current)) {
        if (i == endIndex + 1) {
          endIndex = i;
        } else {
          break; // пропущенный слот — заканчиваем диапазон
        }
      } else {
        break;
      }
    }

    final start = _timeSlots[startIndex];
    final endHour = int.parse(_timeSlots[endIndex].split(':')[0]) + 1;
    final end = '${endHour.toString().padLeft(2, '0')}:00';

    return '$start–$end';
  }

  Future<void> _loadFreeHours() async {
    if (_selectedDay == null) return;
    setState(() => _loading = true);
    try {
      final slots = await fetchFreeHours(_selectedDay!);
      setState(() {
        _availableSlots =
            slots
                .map((e) => '${e.hour.toString().padLeft(2, '0')}:00')
                .toList();
        _selectedSlots.clear(); // очистка при обновлении
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final currentMonth = DateFormat.MMMM('ru').format(_focusedDay);
    final currentYear = DateFormat.y().format(_focusedDay);

    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final weekdayOffset = firstDayOfMonth.weekday - 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Аренда зала", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Выбор месяца
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                      _checkFullyBookedDates();
                    },

                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                  Text(
                    '$currentMonth $currentYear',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                      _checkFullyBookedDates();
                    },

                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Календарь
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysInMonth + weekdayOffset,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  if (index < weekdayOffset) return const SizedBox.shrink();
                  final day = index - weekdayOffset + 1;
                  final date = DateTime(
                    _focusedDay.year,
                    _focusedDay.month,
                    day,
                  );

                  final isBeforeToday = date.isBefore(
                    DateTime(today.year, today.month, today.day),
                  );
                  final isSelected =
                      _selectedDay != null &&
                      DateUtils.isSameDay(date, _selectedDay);
                  final isFullyBooked = _fullyBookedDates.any(
                    (d) => DateUtils.isSameDay(d, date),
                  );
                  if (isFullyBooked) {
                    print('Fully booked: $date');
                  }

                  return GestureDetector(
                    onTap:
                        isBeforeToday
                            ? null
                            : () {
                              setState(() {
                                _selectedDay = date;
                              });
                              _loadFreeHours();
                            },

                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFCC32) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color:
                              isBeforeToday
                                  ? Colors.grey
                                  : isFullyBooked
                                  ? Colors.white
                                  : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.square, color: Colors.red, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "Нет свободных часов",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedDay != null) ...[
                // Выбор времени
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _timeSlots
                          .where((slot) => _availableSlots.contains(slot))
                          .map((slot) {
                            final isSelected = _selectedSlots.contains(slot);
                            return OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedSlots.remove(slot);
                                  } else {
                                    _selectedSlots.add(slot);

                                    if (_selectedSlots.length > 1) {
                                      final sorted = _sortedSlots;
                                      final startIdx = _timeSlots.indexOf(
                                        sorted.first,
                                      );
                                      final endIdx = _timeSlots.indexOf(
                                        sorted.last,
                                      );

                                      for (int i = startIdx; i <= endIdx; i++) {
                                        final s = _timeSlots[i];
                                        if (_availableSlots.contains(s)) {
                                          _selectedSlots.add(s);
                                        }
                                      }
                                    }
                                  }
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                backgroundColor:
                                    isSelected
                                        ? const Color(0xFFFFCC32)
                                        : Colors.transparent,
                                side: const BorderSide(
                                  color: Color(0xFFFFCC32),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                slot,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          })
                          .toList(),
                ),

                const SizedBox(height: 12),
                if (_selectedSlots.isNotEmpty) ...[
                  Text(
                    "${DateFormat('d MMMM', 'ru').format(_selectedDay!)} ${_buildTimeRange()}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$_price руб.",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC32),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (_selectedSlots.isEmpty) return;

                        final sorted = _sortedSlots;
                        final start = int.parse(sorted.first.split(':')[0]);
                        final duration = sorted.length;
                        final prefs = await SharedPreferences.getInstance();
                        final userId = prefs.getInt('userId');
                        if (userId == null) {
                          // Не авторизован
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Ошибка: пользователь не найден'),
                            ),
                          );
                          return;
                        }
                        final dto = ArendaRequestDto(
                          userId: userId, // Заменить на реальный ID
                          date: _selectedDay!,
                          startHour: start,
                          durationHours: duration,
                        );

                        try {
                          await rentHall(dto);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Аренда успешно оформлена"),
                            ),
                          );
                          _loadFreeHours(); // Перезагрузить доступные часы
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },

                      child: const Text("Оплатить"),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
