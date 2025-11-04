import 'dart:convert';

import 'package:groove_app/api_DTOs/trainer_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<List<TrainerDto>> fetchTrainers() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer'),
  );
  print('RESPONSE STATUS: ${response.statusCode}');
  print('RESPONSE BODY: ${response.body}');
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => TrainerDto.fromJson(json)).toList();
  } else {
    throw Exception('Ошибка загрузки тренеров');
  }
}
