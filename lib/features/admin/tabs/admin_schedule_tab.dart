import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/hall_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/trainer_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/type_class_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/api_service/admin_schedule_week_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_schedule_cell_dialog.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:intl/intl.dart';

class AdminScheduleTab extends StatefulWidget {
  const AdminScheduleTab({super.key});

  @override
  State<AdminScheduleTab> createState() => _AdminScheduleTabState();
}

class _AdminScheduleTabState extends State<AdminScheduleTab> {
  DateTime _weekStart = adminSchedulingWeekStart();
  int _typeIndex = 0; // 0 all, 1 group, 2 personal
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _week;
  bool _isFullyPublished = false;
  List<TrainerAdminDto> _trainers = [];
  List<TypeClassAdminDto> _types = [];
  List<HallAdminDto> _halls = [];

  static const _trainerColors = [
    Color(0xFFAD03E2),
    Color(0xFFFFCC32),
    Color(0xFF03DAC6),
    Color(0xFFCA2121),
    Color(0xFF9C68AC),
    Color(0xFF31B527),
  ];

  String get _typeParam => switch (_typeIndex) {
        1 => 'group',
        2 => 'personal',
        _ => 'all',
      };

  @override
  void initState() {
    super.initState();
    _loadLookups();
    _load();
  }

  Future<void> _loadLookups() async {
    try {
      final results = await Future.wait([
        fetchTrainers(),
        fetchTypesAdmin(),
        fetchHalls(),
      ]);
      if (!mounted) return;
      setState(() {
        _trainers = results[0] as List<TrainerAdminDto>;
        _types = results[1] as List<TypeClassAdminDto>;
        _halls = results[2] as List<HallAdminDto>;
      });
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await fetchAdminWeekSchedule(
        weekStart: _weekStart,
        type: _typeParam,
      );
      if (!mounted) return;
      setState(() {
        _week = data;
        _isFullyPublished = data['isFullyPublished'] as bool? ?? false;
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

  Future<void> _validate() async {
    try {
      final result = await validateAdminWeek(_weekStart);
      if (!mounted) return;
      final errors = (result['errors'] as List<dynamic>?)?.cast<String>() ?? [];
      final warnings =
          (result['warnings'] as List<dynamic>?)?.cast<String>() ?? [];
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Проверка расписания', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errors.isEmpty)
                  const Text('Критических ошибок нет', style: TextStyle(color: ActiveGreen))
                else ...errors.map((e) => Text('• $e', style: const TextStyle(color: UnactiveRed))),
                const SizedBox(height: 12),
                ...warnings.map((w) => Text('• $w', style: const TextStyle(color: ProcessYellow))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _publish() async {
    try {
      final validation = await validateAdminWeek(_weekStart);
      final warnings =
          (validation['warnings'] as List<dynamic>?)?.cast<String>() ?? [];
      final empty = validation['emptyGroupSlots'] as int? ?? 0;

      if (empty > 0) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Публикация', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            content: Text(
              'Уверены, что хотите опубликовать расписание? Не все слоты заполнены.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Продолжить')),
            ],
          ),
        );
        if (ok != true) return;
      }

      final result = await publishAdminWeek(_weekStart);
      if (!mounted) return;
      _snack(result['message'] as String? ?? 'Опубликовано');
      if (warnings.isNotEmpty) {
        _snack(warnings.join('\n'));
      }
      await _load();
    } catch (e) {
      _snack(e.toString());
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Планирование расписания',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildToolbar(),
          const SizedBox(height: 8),
          _buildTypeTabs(),
          const SizedBox(height: 8),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final end = _weekStart.add(const Duration(days: 6));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() => _weekStart = _weekStart.subtract(Duration(days: 7)));
            _load();
          },
          icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
        ),
        Text(
          '${DateFormat('d MMM', 'ru').format(_weekStart)} – ${DateFormat('d MMM', 'ru').format(end)}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
        ),
        IconButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() => _weekStart = _weekStart.add(Duration(days: 7)));
            _load();
          },
          icon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
        ),
        if (_isFullyPublished)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Chip(
              label: Text('Опубликовано', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              backgroundColor: ActiveGreen,
            ),
          ),
        OutlinedButton(
          onPressed: _validate,
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            side: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF888888)
                  : const Color(0xFF9E9E9E),
            ),
          ),
          child: Text(
            'Проверить',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(onPressed: _publish, child: const Text('Опубликовать')),
      ],
    );
  }

  Widget _buildTypeTabs() {
    return Row(
      children: [
        _typeChip('Все', 0),
        _typeChip('Групповые', 1),
        _typeChip('Персональные', 2),
      ],
    );
  }

  Widget _typeChip(String label, int index) {
    final selected = _typeIndex == index;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : onSurface,
          ),
        ),
        selected: selected,
        selectedColor: MainPurple,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE8DDF0),
        onSelected: (_) {
          setState(() => _typeIndex = index);
          _load();
        },
      ),
    );
  }

  Widget _buildTable() {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: MainPurple));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))));
    }

    final slotTimes =
        (_week?['slotTimes'] as List<dynamic>?)?.cast<String>() ?? [];
    final days = (_week?['days'] as List<dynamic>?) ?? [];

    final columns = <DataColumn>[
      DataColumn(label: Text('Время', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
      ...days.map((d) {
        final date = DateTime.parse((d as Map)['date'] as String);
        return DataColumn(
          label: Text(
            DateFormat('E\nd.MM', 'ru').format(date),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        );
      }),
    ];

    final rows = <DataRow>[];
    for (final time in slotTimes) {
      final cells = <DataCell>[
        DataCell(Text(time, style: const TextStyle(color: ProcessYellow))),
      ];

      for (final d in days) {
        final dayMap = d as Map<String, dynamic>;
        final cellsList = (dayMap['cells'] as List<dynamic>?) ?? [];
        Map<String, dynamic>? cell;
        for (final c in cellsList) {
          final m = c as Map<String, dynamic>;
          if (m['startTime'] == time) {
            cell = m;
            break;
          }
        }
        final lesson = cell?['lesson'] as Map<String, dynamic>?;
        final dayDate = DateTime.parse(dayMap['date'] as String);
        cells.add(DataCell(_lessonCell(lesson, dayDate, time)));
      }
      rows.add(DataRow(cells: cells));
    }

    return AdminScrollableTable(
      columns: columns,
      rows: rows,
      minWidth: 1100,
      dataRowMinHeight: 92,
    );
  }

  Future<void> _onCellTap(
    Map<String, dynamic>? lesson,
    DateTime date,
    String time,
  ) async {
    try {
      if (lesson == null) {
        final ok = await AdminScheduleCellDialog.showAdd(
          context: context,
          date: date,
          startTime: time,
          typeFilterIndex: _typeIndex,
          trainers: _trainers,
          types: _types,
          halls: _halls,
        );
        if (ok) await _load();
        return;
      }

      final action = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Theme.of(context).cardColor,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: MainPurple),
                title: Text('Редактировать', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
              ListTile(
                leading: Icon(Icons.delete, color: UnactiveRed),
                title: Text('Удалить', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
          ),
        ),
      );
      if (action == 'edit') {
        final ok = await AdminScheduleCellDialog.showEdit(
          context: context,
          lesson: lesson,
          trainers: _trainers,
          types: _types,
          halls: _halls,
        );
        if (ok) await _load();
      } else if (action == 'delete') {
        final ok = await AdminScheduleCellDialog.showDelete(
          context: context,
          lesson: lesson,
        );
        if (ok) {
          _snack('Удалено');
          await _load();
        }
      }
    } catch (e) {
      _snack(e.toString());
    }
  }

  Widget _lessonCell(
    Map<String, dynamic>? lesson,
    DateTime date,
    String time,
  ) {
    if (lesson == null) {
      return InkWell(
        onTap: () => _onCellTap(null, date, time),
        child: const SizedBox(
          width: 120,
          height: 72,
          child: Center(
            child: Icon(Icons.add_circle_outline, color: ProcessYellow, size: 28),
          ),
        ),
      );
    }
    final colorIdx = lesson['trainerColorIndex'] as int? ?? 0;
    final color = _trainerColors[colorIdx % _trainerColors.length];
    final isGroup = lesson['lessonType'] == 'group';
    final status = lesson['status'] as String? ?? '';
    final subtitle = isGroup
        ? '${lesson['trainer']} · зал ${lesson['hall']} · ${lesson['places']}'
        : lesson['client'] != null
            ? '${lesson['trainer']} · ${lesson['client']}'
            : '${lesson['trainer']} · зал ${lesson['hall']}';

    return InkWell(
      onTap: () => _onCellTap(lesson, date, time),
      child: Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((lesson['direction'] as String?)?.isNotEmpty ?? false) ...[
            Text(
              lesson['direction'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
          ],
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 9, height: 1.15),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            maxLines: 1,
            style: TextStyle(
              color: status == 'Draft' ? ProcessYellow : ActiveGreen,
              fontSize: 9,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
