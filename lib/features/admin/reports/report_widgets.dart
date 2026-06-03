import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_DTOs/admin/report_dtos.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:intl/intl.dart';

class ReportMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;

  const ReportMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon = Icons.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.groove.headerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).cardColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: MainPurple, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 6),
            Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class ReportSectionTitle extends StatelessWidget {
  final String title;
  ReportSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 12, top: 8),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

String formatMoney(double v) => '${NumberFormat('#,###', 'ru').format(v.round())} ₽';

/// Текст в строках таблиц отчётов (тёмная тема — светлый, светлая — насыщенно тёмный).
TextStyle reportTableDataStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextStyle(
    color: isDark
        ? const Color(0xFFCCCCCC)
        : const Color(0xFF212121),
    fontSize: 14,
  );
}

/// Заголовки колонок таблиц отчётов.
TextStyle reportTableHeadingStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextStyle(
    color: isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF1A1A1A),
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}

/// Слишком много точек тормозит fl_chart на десктопе.
List<ReportPeriodPointDto> sampleChartPoints(List<ReportPeriodPointDto> points, {int max = 60}) {
  if (points.length <= max) return points;
  final step = (points.length / max).ceil();
  final sampled = <ReportPeriodPointDto>[];
  for (var i = 0; i < points.length; i += step) {
    sampled.add(points[i]);
  }
  if (sampled.last != points.last) sampled.add(points.last);
  return sampled;
}

Widget reportLoading() => const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(color: MainPurple),
      ),
    );

Widget reportError(Object e, VoidCallback onRetry) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.toString(), style: const TextStyle(color: UnactiveRed)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: MainPurple),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );

class ReportLineChart extends StatelessWidget {
  final List<ReportPeriodPointDto> points;
  final bool useAmount;
  final Color color;

  const ReportLineChart({
    super.key,
    required this.points,
    this.useAmount = true,
    this.color = MainPurple,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _emptyChart(context);
    final chartPoints = sampleChartPoints(points);
    final values = chartPoints.map((p) => useAmount ? p.amount : p.count.toDouble()).toList();
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.2;
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY <= 0 ? 1 : maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (v, _) => Text(
                  v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toInt().toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (chartPoints.length / 6).ceilToDouble().clamp(1, 999),
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= chartPoints.length) return SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      chartPoints[i].label,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 9),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                chartPoints.length,
                (i) => FlSpot(i.toDouble(), values[i]),
              ),
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportBarChart extends StatelessWidget {
  final List<ReportPeriodPointDto> points;
  final bool horizontal;
  final bool useAmount;

  const ReportBarChart({
    super.key,
    required this.points,
    this.horizontal = false,
    this.useAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _emptyChart(context);
    final chartPoints = sampleChartPoints(points);
    final values = chartPoints.map((p) => useAmount ? p.amount : p.count.toDouble()).toList();
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.15;
    if (horizontal) {
      return SizedBox(
        height: (chartPoints.length * 36).clamp(120, 320).toDouble(),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY <= 0 ? 1 : maxY,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 100,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= chartPoints.length) return SizedBox.shrink();
                    return Text(
                      chartPoints[i].label,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(
              chartPoints.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    color: MainPurple,
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 1 : maxY,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= chartPoints.length) return SizedBox.shrink();
                  return Text(
                    chartPoints[i].label,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 9),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            chartPoints.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: const Color(0xFF03DAC6),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportPieChart extends StatelessWidget {
  final List<ReportNamedCountDto> items;
  const ReportPieChart({super.key, required this.items});

  static const _colors = [
    MainPurple,
    Color(0xFF03DAC6),
    Color(0xFFFFCC32),
    Color(0xFF643C70),
    ElementsPurple,
  ];

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _emptyChart(context);
    final total = items.fold<double>(0, (s, i) => s + (i.amount > 0 ? i.amount : i.count));
    if (total <= 0) return _emptyChart(context);
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: List.generate(items.length, (i) {
                  final v = items[i].amount > 0 ? items[i].amount : items[i].count.toDouble();
                  return PieChartSectionData(
                    value: v,
                    color: _colors[i % _colors.length],
                    title: '${(v / total * 100).round()}%',
                    radius: 52,
                    titleStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          items[i].name,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportGroupedTrainerChart extends StatelessWidget {
  final List<TrainerReportRowDto> trainers;

  const ReportGroupedTrainerChart({super.key, required this.trainers});

  @override
  Widget build(BuildContext context) {
    final top = trainers.take(8).toList();
    if (top.isEmpty) return _emptyChart(context);
    final maxY = top
            .map((t) => (t.groupClassesCount > t.personalClassesCount
                    ? t.groupClassesCount
                    : t.personalClassesCount)
                .toDouble())
            .reduce((a, b) => a > b ? a : b) *
        1.2;
    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 1 : maxY,
          groupsSpace: 12,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= top.length) return SizedBox.shrink();
                  final name = top[i].trainerName.split(' ').first;
                  return Text(
                    name,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 9),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Color(0xFF2A2A2A), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(top.length, (i) {
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: top[i].groupClassesCount.toDouble(),
                  color: MainPurple,
                  width: 10,
                  borderRadius: BorderRadius.circular(3),
                ),
                BarChartRodData(
                  toY: top[i].personalClassesCount.toDouble(),
                  color: const Color(0xFF03DAC6),
                  width: 10,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

Widget _emptyChart(BuildContext context) => Container(
      height: 120,
      alignment: Alignment.center,
      child: Text(
        'Нет данных за период',
        style: TextStyle(color: context.groove.onSurfaceMuted),
      ),
    );

/// Рейтинг тренеров по числу проведённых занятий (горизонтальные полосы).
class ReportTrainerRankingChart extends StatelessWidget {
  final List<TrainerReportRowDto> trainers;

  const ReportTrainerRankingChart({super.key, required this.trainers});

  @override
  Widget build(BuildContext context) {
    final top = trainers.take(8).toList();
    if (top.isEmpty) return _emptyChart(context);

    final maxCount = top.map((t) => t.totalClassesCount).reduce((a, b) => a > b ? a : b);
    if (maxCount <= 0) return _emptyChart(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: top.map((t) {
        final fraction = t.totalClassesCount / maxCount;
        final shortName = t.trainerName.length > 18
            ? '${t.trainerName.substring(0, 18)}…'
            : t.trainerName;
        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  shortName,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 22,
                    backgroundColor: Theme.of(context).cardColor,
                    color: MainPurple,
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 28,
                child: Text(
                  '${t.totalClassesCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

Widget chartCard({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  final g = context.groove;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: g.cardBackground,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: g.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
