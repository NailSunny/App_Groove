import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/hall_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';

class HallsTab extends StatefulWidget {
  const HallsTab({super.key});

  @override
  State<HallsTab> createState() => _HallsTabState();
}

class _HallsTabState extends State<HallsTab> {
  List<HallAdminDto> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchHalls();
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); showAdminError(context, e); }
    }
  }

  Future<void> _showForm({HallAdminDto? item}) async {
    final numberCtrl = TextEditingController(text: item?.numberHall ?? '');
    bool isRentable = item?.isRentable ?? false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(item == null ? 'Новый зал' : 'Редактировать зал', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: numberCtrl, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Номер зала *')),
                CheckboxListTile(
                  value: isRentable,
                  onChanged: (v) => setDialogState(() => isRentable = v ?? false),
                  title: Text('Доступен для аренды', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                  activeColor: MainPurple,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            ElevatedButton(onPressed: () { if (numberCtrl.text.isEmpty) return; Navigator.pop(ctx, true); }, child: const Text('Сохранить')),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) return;

    try {
      final body = {'number_hall': numberCtrl.text.trim(), 'is_Rentable': isRentable};
      if (item == null) {
        await createHall(body);
        showAdminSuccess(context, 'Зал создан');
      } else {
        await updateHall(item.idHall, body);
        showAdminSuccess(context, 'Зал обновлён');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _delete(HallAdminDto item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Удалить зал?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(item.numberHall ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: UnactiveRed), onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await deleteHall(item.idHall);
      showAdminSuccess(context, 'Зал удалён');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Залы', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold)),
              adminAddButton(onPressed: () => _showForm()),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: MainPurple))
                : AdminScrollableTable(
                      minWidth: 600,
                      columns: [
                        DataColumn(label: Text('Номер', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('Аренда', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      ],
                      rows: _items.map((h) => DataRow(cells: [
                        DataCell(Text(h.numberHall ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(h.isRentable ? 'Да' : 'Нет', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: MainPurple), onPressed: () => _showForm(item: h)),
                            IconButton(icon: const Icon(Icons.delete, color: UnactiveRed), onPressed: () => _delete(h)),
                          ],
                        )),
                      ])).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
