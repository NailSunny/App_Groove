import 'dart:async';
import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/purchase_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:intl/intl.dart';

class PurchasesTab extends StatefulWidget {
  const PurchasesTab({super.key});

  @override
  State<PurchasesTab> createState() => _PurchasesTabState();
}

class _PurchasesTabState extends State<PurchasesTab> {
  List<PurchaseAdminDto> _items = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dateFrom = DateTime(today.year, today.month, today.day);
    _dateTo = _dateFrom;
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchPurchasesAdmin(
        from: _dateFrom,
        to: _dateTo,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAdminError(context, e);
      }
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? (_dateFrom ?? DateTime.now()) : (_dateTo ?? DateTime.now());
    final picked = await pickDate(context, initial);
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _dateFrom = DateTime(picked.year, picked.month, picked.day);
        if (_dateTo != null && _dateFrom!.isAfter(_dateTo!)) _dateTo = _dateFrom;
      } else {
        _dateTo = DateTime(picked.year, picked.month, picked.day);
        if (_dateFrom != null && _dateTo!.isBefore(_dateFrom!)) _dateFrom = _dateTo;
      }
    });
    _load();
  }

  Future<void> _cancel(PurchaseAdminDto item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Отменить покупку?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          'Клиент: ${item.clientFullName}\nСумма ${item.summa} ₽ будет возвращена на баланс.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Нет')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UnactiveRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await cancelPurchase(item.idPurchase);
      if (mounted) showAdminSuccess(context, 'Покупка отменена');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd.MM.yyyy HH:mm');

    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Покупки', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: adminInputDecoration(context, 'Поиск по ФИО клиента'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickDate(isFrom: true),
                icon: Icon(Icons.date_range, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 18),
                label: Text(
                  'С: ${formatDate(_dateFrom)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _pickDate(isFrom: false),
                icon: Icon(Icons.date_range, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 18),
                label: Text(
                  'По: ${formatDate(_dateTo)}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
              TextButton(
                onPressed: () {
                  final today = DateTime.now();
                  setState(() {
                    _dateFrom = DateTime(today.year, today.month, today.day);
                    _dateTo = _dateFrom;
                  });
                  _load();
                },
                child: const Text('Сегодня', style: TextStyle(color: MainPurple)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateFrom = null;
                    _dateTo = null;
                  });
                  _load();
                },
                child: Text('Все даты', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: MainPurple))
                : AdminScrollableTable(
                    minWidth: 1000,
                    columns: [
                      DataColumn(label: Text('Клиент', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Абонементы', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Дата', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Сумма', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Статус', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    ],
                    rows: _items.map((p) {
                      final statusColor = p.isActive ? ActiveGreen : Colors.white54;
                      return DataRow(cells: [
                        DataCell(Text(p.clientFullName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(p.abonementSummary, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(dateFmt.format(p.datePurchase), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text('${p.summa} ₽', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(p.status, style: TextStyle(color: statusColor))),
                        DataCell(
                          p.canCancel
                              ? TextButton(
                                  onPressed: () => _cancel(p),
                                  child: const Text('Отменить', style: TextStyle(color: UnactiveRed)),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ]);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
