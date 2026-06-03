import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/type_class_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';

class DirectionsTab extends StatefulWidget {
  const DirectionsTab({super.key});

  @override
  State<DirectionsTab> createState() => _DirectionsTabState();
}

class _DirectionsTabState extends State<DirectionsTab> {
  List<TypeClassAdminDto> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchTypesAdmin();
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); showAdminError(context, e); }
    }
  }

  Future<void> _showForm({TypeClassAdminDto? item}) async {
    final nameCtrl = TextEditingController(text: item?.nameType ?? '');
    final descCtrl = TextEditingController(text: item?.discription ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          item == null ? 'Новое направление' : 'Редактировать направление',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: adminInputDecoration(context, 'Название *'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 4,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: adminInputDecoration(context, 'Описание'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    try {
      final body = {
        'name_type': nameCtrl.text.trim(),
        'discription': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      };
      if (item == null) {
        await createType(body);
        if (mounted) showAdminSuccess(context, 'Направление создано');
      } else {
        await updateType(item.idType, body);
        if (mounted) showAdminSuccess(context, 'Направление обновлено');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _delete(TypeClassAdminDto item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Удалить направление?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(item.nameType ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UnactiveRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await deleteType(item.idType);
      if (mounted) showAdminSuccess(context, 'Направление удалено');
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
              Text(
                'Направления',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold),
              ),
              adminAddButton(onPressed: () => _showForm()),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: MainPurple))
                : AdminScrollableTable(
                      minWidth: 700,
                      columns: [
                        DataColumn(label: Text('Название', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('Описание', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      ],
                      rows: _items.map((t) => DataRow(cells: [
                        DataCell(Text(t.nameType ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(t.discription ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: MainPurple),
                              onPressed: () => _showForm(item: t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: UnactiveRed),
                              onPressed: () => _delete(t),
                            ),
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
