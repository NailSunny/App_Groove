import 'dart:convert';

import 'package:groove_app/api_DTOs/available_hour.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<List<AvailableHour>> fetchTrainerHours(int trainerId, DateTime date) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/Class/trainer-available')
        .replace(queryParameters: {
      'trainerId': trainerId.toString(),
      'date': date.toIso8601String(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => AvailableHour.fromJson(json)).toList();
    } else {
      throw Exception('Нет доступных часов');
    }
  }