import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_DTOs/admin/report_dtos.dart';
import 'package:groove_app/api_DTOs/admin/trainer_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/type_class_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/api_service/admin_reports_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/reports/report_period_filter.dart';
import 'package:groove_app/features/admin/reports/report_scrollable_table.dart';
import 'package:groove_app/features/admin/reports/report_widgets.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:intl/intl.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({super.key});

  @override
  State<AttendanceReportsScreen> createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  ReportPeriodPreset _preset = ReportPeriodPreset.month;
  late DateTime _start;
  late DateTime _end;
  int? _trainerId;
  int? _typeId;
  final _searchCtrl = TextEditingController();
  List<TrainerAdminDto> _trainers = [];
  List<TypeClassAdminDto> _types = [];
  Future<AttendanceReportDto>? _future;

  @override
  void initState() {
    super.initState();
    final r = ReportPeriodFilter.rangeForPreset(_preset);
    _start = r.$1;
    _end = r.$2;
    _loadFilters();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      final trainers = await fetchTrainers();
      final types = await fetchTypesAdmin();
      if (mounted) {
        setState(() {
          _trainers = trainers;
          _types = types;
        });
      }
    } catch (_) {}
  }

  void _reload() {
    setState(() {
      _future = fetchAttendanceReport(
        startDate: _start,
        endDate: _end,
        trainerId: _trainerId,
        typeId: _typeId,
        clientSearch: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
    });
  }

  void _applyPreset(ReportPeriodPreset p) {
    final r = ReportPeriodFilter.rangeForPreset(p);
    setState(() {
      _preset = p;
      if (p != ReportPeriodPreset.custom) {
        _start = r.$1;
        _end = r.$2;
      }
    });
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.groove.headerBackground,
        title: Text('Отчёт: Посещаемость', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ReportPeriodFilter(
                  preset: _preset,
                  startDate: _start,
                  endDate: _end,
                  onPresetChanged: _applyPreset,
                  onRangeChanged: (s, e) {
                    setState(() {
                      _preset = ReportPeriodPreset.custom;
                      _start = s;
                      _end = e;
                    });
                    _reload();
                  },
                  trailing: IconButton(
                    onPressed: () async {
                      try {
                        final path = await exportAttendanceCsv(
                          _start,
                          _end,
                          trainerId: _trainerId,
                          typeId: _typeId,
                        );
                        if (!context.mounted) return;
                        showAdminSuccess(context, 'Сохранено: $path');
                      } catch (e) {
                        if (!context.mounted) return;
                        showAdminError(context, e);
                      }
                    },
                    icon: Icon(Icons.download, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    DropdownButton<int?>(
                      value: _trainerId,
                      hint: Text('Тренер', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все тренеры')),
                        ..._trainers.map(
                          (t) => DropdownMenuItem(
                            value: t.idTrainer,
                            child: Text(t.fullName),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => _trainerId = v);
                        _reload();
                      },
                    ),
                    DropdownButton<int?>(
                      value: _typeId,
                      hint: Text('Направление', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все направления')),
                        ..._types.map(
                          (t) => DropdownMenuItem(
                            value: t.idType,
                            child: Text(t.nameType ?? '—'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => _typeId = v);
                        _reload();
                      },
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _searchCtrl,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: adminInputDecoration(context, 'Поиск клиента'),
                        onSubmitted: (_) => _reload(),
                      ),
                    ),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Найти', style: TextStyle(color: MainPurple)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<AttendanceReportDto>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                  return reportLoading();
                }
                if (snap.hasError) return reportError(snap.error!, _reload);
                if (!snap.hasData) return reportLoading();
                final r = snap.data!;
                final displayClients = r.clients.take(100).toList();
                final fmt = DateFormat('dd.MM.yyyy');

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, c) {
                          final w = (c.maxWidth - 48) / 5;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: w.clamp(150, 240),
                                child: ReportMetricCard(
                                  title: 'Записей (группа)',
                                  value: '${r.totalGroupRegistrations}',
                                  icon: Icons.groups,
                                ),
                              ),
                              SizedBox(
                                width: w.clamp(150, 240),
                                child: ReportMetricCard(
                                  title: 'Записей (персональные)',
                                  value: '${r.personalRegistrationsCount}',
                                  icon: Icons.person,
                                ),
                              ),
                              SizedBox(
                                width: w.clamp(150, 240),
                                child: ReportMetricCard(
                                  title: 'Заполняемость',
                                  value: '${r.averageFillRatePercent.toStringAsFixed(1)}%',
                                  icon: Icons.pie_chart,
                                ),
                              ),
                              SizedBox(
                                width: w.clamp(150, 240),
                                child: ReportMetricCard(
                                  title: 'Отмены записей',
                                  value: '${r.cancellationsCount}',
                                  subtitle: 'отмена записи на групповое',
                                  icon: Icons.cancel_outlined,
                                ),
                              ),
                              SizedBox(
                                width: w.clamp(150, 240),
                                child: ReportMetricCard(
                                  title: 'Неявки',
                                  value: '${r.absentVisitsCount}',
                                  subtitle: 'Absent на занятиях',
                                  icon: Icons.event_busy,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, c) {
                          final half = (c.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'Посещения по дням недели',
                                  child: ReportBarChart(
                                    points: r.visitsByDayOfWeek,
                                    useAmount: false,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'По направлениям',
                                  child: ReportPieChart(
                                    items: r.visitsByDirection
                                        .map(
                                          (d) => ReportNamedCountDto(
                                            name: d.name,
                                            count: d.count,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'Топ занятий',
                                  child: ReportBarChart(
                                    points: r.topPopularClasses
                                        .map(
                                          (c) => ReportPeriodPointDto(
                                            label: c.name.length > 14
                                                ? '${c.name.substring(0, 14)}…'
                                                : c.name,
                                            count: c.count,
                                          ),
                                        )
                                        .toList(),
                                    useAmount: false,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'Динамика по месяцам',
                                  child: ReportLineChart(
                                    points: r.monthlyAttendanceTrend,
                                    useAmount: false,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      ReportSectionTitle(
                        r.clients.length > 100
                            ? 'Клиенты (показаны первые 100 из ${r.clients.length})'
                            : 'Клиенты',
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: context.groove.headerBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Theme.of(context).cardColor),
                        ),
                        child: ReportScrollableTable(
                          minWidth: 700,
                          maxVisibleRows: 10,
                          dataTextStyle: reportTableDataStyle(context),
                          columns: const [
                            DataColumn(label: Text('Клиент')),
                            DataColumn(label: Text('Групп.'), numeric: true),
                            DataColumn(label: Text('Перс.'), numeric: true),
                            DataColumn(label: Text('Всего'), numeric: true),
                            DataColumn(label: Text('Последний визит')),
                          ],
                          rows: displayClients
                              .map(
                                (c) => DataRow(
                                  cells: [
                                    DataCell(Text(c.fullName)),
                                    DataCell(Text('${c.groupVisits}')),
                                    DataCell(Text('${c.personalVisits}')),
                                    DataCell(Text('${c.totalVisits}')),
                                    DataCell(Text(
                                      c.lastVisitDate != null
                                          ? fmt.format(c.lastVisitDate!)
                                          : '—',
                                    )),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      ReportSectionTitle('Риск оттока (>30 дней без визита)'),
                      if (r.churnRiskClients.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Нет клиентов в зоне риска за выбранные критерии',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: context.groove.headerBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: UnactiveRed.withOpacity(0.4)),
                          ),
                          child: ReportScrollableTable(
                            minWidth: 500,
                            maxVisibleRows: 8,
                            dataTextStyle: reportTableDataStyle(context),
                            columns: const [
                              DataColumn(label: Text('Клиент')),
                              DataColumn(label: Text('Последний визит')),
                              DataColumn(label: Text('Дней'), numeric: true),
                            ],
                            rows: r.churnRiskClients
                                .map(
                                  (c) => DataRow(
                                    cells: [
                                      DataCell(Text(c.fullName)),
                                      DataCell(Text(
                                        c.lastVisitDate != null
                                            ? fmt.format(c.lastVisitDate!)
                                            : '—',
                                      )),
                                      DataCell(Text('${c.daysSinceLastVisit}')),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
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
