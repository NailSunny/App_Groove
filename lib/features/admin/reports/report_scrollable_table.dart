import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/features/admin/reports/report_widgets.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';

/// Таблица с фиксированной высотой — безопасна внутри [SingleChildScrollView].
class ReportScrollableTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double minWidth;
  final int maxVisibleRows;
  final TextStyle? dataTextStyle;

  const ReportScrollableTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 800,
    this.maxVisibleRows = 12,
    this.dataTextStyle,
  });

  static double _headerHeight = 56;
  static double _rowHeight = 52;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text('Нет данных', style: TextStyle(color: context.groove.carouselDotInactive)),
        ),
      );
    }

    final visibleRows = rows.length.clamp(1, maxVisibleRows);
    final height = _headerHeight + visibleRows * _rowHeight;

    final tableDataStyle = dataTextStyle ?? reportTableDataStyle(context);
    final headingStyle = reportTableHeadingStyle(context);

    return SizedBox(
      height: height,
      child: AdminScrollableTable(
        minWidth: minWidth,
        columns: columns
            .map(
              (c) => DataColumn(
                label: DefaultTextStyle(
                  style: headingStyle,
                  child: c.label,
                ),
                numeric: c.numeric,
                tooltip: c.tooltip,
                onSort: c.onSort,
                columnWidth: c.columnWidth,
                headingRowAlignment: c.headingRowAlignment,
              ),
            )
            .toList(),
        rows: rows,
        dataRowMinHeight: _rowHeight,
        dataTextStyle: tableDataStyle,
      ),
    );
  }
}
