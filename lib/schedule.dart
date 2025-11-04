import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/available_hour.dart';
import 'package:groove_app/api_DTOs/regist_pers.dart';
import 'package:groove_app/api_DTOs/schedulegroup_dto.dart';
import 'package:groove_app/api_DTOs/trainer_dto.dart';
import 'package:groove_app/api_service/api_trainers.dart';
import 'package:groove_app/api_service/availablehour_service.dart';
import 'package:groove_app/api_service/registpers_service.dart';
import 'package:groove_app/api_service/registrgroup_service.dart';
import 'package:groove_app/api_service/schedulegroup_service.dart';
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.popAndPushNamed(context, '/home'),
        ),
        title: Text("Расписание", style: TextStyle(color: Colors.white)),
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
    return Container(
      height: 50,
      child: Row(
        children: [_buildTab("Групповые", 0), _buildTab("Персональные", 1)],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          decoration: BoxDecoration(
            border:
                _selectedIndex == index
                    ? Border(
                      bottom: BorderSide(color: Color(0xFFFFCC32), width: 3),
                    )
                    : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color:
                  _selectedIndex == index ? Color(0xFFFFCC32) : Colors.white70,
              fontSize: 16,
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

  void _showRegisterDialog(BuildContext context, int groupClassId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Запись на занятие'),
            content: Text('Вы хотите записаться на это занятие?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); 
                  final prefs = await SharedPreferences.getInstance();
                  final saveduserId = prefs.getInt('userId');
                  if (saveduserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: пользователь не найден')),
                    );
                    return;
                  }
                  final userId =
                      saveduserId;
                  try {
                    final result = await registerToGroupClass(
                      userId,
                      groupClassId,
                    );
                    if (result.contains('Нет подходящего абонемента')) {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text('Нет абонемента'),
                              content: Text(result),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Отмена'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/shop');
                                  },
                                  child: Text('В магазин'),
                                ),
                              ],
                            ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text('Уведомление'),
                              content: Text(result),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('ОК'),
                                ),
                              ],
                            ),
                      );
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text('Ошибка'),
                            content: Text(
                              'Не удалось записаться. Попробуйте позже.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Закрыть'),
                              ),
                            ],
                          ),
                    );
                  }
                },
                child: Text('Записаться'),
              ),
            ],
          ),
    );
  }

  Future<void> _fetchData() async {
    final weekStart = _currentWeek.subtract(
      Duration(days: _currentWeek.weekday - 1),
    );
    final selectedDate = weekStart.add(Duration(days: _selectedDayIndex));

    try {
      types = await getTypeClasses();
      schedule = await getGroupSchedule(
        selectedDate,
        typeId:
            types
                .firstWhere(
                  (t) => t.name == _selectedClass,
                  orElse: () => TypeClassDto(id: -1, name: ""),
                )
                .id,
      );
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _currentWeek.subtract(
      Duration(days: _currentWeek.weekday - 1),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final now = DateTime.now();
    final filteredSchedule =
        schedule.where((item) {
          final day = weekDays[_selectedDayIndex];
          final timeParts = item.time.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          final classDateTime = DateTime(
            day.year,
            day.month,
            day.day,
            hour,
            minute,
          );

          return classDateTime.isAfter(now) ||
              classDateTime.isAtSameMomentAs(now);
        }).toList();

    String formatTime(String time) {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final dateTime = DateTime(0, 1, 1, hours, minutes);
      return DateFormat('HH:mm').format(dateTime);
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Выберите занятие для записи",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFCC32),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedClass,
              hint: Text(
                "Выберите занятие",
                style: TextStyle(color: Colors.white),
              ),
              items:
                  types
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type.name,
                          child: Text(type.name),
                        ),
                      )
                      .toList(),
              onChanged:
                  (val) => setState(() {
                    _selectedClass = val;
                    _fetchData();
                  }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left, color: Colors.white),
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
                  }
                },
              ),
              Text(
                "${DateFormat('d MMM').format(weekDays.first)} - ${DateFormat('d MMM').format(weekDays.last)}",
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right, color: Colors.white),
                onPressed:
                    () => setState(
                      () => _currentWeek = _currentWeek.add(Duration(days: 7)),
                    ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = weekDays[i];
              final selected = i == _selectedDayIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = i),
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
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        DateFormat('d', 'ru').format(day),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        "Нет занятий",
                        style: TextStyle(color: Colors.white),
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
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatTime(item.time),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    _selectedClass ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Зал №${item.hallNumber}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${item.duration} мин",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        "${item.trainerName} ${item.trainerSurname}",
                                        style: TextStyle(color: Colors.white),
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
      final weekStart = _currentWeek.subtract(
        Duration(days: _currentWeek.weekday - 1),
      );
      final selectedDate = weekStart.add(Duration(days: _selectedDayIndex));

      final hours = await fetchTrainerHours(_selectedTrainer!.id, selectedDate);
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

  @override
  Widget build(BuildContext context) {
    final weekStart = _currentWeek.subtract(
      Duration(days: _currentWeek.weekday - 1),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final todayWeekStart = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
    final isPastWeek = weekStart.isBefore(todayWeekStart);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Выберите тренера",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _trainers.map((trainer) {
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
                        color:
                            selected
                                ? Color(0xFFFFCC32).withOpacity(0.9)
                                : Colors.transparent,
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "${trainer.surname} ${trainer.name}",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
          if (_selectedTrainer != null) ...[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_left,
                    color: isPastWeek ? Colors.white24 : Colors.white,
                  ),
                  onPressed:
                      isPastWeek
                          ? null
                          : () {
                            setState(() {
                              _currentWeek = _currentWeek.subtract(
                                Duration(days: 7),
                              );
                            });
                          },
                ),
                Text(
                  "${DateFormat('d MMM').format(weekDays.first)} - ${DateFormat('d MMM').format(weekDays.last)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentWeek = _currentWeek.add(Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day = weekDays[i];
                final selected = i == _selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDayIndex = i);
                    _loadAvailableHours();
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
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          DateFormat('d', 'ru').format(day),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 12),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _availableHours.isEmpty
                ? Center(
                  child: Text(
                    'Нет свободных часов',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
                : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _availableHours.map((slot) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                          ),
                          onPressed: () async {
                            final weekStart = _currentWeek.subtract(
                              Duration(days: _currentWeek.weekday - 1),
                            );
                            final selectedDate = weekStart.add(
                              Duration(days: _selectedDayIndex),
                            );

                            final selectedTimeParts = slot.hour.split(':');
                            final startDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              int.parse(selectedTimeParts[0]),
                              int.parse(selectedTimeParts[1]),
                            );

                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text("Подтвердите запись"),
                                    content: Text(
                                      "Вы хотите записаться на ${DateFormat('dd.MM.yyyy – HH:mm').format(startDateTime)}?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: Text("Отмена"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: Text("Записаться"),
                                      ),
                                    ],
                                  ),
                            );
                            final prefs = await SharedPreferences.getInstance();
                            final saveduserId = prefs.getInt('userId');
                            if (saveduserId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Ошибка: пользователь не найден',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (confirmed == true) {
                              try {
                                final message = await registerPersonalClass(
                                  RegisterPersClassRequest(
                                    userId:
                                        saveduserId,
                                    trainerId: _selectedTrainer!.id,
                                    startDateTime: startDateTime,
                                  ),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );

                                _loadAvailableHours();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Ошибка: ${e.toString()}"),
                                  ),
                                );
                              }
                            }
                          },
                          child: Column(
                            children: [
                              Text(
                                slot.hour,
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "60 м",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
          ],
        ],
      ),
    );
  }
}
