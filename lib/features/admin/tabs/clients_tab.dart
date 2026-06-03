import 'dart:async';
import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/client_admin_dto.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_formatters.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
class ClientsTab extends StatefulWidget {
  const ClientsTab({super.key});

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  List<ClientAdminDto> _items = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
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
    _debounce = Timer(const Duration(milliseconds: 400), () => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await fetchClients(
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

  Future<void> _showForm({ClientAdminDto? item}) async {
    final familiaCtrl = TextEditingController(text: item?.familiaUser ?? '');
    final nameCtrl = TextEditingController(text: item?.nameUser ?? '');
    final patronymicCtrl = TextEditingController(text: item?.patronymic ?? '');
    final emailCtrl = TextEditingController(text: item?.email ?? '');
    final phoneCtrl = TextEditingController(text: item?.phone ?? '');
    final passwordCtrl = TextEditingController();
    DateTime? birthDate = item?.dateOfBirth;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            item == null ? 'Новый клиент' : 'Редактировать клиента',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Дата рождения: ${formatDate(birthDate)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    trailing: const Icon(Icons.calendar_today, color: MainPurple),
                    onTap: () async {
                      final picked = await pickDate(context, birthDate);
                      if (picked != null) setDialogState(() => birthDate = picked);
                    },
                  ),
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
                  if (item == null) ...[
                    SizedBox(height: 12),
                    TextField(controller: passwordCtrl, obscureText: true, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: adminInputDecoration(context, 'Пароль *')),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                if (familiaCtrl.text.isEmpty || nameCtrl.text.isEmpty || patronymicCtrl.text.isEmpty || birthDate == null || emailCtrl.text.isEmpty) return;
                if (item == null && passwordCtrl.text.length < 4) return;
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
      if (item == null) {
        await createClient({
          'familia_user': familiaCtrl.text.trim(),
          'name_user': nameCtrl.text.trim(),
          'patronymic': patronymicCtrl.text.trim(),
          'dateOfBirth': birthDate!.toIso8601String(),
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          'password': passwordCtrl.text,
        });
        showAdminSuccess(context, 'Клиент создан');
      } else {
        await updateClient(item.id, {
          'familia_user': familiaCtrl.text.trim(),
          'name_user': nameCtrl.text.trim(),
          'patronymic': patronymicCtrl.text.trim(),
          'dateOfBirth': birthDate!.toIso8601String(),
          'email': emailCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
        });
        showAdminSuccess(context, 'Клиент обновлён');
      }
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _delete(ClientAdminDto item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Удалить клиента?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(item.fullName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: UnactiveRed), onPressed: () => Navigator.pop(ctx, true), child: const Text('Удалить')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await deleteClient(item.id);
      showAdminSuccess(context, 'Клиент удалён');
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
          Text('Клиенты', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: adminInputDecoration(context, 'Поиск по ФИО'),
                ),
              ),
              const SizedBox(width: 16),
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
                      DataColumn(label: Text('ФИО', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Дата рождения', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Email', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Телефон', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('Баланс', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                      DataColumn(label: Text('', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                    ],
                    rows: _items.map((c) {
                      return DataRow(cells: [
                        DataCell(Text(c.fullName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(formatDate(c.dateOfBirth), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(c.email ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text(c.phone ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Text('${c.balance} ₽', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: MainPurple), onPressed: () => _showForm(item: c)),
                            IconButton(icon: const Icon(Icons.delete, color: UnactiveRed), onPressed: () => _delete(c)),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
