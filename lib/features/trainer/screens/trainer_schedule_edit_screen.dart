import 'package:flutter/material.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/trainer/services/trainer_schedule_draft_api.dart';
import 'package:groove_app/features/trainer/widgets/lesson_type_tabs.dart';
import 'package:groove_app/widgets/schedule_week_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:groove_app/helper/trainer_session.dart';

class TrainerScheduleEditScreen extends StatefulWidget {
  const TrainerScheduleEditScreen({super.key});

  @override
  State<TrainerScheduleEditScreen> createState() =>
      _TrainerScheduleEditScreenState();
}

class _TrainerScheduleEditScreenState extends State<TrainerScheduleEditScreen> {
  int _lessonTypeIndex = 0;
  DateTime _weekStart = schedulingWeekStart();
  int _selectedDayIndex = 0;
  bool _loading = true;
  String? _error;
  int? _trainerId;

  Map<String, dynamic>? _groupWeek;
  Map<String, dynamic>? _personalDay;
  List<Map<String, dynamic>> _directions = [];

  DateTime _currentWeek = schedulingWeekStart();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _weekStart = ScheduleWeekCalendar.weekMonday(_currentWeek);
    _load();
  }

  DateTime get _selectedDate =>
      ScheduleWeekCalendar.selectedDate(_currentWeek, _selectedDayIndex);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _trainerId ??= await resolveTrainerUserId();
      if (_trainerId == null) {
        setState(() {
          _loading = false;
          _error = 'Не найден ID тренера. Выйдите и войдите снова.';
        });
        return;
      }

      _directions = await fetchTrainerDirections(_trainerId!);

      if (_lessonTypeIndex == 0) {
        _groupWeek = await fetchTrainerGroupSlotsWeek(
          trainerId: _trainerId!,
          weekStart: _weekStart,
        );
      } else {
        _personalDay = await fetchTrainerPersonalSlotsDay(
          trainerId: _trainerId!,
          day: _selectedDate,
        );
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _showAddGroupDialog(String startTime) async {
    if (_directions.isEmpty) {
      _snack('Нет доступных направлений. Обратитесь к администратору.');
      return;
    }

    int? directionId = _directions.first['id'] as int?;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: ElementsPurple,
          title: Text('Добавить групповое', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: DropdownButtonFormField<int>(
            value: directionId,
            dropdownColor: BackBlack,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: const InputDecoration(labelText: 'Направление'),
            items: _directions
                .map(
                  (d) => DropdownMenuItem<int>(
                    value: d['id'] as int,
                    child: Text(d['name'] as String? ?? ''),
                  ),
                )
                .toList(),
            onChanged: (v) => directionId = v,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Добавить')),
          ],
        );
      },
    );

    if (ok != true || directionId == null) return;

    try {
      await createGroupDraft(
        trainerId: _trainerId!,
        date: _selectedDate,
        startTime: startTime,
        directionId: directionId!,
      );
      _snack('Занятие добавлено');
      await _load();
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _showAddPersonalDialog(String startTime) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ElementsPurple,
        title: Text('Персональное занятие', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          'Открыть слот на $startTime?\n\n'
          'Направление клиент выберет при записи.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Добавить')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await createPersonalDraft(
        trainerId: _trainerId!,
        date: _selectedDate,
        startTime: startTime,
      );
      _snack('Слот для персонального занятия добавлен');
      await _load();
    } catch (e) {
      _snack(e.toString());
    }
  }

  String _personalSlotSubtitle(Map<String, dynamic> slot) {
    final hall = slot['hall'] as String?;
    final direction = slot['direction'] as String?;
    final hallPart = hall != null && hall.isNotEmpty ? ' · зал $hall' : '';
    if (direction != null && direction.isNotEmpty) {
      return '$direction$hallPart';
    }
    return 'Персональное$hallPart';
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: ScheduleWeekCalendar(
            currentWeek: _currentWeek,
            selectedDayIndex: _selectedDayIndex,
            onWeekChanged: (w) {
              setState(() {
                _currentWeek = w;
                _weekStart = ScheduleWeekCalendar.weekMonday(w);
              });
              _load();
            },
            onDaySelected: (i) {
              setState(() => _selectedDayIndex = i);
              _load();
            },
          ),
        ),
        LessonTypeTabs(
          selectedIndex: _lessonTypeIndex,
          onChanged: (i) {
            setState(() => _lessonTypeIndex = i);
            _load();
          },
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: MainPurple));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))));
    }
    return _lessonTypeIndex == 0 ? _buildGroupSlots() : _buildPersonalSlots();
  }

  Widget _buildGroupSlots() {
    final days = (_groupWeek?['days'] as List<dynamic>?) ?? [];
    Map<String, dynamic> day = {'slots': <dynamic>[]};
    for (final d in days) {
      final m = d as Map<String, dynamic>;
      final dt = DateTime.parse(m['date'] as String);
      if (dt.year == _selectedDate.year &&
          dt.month == _selectedDate.month &&
          dt.day == _selectedDate.day) {
        day = m;
        break;
      }
    }
    final slots = (day['slots'] as List<dynamic>?) ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index] as Map<String, dynamic>;
        final state = slot['state'] as String? ?? 'Free';
        final time = slot['startTime'] as String? ?? '';

        Color bg = ElementsPurple.withValues(alpha: 0.4);
        if (state == 'Mine') bg = MainPurple.withValues(alpha: 0.5);
        if (state == 'Occupied') bg = Colors.grey.withValues(alpha: 0.35);

        return Card(
          color: bg,
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(time, style: TextStyle(color: ProcessYellow)),
            subtitle: Text(
              state == 'Free'
                  ? 'Свободен'
                  : state == 'Mine'
                      ? '${slot['direction']} · зал ${slot['hall']}'
                      : 'Занят: ${slot['direction']}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            trailing: state == 'Mine'
                ? IconButton(
                    icon: const Icon(Icons.delete, color: UnactiveRed),
                    onPressed: () async {
                      try {
                        await deleteGroupDraft(
                          id: slot['groupClassId'] as int,
                          trainerId: _trainerId!,
                        );
                        await _load();
                      } catch (e) {
                        _snack(e.toString());
                      }
                    },
                  )
                : state == 'Free'
                    ? IconButton(
                        icon: const Icon(Icons.add, color: ProcessYellow),
                        onPressed: () => _showAddGroupDialog(time),
                      )
                    : null,
            onTap: state == 'Free' ? () => _showAddGroupDialog(time) : null,
          ),
        );
      },
    );
  }

  Widget _buildPersonalSlots() {
    final hasGroup = _personalDay?['hasGroupClass'] as bool? ?? false;
    if (!hasGroup) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Сначала добавьте групповое занятие на этот день',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
        ),
      );
    }

    final slots = (_personalDay?['slots'] as List<dynamic>?) ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index] as Map<String, dynamic>;
        final state = slot['state'] as String? ?? 'Blocked';
        final time = slot['startTime'] as String? ?? '';
        final isFree = state == 'Free';
        final isMine = state == 'Mine';

        return Card(
          color: isFree
              ? ElementsPurple.withValues(alpha: 0.4)
              : isMine
                  ? MainPurple.withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.25),
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(time, style: TextStyle(color: ProcessYellow)),
            subtitle: Text(
              isFree
                  ? 'Доступен'
                  : isMine
                      ? _personalSlotSubtitle(slot)
                      : 'Недоступен',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            trailing: isMine
                ? IconButton(
                    icon: const Icon(Icons.delete, color: UnactiveRed),
                    onPressed: () async {
                      try {
                        await deletePersonalDraft(
                          id: slot['persClassId'] as int,
                          trainerId: _trainerId!,
                        );
                        await _load();
                      } catch (e) {
                        _snack(e.toString());
                      }
                    },
                  )
                : isFree
                    ? IconButton(
                        icon: const Icon(Icons.add, color: ProcessYellow),
                        onPressed: () => _showAddPersonalDialog(time),
                      )
                    : null,
            onTap: isFree ? () => _showAddPersonalDialog(time) : null,
          ),
        );
      },
    );
  }
}
