import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/abonement_admin_dto.dart';
import 'package:groove_app/api_DTOs/schedulegroup_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';

class AbonementsTab extends StatefulWidget {
  const AbonementsTab({super.key});

  @override
  State<AbonementsTab> createState() => _AbonementsTabState();
}

class _AbonementsTabState extends State<AbonementsTab> {
  List<AbonementAdminDto> _items = [];
  List<TypeClassDto> _types = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchAbonementsAdmin();
      final types = await fetchTypeClasses();
      if (mounted) setState(() { _items = items; _types = types; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); showAdminError(context, e); }
    }
  }

  Future<void> _showForm({AbonementAdminDto? item}) async {
    final nameCtrl = TextEditingController(text: item?.nameAbonement ?? '');
    final durationCtrl = TextEditingController(text: item?.duration ?? '');
    final priceCtrl = TextEditingController(text: item?.price.toString() ?? '');
    final kolCtrl = TextEditingController(text: item?.kolClasses.toString() ?? '1');
    final isTrialItem = item?.isTrial ?? false;
    int? selectedTypeId = item?.idType;
    bool isPrivate = item?.isPrivate ?? false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(item == null ? 'Новый абонемент' : 'Редактировать абонемент', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Название *')),
                  SizedBox(height: 12),
                  if (!isTrialItem)
                    DropdownButtonFormField<int?>(
                      value: selectedTypeId,
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: adminInputDecoration(context, 'Направление (необязательно)'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Любое направление'),
                        ),
                        ..._types.map(
                          (t) => DropdownMenuItem<int?>(
                            value: t.id,
                            child: Text(t.name),
                          ),
                        ),
                      ],
                      onChanged: (v) => setDialogState(() => selectedTypeId = v),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Пробный абонемент (направление: любое)', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
                    ),
                  SizedBox(height: 12),
                  CheckboxListTile(
                    value: isPrivate,
                    onChanged: (v) => setDialogState(() => isPrivate = v ?? false),
                    title: Text('Персональный', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    activeColor: MainPurple,
                  ),
                  TextField(controller: durationCtrl, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Длительность')),
                  SizedBox(height: 12),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Цена *')),
                  SizedBox(height: 12),
                  TextField(controller: kolCtrl, keyboardType: TextInputType.number, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Кол-во занятий *')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || !mounted) return;

    try {
      final body = <String, dynamic>{
        'name_abonement': nameCtrl.text.trim(),
        'is_private': isPrivate,
        'duration': durationCtrl.text.trim().isEmpty ? null : durationCtrl.text.trim(),
        'price': int.parse(priceCtrl.text.trim()),
        'kol_classes': int.parse(kolCtrl.text.trim()),
      };
      if (!isTrialItem) {
        if (selectedTypeId == null) {
          body['universalDirection'] = true;
        } else {
          body['id_type'] = selectedTypeId;
        }
      }
      if (item == null) {
        await createAbonement(body);
        showAdminSuccess(context, 'Абонемент создан');
      } else {
        await updateAbonement(item.idAbonement, body);
        showAdminSuccess(context, 'Абонемент обновлён');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _delete(AbonementAdminDto item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Удалить абонемент?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(item.nameAbonement ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: UnactiveRed), onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await deleteAbonement(item.idAbonement);
      showAdminSuccess(context, 'Абонемент удалён');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  String _typeName(AbonementAdminDto a) {
    if (a.isTrial || a.idType == null) return 'Любое';
    return _types.where((t) => t.id == a.idType).map((t) => t.name).firstOrNull ?? '${a.idType}';
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
              Text('Абонементы', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold)),
              adminAddButton(onPressed: () => _showForm()),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: MainPurple))
                : AdminScrollableTable(
                    minWidth: 1000,
                    columns: [
                      DataColumn(label: Text('Название', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Направление', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Персональный', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Цена', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Занятий', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Длительность', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    ],
                    rows: _items.map((a) => DataRow(cells: [
                      DataCell(Text(a.nameAbonement ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                      DataCell(Text(_typeName(a), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                      DataCell(Text(a.isPrivate ? 'Да' : 'Нет', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                      DataCell(Text('${a.price} ₽', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                      DataCell(Text('${a.kolClasses}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                      DataCell(Text(a.duration ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!a.isTrial)
                            IconButton(icon: const Icon(Icons.edit, color: MainPurple), onPressed: () => _showForm(item: a)),
                          if (!a.isTrial)
                            IconButton(icon: const Icon(Icons.delete, color: UnactiveRed), onPressed: () => _delete(a)),
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
