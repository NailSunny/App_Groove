import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_DTOs/admin/report_dtos.dart';
import 'package:groove_app/api_DTOs/admin/trainer_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/api_service/admin_reports_api.dart';
import 'package:groove_app/features/admin/reports/report_period_filter.dart';
import 'package:groove_app/features/admin/reports/report_scrollable_table.dart';
import 'package:groove_app/features/admin/reports/report_widgets.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';

class TrainersReportsScreen extends StatefulWidget {
  const TrainersReportsScreen({super.key});

  @override
  State<TrainersReportsScreen> createState() => _TrainersReportsScreenState();
}

class _TrainersReportsScreenState extends State<TrainersReportsScreen> {
  ReportPeriodPreset _preset = ReportPeriodPreset.month;
  late DateTime _start;
  late DateTime _end;
  int? _trainerId;
  List<TrainerAdminDto> _trainers = [];
  Future<TrainerReportDto>? _future;
  int? _sortColumn;
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    final r = ReportPeriodFilter.rangeForPreset(_preset);
    _start = r.$1;
    _end = r.$2;
    _loadTrainers();
    _reload();
  }

  Future<void> _loadTrainers() async {
    try {
      final list = await fetchTrainers();
      if (mounted) setState(() => _trainers = list);
    } catch (_) {}
  }

  void _reload() {
    setState(() {
      _future = fetchTrainerReport(
        startDate: _start,
        endDate: _end,
        trainerId: _trainerId,
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

  List<TrainerReportRowDto> _sorted(List<TrainerReportRowDto> rows) {
    if (_sortColumn == null) return rows;
    final list = List<TrainerReportRowDto>.from(rows);
    int cmp(TrainerReportRowDto a, TrainerReportRowDto b) {
      num vA, vB;
      switch (_sortColumn) {
        case 0:
          return a.trainerName.compareTo(b.trainerName);
        case 1:
          vA = a.groupClassesCount;
          vB = b.groupClassesCount;
        case 2:
          vA = a.personalClassesCount;
          vB = b.personalClassesCount;
        case 3:
          vA = a.totalClassesCount;
          vB = b.totalClassesCount;
        case 4:
          vA = a.groupRegistrationsCount;
          vB = b.groupRegistrationsCount;
        case 5:
          vA = a.uniqueClientsCount;
          vB = b.uniqueClientsCount;
        case 6:
          vA = a.classesPerWeek;
          vB = b.classesPerWeek;
        default:
          return 0;
      }
      final c = vA.compareTo(vB);
      return _sortAsc ? c : -c;
    }

    list.sort(cmp);
    return list;
  }

  void _onSort(int col) {
    setState(() {
      if (_sortColumn == col) {
        _sortAsc = !_sortAsc;
      } else {
        _sortColumn = col;
        _sortAsc = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.groove.headerBackground,
        title: Text('Отчёт: Тренеры', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ReportPeriodFilter(
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int?>(
                    value: _trainerId,
                    hint: Text('Все тренеры', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все тренеры')),
                      ..._trainers.map(
                        (t) => DropdownMenuItem(
                          value: t.idTrainer,
                          child: Text('${t.familiaTrainer} ${t.nameTrainer}'),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _trainerId = v);
                      _reload();
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        final path = await exportTrainerCsv(_start, _end, trainerId: _trainerId);
                        if (!context.mounted) return;
                        showAdminSuccess(context, 'Сохранено: $path');
                      } catch (e) {
                        if (!context.mounted) return;
                        showAdminError(context, e);
                      }
                    },
                    icon: Icon(Icons.download, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<TrainerReportDto>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                  return reportLoading();
                }
                if (snap.hasError) return reportError(snap.error!, _reload);
                if (!snap.hasData) return reportLoading();
                final r = snap.data!;
                final rows = _sorted(r.trainers);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  title: 'Рейтинг по занятиям',
                                  child: ReportTrainerRankingChart(trainers: rows),
                                ),
                              ),
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'Групповые vs персональные',
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          _Legend(color: Color(0xFFAD03E2), label: 'Групповые'),
                                          const SizedBox(width: 16),
                                          _Legend(color: Color(0xFF03DAC6), label: 'Персональные'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ReportGroupedTrainerChart(trainers: rows),
                                    ],
                                  ),
                                ),
                              ),
                              if (r.trainerWeeklyLoad.isNotEmpty)
                                SizedBox(
                                  width: c.maxWidth,
                                  child: chartCard(
                    context: context,
                                    title: 'Загрузка по неделям',
                                    child: ReportLineChart(
                                      points: r.trainerWeeklyLoad,
                                      useAmount: false,
                                      color: const Color(0xFF03DAC6),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      ReportSectionTitle('KPI тренеров'),
                      Container(
                        decoration: BoxDecoration(
                          color: context.groove.headerBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Theme.of(context).cardColor),
                        ),
                        child: ReportScrollableTable(
                          minWidth: 900,
                          maxVisibleRows: 10,
                          dataTextStyle: reportTableDataStyle(context),
                          columns: [
                            DataColumn(
                              label: InkWell(
                                onTap: () => _onSort(0),
                                child: const Text('Тренер'),
                              ),
                            ),
                            DataColumn(
                              label: InkWell(
                                onTap: () => _onSort(1),
                                child: const Text('Групп.'),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: InkWell(
                                onTap: () => _onSort(2),
                                child: const Text('Перс.'),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: InkWell(
                                onTap: () => _onSort(3),
                                child: const Text('Всего'),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: InkWell(
                                onTap: () => _onSort(4),
                                child: const Text('Записей'),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: InkWell(
                                onTap: () => _onSort(5),
                                child: const Text('Клиентов'),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: InkWell(
                                onTap: () => _onSort(6),
                                child: const Text('Зан./нед'),
                              ),
                              numeric: true,
                            ),
                          ],
                          rows: rows
                              .map(
                                (t) => DataRow(
                                  cells: [
                                    DataCell(Text(t.trainerName)),
                                    DataCell(Text('${t.groupClassesCount}')),
                                    DataCell(Text('${t.personalClassesCount}')),
                                    DataCell(Text('${t.totalClassesCount}')),
                                    DataCell(Text('${t.groupRegistrationsCount}')),
                                    DataCell(Text('${t.uniqueClientsCount}')),
                                    DataCell(Text(t.classesPerWeek.toStringAsFixed(1))),
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

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: color),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12)),
        ],
      );
}
