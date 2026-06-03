import 'dart:async';
import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/trainer_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/type_class_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_formatters.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';

class TrainersTab extends StatefulWidget {
  const TrainersTab({super.key});

  @override
  State<TrainersTab> createState() => _TrainersTabState();
}

class _TrainersTabState extends State<TrainersTab> {
  List<TrainerAdminDto> _items = [];
  List<TypeClassAdminDto> _types = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
    _loadTypes();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadTypes() async {
    try {
      final types = await fetchTypesAdmin();
      if (mounted) setState(() => _types = types);
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchTrainers(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );
      if (mounted) setState(() { _items = items; _loading = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); showAdminError(context, e); }
    }
  }

  Future<void> _showForm({TrainerAdminDto? item}) async {
    final familiaCtrl = TextEditingController(text: item?.familiaTrainer ?? '');
    final nameCtrl = TextEditingController(text: item?.nameTrainer ?? '');
    final patronymicCtrl = TextEditingController(text: item?.patronymic ?? '');
    final infoCtrl = TextEditingController(text: item?.information ?? '');
    final emailCtrl = TextEditingController(text: item?.email ?? '');
    final phoneCtrl = TextEditingController(text: item?.phone ?? '');
    final passwordCtrl = TextEditingController();
    DateTime? birthDate = item?.dateOfBirth;
    final selectedTypeIds = Set<int>.from(item?.typeClassIds ?? []);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(item == null ? 'Новый тренер' : 'Редактировать тренера', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: familiaCtrl, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Фамилия *')),
                  SizedBox(height: 12),
                  TextField(controller: nameCtrl, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Имя *')),
                  SizedBox(height: 12),
                  TextField(controller: patronymicCtrl, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Отчество *')),
                  SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: adminInputDecoration(context, 'Email *').copyWith(hintText: adminEmailHint),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [adminPhoneFormatter],
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: adminInputDecoration(context, 'Телефон +7(___)___-__-__'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: adminInputDecoration(context, 
                      item == null ? 'Пароль *' : 'Новый пароль (оставьте пустым, чтобы не менять)',
                    ),
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Дата рождения: ${formatDate(birthDate)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    trailing: Icon(Icons.calendar_today, color: MainPurple),
                    onTap: () async {
                      final picked = await pickDate(context, birthDate);
                      if (picked != null) setDialogState(() => birthDate = picked);
                    },
                  ),
                  SizedBox(height: 12),
                  TextField(controller: infoCtrl, maxLines: 3, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Информация')),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Направления', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: 8),
                  if (_types.isEmpty)
                    Text('Сначала добавьте направления во вкладке «Направления»', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _types.map((t) {
                        final selected = selectedTypeIds.contains(t.idType);
                        return FilterChip(
                          label: Text(t.nameType ?? '', style: TextStyle(color: selected ? Colors.white : Colors.white70)),
                          selected: selected,
                          selectedColor: MainPurple,
                          checkmarkColor: Theme.of(context).colorScheme.onSurface,
                          backgroundColor: ElementsPurple.withValues(alpha: 0.3),
                          onSelected: (v) {
                            setDialogState(() {
                              if (v) {
                                selectedTypeIds.add(t.idType);
                              } else {
                                selectedTypeIds.remove(t.idType);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (familiaCtrl.text.isEmpty ||
                    nameCtrl.text.isEmpty ||
                    patronymicCtrl.text.isEmpty ||
                    birthDate == null ||
                    emailCtrl.text.trim().isEmpty) return;
                if (!isValidEmail(emailCtrl.text)) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Укажите корректный email (например trainer@mail.ru)'),
                      backgroundColor: UnactiveRed,
                    ),
                  );
                  return;
                }
                if (item == null && passwordCtrl.text.length < 4) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    familiaCtrl.dispose();
    nameCtrl.dispose();
    patronymicCtrl.dispose();
    infoCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();

    if (ok != true || !mounted) return;
    final birth = birthDate;
    if (birth == null) return;

    try {
      final body = <String, dynamic>{
        'familiaTrainer': familiaCtrl.text.trim(),
        'nameTrainer': nameCtrl.text.trim(),
        'patronymic': patronymicCtrl.text.trim(),
        'dateOfBirth': DateTime(birth.year, birth.month, birth.day).toIso8601String(),
        'information': infoCtrl.text.trim(),
        'typeClassIds': selectedTypeIds.toList(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      };
      if (item == null) {
        body['password'] = passwordCtrl.text;
        await createTrainer(body);
        showAdminSuccess(context, 'Тренер создан');
      } else {
        if (passwordCtrl.text.isNotEmpty) {
          body['password'] = passwordCtrl.text;
        }
        await updateTrainer(item.idTrainer, body);
        showAdminSuccess(context, 'Тренер обновлён');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _delete(TrainerAdminDto item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Удалить тренера?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(item.fullName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: UnactiveRed), onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await deleteTrainer(item.idTrainer);
      showAdminSuccess(context, 'Тренер удалён');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  String _directionNames(TrainerAdminDto t) {
    if (t.typeClassIds.isEmpty) return '—';
    final names = _types
        .where((type) => t.typeClassIds.contains(type.idType))
        .map((type) => type.nameType ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    return names.isEmpty ? '—' : names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Тренеры', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: TextField(controller: _searchController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Поиск по ФИО'))),
              const SizedBox(width: 16),
              adminAddButton(onPressed: () => _showForm()),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: MainPurple))
                : AdminScrollableTable(
                      minWidth: 1050,
                      columns: [
                        DataColumn(label: Text('ФИО', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('Дата рождения', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('Email', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('Телефон', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('Направления', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('Информация', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        DataColumn(label: Text('', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      ],
                      rows: _items.map((t) => DataRow(cells: [
                        DataCell(Text(t.fullName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(formatDate(t.dateOfBirth), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(t.email ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(t.phone ?? '—', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(
                          _directionNames(t),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                        DataCell(Text(t.information ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: MainPurple), onPressed: () => _showForm(item: t)),
                            IconButton(icon: const Icon(Icons.delete, color: UnactiveRed), onPressed: () => _delete(t)),
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
