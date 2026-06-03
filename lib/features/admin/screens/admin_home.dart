import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_service/admin_schedule_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/screens/group_class_details_page.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:groove_app/features/admin/widgets/attendance_toggle.dart';
import 'package:groove_app/features/admin/tabs/abonements_tab.dart';
import 'package:groove_app/features/admin/tabs/directions_tab.dart';
import 'package:groove_app/features/admin/tabs/clients_tab.dart';
import 'package:groove_app/features/admin/tabs/halls_tab.dart';
import 'package:groove_app/features/admin/tabs/purchases_tab.dart';
import 'package:groove_app/features/admin/tabs/admin_schedule_tab.dart';
import 'package:groove_app/features/admin/tabs/trainers_tab.dart';
import 'package:groove_app/features/admin/tabs/admin_rentals_tab.dart';
import 'package:groove_app/features/admin/tabs/admin_news_tab.dart';
import 'package:groove_app/features/admin/tabs/admin_organization_tab.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../layout/admin_scaffold.dart';
import '../reports/finance_reports_screen.dart';
import '../reports/trainers_reports_screen.dart';
import '../reports/attendance_reports_screen.dart';

const _lessonDurationMinutes = 60;

bool _isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Занятие идёт сейчас: выбранный день — сегодня, текущее время в [start, start + duration).
bool isLessonInProgressOnDate({
  required DateTime selectedDate,
  required String timeStr,
  int durationMinutes = _lessonDurationMinutes,
}) {
  final now = DateTime.now();
  if (!_isSameCalendarDay(selectedDate, now)) return false;

  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(timeStr.trim());
  if (match == null) return false;
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null) return false;

  final start = DateTime(now.year, now.month, now.day, hour, minute);
  final end = start.add(Duration(minutes: durationMinutes));
  return !now.isBefore(start) && now.isBefore(end);
}

WidgetStateProperty<Color?>? inProgressRowColor(bool inProgress) {
  if (!inProgress) return null;
  return WidgetStateProperty.all(ProcessYellow.withValues(alpha: 0.28));
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  int _sidebarIndex = 0;
  bool _showTodayRecords = true;
  bool _showWeekSchedule = false;
  bool _showRentals = false;

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

  Widget _buildSidebarContent() {
    switch (_sidebarIndex) {
      case 0:
        return const ClientsTab();
      case 1:
        return const AbonementsTab();
      case 2:
        return const TrainersTab();
      case 3:
        return const DirectionsTab();
      case 4:
        return HallsTab();
      case 5:
        return PurchasesTab();
      case 6:
        return AdminNewsTab();
      case 7:
        return AdminOrganizationTab();
      default:
        return Center(
          child: Text('Раздел в разработке', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 18)),
        );
    }
  }

  Widget _buildScheduleView() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Текущие записи",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTab("Групповые", 0),
              const SizedBox(width: 20),
              _buildTab("Персональные", 1),
            ],
          ),
          const SizedBox(height: 30),
          _buildCalendar(),
          const SizedBox(height: 30),
          Expanded(
            child: _selectedIndex == 0
                ? GroupAdminTable(selectedDate: selectedDate, onOpenGroup: _openGroup)
                : PersonalAdminTable(selectedDate: selectedDate),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedSidebarIndex:
          (_showTodayRecords || _showWeekSchedule || _showRentals) ? -1 : _sidebarIndex,
      onSidebarSelected: (index) {
        setState(() {
          _sidebarIndex = index;
          _showTodayRecords = false;
          _showWeekSchedule = false;
          _showRentals = false;
          _selectedGroupClass = null;
        });
      },
      onHomeTap: () {
        setState(() {
          _showTodayRecords = true;
          _showWeekSchedule = false;
          _showRentals = false;
          _selectedGroupClass = null;
        });
      },
      onScheduleTap: () {
        setState(() {
          _showTodayRecords = false;
          _showWeekSchedule = true;
          _showRentals = false;
          _selectedGroupClass = null;
        });
      },
      onRentalsTap: () {
        setState(() {
          _showTodayRecords = false;
          _showWeekSchedule = false;
          _showRentals = true;
          _selectedGroupClass = null;
        });
      },
      onReportSelected: (type) {
        Widget screen;
        switch (type) {
          case 'finance':
            screen = const FinanceReportsScreen();
            break;
          case 'trainers':
            screen = const TrainersReportsScreen();
            break;
          case 'attendance':
            screen = const AttendanceReportsScreen();
            break;
          default:
            return;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
      child: _selectedGroupClass != null
          ? GroupClassDetailsPage(classData: _selectedGroupClass!, onBack: _closeGroup)
          : (_showRentals
              ? const AdminRentalsTab()
              : _showWeekSchedule
                  ? const AdminScheduleTab()
                  : _showTodayRecords
                      ? _buildScheduleView()
                      : _buildSidebarContent()),
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
              icon: Icon(Icons.arrow_left, color: Theme.of(context).colorScheme.onSurface),
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            ),

            IconButton(
              icon: Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.onSurface),
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
                          ? Border.all(color: Color(0xFFFFCC32), width: 2)
                          : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'ru').format(day),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat('d', 'ru').format(day),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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

class GroupAdminTable extends StatefulWidget {
  final DateTime selectedDate;
  final Function(Map<String, dynamic>) onOpenGroup;

  const GroupAdminTable({
    super.key,
    required this.selectedDate,
    required this.onOpenGroup,
  });

  @override
  State<GroupAdminTable> createState() => _GroupAdminTableState();
}

class _GroupAdminTableState extends State<GroupAdminTable> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void didUpdateWidget(GroupAdminTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchAdminGroupClasses(widget.selectedDate);
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAdminError(context, e);
      }
    }
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> item) => {
        'id': item['id'] ?? item['Id'],
        'direction': item['direction'] ?? item['Direction'] ?? '',
        'trainer': item['trainer'] ?? item['Trainer'] ?? '',
        'hall': item['hall'] ?? item['Hall'] ?? '',
        'time': item['time'] ?? item['Time'] ?? '',
        'places': item['places'] ?? item['Places'] ?? '',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.groove.headerBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _loading
          ? Center(child: CircularProgressIndicator(color: MainPurple))
          : AdminScrollableTable(
              minWidth: 900,
              columns: [
                DataColumn(label: Text('№', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Направление', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Тренер', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Зал', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Время', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Свободно мест', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
              ],
              rows: _items.asMap().entries.map((entry) {
                final item = _normalize(entry.value);
                final inProgress = isLessonInProgressOnDate(
                  selectedDate: widget.selectedDate,
                  timeStr: item['time'].toString(),
                );
                final rowStyle = TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: inProgress ? FontWeight.bold : FontWeight.normal,
                );
                Widget cell(String text) => GestureDetector(
                      onDoubleTap: () => widget.onOpenGroup(_normalize(entry.value)),
                      child: Text(text, style: rowStyle),
                    );
                return DataRow(
                  color: inProgressRowColor(inProgress),
                  cells: [
                    DataCell(cell('${entry.key + 1}')),
                    DataCell(cell(item['direction'].toString())),
                    DataCell(cell(item['trainer'].toString())),
                    DataCell(cell(item['hall'].toString())),
                    DataCell(cell(inProgress ? '${item['time']} • сейчас' : item['time'].toString())),
                    DataCell(cell(item['places'].toString())),
                  ],
                );
              }).toList(),
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
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void didUpdateWidget(PersonalAdminTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchAdminPersonalClasses(widget.selectedDate);
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAdminError(context, e);
      }
    }
  }

  Future<void> _markPresent(int persClassId) async {
    try {
      await markPersonalAttendance(persClassId, 'Present');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.groove.headerBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _loading
          ? Center(child: CircularProgressIndicator(color: MainPurple))
          : _items.isEmpty
              ? Center(
                  child: Text(
                    'Нет записей на этот день',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
                  ),
                )
              : AdminScrollableTable(
              minWidth: 1100,
              columns: [
                DataColumn(label: Text('№', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('ФИО', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Тренер', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Зал', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Время', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Дата записи', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Абонемент', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                DataColumn(label: Text('Посещение', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
              ],
              rows: _items.asMap().entries.map((entry) {
                final item = entry.value;
                final id = item['id'] as int? ?? item['Id'] as int;
                final attendance = (item['attendance'] ?? item['Attendance'] ?? 'Pending').toString();
                final timeStr = (item['time'] ?? item['Time'] ?? '').toString();
                final inProgress = isLessonInProgressOnDate(
                  selectedDate: widget.selectedDate,
                  timeStr: timeStr,
                );
                final rowStyle = TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: inProgress ? FontWeight.bold : FontWeight.normal,
                );
                return DataRow(
                  color: inProgressRowColor(inProgress),
                  cells: [
                    DataCell(Text('${entry.key + 1}', style: rowStyle)),
                    DataCell(Text((item['client'] ?? item['Client'] ?? '').toString(), style: rowStyle)),
                    DataCell(Text((item['trainer'] ?? item['Trainer'] ?? '').toString(), style: rowStyle)),
                    DataCell(Text((item['hall'] ?? item['Hall'] ?? '').toString(), style: rowStyle)),
                    DataCell(Text(inProgress ? '$timeStr • сейчас' : timeStr, style: rowStyle)),
                    DataCell(Text((item['registryDate'] ?? item['RegistryDate'] ?? '').toString(), style: rowStyle)),
                    DataCell(Text((item['subscription'] ?? item['Subscription'] ?? '').toString(), style: rowStyle)),
                    DataCell(AttendanceToggle(
                      attendance: attendance,
                      onMarkPresent: attendance == 'Pending' ? () => _markPresent(id) : null,
                    )),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
