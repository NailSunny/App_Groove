import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_DTOs/admin/report_dtos.dart';
import 'package:groove_app/api_DTOs/admin/hall_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/api_service/admin_reports_api.dart';
import 'package:groove_app/features/admin/reports/report_period_filter.dart';
import 'package:groove_app/features/admin/reports/report_scrollable_table.dart';
import 'package:groove_app/features/admin/reports/report_widgets.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:intl/intl.dart';

class FinanceReportsScreen extends StatefulWidget {
  const FinanceReportsScreen({super.key});

  @override
  State<FinanceReportsScreen> createState() => _FinanceReportsScreenState();
}

class _FinanceReportsScreenState extends State<FinanceReportsScreen> {
  ReportPeriodPreset _preset = ReportPeriodPreset.month;
  late DateTime _start;
  late DateTime _end;
  String _granularity = 'day';
  int? _hallId;
  List<HallAdminDto> _halls = [];
  Future<FinanceReportDto>? _future;

  @override
  void initState() {
    super.initState();
    final r = ReportPeriodFilter.rangeForPreset(_preset);
    _start = r.$1;
    _end = r.$2;
    _loadHalls();
    _reload();
  }

  Future<void> _loadHalls() async {
    try {
      final halls = await fetchHalls();
      if (mounted) setState(() => _halls = halls);
    } catch (_) {}
  }

  void _reload() {
    setState(() {
      _future = fetchFinanceReport(
        startDate: _start,
        endDate: _end,
        hallId: _hallId,
        granularity: _granularity,
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

  Future<void> _export() async {
    try {
      final path = await exportFinanceCsv(_start, _end, hallId: _hallId);
      if (!mounted) return;
      showAdminSuccess(context, 'Сохранено: $path');
    } catch (e) {
      if (!mounted) return;
      showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.groove.headerBackground,
        title: Text('Отчёт: Финансы', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
              granularity: _granularity,
              showGranularity: true,
              onPresetChanged: _applyPreset,
              onRangeChanged: (s, e) {
                setState(() {
                  _preset = ReportPeriodPreset.custom;
                  _start = s;
                  _end = e;
                });
                _reload();
              },
              onGranularityChanged: (g) {
                setState(() => _granularity = g);
                _reload();
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_halls.isNotEmpty)
                    DropdownButton<int?>(
                      value: _hallId,
                      hint: Text('Все залы', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Все залы')),
                        ..._halls.map(
                          (h) => DropdownMenuItem(
                            value: h.idHall,
                            child: Text('Зал ${h.numberHall}'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => _hallId = v);
                        _reload();
                      },
                    ),
                  IconButton(
                    onPressed: _export,
                    icon: Icon(Icons.download, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                    tooltip: 'Экспорт CSV',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<FinanceReportDto>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                  return reportLoading();
                }
                if (snap.hasError) return reportError(snap.error!, _reload);
                if (!snap.hasData) return reportLoading();
                final r = snap.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, c) {
                          final w = (c.maxWidth - 24) / 3;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: w.clamp(180, 400),
                                child: ReportMetricCard(
                                  title: 'Общий доход',
                                  value: formatMoney(r.totalRevenue),
                                  icon: Icons.payments,
                                ),
                              ),
                              SizedBox(
                                width: w.clamp(180, 400),
                                child: ReportMetricCard(
                                  title: 'Абонементы',
                                  value: formatMoney(r.abonementRevenue),
                                  subtitle: 'Продано: ${r.soldAbonementsCount} (пробных: ${r.trialAbonementsCount})',
                                  icon: Icons.card_membership,
                                ),
                              ),
                              SizedBox(
                                width: w.clamp(180, 400),
                                child: ReportMetricCard(
                                  title: 'Аренда залов',
                                  value: formatMoney(r.rentalRevenue),
                                  subtitle: '${r.rentalCount} аренд · ср. ${formatMoney(r.rentalAverageCheck)}',
                                  icon: Icons.meeting_room,
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
                                  title: 'Динамика доходов',
                                  child: ReportLineChart(points: r.revenueTrend),
                                ),
                              ),
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'Доля доходов',
                                  child: ReportPieChart(items: r.revenueShare),
                                ),
                              ),
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'Доход по месяцам',
                                  child: ReportBarChart(points: r.monthlyRevenue),
                                ),
                              ),
                              SizedBox(
                                width: half.clamp(280, 900),
                                child: chartCard(
                    context: context,
                                  title: 'Накопленный доход',
                                  child: ReportLineChart(
                                    points: r.cumulativeRevenue,
                                    color: const Color(0xFF03DAC6),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      ReportSectionTitle('Топ абонементов'),
                      chartCard(
                    context: context,
                        title: 'По количеству продаж',
                        child: ReportBarChart(
                          points: r.topAbonements
                              .map((a) => ReportPeriodPointDto(
                                    label: a.name.length > 12 ? '${a.name.substring(0, 12)}…' : a.name,
                                    count: a.count,
                                  ))
                              .toList(),
                          useAmount: false,
                        ),
                      ),
                      ReportSectionTitle('Последние транзакции'),
                      _TransactionsTable(transactions: r.recentTransactions),
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

class _TransactionsTable extends StatelessWidget {
  final List<ReportTransactionDto> transactions;
  _TransactionsTable({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: context.groove.headerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).cardColor),
      ),
      child: ReportScrollableTable(
        minWidth: 800,
        maxVisibleRows: 10,
        dataTextStyle: reportTableDataStyle(context),
        columns: const [
          DataColumn(label: Text('Дата')),
          DataColumn(label: Text('Тип')),
          DataColumn(label: Text('Клиент')),
          DataColumn(label: Text('Описание')),
          DataColumn(label: Text('Сумма')),
          DataColumn(label: Text('Статус')),
        ],
        rows: transactions
            .map(
              (t) => DataRow(
                cells: [
                  DataCell(Text(fmt.format(t.date))),
                  DataCell(Text(t.type == 'Purchase' ? 'Покупка' : 'Аренда')),
                  DataCell(Text(t.clientName)),
                  DataCell(Text(t.description, overflow: TextOverflow.ellipsis)),
                  DataCell(Text(formatMoney(t.amount))),
                  DataCell(Text(t.status)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
