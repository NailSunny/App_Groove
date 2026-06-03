import 'dart:convert';

import 'package:groove_app/api_DTOs/trainer_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<List<TrainerDto>> fetchTrainers() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => TrainerDto.fromJson(json)).toList();
  } else {
    throw Exception('Ошибка загрузки тренеров');
  }
}

Future<TrainerDto> fetchTrainerById(int id) async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/api/Trainer/$id'),
  );
  if (response.statusCode == 200) {
    return TrainerDto.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }
  throw Exception('Тренер не найден');
}
