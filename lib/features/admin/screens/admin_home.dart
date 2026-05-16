import 'package:flutter/material.dart';
import 'package:groove_app/features/admin/screens/group_class_details_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../layout/admin_scaffold.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  DateTime _currentWeek = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;

  Map<String, dynamic>? _selectedGroupClass;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru');
  }

  List<DateTime> get weekDays {
    final weekStart = _currentWeek.subtract(
      Duration(days: _currentWeek.weekday - 1),
    );

    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  DateTime get selectedDate => weekDays[_selectedDayIndex];

  void _openGroup(Map<String, dynamic> group) {
    setState(() {
      _selectedGroupClass = group;
    });
  }

  void _closeGroup() {
    setState(() {
      _selectedGroupClass = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      child:
          /// ЕСЛИ ОТКРЫТА ГРУППА
          _selectedGroupClass != null
              ? GroupClassDetailsPage(
                classData: _selectedGroupClass!,
                onBack: _closeGroup,
              )
              /// ИНАЧЕ ОСНОВНАЯ СТРАНИЦА
              : Padding(
                padding: const EdgeInsets.all(30),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// ЗАГОЛОВОК
                    const Text(
                      "Текущие записи",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// ПЕРЕКЛЮЧАТЕЛИ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        _buildTab("Групповые", 0),

                        const SizedBox(width: 20),

                        _buildTab("Персональные", 1),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// КАЛЕНДАРЬ
                    _buildCalendar(),

                    const SizedBox(height: 30),

                    /// ТАБЛИЦА
                    Expanded(
                      child:
                          _selectedIndex == 0
                              ? GroupAdminTable(
                                selectedDate: selectedDate,

                                onOpenGroup: _openGroup,
                              )
                              : PersonalAdminTable(selectedDate: selectedDate),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTab(String title, int index) {
    final selected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFAD03E2) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, color: Colors.white),
              onPressed: () {
                final today = DateTime.now();

                final currentWeekStart = DateTime(
                  today.year,
                  today.month,
                  today.day,
                ).subtract(Duration(days: today.weekday - 1));

                final newWeek = _currentWeek.subtract(const Duration(days: 7));

                final newWeekStart = DateTime(
                  newWeek.year,
                  newWeek.month,
                  newWeek.day,
                ).subtract(Duration(days: newWeek.weekday - 1));

                if (!newWeekStart.isBefore(currentWeekStart)) {
                  setState(() {
                    _currentWeek = newWeek;
                  });
                }
              },
            ),

            Text(
              "${DateFormat('d MMM', 'ru').format(weekDays.first)} - "
              "${DateFormat('d MMM', 'ru').format(weekDays.last)}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),

            IconButton(
              icon: const Icon(Icons.arrow_right, color: Colors.white),
              onPressed: () {
                setState(() {
                  _currentWeek = _currentWeek.add(const Duration(days: 7));
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final day = weekDays[i];
            final selected = i == _selectedDayIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDayIndex = i;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  border:
                      selected
                          ? Border.all(color: const Color(0xFFFFCC32), width: 2)
                          : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'ru').format(day),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d', 'ru').format(day),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
}

class GroupAdminTable extends StatelessWidget {
  final DateTime selectedDate;

  final Function(Map<String, dynamic>) onOpenGroup;

  const GroupAdminTable({
    super.key,
    required this.selectedDate,
    required this.onOpenGroup,
  });

  @override
  Widget build(BuildContext context) {
    final mockData = [
      {
        "id": 1,
        "direction": "Hip-Hop",
        "trainer": "Иванов И.О.",
        "hall": "1",
        "time": "18:00",
        "places": "8/10",
      },
      {
        "id": 2,
        "direction": "Break Dance",
        "trainer": "Петров А.В.",
        "hall": "2",
        "time": "19:30",
        "places": "4/12",
      },
      {
        "id": 3,
        "direction": "Jazz-Funk",
        "trainer": "Сидоров Д.К.",
        "hall": "3",
        "time": "20:00",
        "places": "10/10",
      },
      {
        "id": 4,
        "direction": "Contemporary",
        "trainer": "Миронова Е.С.",
        "hall": "4",
        "time": "17:00",
        "places": "6/8",
      },
    ];

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A)),

          dataRowMinHeight: 60,
          dataRowMaxHeight: 60,

          columns: const [
            DataColumn(label: Text("№", style: TextStyle(color: Colors.white))),

            DataColumn(
              label: Text("Направление", style: TextStyle(color: Colors.white)),
            ),

            DataColumn(
              label: Text("Тренер", style: TextStyle(color: Colors.white)),
            ),

            DataColumn(
              label: Text("Зал", style: TextStyle(color: Colors.white)),
            ),

            DataColumn(
              label: Text("Время", style: TextStyle(color: Colors.white)),
            ),

            DataColumn(
              label: Text(
                "Свободно мест",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],

          rows:
              mockData.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      GestureDetector(
                        onDoubleTap: () {
                          onOpenGroup(item);
                        },

                        child: Text(
                          item["id"].toString(),

                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    DataCell(
                      GestureDetector(
                        onDoubleTap: () {
                          onOpenGroup(item);
                        },

                        child: Text(
                          item["direction"].toString(),

                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    DataCell(
                      GestureDetector(
                        onDoubleTap: () {
                          onOpenGroup(item);
                        },

                        child: Text(
                          item["trainer"].toString(),

                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    DataCell(
                      GestureDetector(
                        onDoubleTap: () {
                          onOpenGroup(item);
                        },

                        child: Text(
                          item["hall"].toString(),

                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    DataCell(
                      GestureDetector(
                        onDoubleTap: () {
                          onOpenGroup(item);
                        },

                        child: Text(
                          item["time"].toString(),

                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    DataCell(
                      GestureDetector(
                        onDoubleTap: () {
                          onOpenGroup(item);
                        },

                        child: Text(
                          item["places"].toString(),

                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

class PersonalAdminTable extends StatefulWidget {
  final DateTime selectedDate;

  const PersonalAdminTable({super.key, required this.selectedDate});

  @override
  State<PersonalAdminTable> createState() => _PersonalAdminTableState();
}

class _PersonalAdminTableState extends State<PersonalAdminTable> {
  late List<Map<String, dynamic>> mockData;

  @override
  void initState() {
    super.initState();

    mockData = [
      {
        "id": 1,
        "client": "Иванов И.И.",
        "trainer": "Петров А.В.",
        "hall": "1",
        "time": "12:00",
        "date": "21.04.2026",
        "subscription": "Персональный x8",
        "visited": false,
      },

      {
        "id": 2,
        "client": "Сидоров А.Д.",
        "trainer": "Иванов И.О.",
        "hall": "2",
        "time": "14:00",
        "date": "20.04.2026",
        "subscription": "VIP x12",
        "visited": true,
      },

      {
        "id": 3,
        "client": "Миронова Е.С.",
        "trainer": "Сидоров Д.К.",
        "hall": "3",
        "time": "16:00",
        "date": "19.04.2026",
        "subscription": "Разовое",
        "visited": false,
      },

      {
        "id": 4,
        "client": "Кузнецов А.П.",
        "trainer": "Миронова Е.С.",
        "hall": "4",
        "time": "18:00",
        "date": "18.04.2026",
        "subscription": "Персональный x4",
        "visited": false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Scrollbar(
        thumbVisibility: true,

        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A)),

              dataRowMinHeight: 65,
              dataRowMaxHeight: 65,

              columns: const [
                DataColumn(
                  label: Text("№", style: TextStyle(color: Colors.white)),
                ),

                DataColumn(
                  label: Text("ФИО", style: TextStyle(color: Colors.white)),
                ),

                DataColumn(
                  label: Text("Тренер", style: TextStyle(color: Colors.white)),
                ),

                DataColumn(
                  label: Text("Зал", style: TextStyle(color: Colors.white)),
                ),

                DataColumn(
                  label: Text("Время", style: TextStyle(color: Colors.white)),
                ),

                DataColumn(
                  label: Text(
                    "Дата записи",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Абонемент",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                DataColumn(
                  label: Text(
                    "Посещение",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],

              rows:
                  mockData.map((item) {
                    final visited = item["visited"] as bool;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item["id"].toString(),

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        /// ФИО
                        DataCell(
                          SizedBox(
                            width: 170,

                            child: Text(
                              item["client"].toString(),

                              style: const TextStyle(color: Colors.white),

                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        /// ТРЕНЕР
                        DataCell(
                          Text(
                            item["trainer"].toString(),

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        /// ЗАЛ
                        DataCell(
                          Text(
                            item["hall"].toString(),

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        /// ВРЕМЯ
                        DataCell(
                          Text(
                            item["time"].toString(),

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        /// ДАТА ЗАПИСИ
                        DataCell(
                          Text(
                            item["date"].toString(),

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        /// АБОНЕМЕНТ
                        DataCell(
                          Text(
                            item["subscription"].toString(),

                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        /// ПОСЕЩЕНИЕ
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                item["visited"] = true;
                              });
                            },

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),

                              width: 36,
                              height: 36,

                              decoration: BoxDecoration(
                                color:
                                    visited ? Colors.transparent : Colors.green,

                                borderRadius: BorderRadius.circular(10),

                                border:
                                    visited
                                        ? Border.all(
                                          color: Colors.green,
                                          width: 2,
                                        )
                                        : null,
                              ),

                              child: Icon(
                                Icons.check,

                                color: visited ? Colors.green : Colors.white,

                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
