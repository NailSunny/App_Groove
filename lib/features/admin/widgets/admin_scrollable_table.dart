import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';

/// DataTable с горизонтальной и вертикальной прокруткой — без overflow.
class AdminScrollableTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double minWidth;
  final double dataRowMinHeight;
  final TextStyle? dataTextStyle;

  const AdminScrollableTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 900,
    this.dataRowMinHeight = 52,
    this.dataTextStyle,
  });

  @override
  State<AdminScrollableTable> createState() => _AdminScrollableTableState();
}

class _AdminScrollableTableState extends State<AdminScrollableTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.groove;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = g.headerBackground;
    final rowColor = isDark ? const Color(0xFF1E1E1E) : g.cardBackground;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > widget.minWidth
            ? constraints.maxWidth
            : widget.minWidth;
        return Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              notificationPredicate: (notification) =>
                  notification.depth == 1,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: width),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(headingColor),
                    dataRowColor: WidgetStateProperty.all(rowColor),
                    dataTextStyle: widget.dataTextStyle ??
                        TextStyle(color: g.onSurface),
                    dataRowMinHeight: widget.dataRowMinHeight,
                    dataRowMaxHeight: widget.dataRowMinHeight,
                    columnSpacing: 16,
                    horizontalMargin: 12,
                    columns: widget.columns,
                    rows: widget.rows,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
