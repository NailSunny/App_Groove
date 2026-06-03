import 'package:flutter/material.dart';
import 'package:groove_app/api_service/hall_rental_service.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/designs/groove_page_styles.dart';
import 'package:groove_app/helper/rental_week.dart';
import 'package:groove_app/rental_slot_selection_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ArendaPage extends StatefulWidget {
  const ArendaPage({super.key});

  @override
  State<ArendaPage> createState() => _ArendaPageState();
}

class _ArendaPageState extends State<ArendaPage> {
  DateTime _focusedDay = DateTime.now();
  final Map<String, bool> _hasSlotsCache = {};
  final Set<String> _fullyBookedKeys = {};
  bool _checkingMonth = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _refreshMonthAvailability();
  }

  Future<void> _refreshMonthAvailability() async {
    setState(() => _checkingMonth = true);
    _fullyBookedKeys.clear();

    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, day);
      if (!RentalWeek.isAllowed(date)) continue;

      final key = RentalWeek.cacheKey(date);
      bool hasSlots;
      if (_hasSlotsCache.containsKey(key)) {
        hasSlots = _hasSlotsCache[key]!;
      } else {
        try {
          final slots = await fetchAvailableRentalSlots(date);
          hasSlots = slots.isNotEmpty;
          _hasSlotsCache[key] = hasSlots;
        } catch (_) {
          hasSlots = false;
        }
      }
      if (!hasSlots) _fullyBookedKeys.add(key);
    }

    if (mounted) {
      setState(() => _checkingMonth = false);
    }
  }

  Future<void> _openDay(DateTime date) async {
    final key = RentalWeek.cacheKey(date);
    if (_fullyBookedKeys.contains(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('На этот день нет свободных слотов')),
      );
      return;
    }

    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RentalSlotSelectionScreen(date: date),
      ),
    );

    if (refreshed == true) {
      _hasSlotsCache.remove(key);
      await _refreshMonthAvailability();
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = context.groove;
    final onSurface = Theme.of(context).colorScheme.onSurface;
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
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Аренда зала', style: GroovePageStyles.title(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                      });
                      await _refreshMonthAvailability();
                    },
                    icon: Icon(Icons.chevron_left, color: onSurface),
                  ),
                  Text(
                    '$currentMonth $currentYear',
                    style: GroovePageStyles.body(context, size: 16),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                      await _refreshMonthAvailability();
                    },
                    icon: Icon(Icons.chevron_right, color: onSurface),
                  ),
                ],
              ),
              if (_checkingMonth)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: LinearProgressIndicator(color: MainPurple),
                ),
              const SizedBox(height: 8),
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

                  final allowed = RentalWeek.isAllowed(date);
                  final isBeforeToday = date.isBefore(
                    DateTime(today.year, today.month, today.day),
                  );
                  final key = RentalWeek.cacheKey(date);
                  final isFullyBooked =
                      allowed && _fullyBookedKeys.contains(key);
                  final canTap = allowed && !isFullyBooked && !isBeforeToday;

                  Color dayColor;
                  if (!allowed || isBeforeToday) {
                    dayColor = g.onSurfaceMuted;
                  } else if (isFullyBooked) {
                    dayColor = Colors.white;
                  } else {
                    dayColor = onSurface;
                  }

                  return GestureDetector(
                    onTap: canTap ? () => _openDay(date) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isFullyBooked
                            ? Colors.red.withValues(alpha: 0.85)
                            : canTap
                                ? g.cardBackground
                                : null,
                        borderRadius: BorderRadius.circular(8),
                        border: canTap
                            ? Border.all(color: g.border)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: GroovePageStyles.body(
                          context,
                          size: 14,
                          color: dayColor,
                        ).copyWith(
                          fontWeight:
                              canTap ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.square, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Нет свободных слотов',
                    style: GroovePageStyles.body(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Аренда доступна на текущую и следующую неделю. '
                'Нажмите на доступный день, чтобы выбрать время.',
                style: GroovePageStyles.muted(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
