import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/hall_admin_dto.dart';
import 'package:groove_app/api_DTOs/hall_rental_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:intl/intl.dart';

class AdminRentalsTab extends StatefulWidget {
  const AdminRentalsTab({super.key});

  @override
  State<AdminRentalsTab> createState() => _AdminRentalsTabState();
}

class _AdminRentalsTabState extends State<AdminRentalsTab> {
  DateTime _currentWeek = DateTime.now();
  int _selectedDayIndex = DateTime.now().weekday - 1;
  List<AdminHallRentalDto> _rentals = [];
  List<HallAdminDto> _halls = [];
  int? _hallFilterId;
  bool _loading = false;
  String? _error;

  List<DateTime> get weekDays {
    final weekStart = _currentWeek.subtract(
      Duration(days: _currentWeek.weekday - 1),
    );
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  DateTime get selectedDate => weekDays[_selectedDayIndex];

  @override
  void initState() {
    super.initState();
    _loadHalls();
    _loadRentals();
  }

  Future<void> _loadHalls() async {
    try {
      final halls = await fetchHalls();
      if (!mounted) return;
      setState(() {
        _halls = halls.where((h) => h.isRentable).toList();
        if (_hallFilterId == null && _halls.isNotEmpty) {
          _hallFilterId = _halls.first.idHall;
        }
      });
    } catch (_) {}
  }

  Future<void> _loadRentals() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await fetchAdminHallRentals(
        date: selectedDate,
        hallId: _hallFilterId,
      );
      if (!mounted) return;
      setState(() {
        _rentals = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _cancel(AdminHallRentalDto rental) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFFD9D9D9),
        title: Text('Отмена аренды', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          'Отменить аренду ${rental.startTime} (${rental.clientName})?\n'
          'Средства (${rental.totalPrice} ₽) будут возвращены на баланс клиента.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Отменить аренду', style: TextStyle(color: UnactiveRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await cancelAdminHallRental(rental.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аренда отменена')),
      );
      await _loadRentals();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Аренды залов',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          if (_halls.length > 1)
            Row(
              children: [
                Text('Зал: ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: _hallFilterId,
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Все арендуемые'),
                    ),
                    ..._halls.map(
                      (h) => DropdownMenuItem(
                        value: h.idHall,
                        child: Text('Зал ${h.numberHall ?? h.idHall}'),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _hallFilterId = v);
                    _loadRentals();
                  },
                ),
              ],
            ),
          const SizedBox(height: 16),
          _buildWeekCalendar(),
          SizedBox(height: 24),
          if (_error != null)
            Text(_error!, style: TextStyle(color: UnactiveRed)),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: MainPurple))
                : AdminScrollableTable(
                    columns: [
                      DataColumn(label: Text('Время', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Часов', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Клиент', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Телефон', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Зал', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Сумма', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Статус', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    ],
                    rows: _rentals.isEmpty
                        ? [
                            DataRow(
                              cells: [
                                DataCell(Text('Нет аренд на выбранный день',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)))),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ],
                            ),
                          ]
                        : _rentals.map((r) {
                            final statusLabel = _rentalStatusLabel(r.status);
                            final statusColor = switch (r.status) {
                              'Active' => ProcessYellow,
                              'Completed' => Colors.white54,
                              'Cancelled' => UnactiveRed,
                              _ => Colors.white70,
                            };
                            return DataRow(
                              cells: [
                                DataCell(Text(r.startTime,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                                DataCell(Text('${r.durationHours}',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                                DataCell(Text(r.clientName,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                                DataCell(Text(r.clientPhone ?? '—',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                                DataCell(Text(r.hallNumber ?? '${r.hallId}',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                                DataCell(Text('${r.totalPrice} ₽',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                                DataCell(Text(
                                  statusLabel,
                                  style: TextStyle(color: statusColor),
                                )),
                                DataCell(
                                  r.canCancel
                                      ? TextButton(
                                          onPressed: () => _cancel(r),
                                          child: const Text(
                                            'Отменить',
                                            style: TextStyle(color: UnactiveRed),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  String _rentalStatusLabel(String status) {
    switch (status) {
      case 'Active':
        return 'Активна';
      case 'Completed':
        return 'Прошла';
      case 'Cancelled':
        return 'Отменена';
      default:
        return status;
    }
  }

  Widget _buildWeekCalendar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                setState(() {
                  _currentWeek = _currentWeek.subtract(Duration(days: 7));
                });
                _loadRentals();
              },
            ),
            Text(
              '${DateFormat('d MMM', 'ru').format(weekDays.first)} - '
              '${DateFormat('d MMM', 'ru').format(weekDays.last)}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () {
                setState(() {
                  _currentWeek = _currentWeek.add(const Duration(days: 7));
                });
                _loadRentals();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final day = weekDays[i];
            final selected = i == _selectedDayIndex;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDayIndex = i);
                _loadRentals();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                decoration: BoxDecoration(
                  border: selected
                      ? Border.all(color: ProcessYellow, width: 2)
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
                        fontSize: 16,
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
