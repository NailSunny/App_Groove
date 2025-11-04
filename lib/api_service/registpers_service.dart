import 'dart:convert';

import 'package:groove_app/api_DTOs/regist_pers.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<String> registerPersonalClass(RegisterPersClassRequest request) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/PersonalTraining/register'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(request.toJson()),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['message'];
  } else {
    throw Exception('Ошибка записи на персональное занятие');
  }
}
