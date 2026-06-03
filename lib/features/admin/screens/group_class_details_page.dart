import 'package:flutter/material.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/api_service/admin_schedule_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_scrollable_table.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:groove_app/features/admin/widgets/attendance_toggle.dart';

class GroupClassDetailsPage extends StatefulWidget {
  final VoidCallback onBack;
  final Map<String, dynamic> classData;

  const GroupClassDetailsPage({
    super.key,
    required this.classData,
    required this.onBack,
  });

  @override
  State<GroupClassDetailsPage> createState() => _GroupClassDetailsPageState();
}

class _GroupClassDetailsPageState extends State<GroupClassDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _clients = [];
  bool _loading = true;
  String _search = '';

  int get _groupClassId => widget.classData['id'] as int? ?? widget.classData['Id'] as int;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await fetchGroupRegistrations(_groupClassId);
      if (mounted) setState(() { _clients = list; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAdminError(context, e);
      }
    }
  }

  Future<void> _markPresent(int registryId) async {
    try {
      await markGroupAttendance(registryId, 'Present');
      await _load();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _clients;
    final q = _search.toLowerCase();
    return _clients.where((c) {
      final name = (c['client'] ?? c['Client'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.classData['direction'] ?? widget.classData['Direction'] ?? '';
    final time = widget.classData['time'] ?? widget.classData['Time'] ?? '';
    final hall = widget.classData['hall'] ?? widget.classData['Hall'] ?? '';

    return SizedBox.expand(
      child: Container(
        color: const Color(0xFF151515),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      '$direction • $time • Зал $hall',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _search = v),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Поиск клиента',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.groove.headerBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _loading
                      ? Center(child: CircularProgressIndicator(color: MainPurple))
                      : AdminScrollableTable(
                          minWidth: 800,
                          columns: [
                            DataColumn(label: Text('№', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('ФИО', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Дата записи', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Абонемент', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Посещение', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))),
                          ],
                          rows: _filtered.asMap().entries.map((entry) {
                            final item = entry.value;
                            final registryId = item['registryId'] as int? ?? item['RegistryId'] as int;
                            final attendance = (item['attendance'] ?? item['Attendance'] ?? 'Pending').toString();
                            return DataRow(cells: [
                              DataCell(Text('${entry.key + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                              DataCell(Text(
                                (item['client'] ?? item['Client'] ?? '').toString(),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              )),
                              DataCell(Text(
                                (item['registryDate'] ?? item['RegistryDate'] ?? '').toString(),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              )),
                              DataCell(Text(
                                (item['subscription'] ?? item['Subscription'] ?? '').toString(),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                              )),
                              DataCell(AttendanceToggle(
                                attendance: attendance,
                                onMarkPresent: attendance == 'Pending' ? () => _markPresent(registryId) : null,
                              )),
                            ]);
                          }).toList(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
