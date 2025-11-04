import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/registryrecord_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyjournalPage extends StatefulWidget {
  const MyjournalPage({super.key});

  @override
  State<MyjournalPage> createState() => _MyjournalPageState();
}

class _MyjournalPageState extends State<MyjournalPage> {
  DateTime _currentWeek = DateTime.now();
  List<RegistryRecord> _records = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _loadUserAndFetchRegistry();
  }

  Future<void> _loadUserAndFetchRegistry() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('userId');

    if (savedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не найден')),
      );
      return;
    }

    setState(() {
      userId = savedUserId;
    });

    _fetchRegistry();
  }

  void _previousWeek() {
    setState(() {
      _currentWeek = _currentWeek.subtract(const Duration(days: 7));
    });
    _fetchRegistry();
  }

  void _nextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(const Duration(days: 7));
    });
    _fetchRegistry();
  }

  String _formatWeekRange(DateTime date) {
    final start = date;
    final end = date.add(const Duration(days: 6));
    return '${start.day} - ${end.day} ${_getMonthName(end.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return months[month - 1];
  }

  Future<void> _fetchRegistry() async {
    if (userId == null) return;

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/registry/$userId'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      final startOfWeek = _currentWeek;
      final endOfWeek = _currentWeek.add(const Duration(days: 6));
      setState(() {
        _records =
            data
                .map((e) => RegistryRecord.fromJson(e))
                .where(
                  (r) =>
                      r.start.isAfter(
                        startOfWeek.subtract(const Duration(days: 1)),
                      ) &&
                      r.start.isBefore(endOfWeek.add(const Duration(days: 1))),
                )
                .toList();
      });
    } else {
      throw Exception('Ошибка при получении данных');
    }
  }

  Future<void> _cancelRegistry(int id) async {
    if (userId == null) return;

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/registry/$id/cancel?userId=$userId'),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Запись отменена")));
      _fetchRegistry();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Нельзя отменить занятие")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'ЖУРНАЛ ЗАПИСЕЙ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
      ),
      body:
          userId == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousWeek,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatWeekRange(_currentWeek),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextWeek,
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_records.isEmpty)
                    const Center(
                      child: Text(
                        'Нет записей на этой неделе',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ..._records.map((r) => _buildRecordContainer(r)).toList(),
                ],
              ),
    );
  }

  Widget _buildRecordContainer(RegistryRecord record) {
    final dateFormat = DateFormat('dd MMMM yyyy HH:mm', 'ru');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dateFormat.format(record.start)} - ${DateFormat('HH:mm').format(record.end)}, ${record.duration} мин',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Зал №${record.hall}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            record.classType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Абонемент: ${record.abonementName}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          if (record.status == 'Предстоящее')
            ElevatedButton(
              onPressed: () => _cancelRegistry(record.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
              ),
              child: const Text(
                'ОТМЕНИТЬ',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
