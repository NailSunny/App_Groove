import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:intl/intl.dart';

enum ReportPeriodPreset { day, week, month, year, custom }

class ReportPeriodFilter extends StatelessWidget {
  final ReportPeriodPreset preset;
  final DateTime startDate;
  final DateTime endDate;
  final String granularity;
  final ValueChanged<ReportPeriodPreset> onPresetChanged;
  final void Function(DateTime start, DateTime end) onRangeChanged;
  final ValueChanged<String>? onGranularityChanged;
  final bool showGranularity;
  final Widget? trailing;

  const ReportPeriodFilter({
    super.key,
    required this.preset,
    required this.startDate,
    required this.endDate,
    this.granularity = 'day',
    required this.onPresetChanged,
    required this.onRangeChanged,
    this.onGranularityChanged,
    this.showGranularity = false,
    this.trailing,
  });

  static (DateTime start, DateTime end) rangeForPreset(ReportPeriodPreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (preset) {
      ReportPeriodPreset.day => (today, today),
      ReportPeriodPreset.week => (
          today.subtract(Duration(days: today.weekday - 1)),
          today,
        ),
      ReportPeriodPreset.month => (DateTime(today.year, today.month, 1), today),
      ReportPeriodPreset.year => (DateTime(today.year, 1, 1), today),
      ReportPeriodPreset.custom => (today.subtract(const Duration(days: 30)), today),
    };
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy');
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.groove.headerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).cardColor),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _chip(context, 'День', ReportPeriodPreset.day),
          _chip(context, 'Неделя', ReportPeriodPreset.week),
          _chip(context, 'Месяц', ReportPeriodPreset.month),
          _chip(context, 'Год', ReportPeriodPreset.year),
          _chip(context, 'Период…', ReportPeriodPreset.custom),
          SizedBox(width: 8),
          Text(
            '${fmt.format(startDate)} — ${fmt.format(endDate)}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          if (preset == ReportPeriodPreset.custom)
            TextButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(start: startDate, end: endDate),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: MainPurple,
                        onPrimary: Colors.white,
                        surface: Color(0xFF2A2A2A),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  onRangeChanged(picked.start, picked.end);
                }
              },
              icon: Icon(Icons.date_range, color: MainPurple, size: 18),
              label: Text('Выбрать', style: TextStyle(color: MainPurple)),
            ),
          if (showGranularity && onGranularityChanged != null) ...[
            SizedBox(width: 12),
            DropdownButton<String>(
              value: granularity,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              items: const [
                DropdownMenuItem(value: 'day', child: Text('По дням')),
                DropdownMenuItem(value: 'week', child: Text('По неделям')),
                DropdownMenuItem(value: 'month', child: Text('По месяцам')),
              ],
              onChanged: (v) {
                if (v != null) onGranularityChanged!(v);
              },
            ),
          ],
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, ReportPeriodPreset value) {
    final g = context.groove;
    final selected = preset == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPresetChanged(value),
      selectedColor: MainPurple.withValues(alpha: 0.35),
      checkmarkColor: Theme.of(context).colorScheme.onSurface,
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).colorScheme.onSurface : g.onSurfaceSecondary,
      ),
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(color: selected ? MainPurple : g.border),
    );
  }
}
