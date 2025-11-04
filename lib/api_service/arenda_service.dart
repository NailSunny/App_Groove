 import 'dart:convert';

import 'package:groove_app/api_DTOs/arenda_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<List<FreeHourDto>> fetchFreeHours(DateTime date) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/arenda/free-hours?date=${date.toIso8601String()}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final list = json.decode(response.body) as List;
      return list.map((e) => FreeHourDto.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки свободных часов');
    }
  }

Future<void> rentHall(ArendaRequestDto dto) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/arenda/rent');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dto.toJson()),
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Ошибка при аренде');
    }
  }