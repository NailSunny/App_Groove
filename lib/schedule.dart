import 'package:flutter/material.dart';
import 'package:groove_app/client_routes.dart';
import 'package:groove_app/api_DTOs/available_hour.dart';
import 'package:groove_app/api_DTOs/regist_pers.dart';
import 'package:groove_app/api_DTOs/schedulegroup_dto.dart';
import 'package:groove_app/api_DTOs/trainer_dto.dart';
import 'package:groove_app/api_service/api_trainers.dart';
import 'package:groove_app/api_service/availablehour_service.dart';
import 'package:groove_app/api_service/registpers_service.dart';
import 'package:groove_app/api_service/myabonement_service.dart';
import 'package:groove_app/api_service/registrgroup_service.dart';
import 'package:groove_app/api_service/schedulegroup_service.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/designs/groove_page_styles.dart';
import 'package:groove_app/widgets/schedule_week_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.popAndPushNamed(context, ClientRoutes.home),
        ),
        title: Text('Расписание', style: GroovePageStyles.title(context)),
      ),
      body: Column(
        children: [
          _buildNavigationBar(),
          Expanded(
            child:
                _selectedIndex == 0
                    ? GroupScheduleView()
                    : PersonalScheduleView(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    final g = context.groove;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: g.border)),
      ),
      child: Row(
        children: [_buildTab('Групповые', 0), _buildTab('Персональные', 1)],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final g = context.groove;
    final selected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          decoration: BoxDecoration(
            border: selected
                ? const Border(
                    bottom: BorderSide(color: ProcessYellow, width: 3),
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GroovePageStyles.body(
              context,
              size: 16,
              color: selected ? ProcessYellow : g.onSurfaceSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class GroupScheduleView extends StatefulWidget {
  @override
  _GroupScheduleViewState createState() => _GroupScheduleViewState();
}

class _GroupScheduleViewState extends State<GroupScheduleView> {
  DateTime _currentWeek = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;
  String? _selectedClass;
  List<TypeClassDto> types = [];
  List<GroupClassScheduleDto> schedule = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _performGroupRegistration(
    BuildContext context,
    int userId,
    int groupClassId, {
    bool? useTrial,
  }) async {
    try {
      final result = await registerToGroupClass(
        userId,
        groupClassId,
        useTrial: useTrial,
      );
      if (!context.mounted) return;

      if (result.contains('Нет подходящего абонемента')) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Нет абонемента'),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, ClientRoutes.shop);
                },
                child: const Text('В магазин'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Уведомление'),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОК'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Ошибка'),
          content: const Text('Не удалось записаться. Попробуйте позже.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    }
  }

  void _showRegisterDialog(BuildContext context, int groupClassId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не найден')),
      );
      return;
    }

    bool? useTrial;
    try {
      final abonements = await fetchUserAbonements(userId);
      final hasTrial = abonements.any(
        (a) => a.isTrial && a.ostatok > 0 && a.status == 'Активен',
      );
      if (hasTrial && context.mounted) {
        useTrial = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Пробный абонемент'),
            content: const Text(
              'У вас есть пробное занятие. Использовать пробный абонемент для этой записи?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Нет, другой абонемент'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Да, пробный'),
              ),
            ],
          ),
        );
        if (useTrial == null || !context.mounted) return;
      }
    } catch (_) {
      // Продолжаем без выбора пробного
    }

    if (!context.mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Запись на занятие'),
        content: const Text('Вы хотите записаться на это занятие?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Записаться'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;
    await _performGroupRegistration(
      context,
      userId,
      groupClassId,
      useTrial: useTrial,
    );
  }

  DateTime get _selectedDate {
    final weekStart = _currentWeek.subtract(
      Duration(days: _currentWeek.weekday - 1),
    );
    return weekStart.add(Duration(days: _selectedDayIndex));
  }

  int? get _selectedTypeId {
    if (_selectedClass == null) return null;
    final match = types.where((t) => t.name == _selectedClass);
    if (match.isEmpty) return null;
    return match.first.id;
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    try {
      types = await getTypeClasses();
      schedule = await getGroupSchedule(
        _selectedDate,
        typeId: _selectedTypeId,
      );
    } catch (e) {
      print(e);
      schedule = [];
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  bool _isClassUpcoming(GroupClassScheduleDto item, DateTime day) {
    final timeParts = item.time.split(':');
    if (timeParts.length < 2) return true;
    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final start = DateTime(day.year, day.month, day.day, hour, minute);
    final end = start.add(Duration(minutes: item.duration));
    return end.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _currentWeek.subtract(
      Duration(days: _currentWeek.weekday - 1),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final selectedDay = weekDays[_selectedDayIndex];
    final filteredSchedule = schedule
        .where((item) => _isClassUpcoming(item, selectedDay))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final isToday = selectedDay.year == DateTime.now().year &&
        selectedDay.month == DateTime.now().month &&
        selectedDay.day == DateTime.now().day;
    final emptyMessage = isToday
        ? 'На сегодня занятий больше нет'
        : 'Нет занятий';

    String formatTime(String time) {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final dateTime = DateTime(0, 1, 1, hours, minutes);
      return DateFormat('HH:mm').format(dateTime);
    }

    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Выберите занятие для записи",
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFCC32),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String?>(
              isExpanded: true,
              value: _selectedClass,
              hint: const Text(
                'Все направления',
                style: TextStyle(color: Colors.black87),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Все направления'),
                ),
                ...types.map(
                  (type) => DropdownMenuItem<String?>(
                    value: type.name,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.name),
                        if (type.description != null && type.description!.isNotEmpty)
                          Text(
                            type.description!,
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() => _selectedClass = val);
                _fetchData();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  final today = DateTime.now();
                  final currentWeekStart = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  ).subtract(
                    Duration(days: today.weekday - 1),
                  ); 

                  final newWeek = _currentWeek.subtract(Duration(days: 7));
                  final newWeekStart = DateTime(
                    newWeek.year,
                    newWeek.month,
                    newWeek.day,
                  ).subtract(Duration(days: newWeek.weekday - 1));

                  if (!newWeekStart.isBefore(currentWeekStart)) {
                    setState(() => _currentWeek = newWeek);
                    _fetchData();
                  }
                },
              ),
              Text(
                "${DateFormat('d MMM').format(weekDays.first)} - ${DateFormat('d MMM').format(weekDays.last)}",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                  setState(() => _currentWeek = _currentWeek.add(const Duration(days: 7)));
                  _fetchData();
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = weekDays[i];
              final selected = i == _selectedDayIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDayIndex = i);
                  _fetchData();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    border:
                        selected
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
          SizedBox(height: 10),
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredSchedule.isEmpty
                    ? Center(
                      child: Text(
                        emptyMessage,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredSchedule.length,
                      itemBuilder: (context, index) {
                        final item = filteredSchedule[index];

                        return GestureDetector(
                          onTap: () => _showRegisterDialog(context, item.id),
                          child: Card(
                            color: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatTime(item.time),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  Text(
                                    item.direction.isNotEmpty
                                        ? item.direction
                                        : (_selectedClass ?? 'Занятие'),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Зал №${item.hallNumber}",
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  if (item.maxCapacity > 0) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      '${item.registeredCount}/${item.maxCapacity}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${item.duration} мин",
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                      Text(
                                        "${item.trainerName} ${item.trainerSurname}",
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class PersonalScheduleView extends StatefulWidget {
  @override
  _PersonalScheduleViewState createState() => _PersonalScheduleViewState();
}

class _PersonalScheduleViewState extends State<PersonalScheduleView> {
  DateTime _currentWeek = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;
  List<TrainerDto> _trainers = [];
  TrainerDto? _selectedTrainer;
  List<AvailableHour> _availableHours = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    final trainers = await fetchTrainers();
    setState(() {
      _trainers = trainers;
    });
  }

  Future<void> _loadAvailableHours() async {
    if (_selectedTrainer == null) return;
    setState(() => _isLoading = true);

    try {
      final selectedDate = ScheduleWeekCalendar.selectedDate(
        _currentWeek,
        _selectedDayIndex,
      );

      final hours = await fetchTrainerHours(_selectedTrainer!.id, selectedDate);
      hours.sort((a, b) => a.hour.compareTo(b.hour));
      setState(() {
        _availableHours = hours;
      });
    } catch (_) {
      setState(() {
        _availableHours = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  DateTime get _selectedDate => ScheduleWeekCalendar.selectedDate(
        _currentWeek,
        _selectedDayIndex,
      );

  Future<void> _registerSlot(AvailableHour slot) async {
    final parts = slot.hour.split(':');
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите запись'),
        content: Text(
          'Запись на ${DateFormat('dd.MM.yyyy – HH:mm', 'ru').format(startDateTime)}'
          '${slot.direction.isNotEmpty ? '\n${slot.direction}' : ''}'
          '${slot.hall.isNotEmpty ? '\nЗал ${slot.hall}' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Записаться'),
          ),
        ],
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final saveduserId = prefs.getInt('userId');
    if (saveduserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не найден')),
      );
      return;
    }

    if (confirmed != true || _selectedTrainer == null) return;

    try {
      final message = await registerPersonalClass(
        RegisterPersClassRequest(
          userId: saveduserId,
          trainerId: _selectedTrainer!.id,
          startDateTime: startDateTime,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      await _loadAvailableHours();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Text(
            'Выберите тренера',
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trainers.map((trainer) {
              final selected = _selectedTrainer == trainer;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTrainer = trainer;
                    _selectedDayIndex = DateTime.now().weekday - 1;
                  });
                  _loadAvailableHours();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? Color(0xFFFFCC32).withValues(alpha: 0.9)
                        : Colors.transparent,
                    border: Border.all(color: context.groove.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface, size: 16),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${trainer.surname} ${trainer.name}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedTrainer != null) ...[
          ScheduleWeekCalendar(
            currentWeek: _currentWeek,
            selectedDayIndex: _selectedDayIndex,
            blockPastWeeks: true,
            onWeekChanged: (w) {
              setState(() => _currentWeek = w);
              _loadAvailableHours();
            },
            onDaySelected: (i) {
              setState(() => _selectedDayIndex = i);
              _loadAvailableHours();
            },
          ),
          SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: MainPurple))
                : _availableHours.isEmpty
                    ? Center(
                        child: Text(
                          'Нет свободных слотов на этот день',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _availableHours.length,
                        itemBuilder: (context, index) {
                          final slot = _availableHours[index];
                          return Card(
                            color: ElementsPurple.withValues(alpha: 0.5),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                slot.hour,
                                style: const TextStyle(
                                  color: ProcessYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  if (slot.direction.isNotEmpty) slot.direction,
                                  if (slot.hall.isNotEmpty) 'Зал ${slot.hall}',
                                  '60 мин',
                                ].join(' · '),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: ProcessYellow,
                              ),
                              onTap: () => _registerSlot(slot),
                            ),
                          );
                        },
                      ),
          ),
        ] else
          Expanded(
            child: Center(
              child: Text(
                'Выберите тренера для просмотра слотов',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
              ),
            ),
          ),
      ],
    );
  }
}
