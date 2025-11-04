import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/arendalist_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyarendalistPage extends StatefulWidget {
  const MyarendalistPage({super.key});

  @override
  State<MyarendalistPage> createState() => _MyarendalistPageState();
}

class _MyarendalistPageState extends State<MyarendalistPage> {
  DateTime _currentWeek = DateTime.now();
  List<ArendaListDto> _arendas = [];
  int? userId; // ← переменная теперь nullable

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _loadUserAndFetchArendas();
  }

  Future<void> _loadUserAndFetchArendas() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('userId');

    if (savedUserId == null) {
      // Обработка случая: пользователь не авторизован
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: пользователь не найден')),
      );
      return;
    }

    setState(() {
      userId = savedUserId;
    });

    _fetchArendas();
  }

  void _previousWeek() {
    setState(() {
      _currentWeek = _currentWeek.subtract(const Duration(days: 7));
    });
    _fetchArendas();
  }

  void _nextWeek() {
    setState(() {
      _currentWeek = _currentWeek.add(const Duration(days: 7));
    });
    _fetchArendas();
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

  Future<void> _fetchArendas() async {
    if (userId == null) return;

    final start = _currentWeek.toIso8601String();
    final end = _currentWeek.add(const Duration(days: 6)).toIso8601String();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/arendalist/$userId/filter?weekStart=$start&weekEnd=$end',
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _arendas = data.map((e) => ArendaListDto.fromJson(e)).toList();
      });
    } else {
      print('Ошибка загрузки аренд');
    }
  }

  Future<void> _cancelArenda(int arendaId) async {
    if (userId == null) return;

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/arendalist/$arendaId/cancel?userId=$userId',
    );
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Аренда отменена')),
      );
      _fetchArendas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нельзя отменить аренду')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('АРЕНДА', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousWeek,
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Text(
                      _formatWeekRange(_currentWeek),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      onPressed: _nextWeek,
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_arendas.isEmpty)
                  const Center(
                    child: Text(
                      'Нет аренд на этой неделе',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ..._arendas.map((arenda) => _buildRentCard(arenda)).toList(),
              ],
            ),
    );
  }

  Widget _buildRentCard(ArendaListDto arenda) {
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
            'Оформлено: ${DateFormat('dd MMMM yyyy', 'ru').format(arenda.dateArenda)}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            'Бронь: ${dateFormat.format(arenda.startTime)} - ${DateFormat('HH:mm').format(arenda.endTime)}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Длительность: ${arenda.durationHours} час(а)',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Зал: ${arenda.hallNumber}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Стоимость: ${arenda.sum} руб.',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _cancelArenda(arenda.idArenda),
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
